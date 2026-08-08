import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const APP_NAME = "Böl";
const FIREBASE_HOST = "https://mealplanner-a818e.web.app";
const OG_BUCKET = "share-og";
const PLAY_STORE_URL =
  "https://play.google.com/store/apps/details?id=com.japegomez.meal_planner";

function escapeHtml(s: string): string {
  return s
    .replaceAll("&", "&amp;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#39;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;");
}

function html({
  title,
  description,
  pageUrl,
}: {
  title: string;
  description: string;
  pageUrl: string;
}): string {
  const t = escapeHtml(title);
  const d = escapeHtml(description);
  const u = escapeHtml(pageUrl);
  const playUrl = escapeHtml(PLAY_STORE_URL);

  return `<!DOCTYPE html>
<html lang="es" prefix="og: https://ogp.me/ns#">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>${t}</title>
    <meta name="description" content="${d}" />
    <meta property="og:locale" content="es_ES" />
    <meta property="og:type" content="article" />
    <meta property="og:site_name" content="${APP_NAME}" />
    <meta property="og:title" content="${t}" />
    <meta property="og:description" content="${d}" />
    <meta property="og:url" content="${u}" />
    <meta name="twitter:card" content="summary" />
    <meta name="twitter:title" content="${t}" />
    <meta name="twitter:description" content="${d}" />
    <style>
      *{box-sizing:border-box}
      body{margin:0;min-height:100vh;display:grid;place-items:center;background:#f6f3ee;color:#1f1a17;font-family:"Segoe UI",system-ui,sans-serif;padding:24px}
      main{width:min(420px,100%);text-align:center}
      h1{margin:0 0 8px;font-size:2rem}
      p{margin:0 0 24px;color:#6b635c;line-height:1.5}
      .actions{display:flex;flex-direction:column;gap:12px;align-items:center}
      a.btn{display:inline-block;background:#2f6f5e;color:#fff;text-decoration:none;padding:14px 22px;border-radius:12px;font-weight:600}
      .hint{margin-top:8px;font-size:0.9rem;color:#6b635c}
    </style>
  </head>
  <body>
    <main>
      <h1>${t}</h1>
      <p>${d}</p>
      <div class="actions">
        <a class="btn" href="${playUrl}">Instalar la app</a>
      </div>
      <p class="hint">Si no tienes la app, instálala y vuelve a abrir este enlace.</p>
    </main>
  </body>
</html>`;
}

function parsePath(pathname: string): { kind: string; id: string } | null {
  const parts = pathname.split("/").filter(Boolean);
  const idx = parts.indexOf("share-landing");
  const seg = idx >= 0 ? parts.slice(idx + 1) : parts;
  if (seg.length >= 2 && (seg[0] === "r" || seg[0] === "p" || seg[0] === "h")) {
    return { kind: seg[0], id: seg[1] };
  }
  return null;
}

async function getOgTitle(
  supabase: ReturnType<typeof createClient>,
  kind: string,
  id: string,
): Promise<string | null> {
  if (kind === "r") {
    const { data, error } = await supabase.rpc("get_private_share_og", {
      p_token: id,
    });
    if (error || !data?.valid) return null;
    return data.title as string;
  }
  if (kind === "p") {
    const { data, error } = await supabase.rpc("get_public_recipe_og", {
      p_recipe_id: id,
    });
    if (error || !data?.valid) return null;
    return data.title as string;
  }
  if (kind === "h") {
    const { data, error } = await supabase.rpc("get_household_invite_og", {
      p_code: id,
    });
    if (error || !data?.valid) return null;
    return data.title as string;
  }
  return null;
}

/** Publish HTML to Storage (real text/html) and redirect crawlers there. */
async function publishAndRedirect(
  supabase: ReturnType<typeof createClient>,
  supabaseUrl: string,
  kind: string,
  id: string,
  body: string,
): Promise<Response> {
  const objectPath = `${kind}/${id}.html`;
  const bytes = new TextEncoder().encode(body);
  const { error } = await supabase.storage.from(OG_BUCKET).upload(
    objectPath,
    bytes,
    {
      contentType: "text/html",
      upsert: true,
      cacheControl: "300",
    },
  );
  if (error) {
    console.error("share-og upload failed", error);
    return new Response(
      `Preview temporarily unavailable (${error.message}). Install Böl and open the link again.`,
      { status: 502, headers: { "Content-Type": "text/plain; charset=utf-8" } },
    );
  }

  const publicUrl =
    `${supabaseUrl}/storage/v1/object/public/${OG_BUCKET}/${objectPath}`;
  return new Response(null, {
    status: 302,
    headers: {
      Location: publicUrl,
      "Cache-Control": "public, max-age=60",
      "Access-Control-Allow-Origin": "*",
    },
  });
}

Deno.serve(async (req) => {
  if (req.method !== "GET" && req.method !== "HEAD") {
    return new Response("Method Not Allowed", { status: 405 });
  }

  const url = new URL(req.url);
  const parsed = parsePath(url.pathname);
  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

  if (!supabaseUrl || !serviceKey || !parsed) {
    return new Response("Not found", { status: 404 });
  }

  const pageUrl = `${FIREBASE_HOST}/${parsed.kind}/${parsed.id}`;

  try {
    const supabase = createClient(supabaseUrl, serviceKey);
    const title = await getOgTitle(supabase, parsed.kind, parsed.id);
    if (title == null) {
      return new Response("Not found", { status: 404 });
    }

    const description = parsed.kind === "h"
      ? `Invitación a un hogar en ${APP_NAME}`
      : `Receta en ${APP_NAME}`;

    const body = html({
      title,
      description,
      pageUrl,
    });

    return await publishAndRedirect(
      supabase,
      supabaseUrl,
      parsed.kind,
      parsed.id,
      body,
    );
  } catch (error) {
    console.error("share-landing error", error);
    return new Response("Error", { status: 500 });
  }
});
