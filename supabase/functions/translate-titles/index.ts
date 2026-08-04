import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const TRANSLATE_URL = "https://translation.googleapis.com/language/translate/v2";

const SUPPORTED_LANGS = ["en", "es", "ca", "eu", "gl", "pt", "it"];
const MAX_RECIPE_IDS = 100;

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

async function translateTexts(
  apiKey: string,
  texts: string[],
  targetLang: string,
): Promise<string[]> {
  if (texts.length === 0) return [];

  // Source language is auto-detected so titles from different source languages
  // can be translated in a single request.
  const res = await fetch(`${TRANSLATE_URL}?key=${apiKey}`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ q: texts, target: targetLang, format: "text" }),
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

    const { recipe_ids: recipeIds, target_lang: targetLang } = await req.json();
    if (!Array.isArray(recipeIds) || recipeIds.length === 0 || !targetLang) {
      return new Response(
        JSON.stringify({ error: "Missing recipe_ids or target_lang" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }
    if (!SUPPORTED_LANGS.includes(targetLang)) {
      return new Response(JSON.stringify({ error: "Unsupported target_lang" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }
    if (recipeIds.length > MAX_RECIPE_IDS) {
      return new Response(JSON.stringify({ error: "Too many recipe_ids" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const ids = [...new Set(recipeIds.map((id: unknown) => String(id)))];

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const userClient = createClient(
      supabaseUrl,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: authHeader } } },
    );
    const adminClient = createClient(supabaseUrl, serviceKey);

    // Only titles the caller is allowed to see (RLS enforced via userClient).
    const { data: recipeRows, error: recipeError } = await userClient
      .from("recipes")
      .select("id, title, source_lang")
      .in("id", ids);

    if (recipeError) {
      console.error("Recipe read error:", recipeError);
      return new Response(JSON.stringify({ error: "Read failed" }), {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const visible = (recipeRows ?? []).filter(
      (r) => ((r.source_lang as string) || "es") !== targetLang,
    ) as Array<{ id: string; title: string; source_lang: string | null }>;

    const result: Record<string, string> = {};
    if (visible.length === 0) {
      return new Response(JSON.stringify({ translations: result }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const visibleIds = visible.map((r) => r.id);
    const { data: cachedRows } = await adminClient
      .from("recipe_title_translations")
      .select("recipe_id, title")
      .eq("lang", targetLang)
      .in("recipe_id", visibleIds);

    const cached = new Map<string, string>(
      (cachedRows ?? []).map((r) => [r.recipe_id as string, r.title as string]),
    );

    const missing = visible.filter((r) => !cached.has(r.id));
    for (const [id, title] of cached) result[id] = title;

    if (missing.length > 0) {
      const translated = await translateTexts(
        apiKey,
        missing.map((r) => r.title),
        targetLang,
      );

      const rowsToUpsert = missing.map((r, i) => ({
        recipe_id: r.id,
        lang: targetLang,
        title: translated[i],
      }));

      for (const row of rowsToUpsert) result[row.recipe_id] = row.title;

      const { error: upsertError } = await adminClient
        .from("recipe_title_translations")
        .upsert(rowsToUpsert);
      if (upsertError) console.error("Title cache upsert error:", upsertError);
    }

    return new Response(JSON.stringify({ translations: result }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error) {
    console.error("translate-titles error:", error);
    return new Response(JSON.stringify({ error: "Internal error" }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
