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

/**
 * Reads AI quota env limits, validates them, and calls
 * check_and_increment_ai_usage. On failure returns a ready-made Response
 * (503 for misconfig/RPC errors, 429/503 for quota denials).
 */
export async function enforceAiQuota(
  adminClient: SupabaseClient,
  userId: string,
  corsHeaders: CorsHeaders,
): Promise<QuotaCheckResult> {
  const dailyLimit = Number(Deno.env.get("AI_ASSISTANT_DAILY_LIMIT") ?? "20");
  const minInterval = Number(
    Deno.env.get("AI_ASSISTANT_MIN_INTERVAL_SECONDS") ?? "3",
  );
  const globalLimitRaw = Deno.env.get("AI_ASSISTANT_GLOBAL_DAILY_LIMIT");
  const globalLimit = globalLimitRaw ? Number(globalLimitRaw) : null;

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
  if (
    globalLimit !== null &&
    (!Number.isFinite(globalLimit) || globalLimit <= 0)
  ) {
    console.error("Invalid AI_ASSISTANT_GLOBAL_DAILY_LIMIT:", globalLimit);
    return {
      ok: false,
      response: new Response(JSON.stringify({ error: "quota_check_failed" }), {
        status: 503,
        headers: jsonHeaders,
      }),
    };
  }

  const { data: quotaRows, error: quotaError } = await adminClient.rpc(
    "check_and_increment_ai_usage",
    {
      p_user_id: userId,
      p_daily_limit: dailyLimit,
      p_min_interval_seconds: minInterval,
      p_global_daily_limit: globalLimit,
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
