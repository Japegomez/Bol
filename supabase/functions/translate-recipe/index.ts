import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const TRANSLATE_URL = "https://translation.googleapis.com/language/translate/v2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

type IngredientRow = {
  id: string;
  name: string;
  unit: string | null;
  category: string | null;
};

type StepRow = {
  id: string;
  description: string;
};

type TranslationPayload = {
  title: string;
  tips: string | null;
  tags: string[];
  ingredients: IngredientRow[];
  steps: StepRow[];
  source_lang: string;
  target_lang: string;
};

async function translateTexts(
  apiKey: string,
  texts: string[],
  targetLang: string,
  sourceLang?: string,
): Promise<string[]> {
  if (texts.length === 0) return [];

  const body: Record<string, unknown> = {
    q: texts,
    target: targetLang,
    format: "text",
  };
  if (sourceLang) body.source = sourceLang;

  const res = await fetch(`${TRANSLATE_URL}?key=${apiKey}`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });

  if (!res.ok) {
    const errText = await res.text();
    console.error("Translation API error:", res.status, errText);
    throw new Error("Translation API failed");
  }

  const data = await res.json();
  const translations = data?.data?.translations as
    | Array<{ translatedText: string }>
    | undefined;
  if (!translations || translations.length !== texts.length) {
    throw new Error("Unexpected translation response");
  }
  return translations.map((t) => t.translatedText);
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const apiKey = Deno.env.get("GOOGLE_API_KEY");
    if (!apiKey) {
      return new Response(
        JSON.stringify({ error: "Translation not configured" }),
        {
          status: 503,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const { recipe_id: recipeId, target_lang: targetLang } = await req.json();
    if (!recipeId || !targetLang) {
      return new Response(
        JSON.stringify({ error: "Missing recipe_id or target_lang" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    // ── Target language allowlist (ISO 639-1 codes we support) ───────────────
    const ALLOWED_TARGET_LANGS = new Set([
      "es", "en", "ca", "eu", "gl", "pt", "it", "fr", "de",
    ]);
    if (typeof targetLang !== "string" || !ALLOWED_TARGET_LANGS.has(targetLang)) {
      return new Response(
        JSON.stringify({ error: "Unsupported target language" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const userClient = createClient(supabaseUrl, Deno.env.get("SUPABASE_ANON_KEY")!, {
      global: { headers: { Authorization: authHeader } },
    });
    const adminClient = createClient(supabaseUrl, serviceKey);

    // ── Authenticate the caller and enforce per-user/global quota ───────────
    const { data: userData, error: userError } = await userClient.auth.getUser();
    if (userError || !userData?.user) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }
    const userId = userData.user.id;

    const dailyLimit = Number(Deno.env.get("AI_ASSISTANT_DAILY_LIMIT") ?? "20");
    const minInterval = Number(
      Deno.env.get("AI_ASSISTANT_MIN_INTERVAL_SECONDS") ?? "3",
    );
    const globalLimitRaw = Deno.env.get("AI_ASSISTANT_GLOBAL_DAILY_LIMIT");
    const globalLimit = globalLimitRaw ? Number(globalLimitRaw) : null;

    if (!Number.isFinite(dailyLimit) || dailyLimit <= 0) {
      console.error("Invalid AI_ASSISTANT_DAILY_LIMIT:", dailyLimit);
      return new Response(
        JSON.stringify({ error: "quota_check_failed" }),
        { status: 503, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }
    if (!Number.isFinite(minInterval) || minInterval < 0) {
      console.error("Invalid AI_ASSISTANT_MIN_INTERVAL_SECONDS:", minInterval);
      return new Response(
        JSON.stringify({ error: "quota_check_failed" }),
        { status: 503, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }
    if (globalLimit !== null && (!Number.isFinite(globalLimit) || globalLimit <= 0)) {
      console.error("Invalid AI_ASSISTANT_GLOBAL_DAILY_LIMIT:", globalLimit);
      return new Response(
        JSON.stringify({ error: "quota_check_failed" }),
        { status: 503, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const { data: quotaRows, error: quotaError } = await adminClient
      .rpc("check_and_increment_ai_usage", {
        p_user_id: userId,
        p_daily_limit: dailyLimit,
        p_min_interval_seconds: minInterval,
        p_global_daily_limit: globalLimit,
      });

    type QuotaRow = {
      allowed: boolean;
      reason: string | null;
      remaining: number;
      retry_after_seconds: number;
    };

    if (quotaError || !quotaRows || (quotaRows as QuotaRow[]).length === 0) {
      console.error("quota check error:", quotaError);
      return new Response(
        JSON.stringify({ error: "quota_check_failed" }),
        { status: 503, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const quota = (quotaRows as QuotaRow[])[0];
    if (!quota.allowed) {
      const status = quota.reason === "service_at_capacity" ? 503 : 429;
      return new Response(
        JSON.stringify({ error: quota.reason }),
        { status, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const { data: recipe, error: recipeError } = await userClient
      .from("recipes")
      .select("id, title, tips, tags, source_lang, is_public, user_id")
      .eq("id", recipeId)
      .maybeSingle();

    if (recipeError || !recipe) {
      return new Response(JSON.stringify({ error: "Recipe not found" }), {
        status: 404,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const sourceLang = (recipe.source_lang as string) || "es";
    if (sourceLang === targetLang) {
      return new Response(JSON.stringify({ error: "Same language" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const { data: cached, error: cacheError } = await adminClient
      .from("recipe_translations")
      .select("payload, status")
      .eq("recipe_id", recipeId)
      .eq("lang", targetLang)
      .maybeSingle();

    if (cacheError) {
      console.error("Cache read error:", cacheError);
    }
    if (cached?.payload) {
      return new Response(
        JSON.stringify({ payload: cached.payload, cached: true }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const [ingredientsRes, stepsRes] = await Promise.all([
      userClient
        .from("ingredients")
        .select("id, name, unit, category, position")
        .eq("recipe_id", recipeId)
        .order("position", { ascending: true }),
      userClient
        .from("recipe_steps")
        .select("id, description, position")
        .eq("recipe_id", recipeId)
        .order("position", { ascending: true }),
    ]);

    const ingredients = (ingredientsRes.data ?? []) as Array<
      Record<string, unknown>
    >;
    const steps = (stepsRes.data ?? []) as Array<Record<string, unknown>>;

    // Only free-text fields are machine translated. Tags, units and categories
    // are stable keys localized on the client, so we pass them through
    // untouched and keep the response grouped by field for index alignment.
    const tipsText = recipe.tips ? (recipe.tips as string) : null;
    const tags = (recipe.tags as string[] ?? []);
    const ingredientNames = ingredients.map((i) => (i.name as string) ?? "");
    const stepDescriptions = steps.map((s) => (s.description as string) ?? "");

    const textsToTranslate: string[] = [
      recipe.title as string,
      ...(tipsText ? [tipsText] : []),
      ...ingredientNames,
      ...stepDescriptions,
    ];

    // ── Size cap: reject payloads that would cost too much in one call ──────
    const MAX_TRANSLATE_CHARS = 10_000;
    const totalChars = textsToTranslate.reduce((n, t) => n + t.length, 0);
    if (totalChars > MAX_TRANSLATE_CHARS) {
      return new Response(
        JSON.stringify({ error: "Recipe too large to translate" }),
        { status: 413, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const translated = await translateTexts(
      apiKey,
      textsToTranslate,
      targetLang,
      sourceLang,
    );

    let idx = 0;
    const title = translated[idx++];
    const tips = tipsText ? translated[idx++] : null;

    const nameStart = idx;
    idx += ingredientNames.length;
    const stepStart = idx;
    idx += stepDescriptions.length;

    const translatedIngredients: IngredientRow[] = ingredients.map((row, i) => ({
      id: row.id as string,
      name: translated[nameStart + i],
      unit: (row.unit as string | null) ?? null,
      category: (row.category as string | null) ?? null,
    }));
    const translatedSteps: StepRow[] = steps.map((row, i) => ({
      id: row.id as string,
      description: translated[stepStart + i],
    }));

    const payload: TranslationPayload = {
      title,
      tips,
      tags,
      ingredients: translatedIngredients,
      steps: translatedSteps,
      source_lang: sourceLang,
      target_lang: targetLang,
    };

    const { error: upsertError } = await adminClient
      .from("recipe_translations")
      .upsert({
        recipe_id: recipeId,
        lang: targetLang,
        payload,
        status: "ready",
      });

    if (upsertError) {
      console.error("Cache upsert error:", upsertError);
    }

    return new Response(
      JSON.stringify({ payload, cached: false }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (error) {
    console.error("translate-recipe error:", error);
    return new Response(JSON.stringify({ error: "Internal error" }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
