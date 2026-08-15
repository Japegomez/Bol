import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";
import { enforceAiQuota } from "../_shared/ai_quota.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const INGREDIENT_CATEGORY_KEYS = [
  "meat_fish",
  "vegetables",
  "fruits",
  "dairy",
  "grains",
  "legumes",
  "spices",
  "oils_vinegars",
  "canned",
  "nuts",
  "beverages",
  "baking",
  "frozen",
  "sauces",
  "other",
] as const;

const PREDEFINED_UNITS = [
  "g",
  "kg",
  "ml",
  "l",
  "unidad",
  "pizca",
  "cucharadita",
  "cucharada",
  "vaso",
  "taza",
  "puñado",
  "hoja",
  "diente",
  "chorrito",
  "rebanada",
  "rama",
  "trozo",
  "filete",
  "rodaja",
  "lata",
  "bote",
  "paquete",
  "sobre",
] as const;

const SUGGESTED_RECIPE_TAG_KEYS = [
  "main_course",
  "dessert",
  "breakfast",
  "appetizer",
  "side_dish",
  "vegetarian",
  "vegan",
  "pescatarian",
  "gluten_free",
  "lactose_free",
  "dairy_free",
  "egg_free",
  "nut_free",
  "peanut_free",
  "soy_free",
  "fish_free",
  "shellfish_free",
  "sugar_free",
  "high_protein",
  "low_calorie",
  "low_carb",
  "high_fiber",
  "healthy",
  "spanish",
  "italian",
  "asian",
  "mexican",
  "indian",
  "quick",
  "budget",
  "batch_cooking",
  "freezer_friendly",
  "no_oven",
  "spicy",
  "kid_friendly",
] as const;

type AssistantMode =
  | "generate_recipe"
  | "generate_nutrition"
  | "generate_tags";

type IngredientInput = {
  name: string;
  quantity?: number | null;
  unit?: string | null;
  category?: string | null;
  isOptional?: boolean;
  isToTaste?: boolean;
};

type StepInput = {
  description: string;
  isOptional?: boolean;
};

const SIN_TAG_KEYS = [
  "gluten_free",
  "lactose_free",
  "dairy_free",
  "egg_free",
  "nut_free",
  "peanut_free",
  "soy_free",
  "fish_free",
  "shellfish_free",
  "sugar_free",
] as const;

const MAXIMIZE_TAG_KEYS = SUGGESTED_RECIPE_TAG_KEYS.filter(
  (tag) => !(SIN_TAG_KEYS as readonly string[]).includes(tag),
);

const TAG_SELECTION_RULES = `Tag selection (applies whenever you return tags):
- Select tags ONLY from the allowed enum. Never invent custom tags.
- Be MAXIMAL, not selective. Walk through EVERY allowed tag and include it if it reasonably applies. Returning only 2–3 tags is usually wrong. A typical complete dish should get many tags (often 6 or more).
- Do NOT pick a small "best" subset. If two course tags fit, include both. Breakfast, appetizer, and side_dish are also course tags: include every one that fits.
- Default for non-"sin" tags (${MAXIMIZE_TAG_KEYS.join(", ")}): if it is plausible from the title, ingredients, steps, or times, INCLUDE it. When unsure on these, include rather than omit.
- vegetarian = no meat and no fish/seafood. vegan = no animal products (also include vegetarian when vegan applies). pescatarian = the dish contains fish/seafood and no meat; do NOT add pescatarian to vegetarian/vegan dishes.
- quick = total prep+cook typically 30 minutes or less. budget = inexpensive pantry staples. batch_cooking = reheats well in quantity. freezer_friendly = freezes well. kid_friendly = not very spicy/bitter/alcoholic, familiar flavours. healthy = vegetable-forward or reasonably balanced, not deep-fried. no_oven = the recipe does not require an oven (stovetop, raw, fridge, microwave, grill, etc.).
- Cuisine tags (spanish, italian, asian, mexican, indian): include every cuisine that clearly fits the dish.
- The ONLY tags that require caution are the "sin"/allergen-free tags: ${SIN_TAG_KEYS.join(", ")}. Include a "sin" tag ONLY when you are certain from the listed ingredients and steps that it applies. If there is ANY doubt (hidden ingredients, sauces, broths, traces, processed foods, incomplete information), omit that "sin" tag. Never guess a "sin" tag.
- Allergen rules (none of the ingredients or typical derivatives may contain it): gluten_free (pasta, bread, flour unless gluten-free); lactose_free (milk, cheese, butter, cream unless lactose-free; lactose-free dairy is OK); dairy_free (no milk, cheese, butter, cream, yogurt, whey — stricter than lactose_free; do not add dairy_free only because lactose_free applies); egg_free (eggs, mayonnaise, fresh pasta); nut_free (tree nuts: almond, walnut, hazelnut, cashew, pistachio — peanuts are peanut_free, not nut_free); peanut_free (peanuts, peanut butter, peanut oil); soy_free (tofu, soy sauce, edamame); fish_free (fish; shellfish is shellfish_free); shellfish_free (shrimp, mussel, squid, etc.); sugar_free (added sugar, honey, syrups).`;

function buildAllergenRules(userAllergens: readonly string[]): string {
  if (userAllergens.length === 0) return "";
  const labels = userAllergens.map((key) => {
    const label = ALLERGEN_LABELS[key as keyof typeof ALLERGEN_LABELS];
    return label ? `${key} (${label})` : key;
  });
  return `

USER ALLERGIES / INTOLERANCES (mandatory constraints):
The user is allergic/intolerant to the following allergen keys: ${labels.join(", ")}.
- You MUST NOT include ANY ingredient that contains or typically derives from these allergens. This includes hidden sources (sauces, broths, marinades, processed foods, thickeners, emulsifiers).
- Prefer ADAPTING the recipe: OMIT garnish/optional allergens or REPLACE them with a safe alternative whenever the dish can still be made. Examples that MUST be adapted (not rejected): omit crushed peanuts on pad thai; skip scrambled egg in pad thai; use gluten-free noodles for pasta; use dairy-free milk in a cake when a plant milk works.
- Do not announce the change inside ingredients, steps, or tips — record each change as a separate short Spanish sentence in "allergenAdjustments".
- When you adapted the recipe for allergies, you MAY keep a short marker in the title such as "adaptado" in lowercase (e.g. "Pad Thai adaptado"). Never capitalize it as "Adaptado". Do not put long explanations in the title.
- Every allergenAdjustments note MUST explicitly name the allergen or intolerance substance (without "sin"), e.g. "Se ha modificado la receta por el alérgeno o intolerancia: huevo." or "Se sustituyó el huevo por tofu revuelto.". Vague notes without naming the allergen/intolerance are forbidden.
- CRITICAL: when any user allergen is omitted or substituted, "allergenAdjustments" MUST be a non-empty array with one note per avoided allergen, AND "adjustedAllergens" MUST list the matching keys from the user's list (e.g. ["egg_free","peanut_free"]). Never return an empty allergenAdjustments / adjustedAllergens if you adapted the recipe for allergies.
- ONLY return {"error":"allergen_conflict","message":"<Spanish explanation that MUST name the allergen/intolerance>","conflictingAllergens":[<keys>]} when the allergen is the defining core of the dish and no sensible substitute exists (e.g. egg in a classic Spanish tortilla de patatas, peanut paste as the base of satay sauce, wheat flour as the base of bread). When in doubt, ADAPT and produce the recipe.
- allergen_conflict "message" MUST explicitly name each conflicting allergen/intolerance substance (without "sin"), e.g. "No se puede crear la receta sin el alérgeno o intolerancia: huevo.". Never return a generic message that omits the allergen name.
- "conflictingAllergens" must list ONLY keys from the user's list that make the recipe impossible (never empty on allergen_conflict).
- When you DO produce a recipe, add the matching "sin" tag for every user allergen to "tags" (e.g. egg_free, peanut_free), in addition to the normal tag rules above.
- Always include "allergenAdjustments" and "adjustedAllergens" as arrays (empty only if the original dish never contained those allergens).`;
}

const ALLERGEN_LABELS: Record<string, string> = {
  gluten_free: "gluten",
  lactose_free: "lactosa",
  dairy_free: "lácteos",
  egg_free: "huevo",
  nut_free: "frutos secos",
  peanut_free: "cacahuetes",
  soy_free: "soja",
  fish_free: "pescado",
  shellfish_free: "marisco",
  sugar_free: "azúcar",
};

/** Fallback notes when the LLM adapts for allergens but forgets allergenAdjustments. */
const ALLERGEN_ADJUSTMENT_FALLBACKS: Record<string, string> = {
  gluten_free:
    "Se ha modificado la receta por el alérgeno o intolerancia: gluten.",
  lactose_free:
    "Se ha modificado la receta por el alérgeno o intolerancia: lactosa.",
  dairy_free:
    "Se ha modificado la receta por el alérgeno o intolerancia: lácteos.",
  egg_free:
    "Se ha modificado la receta por el alérgeno o intolerancia: huevo.",
  nut_free:
    "Se ha modificado la receta por el alérgeno o intolerancia: frutos secos.",
  peanut_free:
    "Se ha modificado la receta por el alérgeno o intolerancia: cacahuetes.",
  soy_free:
    "Se ha modificado la receta por el alérgeno o intolerancia: soja.",
  fish_free:
    "Se ha modificado la receta por el alérgeno o intolerancia: pescado.",
  shellfish_free:
    "Se ha modificado la receta por el alérgeno o intolerancia: marisco.",
  sugar_free:
    "Se ha modificado la receta por el alérgeno o intolerancia: azúcar.",
};

function normalizeAdaptedTitleMarker(title: unknown): string {
  if (typeof title !== "string") return "";
  return title
    .trim()
    // Keep the adaptation marker, but force lowercase ("adaptado" / "adapted").
    .replace(/\bAdaptad([oa]s?)\b/g, (_m, ending: string) => `adaptad${ending}`)
    .replace(/\bAdapted\b/g, "adapted");
}

function hasAllergenAdaptationSignal(
  result: Record<string, unknown>,
  allergenAdjustments: readonly string[],
): boolean {
  if (allergenAdjustments.length > 0) return true;
  const title = typeof result.title === "string" ? result.title : "";
  return /adaptad|adapted/i.test(title);
}

function fallbackAllergenAdjustments(userAllergens: readonly string[]): string[] {
  return userAllergens
    .map((key) => ALLERGEN_ADJUSTMENT_FALLBACKS[key])
    .filter((note): note is string => typeof note === "string" && note.length > 0);
}

function parseUserAllergens(body: unknown): string[] {
  const raw = (body as Record<string, unknown> | null)?.userAllergens;
  if (!Array.isArray(raw)) return [];
  const valid = new Set<string>(SIN_TAG_KEYS);
  const seen = new Set<string>();
  const out: string[] = [];
  for (const item of raw) {
    if (typeof item !== "string") continue;
    const key = item.trim();
    if (!valid.has(key) || seen.has(key)) continue;
    seen.add(key);
    out.push(key);
  }
  return out;
}

const tagsSchema = {
  type: "object",
  additionalProperties: false,
  properties: {
    tags: {
      type: "array",
      items: { type: "string", enum: [...SUGGESTED_RECIPE_TAG_KEYS] },
    },
  },
  required: ["tags"],
};

const nutritionSchema = {
  type: "object",
  additionalProperties: false,
  properties: {
    calories: { type: ["integer", "null"], minimum: 0 },
    protein: { type: ["integer", "null"], minimum: 0 },
    carbohydrates: { type: ["integer", "null"], minimum: 0 },
    fat: { type: ["integer", "null"], minimum: 0 },
    fiber: { type: ["integer", "null"], minimum: 0 },
  },
  required: ["calories", "protein", "carbohydrates", "fat", "fiber"],
};

type NutritionInput = {
  calories?: number | null;
  protein?: number | null;
  carbohydrates?: number | null;
  fat?: number | null;
  fiber?: number | null;
};

const NUTRITION_FIELDS = [
  "calories",
  "protein",
  "carbohydrates",
  "fat",
  "fiber",
] as const;

function parseExistingNutrition(raw: unknown): NutritionInput | null {
  if (!raw || typeof raw !== "object" || Array.isArray(raw)) return null;
  const source = raw as Record<string, unknown>;
  const parsed: NutritionInput = {};
  let hasAny = false;

  for (const field of NUTRITION_FIELDS) {
    const value = source[field];
    if (value === null || value === undefined || value === "") {
      parsed[field] = null;
      continue;
    }
    const num = typeof value === "number"
      ? value
      : typeof value === "string"
      ? Number(value.replace(",", "."))
      : NaN;
    if (!Number.isFinite(num) || num < 0) {
      parsed[field] = null;
      continue;
    }
    parsed[field] = Math.round(num);
    hasAny = true;
  }

  return hasAny ? parsed : null;
}

function formatExistingNutritionForPrompt(nutrition: NutritionInput): string {
  return NUTRITION_FIELDS
    .map((field) => {
      const value = nutrition[field];
      return `- ${field}: ${value === null || value === undefined ? "null" : value}`;
    })
    .join("\n");
}

function normalizeTags(parsed: Record<string, unknown>): string[] {
  const raw = parsed.tags;
  if (!Array.isArray(raw)) return [];

  const seen = new Set<string>();
  const tags: string[] = [];
  for (const entry of raw) {
    if (
      typeof entry !== "string" ||
      !(SUGGESTED_RECIPE_TAG_KEYS as readonly string[]).includes(entry) ||
      seen.has(entry)
    ) {
      continue;
    }
    seen.add(entry);
    tags.push(entry);
  }
  return tags;
}

function parseExistingTags(raw: unknown): string[] | null {
  if (!Array.isArray(raw)) return null;
  const tags = normalizeTags({ tags: raw });
  return tags.length > 0 ? tags : null;
}

/** Coerce nutrition payload to non-negative integers (or null). */
function normalizeNutrition(
  parsed: Record<string, unknown>,
): Record<string, unknown> {
  const out: Record<string, unknown> = {};
  for (const field of NUTRITION_FIELDS) {
    const value = parsed[field];
    if (value === null || value === undefined) {
      out[field] = null;
      continue;
    }
    const num = typeof value === "number"
      ? value
      : typeof value === "string"
      ? Number(value.replace(",", "."))
      : NaN;
    out[field] = Number.isFinite(num) && num >= 0 ? Math.round(num) : null;
  }
  return out;
}

const recipeSchema = {
  type: "object",
  additionalProperties: false,
  properties: {
    error: { type: "string", enum: ["not_a_recipe_request", "allergen_conflict"] },
    message: { type: "string" },
    conflictingAllergens: {
      type: "array",
      items: { type: "string", enum: [...SIN_TAG_KEYS] },
    },
    allergenAdjustments: {
      type: "array",
      items: { type: "string" },
    },
    adjustedAllergens: {
      type: "array",
      items: { type: "string", enum: [...SIN_TAG_KEYS] },
    },
    title: { type: "string" },
    servings: { type: "integer", minimum: 1 },
    prepTime: { type: ["integer", "null"], minimum: 0 },
    cookTime: { type: ["integer", "null"], minimum: 0 },
    detectedLang: { type: "string" },
    tips: { type: ["string", "null"] },
    tags: {
      type: "array",
      items: { type: "string", enum: [...SUGGESTED_RECIPE_TAG_KEYS] },
    },
    ingredients: {
      type: "array",
      items: {
        type: "object",
        additionalProperties: false,
        properties: {
          name: { type: "string" },
          quantity: { type: ["number", "null"] },
          unit: { type: ["string", "null"], enum: [...PREDEFINED_UNITS, null] },
          category: { type: "string", enum: [...INGREDIENT_CATEGORY_KEYS] },
          isOptional: { type: "boolean" },
          isToTaste: { type: "boolean" },
        },
        required: [
          "name",
          "quantity",
          "unit",
          "category",
          "isOptional",
          "isToTaste",
        ],
      },
    },
    steps: {
      type: "array",
      items: {
        type: "object",
        additionalProperties: false,
        properties: {
          description: { type: "string" },
          isOptional: { type: "boolean" },
        },
        required: ["description", "isOptional"],
      },
    },
    nutrition: nutritionSchema,
  },
};

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

function getLlmConfig() {
  const apiKey = Deno.env.get("LLM_API_KEY");
  const baseUrl = Deno.env.get("LLM_BASE_URL") ??
    "https://generativelanguage.googleapis.com/v1beta/openai/";
  // gemini-2.5-flash is blocked for new Google AI projects (404 NOT_FOUND).
  // Prefer gemini-3.5-flash-lite (cheap multimodal) or gemini-3.5-flash (higher quality).
  const model = Deno.env.get("LLM_MODEL") ?? "gemini-3.5-flash-lite";
  return { apiKey, baseUrl: baseUrl.replace(/\/?$/, "/"), model };
}

function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

type RecipeImagePayload = { mimeType: string; base64: string };

type CallLlmOptions = {
  preferJsonObject?: boolean;
  minMaxTokens?: number;
  /** Optional images as data URL payloads for multimodal chat completions. */
  images?: RecipeImagePayload[];
  temperature?: number;
  maxAttempts?: number;
  totalBudgetMs?: number;
  fetchTimeoutMs?: number;
  maxDelayMs?: number;
};

function buildUserContent(
  userPrompt: string,
  images?: RecipeImagePayload[],
): string | Array<Record<string, unknown>> {
  if (!images?.length) return userPrompt;
  return [
    { type: "text", text: userPrompt },
    ...images.map((image) => ({
      type: "image_url",
      image_url: {
        url: `data:${image.mimeType};base64,${image.base64}`,
      },
    })),
  ];
}

function extractJsonPayload(content: string): Record<string, unknown> | null {
  const trimmed = content.trim();
  if (!trimmed) return null;

  try {
    return JSON.parse(trimmed) as Record<string, unknown>;
  } catch {
    // Continue with fallbacks.
  }

  const fenced = trimmed.match(/```(?:json)?\s*([\s\S]*?)```/i);
  if (fenced) {
    try {
      return JSON.parse(fenced[1].trim()) as Record<string, unknown>;
    } catch {
      // Continue with fallbacks.
    }
  }

  const start = trimmed.indexOf("{");
  const end = trimmed.lastIndexOf("}");
  if (start >= 0 && end > start) {
    try {
      return JSON.parse(trimmed.slice(start, end + 1)) as Record<string, unknown>;
    } catch {
      return null;
    }
  }

  return null;
}

function getMessageContent(data: unknown): string {
  const message = (data as {
    choices?: Array<{ message?: Record<string, unknown> }>;
  })?.choices?.[0]?.message;

  if (!message) return "";

  const content = message.content;
  if (typeof content === "string" && content.trim()) {
    return content;
  }

  const reasoning = message.reasoning;
  if (typeof reasoning === "string" && reasoning.trim()) {
    return reasoning;
  }

  return "";
}

function isCerebrasProvider(baseUrl: string): boolean {
  return baseUrl.includes("cerebras.ai");
}

function isNonEmptyString(value: unknown): value is string {
  return typeof value === "string" && value.trim().length > 0;
}

function isNumberOrNull(value: unknown): value is number | null {
  return value === null || (typeof value === "number" && Number.isFinite(value));
}

function isIntegerOrNull(value: unknown, minimum = 0): value is number | null {
  return value === null ||
    (typeof value === "number" && Number.isInteger(value) && value >= minimum);
}

function isValidUnit(value: unknown): boolean {
  return value === null ||
    (typeof value === "string" && (PREDEFINED_UNITS as readonly string[]).includes(value));
}

function isValidIngredient(item: unknown): boolean {
  if (!item || typeof item !== "object") return false;
  const ingredient = item as Record<string, unknown>;

  if (!isNonEmptyString(ingredient.name)) return false;
  if (!isNumberOrNull(ingredient.quantity)) return false;
  if (!isValidUnit(ingredient.unit)) return false;
  if (
    typeof ingredient.category !== "string" ||
    !(INGREDIENT_CATEGORY_KEYS as readonly string[]).includes(ingredient.category)
  ) {
    return false;
  }
  if (typeof ingredient.isOptional !== "boolean") return false;
  if (typeof ingredient.isToTaste !== "boolean") return false;

  return true;
}

function isValidStep(item: unknown): boolean {
  if (!item || typeof item !== "object") return false;
  const step = item as Record<string, unknown>;

  return isNonEmptyString(step.description) &&
    typeof step.isOptional === "boolean";
}

function validateGeneratedRecipe(parsed: Record<string, unknown>): boolean {
  if (parsed.error === "not_a_recipe_request") {
    return true;
  }

  if (parsed.error === "allergen_conflict") {
    // Conflict responses must not include a recipe body — only the error payload.
    return typeof parsed.message === "string" &&
      parsed.message.trim().length > 0 &&
      Array.isArray(parsed.conflictingAllergens);
  }

  if (!isNonEmptyString(parsed.title)) return false;
  if (typeof parsed.servings !== "number" || !Number.isInteger(parsed.servings) ||
    parsed.servings < 1) {
    return false;
  }
  if (!isIntegerOrNull(parsed.prepTime)) return false;
  if (!isIntegerOrNull(parsed.cookTime)) return false;
  if (typeof parsed.detectedLang !== "string" || !parsed.detectedLang.trim()) {
    return false;
  }
  if (parsed.tips !== null && typeof parsed.tips !== "string") return false;

  if (!Array.isArray(parsed.tags)) return false;
  for (const tag of parsed.tags) {
    if (
      typeof tag !== "string" ||
      !(SUGGESTED_RECIPE_TAG_KEYS as readonly string[]).includes(tag)
    ) {
      return false;
    }
  }

  if (!Array.isArray(parsed.ingredients) || parsed.ingredients.length === 0) {
    return false;
  }
  let hasRequiredIngredient = false;
  for (const ingredient of parsed.ingredients) {
    if (!isValidIngredient(ingredient)) return false;
    const item = ingredient as Record<string, unknown>;
    if (item.isOptional !== true && item.isToTaste !== true) {
      hasRequiredIngredient = true;
    }
  }
  if (!hasRequiredIngredient) return false;

  if (!Array.isArray(parsed.steps) || parsed.steps.length === 0) return false;
  let hasRequiredStep = false;
  for (const step of parsed.steps) {
    if (!isValidStep(step)) return false;
    if ((step as Record<string, unknown>).isOptional !== true) {
      hasRequiredStep = true;
    }
  }
  if (!hasRequiredStep) return false;

  if (!parsed.nutrition || typeof parsed.nutrition !== "object") return false;
  return validateAgainstSchema(
    parsed.nutrition as Record<string, unknown>,
    "recipe_nutrition",
    nutritionSchema,
  );
}

function validateAgainstSchema(
  parsed: Record<string, unknown>,
  schemaName: string,
  schema: Record<string, unknown>,
): boolean {
  if (schemaName === "recipe_nutrition" || schema === nutritionSchema) {
    const normalized = normalizeNutrition(parsed);
    Object.assign(parsed, normalized);

    const calories = parsed.calories;
    const protein = parsed.protein;
    const carbohydrates = parsed.carbohydrates;
    const fat = parsed.fat;
    const fiber = parsed.fiber;

    const isValidIntOrNull = (value: unknown) =>
      value === null ||
      (typeof value === "number" && Number.isInteger(value) && value >= 0);

    if (
      !isValidIntOrNull(calories) ||
      !isValidIntOrNull(protein) ||
      !isValidIntOrNull(carbohydrates) ||
      !isValidIntOrNull(fat) ||
      !isValidIntOrNull(fiber)
    ) {
      return false;
    }

    if (
      calories === null && protein === null &&
      carbohydrates === null && fat === null && fiber === null
    ) {
      return false;
    }

    return true;
  }

  if (schemaName === "generated_recipe" || schema === recipeSchema) {
    return validateGeneratedRecipe(parsed);
  }

  if (schemaName === "recipe_tags" || schema === tagsSchema) {
    parsed.tags = normalizeTags(parsed);
    return Array.isArray(parsed.tags);
  }

  return true;
}

async function callLlm(
  systemPrompt: string,
  userPrompt: string,
  schemaName: string,
  schema: Record<string, unknown>,
  maxTokens = 8192,
  options: CallLlmOptions = {},
): Promise<Record<string, unknown>> {
  const { apiKey, baseUrl, model } = getLlmConfig();
  if (!apiKey) {
    throw new Error("not_configured");
  }

  const configuredMax = Deno.env.get("LLM_MAX_TOKENS");
  const parsedConfiguredMax = configuredMax
    ? Number.parseInt(configuredMax, 10)
    : NaN;
  const modeMax = Math.max(maxTokens, options.minMaxTokens ?? 0);
  const effectiveMax = Number.isFinite(parsedConfiguredMax) && parsedConfiguredMax > 0
    ? Math.max(parsedConfiguredMax, modeMax)
    : modeMax;

  const maxAttempts = options.maxAttempts ?? 3;
  const totalBudgetMs = options.totalBudgetMs ?? 240000;
  const maxDelayMs = options.maxDelayMs ?? 30000;
  const fetchTimeoutMs = options.fetchTimeoutMs ?? 180000;
  const startTime = Date.now();
  let useJsonObject = options.preferJsonObject ?? false;

  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    const elapsedMs = Date.now() - startTime;
    if (elapsedMs >= totalBudgetMs) {
      throw new Error("rate_limited");
    }

    const userContent = buildUserContent(userPrompt, options.images);

    const body: Record<string, unknown> = {
      model,
      max_tokens: effectiveMax,
      messages: [
        { role: "system", content: systemPrompt },
        { role: "user", content: userContent },
      ],
    };

    if (options.temperature != null) {
      body.temperature = options.temperature;
    }

    if (isCerebrasProvider(baseUrl)) {
      body.reasoning_format = "hidden";
    }

    if (useJsonObject) {
      body.response_format = { type: "json_object" };
      body.messages = [
        {
          role: "system",
          content:
            `${systemPrompt}\n\nRespond with a single valid JSON object only. No markdown, no commentary.`,
        },
        { role: "user", content: userContent },
      ];
    } else {
      body.response_format = {
        type: "json_schema",
        json_schema: {
          name: schemaName,
          schema,
          strict: false,
        },
      };
    }

    const abortController = new AbortController();
    const timeoutId = setTimeout(() => abortController.abort(), fetchTimeoutMs);

    let res: Response;
    try {
      res = await fetch(`${baseUrl}chat/completions`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${apiKey}`,
        },
        body: JSON.stringify(body),
        signal: abortController.signal,
      });
    } catch (error) {
      clearTimeout(timeoutId);
      if (error instanceof Error && error.name === "AbortError") {
        throw new Error("rate_limited");
      }
      throw error;
    } finally {
      clearTimeout(timeoutId);
    }

    if (res.status === 429) {
      if (attempt < maxAttempts) {
        const retryAfterHeader = res.headers.get("retry-after");
        const retryAfterSeconds = retryAfterHeader
          ? Number.parseInt(retryAfterHeader, 10)
          : NaN;
        let delayMs = Number.isFinite(retryAfterSeconds) && retryAfterSeconds > 0
          ? retryAfterSeconds * 1000
          : attempt * 2000;
        delayMs = Math.min(delayMs, maxDelayMs);

        const remainingBudget = totalBudgetMs - (Date.now() - startTime);
        if (delayMs >= remainingBudget) {
          throw new Error("rate_limited");
        }

        console.warn(
          `LLM rate limited (attempt ${attempt}/${maxAttempts}), retrying in ${delayMs}ms`,
        );
        await sleep(delayMs);
        continue;
      }
      throw new Error("rate_limited");
    }

    if (!res.ok) {
      const errText = await res.text();
      console.error("LLM API error:", res.status, errText);

      const shouldFallbackToJsonObject = !useJsonObject && attempt < maxAttempts &&
        (
          errText.includes("json_validate_failed") ||
          errText.includes("max completion tokens reached") ||
          errText.includes("does not support response format") ||
          errText.includes("json_schema")
        );

      if (shouldFallbackToJsonObject) {
        console.warn("JSON schema generation failed, retrying with json_object mode");
        useJsonObject = true;
        continue;
      }

      throw new Error("llm_failed");
    }

    const data = await res.json();
    const content = getMessageContent(data);
    const parsed = extractJsonPayload(content);

    if (parsed && validateAgainstSchema(parsed, schemaName, schema)) {
      return parsed;
    }

    console.error(
      "LLM invalid response content",
      JSON.stringify({
        schemaName,
        useJsonObject,
        attempt,
        contentLength: content.trim().length,
        finishReason: (data as {
          choices?: Array<{ finish_reason?: string }>;
        })?.choices?.[0]?.finish_reason ?? null,
      }),
    );

    if (!useJsonObject && attempt < maxAttempts) {
      console.warn("Invalid LLM payload, retrying with json_object mode");
      useJsonObject = true;
      continue;
    }

    throw new Error("llm_invalid_response");
  }

  throw new Error("rate_limited");
}

const RECIPE_SYSTEM_PROMPT = `You are a recipe assistant for a meal planning app. You ONLY help users create or adapt recipes into the app's structured format.

Three modes of input (detect automatically):
1) SHORT DESCRIPTION — the user names or briefly describes a dish (e.g. "tortilla de patatas para 4"). Invent a complete, realistic recipe.
2) FULL RECIPE — the user pastes an existing recipe (ingredients list, method/steps, servings, tips, etc.). ADAPT it to the app schema; do NOT invent a different dish.
3) IMAGE — the user attaches one or more photos (up to 4) of a recipe (book, screen, handwritten card, packaging) and/or ingredients/food. Extract or adapt using all images together. If there is also text, follow the text as instructions (adapt, scale servings, dietary change, "what can I cook with this", etc.) while using the images as context.
- Photos are expected to be of the SAME recipe (multiple pages, a dish plus its ingredients, etc.). Combine them into one recipe.
- If the photos clearly show DISTINCT recipes, create ONLY the first recipe (the one in the first image, or the first complete recipe you can identify). Ignore the rest. Do not merge unrelated dishes into one recipe.

When the input is image-only (no user text):
- Treat it as FULL RECIPE extraction from the image(s). Transcribe ingredients, quantities, steps, servings, and tips from the photos as faithfully as possible.
- If the images show a finished dish or ingredients without a written recipe, invent a realistic recipe that matches what you see and set a clear title.

When adapting a full recipe (mode 2 or readable recipe text in an image):
- Preserve the dish: keep the same title meaning, servings (if given), and cooking intent.
- Include EVERY edible ingredient from the input. Do not omit ingredients. Map each to name, quantity, unit, and category.
- Parse quantities and units from the text (e.g. "2 cebollas" → quantity 2, unit "unidad"; "200 g de queso" → 200, "g"). Use isToTaste=true when the source says "al gusto" / "to taste" / similar.
- If a quantity or unit is missing in the source, estimate a reasonable value; do not drop the ingredient.
- Split the preparation method into clear, actionable steps. Break long paragraphs into separate steps whenever there is a new action, timing, or technique. Expand sparse steps only when needed for clarity; do not invent unrelated steps.
- Keep any tips/notes from the source in tips (or weave them into steps if they are pure instructions).
- Still apply the naming, water, and tag rules below.

Shared rules (all modes):
- A short dish name or brief description (e.g. "pad thai", "tortilla de patatas para 4", "pasta carbonara") IS a valid recipe request (mode 1). Invent a complete recipe. Never return not_a_recipe_request for dish names or cooking requests.
- If the user prompt is clearly NOT about food/recipes at all (and there is no recipe-related image), respond with JSON containing only: {"error":"not_a_recipe_request"} and no other fields. Do not use not_a_recipe_request for allergy/dietary constraints — those are handled by adapting the recipe.
- Write ALL recipe content (title, ingredient names, steps, tips) in the SAME language as the user's prompt. If there is no prompt text, use the language of the recipe text in the image; if that is unclear, use Spanish (es). Set detectedLang to the ISO 639-1 code of that language (e.g. es, en, ca, eu, gl, pt, it).
- If the user does not specify servings, choose the most common serving count for that dish in its cuisine.
- Use realistic quantities and appropriate units from the allowed enum. Use "unidad" for countable items, weight/volume units when appropriate, and relative units (cucharada, pizca, etc.) when fitting.
- Assign each ingredient the best matching category key from the allowed enum.
- Mark garnish or truly optional ingredients with isOptional=true. Use isToTaste=true with null quantity/unit for "al gusto" items.
- Include at least one non-optional, non-to-taste ingredient and at least one non-optional step.
- Write DETAILED preparation steps: typically 6–12 for a full dish (fewer is fine for very short recipes). Each step must be a clear, actionable instruction of 2–3 sentences covering techniques, heat levels, durations, and visual cues (colour, texture, aroma) when relevant. Split complex actions into separate steps instead of merging them.
- Keep ingredient names short and concise (no preparation details in the ingredient name — put those in the steps).
- Always use SINGULAR ingredient names, even when quantity > 1 (e.g. "Patata" for 4 units, not "Patatas"; "Ajo", not "Ajos").
- Capitalize the first letter of every ingredient name (e.g. "Patata", not "patata").
- Do NOT list water used only for cooking techniques (boiling pasta, blanching, steaming, bain-marie, etc.). Mention that water in the steps instead. Only include water when it is consumed as part of the dish (soups, broths, drinks).
${TAG_SELECTION_RULES}
- Estimate nutritional values PER SERVING as whole integers only (no decimals): calories in kcal, macros and fiber in grams. Provide your best reasonable estimates.
- prepTime and cookTime are in minutes; use null if unknown.
- Do not include photo references.`;

const IMAGE_ONLY_USER_PROMPT =
  "Extract the recipe from the attached image(s) and fill the structured recipe fields. Prefer faithful transcription of any visible ingredients, quantities, and steps. Photos are expected to be of the same recipe: combine them if they are. If they clearly show different recipes, create ONLY the first recipe and ignore the others.";

const ALLOWED_IMAGE_MIME_TYPES = new Set([
  "image/jpeg",
  "image/png",
  "image/webp",
]);

/** Max base64 character length (~1.5 MB binary). */
const MAX_IMAGE_BASE64_LENGTH = Math.floor(1.5 * 1024 * 1024 * 4 / 3);
const MAX_RECIPE_IMAGES = 4;

function parseOneRecipeImage(
  rawBase64: string,
  mimeRaw: string,
): RecipeImagePayload | "invalid" | "too_large" {
  if (!rawBase64) return "invalid";

  if (rawBase64.length > MAX_IMAGE_BASE64_LENGTH) {
    return "too_large";
  }

  if (!ALLOWED_IMAGE_MIME_TYPES.has(mimeRaw)) {
    return "invalid";
  }

  // Reject obvious non-base64 payloads early.
  if (!/^[A-Za-z0-9+/=\s]+$/.test(rawBase64)) {
    return "invalid";
  }

  const cleaned = rawBase64.replace(/\s+/g, "");
  // Validate base64 structure: length must be a multiple of 4, padding must be
  // well-formed (0–2 '=' only at the end), and the payload must be non-empty.
  if (cleaned.length === 0 || cleaned.length % 4 !== 0) {
    return "invalid";
  }
  const paddingMatch = cleaned.match(/=+$/);
  const padding = paddingMatch ? paddingMatch[0].length : 0;
  if (padding > 2) {
    return "invalid";
  }
  // Padding chars may only appear at the very end; reject interior '='.
  if (padding > 0 && cleaned.slice(0, cleaned.length - padding).includes("=")) {
    return "invalid";
  }

  return { mimeType: mimeRaw, base64: cleaned };
}

function parseRecipeImages(
  body: Record<string, unknown> | null | undefined,
): RecipeImagePayload[] | "invalid" | "too_large" | "too_many" {
  const rawImages = body?.images;
  if (Array.isArray(rawImages)) {
    if (rawImages.length > MAX_RECIPE_IMAGES) return "too_many";
    if (rawImages.length === 0) return [];

    const parsed: RecipeImagePayload[] = [];
    for (const item of rawImages) {
      if (!item || typeof item !== "object") return "invalid";
      const rec = item as Record<string, unknown>;
      const rawBase64 = typeof rec.imageBase64 === "string"
        ? rec.imageBase64.trim()
        : "";
      const mimeRaw = typeof rec.imageMimeType === "string"
        ? rec.imageMimeType.trim().toLowerCase()
        : "";
      const result = parseOneRecipeImage(rawBase64, mimeRaw);
      if (result === "invalid" || result === "too_large") return result;
      parsed.push(result);
    }
    return parsed;
  }

  const legacyBase64 = typeof body?.imageBase64 === "string"
    ? body.imageBase64.trim()
    : "";
  if (!legacyBase64) return [];

  const mimeRaw = typeof body?.imageMimeType === "string"
    ? body.imageMimeType.trim().toLowerCase()
    : "";
  const result = parseOneRecipeImage(legacyBase64, mimeRaw);
  if (result === "invalid" || result === "too_large") return result;
  return [result];
}

const TAGS_SYSTEM_PROMPT = `You are a tagging assistant for a meal planning app. Given a recipe, select EVERY allowed tag that reasonably applies.

Rules:
- Return a JSON object with a single "tags" array. Each item must be a key from the allowed enum.
- Your goal is coverage, not a short highlight list. Evaluate every allowed tag. Include all non-"sin" tags that reasonably fit.
- An empty array is valid only if nothing at all applies, which is rare.
- ${TAG_SELECTION_RULES}
- If the user message includes "Existing tags", treat those as currently selected chips.
- Keep an existing non-"sin" tag if it still reasonably applies. For "sin"/allergen-free tags, drop them if there is any doubt, even if they were previously selected.
- Return the full recommended set of tags, not a diff.
- Do not include any other fields or commentary.`;

const NUTRITION_SYSTEM_PROMPT = `You are a nutrition assistant for a meal planning app. Given a recipe title, servings count, and ingredient list, estimate the nutritional information PER SERVING.

Rules:
- Return a JSON object with exactly these five fields as non-negative INTEGERS only (no decimals): calories (kcal), protein (g), carbohydrates (g), fat (g), fiber (g).
- Use null for a field only if it cannot be reasonably estimated.
- Base estimates on the listed ingredients and quantities for the given servings.
- If the user message includes "Existing nutrition (per serving)", treat those as the current saved values.
- When existing values are present and are coherent with the recipe (title, servings, ingredients), return those values UNCHANGED.
- Only change an existing value when it is clearly wrong or inconsistent; fill null/missing fields with estimates.
- Do not include any other fields or commentary.`;

function formatIngredientsForPrompt(ingredients: IngredientInput[]): string {
  return ingredients
    .map((ingredient, index) => {
      const parts = [`${index + 1}. ${ingredient.name}`];
      if (ingredient.isToTaste) {
        parts.push("(al gusto)");
      } else if (ingredient.quantity != null) {
        const unit = ingredient.unit ? ` ${ingredient.unit}` : "";
        parts.push(`— ${ingredient.quantity}${unit}`);
      }
      if (ingredient.isOptional) parts.push("(opcional)");
      return parts.join(" ");
    })
    .join("\n");
}

function formatStepsForPrompt(steps: StepInput[]): string {
  return steps
    .map((step, index) => `${index + 1}. ${step.description}`)
    .join("\n");
}

function parseOptionalNonNegativeInt(raw: unknown): number | null {
  if (raw === null || raw === undefined || raw === "") return null;
  const num = typeof raw === "number"
    ? raw
    : typeof raw === "string"
    ? Number(raw.replace(",", "."))
    : NaN;
  if (!Number.isFinite(num) || num < 0) return null;
  return Math.round(num);
}

type TagSelectionInput = {
  title: string;
  servings: number;
  ingredients: IngredientInput[];
  steps?: StepInput[];
  prepTime?: number | null;
  cookTime?: number | null;
  tips?: string;
  existingTags?: string[] | null;
};

function asIngredientInputs(raw: unknown): IngredientInput[] {
  if (!Array.isArray(raw)) return [];
  return raw.filter((item): item is IngredientInput =>
    !!item &&
    typeof item === "object" &&
    typeof (item as IngredientInput).name === "string" &&
    (item as IngredientInput).name.trim().length > 0
  );
}

function asStepInputs(raw: unknown): StepInput[] {
  if (!Array.isArray(raw)) return [];
  return raw.filter((item): item is StepInput =>
    !!item &&
    typeof item === "object" &&
    typeof (item as StepInput).description === "string" &&
    (item as StepInput).description.trim().length > 0
  );
}

function buildTagsUserPrompt(input: TagSelectionInput): string {
  const parts = [
    `Recipe: ${input.title}`,
    `Servings: ${input.servings}`,
  ];
  if (input.prepTime != null) {
    parts.push(`Prep time (minutes): ${input.prepTime}`);
  }
  if (input.cookTime != null) {
    parts.push(`Cook time (minutes): ${input.cookTime}`);
  }
  parts.push("Ingredients:", formatIngredientsForPrompt(input.ingredients));

  const steps = (input.steps ?? []).filter((step) =>
    step.description.trim().length > 0
  );
  if (steps.length > 0) {
    parts.push("", "Steps:", formatStepsForPrompt(steps));
  }

  const tips = input.tips?.trim() ?? "";
  if (tips) {
    parts.push("", "Tips:", tips);
  }

  parts.push(
    "",
    "Evaluate EVERY allowed tag. Include all non-\"sin\" tags that reasonably apply.",
    `Non-"sin" tags (maximize): ${MAXIMIZE_TAG_KEYS.join(", ")}`,
    `"Sin"/allergen-free tags (only if certain): ${SIN_TAG_KEYS.join(", ")}`,
  );

  if (input.existingTags && input.existingTags.length > 0) {
    parts.push(
      "",
      "Existing tags:",
      input.existingTags.join(", "),
      "Keep existing non-\"sin\" tags if they still reasonably apply. Drop \"sin\"/allergen-free tags if there is any doubt.",
    );
  }

  return parts.join("\n");
}

async function selectRecipeTags(input: TagSelectionInput): Promise<string[]> {
  const tagsResult = await callLlm(
    TAGS_SYSTEM_PROMPT,
    buildTagsUserPrompt(input),
    "recipe_tags",
    tagsSchema,
    1024,
    {
      temperature: 0,
      minMaxTokens: 1024,
      // Keep secondary tag selection well under the client's ~210s budget.
      maxAttempts: 2,
      totalBudgetMs: 60000,
      fetchTimeoutMs: 45000,
      maxDelayMs: 5000,
    },
  );
  return normalizeTags(tagsResult);
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return jsonResponse({ error: "unauthorized" }, 401);
    }

    // ── Validate JWT and extract the real user id ─────────────────────────────
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
    const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

    const userClient = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authHeader } },
    });
    const { data: userData, error: userError } = await userClient.auth.getUser();
    if (userError || !userData?.user) {
      return jsonResponse({ error: "unauthorized" }, 401);
    }
    const userId = userData.user.id;

    const adminClient = createClient(supabaseUrl, serviceKey);

    const body = await req.json();
    const mode = body?.mode as AssistantMode | undefined;

    if (
      mode !== "generate_recipe" &&
      mode !== "generate_nutrition" &&
      mode !== "generate_tags"
    ) {
      return jsonResponse({ error: "invalid_mode" }, 400);
    }

    const quotaResult = await enforceAiQuota(
      adminClient,
      userId,
      corsHeaders,
      req,
    );
    if (!quotaResult.ok) return quotaResult.response;

    if (mode === "generate_recipe") {
      const prompt = typeof body?.prompt === "string" ? body.prompt.trim() : "";
      const imageResult = parseRecipeImages(body as Record<string, unknown>);

      if (imageResult === "too_large") {
        return jsonResponse({ error: "image_too_large" }, 400);
      }
      if (imageResult === "invalid") {
        return jsonResponse({ error: "invalid_image" }, 400);
      }
      if (imageResult === "too_many") {
        return jsonResponse({ error: "too_many_images" }, 400);
      }

      const images = imageResult;
      if (!prompt && images.length === 0) {
        return jsonResponse({ error: "missing_input" }, 400);
      }

      if (prompt.length > 3000) {
        return jsonResponse({ error: "prompt_too_long" }, 400);
      }

      const userAllergens = parseUserAllergens(body);
      const allergenRules = buildAllergenRules(userAllergens);

      let userPrompt = prompt;
      if (images.length > 0 && !prompt) {
        userPrompt = IMAGE_ONLY_USER_PROMPT;
      } else if (images.length > 0 && prompt) {
        userPrompt =
          `${prompt}\n\nUse the attached image(s) as additional context for this recipe request. Photos are expected to be of the same recipe. If they clearly show different recipes, create ONLY the first recipe and ignore the others.`;
      }

      // Keep allergen constraints on the user turn so they are not confused with
      // the system "not_a_recipe_request" gate.
      if (allergenRules) {
        userPrompt = `${userPrompt}\n${allergenRules}`;
      }

      const result = await callLlm(
        RECIPE_SYSTEM_PROMPT,
        userPrompt,
        "generated_recipe",
        recipeSchema,
        8192,
        images.length > 0 ? { images } : {},
      );

      if (result.error === "not_a_recipe_request") {
        return jsonResponse({ error: "not_a_recipe_request" }, 422);
      }

      if (result.error === "allergen_conflict") {
        let conflicting = Array.isArray(result.conflictingAllergens)
          ? result.conflictingAllergens.filter((a: unknown) =>
            typeof a === "string" &&
            (SIN_TAG_KEYS as readonly string[]).includes(a) &&
            userAllergens.includes(a)
          )
          : [];
        if (conflicting.length === 0) {
          conflicting = [...userAllergens];
        }
        const named = conflicting
          .map((key: string) => ALLERGEN_LABELS[key] ?? key)
          .join(", ");
        return jsonResponse(
          {
            error: "allergen_conflict",
            message: typeof result.message === "string" &&
                result.message.trim().length > 0
              ? result.message.trim()
              : `No se puede crear la receta sin el alérgeno o intolerancia: ${named}.`,
            conflictingAllergens: conflicting,
          },
          422,
        );
      }

      // Normalize allergenAdjustments so the client always receives an array.
      if (!Array.isArray(result.allergenAdjustments)) {
        result.allergenAdjustments = [];
      } else {
        result.allergenAdjustments = result.allergenAdjustments
          .filter((note: unknown): note is string =>
            typeof note === "string" && note.trim().length > 0
          )
          .map((note: string) => note.trim());
      }

      let adjustedAllergens = Array.isArray(result.adjustedAllergens)
        ? result.adjustedAllergens.filter((a: unknown): a is string =>
          typeof a === "string" &&
          (SIN_TAG_KEYS as readonly string[]).includes(a) &&
          userAllergens.includes(a)
        )
        : [];

      // Models often adapt the dish (even renaming it "… Adaptado") but forget
      // allergenAdjustments / adjustedAllergens. Detect that before cleaning the
      // title so the client can show the allergy popup.
      const adaptationSignal = hasAllergenAdaptationSignal(
        result,
        result.allergenAdjustments as string[],
      );
      if (
        userAllergens.length > 0 &&
        adjustedAllergens.length === 0 &&
        adaptationSignal
      ) {
        adjustedAllergens = [...userAllergens];
      }

      if (
        adjustedAllergens.length > 0 &&
        (result.allergenAdjustments as string[]).length === 0
      ) {
        result.allergenAdjustments = fallbackAllergenAdjustments(
          adjustedAllergens,
        );
      }
      result.adjustedAllergens = adjustedAllergens;

      const normalizedTitle = normalizeAdaptedTitleMarker(result.title);
      if (normalizedTitle) {
        result.title = normalizedTitle;
      }

      try {
        const tagIngredients = asIngredientInputs(result.ingredients);
        const tagTitle = typeof result.title === "string" ? result.title.trim() : "";
        if (tagTitle && tagIngredients.length > 0) {
          const selectedTags = await selectRecipeTags({
            title: tagTitle,
            servings: typeof result.servings === "number" ? result.servings : 4,
            ingredients: tagIngredients,
            steps: asStepInputs(result.steps),
            prepTime: parseOptionalNonNegativeInt(result.prepTime),
            cookTime: parseOptionalNonNegativeInt(result.cookTime),
            tips: typeof result.tips === "string" ? result.tips : "",
            existingTags: parseExistingTags(result.tags),
          });
          // Auto-apply "sin" tags only for allergens the model confirmed adjusted.
          if (adjustedAllergens.length > 0) {
            const merged = new Set<string>(selectedTags);
            for (const allergen of adjustedAllergens) {
              merged.add(allergen);
            }
            result.tags = [...merged];
          } else {
            result.tags = selectedTags;
          }
        }
      } catch (error) {
        console.warn(
          "tag selection after recipe generation failed, keeping recipe tags",
          error,
        );
      }

      return jsonResponse({ recipe: result });
    }

    const title = typeof body?.title === "string" ? body.title.trim() : "";
    const servings = Number(body?.servings);
    const ingredients = Array.isArray(body?.ingredients)
      ? body.ingredients as IngredientInput[]
      : [];

    if (!title || !Number.isFinite(servings) || servings < 1) {
      return jsonResponse({ error: "missing_recipe_context" }, 400);
    }

    if (title.length > 200) {
      return jsonResponse({ error: "title_too_long" }, 400);
    }

    if (ingredients.length > 100) {
      return jsonResponse({ error: "too_many_ingredients" }, 400);
    }

    const validIngredients = ingredients.filter((item) =>
      typeof item?.name === "string" && item.name.trim().length > 0
    );
    if (validIngredients.length === 0) {
      return jsonResponse({ error: "missing_recipe_context" }, 400);
    }

    let totalInputSize = title.length;
    for (const ingredient of validIngredients) {
      if (ingredient.name.length > 200) {
        return jsonResponse({ error: "ingredient_name_too_long" }, 400);
      }
      totalInputSize += ingredient.name.length;
      if (ingredient.unit && typeof ingredient.unit === "string") {
        totalInputSize += ingredient.unit.length;
      }
    }

    if (totalInputSize > 20000) {
      return jsonResponse({ error: "input_too_large" }, 400);
    }

    if (mode === "generate_nutrition") {
      const existingNutrition = parseExistingNutrition(body?.existingNutrition);

      const userPromptParts = [
        `Recipe: ${title}`,
        `Servings: ${servings}`,
        "Ingredients:",
        formatIngredientsForPrompt(validIngredients),
      ];
      if (existingNutrition) {
        userPromptParts.push(
          "",
          "Existing nutrition (per serving):",
          formatExistingNutritionForPrompt(existingNutrition),
          "If these values are coherent with the recipe, return them unchanged. Only adjust clearly wrong values; fill nulls.",
        );
      }

      const nutrition = await callLlm(
        NUTRITION_SYSTEM_PROMPT,
        userPromptParts.join("\n"),
        "recipe_nutrition",
        nutritionSchema,
        4096,
        { preferJsonObject: true, minMaxTokens: 4096 },
      );

      return jsonResponse({ nutrition: normalizeNutrition(nutrition) });
    }

    const rawSteps = Array.isArray(body?.steps) ? body.steps as StepInput[] : [];
    if (rawSteps.length > 50) {
      return jsonResponse({ error: "too_many_steps" }, 400);
    }
    const validSteps = rawSteps.filter((item) =>
      typeof item?.description === "string" && item.description.trim().length > 0
    );
    for (const step of validSteps) {
      if (step.description.length > 1000) {
        return jsonResponse({ error: "step_too_long" }, 400);
      }
      totalInputSize += step.description.length;
    }

    const tips = typeof body?.tips === "string" ? body.tips.trim() : "";
    if (tips.length > 2000) {
      return jsonResponse({ error: "tips_too_long" }, 400);
    }
    totalInputSize += tips.length;

    if (totalInputSize > 20000) {
      return jsonResponse({ error: "input_too_large" }, 400);
    }

    const prepTime = parseOptionalNonNegativeInt(body?.prepTime);
    const cookTime = parseOptionalNonNegativeInt(body?.cookTime);
    const existingTags = parseExistingTags(body?.existingTags);

    const tags = await selectRecipeTags({
      title,
      servings,
      ingredients: validIngredients,
      steps: validSteps,
      prepTime,
      cookTime,
      tips,
      existingTags,
    });

    return jsonResponse({ tags });
  } catch (error) {
    const message = error instanceof Error ? error.message : "internal_error";
    console.error("recipe-assistant error:", error);

    if (message === "not_configured") {
      return jsonResponse({ error: "not_configured" }, 503);
    }
    if (message === "rate_limited") {
      return jsonResponse({ error: "rate_limited" }, 429);
    }
    if (message === "llm_failed" || message === "llm_invalid_response") {
      return jsonResponse({ error: "generation_failed" }, 502);
    }

    return jsonResponse({ error: "internal_error" }, 500);
  }
});
