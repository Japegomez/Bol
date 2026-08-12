import type { SupabaseClient } from "jsr:@supabase/supabase-js@2";

export type QuotaRow = {
  allowed: boolean;
  reason: string | null;
  remaining: number;
  retry_after_seconds: number;
};

export type QuotaCheckResult =
  | { ok: true; quota: QuotaRow }
  | { ok: false; response: Response };

type CorsHeaders = Record<string, string>;

/** First hop in X-Forwarded-For, else X-Real-IP / CF-Connecting-IP. */
export function clientIpFromRequest(req: Request): string | null {
  const forwarded = req.headers.get("x-forwarded-for");
  if (forwarded) {
    const first = forwarded.split(",")[0]?.trim();
    if (first) return first;
  }
  const realIp = req.headers.get("x-real-ip")?.trim();
  if (realIp) return realIp;
  const cfIp = req.headers.get("cf-connecting-ip")?.trim();
  if (cfIp) return cfIp;
  return null;
}

export async function sha256Hex(value: string): Promise<string> {
  const digest = await crypto.subtle.digest(
    "SHA-256",
    new TextEncoder().encode(value),
  );
  return [...new Uint8Array(digest)]
    .map((byte) => byte.toString(16).padStart(2, "0"))
    .join("");
}

/**
 * Reads AI quota env limits, validates them, and calls
 * check_and_increment_ai_usage. On failure returns a ready-made Response
 * (503 for misconfig/RPC errors, 429/503 for quota denials).
 *
 * IP hashes are stored instead of raw addresses. Missing IP skips the IP gate.
 * IP exhaustion uses the same `service_at_capacity` code as the global cap.
 */
export async function enforceAiQuota(
  adminClient: SupabaseClient,
  userId: string,
  corsHeaders: CorsHeaders,
  req: Request,
): Promise<QuotaCheckResult> {
  const dailyLimit = Number(Deno.env.get("AI_ASSISTANT_DAILY_LIMIT") ?? "20");
  const minInterval = Number(
    Deno.env.get("AI_ASSISTANT_MIN_INTERVAL_SECONDS") ?? "5",
  );
  const globalLimit = Number(
    Deno.env.get("AI_ASSISTANT_GLOBAL_DAILY_LIMIT") ?? "500",
  );
  const ipDailyLimit = Number(
    Deno.env.get("AI_ASSISTANT_IP_DAILY_LIMIT") ?? "50",
  );

  const jsonHeaders = { ...corsHeaders, "Content-Type": "application/json" };

  if (!Number.isFinite(dailyLimit) || dailyLimit <= 0) {
    console.error("Invalid AI_ASSISTANT_DAILY_LIMIT:", dailyLimit);
    return {
      ok: false,
      response: new Response(JSON.stringify({ error: "quota_check_failed" }), {
        status: 503,
        headers: jsonHeaders,
      }),
    };
  }
  if (!Number.isFinite(minInterval) || minInterval < 0) {
    console.error("Invalid AI_ASSISTANT_MIN_INTERVAL_SECONDS:", minInterval);
    return {
      ok: false,
      response: new Response(JSON.stringify({ error: "quota_check_failed" }), {
        status: 503,
        headers: jsonHeaders,
      }),
    };
  }
  if (!Number.isFinite(globalLimit) || globalLimit <= 0) {
    console.error("Invalid AI_ASSISTANT_GLOBAL_DAILY_LIMIT:", globalLimit);
    return {
      ok: false,
      response: new Response(JSON.stringify({ error: "quota_check_failed" }), {
        status: 503,
        headers: jsonHeaders,
      }),
    };
  }
  if (!Number.isFinite(ipDailyLimit) || ipDailyLimit <= 0) {
    console.error("Invalid AI_ASSISTANT_IP_DAILY_LIMIT:", ipDailyLimit);
    return {
      ok: false,
      response: new Response(JSON.stringify({ error: "quota_check_failed" }), {
        status: 503,
        headers: jsonHeaders,
      }),
    };
  }

  const ip = clientIpFromRequest(req);
  const ipHash = ip ? await sha256Hex(ip) : null;

  const { data: quotaRows, error: quotaError } = await adminClient.rpc(
    "check_and_increment_ai_usage",
    {
      p_user_id: userId,
      p_daily_limit: dailyLimit,
      p_min_interval_seconds: minInterval,
      p_global_daily_limit: globalLimit,
      p_ip_hash: ipHash,
      p_ip_daily_limit: ipHash ? ipDailyLimit : null,
    },
  );

  if (quotaError || !quotaRows || (quotaRows as QuotaRow[]).length === 0) {
    console.error("quota check error:", quotaError);
    return {
      ok: false,
      response: new Response(JSON.stringify({ error: "quota_check_failed" }), {
        status: 503,
        headers: jsonHeaders,
      }),
    };
  }

  const quota = (quotaRows as QuotaRow[])[0];
  if (!quota.allowed) {
    const status = quota.reason === "service_at_capacity" ? 503 : 429;
    return {
      ok: false,
      response: new Response(JSON.stringify({ error: quota.reason }), {
        status,
        headers: jsonHeaders,
      }),
    };
  }

  return { ok: true, quota };
}
