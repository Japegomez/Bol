-- 045_ai_assistant_ip_usage: high daily cap per client IP (defense in depth)
--
-- Complements per-user and global quotas. Stores a SHA-256 hash of the IP
-- (hashed in the Edge Function), never the raw address.
-- Exhausted IPs return service_at_capacity (same as the global cap) so the
-- client does not surface an "IP blocked" message.
-- Missing p_ip_hash skips this gate (local/dev without forwarded headers).

CREATE TABLE IF NOT EXISTS public.ai_assistant_ip_usage (
  ip_hash        text NOT NULL,
  usage_date     date NOT NULL,
  request_count  integer NOT NULL DEFAULT 0,
  PRIMARY KEY (ip_hash, usage_date)
);

ALTER TABLE public.ai_assistant_ip_usage ENABLE ROW LEVEL SECURITY;
-- No policies: only the SECURITY DEFINER RPC (service_role) touches this table.

DROP FUNCTION IF EXISTS public.check_and_increment_ai_usage(uuid, integer, integer, integer);

CREATE FUNCTION public.check_and_increment_ai_usage(
  p_user_id              uuid,
  p_daily_limit          integer,
  p_min_interval_seconds integer DEFAULT 5,
  p_global_daily_limit   integer DEFAULT NULL,
  p_ip_hash              text DEFAULT NULL,
  p_ip_daily_limit       integer DEFAULT NULL
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
  v_ip_count          integer;
  v_elapsed_seconds   numeric;
  v_retry_after       integer;
  v_ip_hash           text;
BEGIN
  IF p_daily_limit IS NULL OR p_daily_limit <= 0 THEN
    RAISE EXCEPTION 'p_daily_limit must be a positive integer, got: %', p_daily_limit;
  END IF;

  IF p_min_interval_seconds IS NULL OR p_min_interval_seconds < 0 THEN
    RAISE EXCEPTION 'p_min_interval_seconds must be non-negative, got: %', p_min_interval_seconds;
  END IF;

  IF p_global_daily_limit IS NOT NULL AND p_global_daily_limit <= 0 THEN
    RAISE EXCEPTION 'p_global_daily_limit must be NULL or a positive integer, got: %', p_global_daily_limit;
  END IF;

  IF p_ip_daily_limit IS NOT NULL AND p_ip_daily_limit <= 0 THEN
    RAISE EXCEPTION 'p_ip_daily_limit must be NULL or a positive integer, got: %', p_ip_daily_limit;
  END IF;

  v_ip_hash := nullif(trim(p_ip_hash), '');

  INSERT INTO public.ai_assistant_usage (user_id, usage_date, request_count, last_request_at)
  VALUES (p_user_id, v_today, 0, NULL)
  ON CONFLICT (user_id, usage_date) DO NOTHING;

  SELECT u.request_count, u.last_request_at
    INTO v_user_count, v_last_request_at
    FROM public.ai_assistant_usage u
   WHERE u.user_id = p_user_id AND u.usage_date = v_today
     FOR UPDATE;

  IF v_user_count >= p_daily_limit THEN
    RETURN QUERY SELECT false, 'daily_limit_reached'::text, 0, 0;
    RETURN;
  END IF;

  IF v_last_request_at IS NOT NULL AND p_min_interval_seconds > 0 THEN
    v_elapsed_seconds := EXTRACT(EPOCH FROM (v_now - v_last_request_at));
    IF v_elapsed_seconds < p_min_interval_seconds THEN
      v_retry_after := ceil(p_min_interval_seconds - v_elapsed_seconds)::integer;
      RETURN QUERY SELECT false, 'too_fast'::text, (p_daily_limit - v_user_count), v_retry_after;
      RETURN;
    END IF;
  END IF;

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
  END IF;

  IF v_ip_hash IS NOT NULL AND p_ip_daily_limit IS NOT NULL THEN
    INSERT INTO public.ai_assistant_ip_usage (ip_hash, usage_date, request_count)
    VALUES (v_ip_hash, v_today, 0)
    ON CONFLICT (ip_hash, usage_date) DO NOTHING;

    SELECT i.request_count
      INTO v_ip_count
      FROM public.ai_assistant_ip_usage i
     WHERE i.ip_hash = v_ip_hash AND i.usage_date = v_today
       FOR UPDATE;

    IF v_ip_count >= p_ip_daily_limit THEN
      RETURN QUERY SELECT false, 'service_at_capacity'::text, (p_daily_limit - v_user_count), 0;
      RETURN;
    END IF;
  END IF;

  IF p_global_daily_limit IS NOT NULL THEN
    UPDATE public.ai_assistant_global_usage
       SET request_count = request_count + 1
     WHERE usage_date = v_today;
  END IF;

  IF v_ip_hash IS NOT NULL AND p_ip_daily_limit IS NOT NULL THEN
    UPDATE public.ai_assistant_ip_usage
       SET request_count = request_count + 1
     WHERE ip_hash = v_ip_hash AND usage_date = v_today;
  END IF;

  UPDATE public.ai_assistant_usage
     SET request_count   = request_count + 1,
         last_request_at = v_now
   WHERE user_id = p_user_id AND usage_date = v_today;

  RETURN QUERY SELECT true, NULL::text, (p_daily_limit - v_user_count - 1), 0;
END;
$$;

REVOKE ALL ON FUNCTION public.check_and_increment_ai_usage(uuid, integer, integer, integer, text, integer)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.check_and_increment_ai_usage(uuid, integer, integer, integer, text, integer)
  TO service_role;
