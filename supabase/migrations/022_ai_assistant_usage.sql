-- 022_ai_assistant_usage: per-user and global daily quota tracking for the AI assistant.
-- Access is restricted to service_role via a SECURITY DEFINER RPC; no RLS policies are exposed
-- to authenticated or anon roles.

CREATE TABLE public.ai_assistant_usage (
  user_id          uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  usage_date       date NOT NULL,
  request_count    integer NOT NULL DEFAULT 0,
  last_request_at  timestamptz,
  PRIMARY KEY (user_id, usage_date)
);

CREATE TABLE public.ai_assistant_global_usage (
  usage_date     date PRIMARY KEY,
  request_count  integer NOT NULL DEFAULT 0
);

ALTER TABLE public.ai_assistant_usage ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_assistant_global_usage ENABLE ROW LEVEL SECURITY;

-- ─────────────────────────────────────────────────────────────────────────────
-- RPC: check_and_increment_ai_usage
--
-- Atomically checks three gates in a single transaction (row-level FOR UPDATE
-- prevents race conditions under concurrent requests):
--   1. Burst cooldown  — rejects if last_request_at < p_min_interval_seconds ago.
--   2. Per-user limit  — rejects if user's daily count >= p_daily_limit.
--   3. Global cap      — rejects if today's global count >= p_global_daily_limit
--                        (only when p_global_daily_limit IS NOT NULL).
-- On success, increments both counters atomically.
-- On any rejection, no counters are touched.
--
-- Returns a single row:
--   allowed               bool    — whether the request may proceed
--   reason                text    — NULL (allowed) | 'too_fast' | 'daily_limit_reached' | 'service_at_capacity'
--   remaining             integer — requests remaining for the user today (post-increment when allowed)
--   retry_after_seconds   integer — seconds until cooldown expires (only meaningful for 'too_fast')
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.check_and_increment_ai_usage(
  p_user_id              uuid,
  p_daily_limit          integer,
  p_min_interval_seconds integer DEFAULT 3,
  p_global_daily_limit   integer DEFAULT NULL
)
RETURNS TABLE(
  allowed               boolean,
  reason                text,
  remaining             integer,
  retry_after_seconds   integer
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_today             date    := current_date;
  v_now               timestamptz := now();
  v_user_count        integer;
  v_last_request_at   timestamptz;
  v_global_count      integer;
  v_elapsed_seconds   numeric;
  v_retry_after       integer;
BEGIN
  -- ── Gate 1 & 2: per-user row ──────────────────────────────────────────────
  INSERT INTO public.ai_assistant_usage (user_id, usage_date, request_count, last_request_at)
  VALUES (p_user_id, v_today, 0, NULL)
  ON CONFLICT (user_id, usage_date) DO NOTHING;

  SELECT u.request_count, u.last_request_at
    INTO v_user_count, v_last_request_at
    FROM public.ai_assistant_usage u
   WHERE u.user_id = p_user_id AND u.usage_date = v_today
     FOR UPDATE;

  -- Gate 1: burst cooldown
  IF v_last_request_at IS NOT NULL AND p_min_interval_seconds > 0 THEN
    v_elapsed_seconds := EXTRACT(EPOCH FROM (v_now - v_last_request_at));
    IF v_elapsed_seconds < p_min_interval_seconds THEN
      v_retry_after := ceil(p_min_interval_seconds - v_elapsed_seconds)::integer;
      RETURN QUERY SELECT false, 'too_fast'::text, (p_daily_limit - v_user_count), v_retry_after;
      RETURN;
    END IF;
  END IF;

  -- Gate 2: daily per-user limit
  IF v_user_count >= p_daily_limit THEN
    RETURN QUERY SELECT false, 'daily_limit_reached'::text, 0, 0;
    RETURN;
  END IF;

  -- ── Gate 3: global cap (only when p_global_daily_limit is set) ────────────
  IF p_global_daily_limit IS NOT NULL THEN
    INSERT INTO public.ai_assistant_global_usage (usage_date, request_count)
    VALUES (v_today, 0)
    ON CONFLICT (usage_date) DO NOTHING;

    SELECT g.request_count
      INTO v_global_count
      FROM public.ai_assistant_global_usage g
     WHERE g.usage_date = v_today
       FOR UPDATE;

    IF v_global_count >= p_global_daily_limit THEN
      RETURN QUERY SELECT false, 'service_at_capacity'::text, (p_daily_limit - v_user_count), 0;
      RETURN;
    END IF;

    -- Increment global counter
    UPDATE public.ai_assistant_global_usage
       SET request_count = request_count + 1
     WHERE usage_date = v_today;
  END IF;

  -- ── All gates passed: increment user counter ───────────────────────────────
  UPDATE public.ai_assistant_usage
     SET request_count   = request_count + 1,
         last_request_at = v_now
   WHERE user_id = p_user_id AND usage_date = v_today;

  RETURN QUERY SELECT true, NULL::text, (p_daily_limit - v_user_count - 1), 0;
END;
$$;

-- Only service_role (used by the Edge Function via the service key) may call this function.
-- Revoke from PUBLIC first, then grant narrowly.
REVOKE ALL ON FUNCTION public.check_and_increment_ai_usage(uuid, integer, integer, integer) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.check_and_increment_ai_usage(uuid, integer, integer, integer) TO service_role;
