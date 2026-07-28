import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";
import { Image } from "https://deno.land/x/imagescript@1.3.0/mod.ts";

const OG_WIDTH = 1200;
const OG_HEIGHT = 630;

function parsePath(pathname: string): { kind: string; id: string } | null {
  const parts = pathname.split("/").filter(Boolean);
  const idx = parts.indexOf("share-image");
  const seg = idx >= 0 ? parts.slice(idx + 1) : parts;
  if (seg.length >= 2 && (seg[0] === "r" || seg[0] === "p")) {
    return { kind: seg[0], id: seg[1] };
  }
  return null;
}

async function resolvePhotoPath(
  supabase: ReturnType<typeof createClient>,
  kind: string,
  id: string,
): Promise<string | null> {
  if (kind === "r") {
    const { data, error } = await supabase.rpc("get_private_share_og", {
      p_token: id,
    });
    if (error || !data?.valid || !data.photo_path) return null;
    return data.photo_path as string;
  }
  if (kind === "p") {
    const { data, error } = await supabase.rpc("get_public_recipe_og", {
      p_recipe_id: id,
    });
    if (error || !data?.valid || !data.photo_path) return null;
    return data.photo_path as string;
  }
  return null;
}

/** Cover-crop resize to WhatsApp-friendly 1200x630 JPEG. */
async function toOgJpeg(bytes: Uint8Array): Promise<Uint8Array> {
  const image = await Image.decode(bytes);
  const scale = Math.max(OG_WIDTH / image.width, OG_HEIGHT / image.height);
  const resized = image.resize(
    Math.max(1, Math.round(image.width * scale)),
    Math.max(1, Math.round(image.height * scale)),
  );
  const x = Math.max(0, Math.floor((resized.width - OG_WIDTH) / 2));
  const y = Math.max(0, Math.floor((resized.height - OG_HEIGHT) / 2));
  const cropped = resized.crop(x, y, OG_WIDTH, OG_HEIGHT);
  return await cropped.encodeJPEG(85);
}

Deno.serve(async (req) => {
  if (req.method !== "GET" && req.method !== "HEAD") {
    return new Response("Method Not Allowed", { status: 405 });
  }

  const parsed = parsePath(new URL(req.url).pathname);
  if (!parsed) return new Response("Not found", { status: 404 });

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!supabaseUrl || !serviceKey) {
    return new Response("Not configured", { status: 503 });
  }

  try {
    const supabase = createClient(supabaseUrl, serviceKey);
    const photoPath = await resolvePhotoPath(supabase, parsed.kind, parsed.id);
    if (!photoPath) return new Response("Not found", { status: 404 });

    const { data, error } = await supabase.storage
      .from("recipe-photos")
      .download(photoPath);
    if (error || !data) return new Response("Not found", { status: 404 });

    const original = new Uint8Array(await data.arrayBuffer());
    let jpeg: Uint8Array;
    try {
      jpeg = await toOgJpeg(original);
    } catch (resizeError) {
      console.error("share-image resize failed, serving original", resizeError);
      jpeg = original;
    }

    return new Response(req.method === "HEAD" ? null : jpeg, {
      headers: {
        "Content-Type": "image/jpeg",
        "Content-Disposition": "inline; filename=\"og.jpg\"",
        "Cache-Control": "public, max-age=86400, s-maxage=86400",
        "Access-Control-Allow-Origin": "*",
      },
    });
  } catch (error) {
    console.error("share-image error", error);
    return new Response("Error", { status: 500 });
  }
});
