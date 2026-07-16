import "jsr:@supabase/functions-js/edge-runtime.d.ts";

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
  "starter",
  "main_course",
  "dessert",
  "vegetarian",
  "vegan",
  "pescatarian",
  "gluten_free",
  "lactose_free",
  "egg_free",
  "nut_free",
  "soy_free",
  "shellfish_free",
  "sugar_free",
  "high_protein",
  "low_calorie",
  "low_carb",
  "high_fiber",
  "mediterranean",
  "quick",
  "budget",
  "batch_cooking",
  "freezer_friendly",
  "spicy",
  "kid_friendly",
] as const;

type AssistantMode = "generate_recipe" | "generate_nutrition";

type IngredientInput = {
  name: string;
  quantity?: number | null;
  unit?: string | null;
  category?: string | null;
  isOptional?: boolean;
  isToTaste?: boolean;
};

const nutritionSchema = {
  type: "object",
  additionalProperties: false,
  properties: {
    calories: { type: ["number", "null"], minimum: 0 },
    protein: { type: ["number", "null"], minimum: 0 },
    carbohydrates: { type: ["number", "null"], minimum: 0 },
    fat: { type: ["number", "null"], minimum: 0 },
    fiber: { type: ["number", "null"], minimum: 0 },
  },
  required: ["calories", "protein", "carbohydrates", "fat", "fiber"],
};

const recipeSchema = {
  type: "object",
  additionalProperties: false,
  properties: {
    error: { type: "string", enum: ["not_a_recipe_request"] },
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
  const model = Deno.env.get("LLM_MODEL") ?? "gemini-2.5-flash";
  return { apiKey, baseUrl: baseUrl.replace(/\/?$/, "/"), model };
}

function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

type CallLlmOptions = {
  preferJsonObject?: boolean;
  minMaxTokens?: number;
};

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
    const calories = parsed.calories;
    const protein = parsed.protein;
    const carbohydrates = parsed.carbohydrates;
    const fat = parsed.fat;
    const fiber = parsed.fiber;

    if (
      (calories !== null && (typeof calories !== "number" || calories < 0)) ||
      (protein !== null && (typeof protein !== "number" || protein < 0)) ||
      (carbohydrates !== null && (typeof carbohydrates !== "number" || carbohydrates < 0)) ||
      (fat !== null && (typeof fat !== "number" || fat < 0)) ||
      (fiber !== null && (typeof fiber !== "number" || fiber < 0))
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

  const maxAttempts = 3;
  const totalBudgetMs = 240000;
  const maxDelayMs = 30000;
  const fetchTimeoutMs = 180000;
  const startTime = Date.now();
  let useJsonObject = options.preferJsonObject ?? false;

  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    const elapsedMs = Date.now() - startTime;
    if (elapsedMs >= totalBudgetMs) {
      throw new Error("rate_limited");
    }

    const body: Record<string, unknown> = {
      model,
      temperature: 0.4,
      max_tokens: effectiveMax,
      messages: [
        { role: "system", content: systemPrompt },
        { role: "user", content: userPrompt },
      ],
    };

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
        { role: "user", content: userPrompt },
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

Two modes of input (detect automatically):
1) SHORT DESCRIPTION — the user names or briefly describes a dish (e.g. "tortilla de patatas para 4"). Invent a complete, realistic recipe.
2) FULL RECIPE — the user pastes an existing recipe (ingredients list, method/steps, servings, tips, etc.). ADAPT it to the app schema; do NOT invent a different dish.

When adapting a full recipe (mode 2):
- Preserve the dish: keep the same title meaning, servings (if given), and cooking intent.
- Include EVERY edible ingredient from the input. Do not omit ingredients. Map each to name, quantity, unit, and category.
- Parse quantities and units from the text (e.g. "2 cebollas" → quantity 2, unit "unidad"; "200 g de queso" → 200, "g"). Use isToTaste=true when the source says "al gusto" / "to taste" / similar.
- If a quantity or unit is missing in the source, estimate a reasonable value; do not drop the ingredient.
- Split the preparation method into clear, actionable steps. Break long paragraphs into separate steps whenever there is a new action, timing, or technique. Expand sparse steps only when needed for clarity; do not invent unrelated steps.
- Keep any tips/notes from the source in tips (or weave them into steps if they are pure instructions).
- Still apply the naming, water, and tag rules below.

Shared rules (both modes):
- If the user prompt is NOT a request to create, describe, or paste a recipe, respond with JSON containing only: {"error":"not_a_recipe_request"} and no other fields.
- Write ALL recipe content (title, ingredient names, steps, tips) in the SAME language as the user's prompt. Set detectedLang to the ISO 639-1 code of that language (e.g. es, en, ca, eu, gl, pt).
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
- Select relevant tags only from the allowed enum (dietary, course type, etc.).
- Estimate nutritional values PER SERVING (calories in kcal, macros and fiber in grams). Provide your best reasonable estimates.
- prepTime and cookTime are in minutes; use null if unknown.
- Do not include photo references.`;

const NUTRITION_SYSTEM_PROMPT = `You are a nutrition assistant for a meal planning app. Given a recipe title, servings count, and ingredient list, estimate the nutritional information PER SERVING.

Rules:
- Return a JSON object with exactly these five numeric fields: calories (kcal), protein (g), carbohydrates (g), fat (g), fiber (g).
- Use null for a field only if it cannot be reasonably estimated.
- Base estimates on the listed ingredients and quantities for the given servings.
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

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return jsonResponse({ error: "unauthorized" }, 401);
    }

    const body = await req.json();
    const mode = body?.mode as AssistantMode | undefined;

    if (mode !== "generate_recipe" && mode !== "generate_nutrition") {
      return jsonResponse({ error: "invalid_mode" }, 400);
    }

    if (mode === "generate_recipe") {
      const prompt = typeof body?.prompt === "string" ? body.prompt.trim() : "";
      if (!prompt) {
        return jsonResponse({ error: "missing_prompt" }, 400);
      }

      if (prompt.length > 10000) {
        return jsonResponse({ error: "prompt_too_long" }, 400);
      }

      const result = await callLlm(
        RECIPE_SYSTEM_PROMPT,
        prompt,
        "generated_recipe",
        recipeSchema,
      );

      if (result.error === "not_a_recipe_request") {
        return jsonResponse({ error: "not_a_recipe_request" }, 422);
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

    const userPrompt = [
      `Recipe: ${title}`,
      `Servings: ${servings}`,
      "Ingredients:",
      formatIngredientsForPrompt(validIngredients),
    ].join("\n");

    const nutrition = await callLlm(
      NUTRITION_SYSTEM_PROMPT,
      userPrompt,
      "recipe_nutrition",
      nutritionSchema,
      4096,
      { preferJsonObject: true, minMaxTokens: 4096 },
    );

    return jsonResponse({ nutrition });
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
