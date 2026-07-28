import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const APP_NAME = "Böl";
const APP_SCHEME = "bol://";
const OG_WIDTH = 1200;
const OG_HEIGHT = 630;

function escapeHtml(s: string): string {
  return s
    .replaceAll("&", "&amp;")
    .replaceAll('"', "&quot;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;");
}

function html({
  title,
  description,
  pageUrl,
  imageUrl,
  appPath,
}: {
  title: string;
  description: string;
  pageUrl: string;
  imageUrl: string | null;
  appPath: string;
}): string {
  const t = escapeHtml(title);
  const d = escapeHtml(description);
  const u = escapeHtml(pageUrl);
  const img = imageUrl ? escapeHtml(imageUrl) : "";
  const appUrl = escapeHtml(`${APP_SCHEME}${appPath.replace(/^\//, "")}`);

  const imageMeta = img
    ? `
    <link rel="image_src" href="${img}" />
    <meta property="og:image" content="${img}" />
    <meta property="og:image:url" content="${img}" />
    <meta property="og:image:secure_url" content="${img}" />
    <meta property="og:image:type" content="image/jpeg" />
    <meta property="og:image:width" content="${OG_WIDTH}" />
    <meta property="og:image:height" content="${OG_HEIGHT}" />
    <meta name="twitter:card" content="summary_large_image" />
    <meta name="twitter:image" content="${img}" />`
    : `
    <meta name="twitter:card" content="summary" />`;

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
    ${imageMeta}
    <meta name="twitter:title" content="${t}" />
    <meta name="twitter:description" content="${d}" />
    <style>
      *{box-sizing:border-box}
      body{margin:0;min-height:100vh;display:grid;place-items:center;background:#f6f3ee;color:#1f1a17;font-family:"Segoe UI",system-ui,sans-serif;padding:24px}
      main{width:min(420px,100%);text-align:center}
      h1{margin:0 0 8px;font-size:2rem}
      p{margin:0 0 24px;color:#6b635c;line-height:1.5}
      a.btn{display:inline-block;background:#2f6f5e;color:#fff;text-decoration:none;padding:14px 22px;border-radius:12px;font-weight:600}
      img.preview{width:min(320px,100%);aspect-ratio:1200/630;object-fit:cover;border-radius:16px;margin:0 auto 20px;display:block}
    </style>
  </head>
  <body>
    <main>
      ${img ? `<img class="preview" src="${img}" alt="${t}" width="${OG_WIDTH}" height="${OG_HEIGHT}" />` : ""}
      <h1>${t}</h1>
      <p>${d}</p>
      <a class="btn" href="${appUrl}">Abrir en ${APP_NAME}</a>
    </main>
  </body>
</html>`;
}

function parsePath(pathname: string): { kind: string; id: string } | null {
  const parts = pathname.split("/").filter(Boolean);
  const idx = parts.indexOf("share-landing");
  const seg = idx >= 0 ? parts.slice(idx + 1) : parts;
  if (seg.length >= 2 && (seg[0] === "r" || seg[0] === "p")) {
    return { kind: seg[0], id: seg[1] };
  }
  return null;
}

async function getOgData(
  supabase: ReturnType<typeof createClient>,
  kind: string,
  id: string,
): Promise<{ title: string; hasPhoto: boolean } | null> {
  if (kind === "r") {
    const { data, error } = await supabase.rpc("get_private_share_og", {
      p_token: id,
    });
    if (error || !data?.valid) return null;
    return { title: data.title, hasPhoto: Boolean(data.photo_path) };
  }
  if (kind === "p") {
    const { data, error } = await supabase.rpc("get_public_recipe_og", {
      p_recipe_id: id,
    });
    if (error || !data?.valid) return null;
    return { title: data.title, hasPhoto: Boolean(data.photo_path) };
  }
  return null;
}

Deno.serve(async (req) => {
  if (req.method !== "GET" && req.method !== "HEAD") {
    return new Response("Method Not Allowed", { status: 405 });
  }

  const url = new URL(req.url);
  const parsed = parsePath(url.pathname);
  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

  const appPath = parsed ? `/${parsed.kind}/${parsed.id}` : "/";
  // Canonical share URL must match what users paste into WhatsApp
  const pageUrl = parsed
    ? `${supabaseUrl}/functions/v1/share-landing/${parsed.kind}/${parsed.id}`
    : `${supabaseUrl}/functions/v1/share-landing`;

  const respond = (body: string, maxAge = 60) =>
    new Response(req.method === "HEAD" ? null : body, {
      headers: {
        "Content-Type": "text/html; charset=utf-8",
        "Cache-Control": `public, max-age=${maxAge}`,
        "Access-Control-Allow-Origin": "*",
      },
    });

  if (!supabaseUrl || !serviceKey || !parsed) {
    return respond(
      html({
        title: APP_NAME,
        description: "Abriendo la receta en la app…",
        pageUrl,
        imageUrl: null,
        appPath,
      }),
    );
  }

  try {
    const supabase = createClient(supabaseUrl, serviceKey);
    const og = await getOgData(supabase, parsed.kind, parsed.id);
    if (!og) {
      return respond(
        html({
          title: APP_NAME,
          description: "Abriendo la receta en la app…",
          pageUrl,
          imageUrl: null,
          appPath,
        }),
      );
    }

    // Clean URL without query params — WhatsApp crawlers handle this better
    // than long signed storage tokens. Image is resized to 1200x630 JPEG.
    const imageUrl = og.hasPhoto
      ? `${supabaseUrl}/functions/v1/share-image/${parsed.kind}/${parsed.id}`
      : null;

    return respond(
      html({
        title: og.title,
        description: `Receta en ${APP_NAME}`,
        pageUrl,
        imageUrl,
        appPath,
      }),
      300,
    );
  } catch (error) {
    console.error("share-landing error", error);
    return respond(
      html({
        title: APP_NAME,
        description: "Abriendo la receta en la app…",
        pageUrl,
        imageUrl: null,
        appPath,
      }),
    );
  }
});
