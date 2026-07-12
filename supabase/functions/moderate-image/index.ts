import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const VISION_URL = "https://vision.googleapis.com/v1/images:annotate";

type Likelihood =
  | "UNKNOWN"
  | "VERY_UNLIKELY"
  | "UNLIKELY"
  | "POSSIBLE"
  | "LIKELY"
  | "VERY_LIKELY";

interface SafeSearchAnnotation {
  adult?: Likelihood;
  violence?: Likelihood;
  racy?: Likelihood;
}

const rejectLevels = new Set<Likelihood>(["LIKELY", "VERY_LIKELY"]);

function rejectionReasons(annotation: SafeSearchAnnotation): string[] {
  const reasons: string[] = [];
  if (annotation.adult && rejectLevels.has(annotation.adult)) {
    reasons.push("adult");
  }
  if (annotation.violence && rejectLevels.has(annotation.violence)) {
    reasons.push("violence");
  }
  if (annotation.racy === "VERY_LIKELY") {
    reasons.push("racy");
  }
  return reasons;
}

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const apiKey = Deno.env.get("GOOGLE_VISION_API_KEY");
    if (!apiKey) {
      return new Response(
        JSON.stringify({ error: "Moderation not configured" }),
        { status: 503, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const { image } = await req.json();
    if (!image || typeof image !== "string") {
      return new Response(
        JSON.stringify({ error: "Missing image" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const visionTimeoutMs = 15_000;
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), visionTimeoutMs);

    let visionRes: Response;
    try {
      visionRes = await fetch(`${VISION_URL}?key=${apiKey}`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          requests: [
            {
              image: { content: image },
              features: [{ type: "SAFE_SEARCH_DETECTION", maxResults: 1 }],
            },
          ],
        }),
        signal: controller.signal,
      });
    } finally {
      clearTimeout(timeoutId);
    }

    if (!visionRes.ok) {
      const errText = await visionRes.text();
      console.error("Vision API HTTP error:", visionRes.status, errText);
      let detail: string | undefined;
      try {
        const parsed = JSON.parse(errText);
        detail = parsed?.error?.message;
      } catch {
        detail = errText.slice(0, 200);
      }
      return new Response(
        JSON.stringify({
          error: "Vision API failed",
          status: visionRes.status,
          detail,
        }),
        {
          status: 502,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    const visionData = await visionRes.json();
    const visionResponse = visionData.responses?.[0];

    if (visionResponse?.error) {
      const visionError = visionResponse.error;
      console.error(
        "Vision API response error:",
        visionError.code,
        visionError.message,
      );
      return new Response(
        JSON.stringify({
          error: "Vision API failed",
          code: visionError.code,
          detail: visionError.message,
        }),
        {
          status: 502,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    const annotation = visionResponse
      ?.safeSearchAnnotation as SafeSearchAnnotation | undefined;

    if (!annotation) {
      console.error("Vision API missing safeSearchAnnotation:", visionData);
      return new Response(
        JSON.stringify({ error: "No moderation result" }),
        { status: 502, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const reasons = rejectionReasons(annotation);
    return new Response(
      JSON.stringify({ allowed: reasons.length === 0, reasons }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (error) {
    console.error("moderate-image error:", error);
    return new Response(
      JSON.stringify({ error: "Internal error" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});
