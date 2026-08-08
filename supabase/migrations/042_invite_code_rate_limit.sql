-- 042_invite_code_rate_limit: throttle join_household brute-force (M8)
--
-- Bug: join_household had no rate limiting, so an authenticated user could
-- brute-force 6-char invite codes (~2 billion space) at high speed.
--
-- Fix:
--  * Track per-user join attempts (last_attempt_at, failed_count) and lock
--    out a user after 5 failed attempts within 5 minutes.
--  * Enforce a 1-second minimum interval between any attempts.
--  * Lengthen newly generated invite codes from 6 to 8 characters
--    (generate_invite_code default). Existing codes keep their length.
--  * Invalid-code failures RETURN NULL (after persisting the attempt) so the
--    counter is committed; lockout/throttle still RAISE (read-only checks on
--    already-committed state). Callers treat NULL as an invalid invite code.

CREATE TABLE IF NOT EXISTS public.household_join_attempts (
  user_id        uuid PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
  last_attempt_at timestamptz NOT NULL DEFAULT now(),
  failed_count   int NOT NULL DEFAULT 0
);

ALTER TABLE public.household_join_attempts ENABLE ROW LEVEL SECURITY;
-- No SELECT/INSERT/UPDATE/DELETE policies: the table is only touched by the
-- SECURITY DEFINER join_household RPC (which bypasses RLS). Clients cannot
-- read or write it directly.

DROP FUNCTION IF EXISTS public.generate_invite_code(int);
CREATE FUNCTION public.generate_invite_code(code_length int DEFAULT 8)
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE
  chars text := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  result text := '';
  i int;
BEGIN
  FOR i IN 1..code_length LOOP
    result := result || substr(chars, 1 + floor(random() * length(chars))::int, 1);
  END LOOP;
  RETURN result;
END;
$$;

CREATE OR REPLACE FUNCTION public.join_household(code text)
RETURNS public.household_members
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  current_user_id uuid := auth.uid();
  target_household_id uuid;
  new_member public.household_members;
  attempt public.household_join_attempts%ROWTYPE;
  locked_until timestamptz;
BEGIN
  IF current_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  IF trim(code) = '' THEN
    RAISE EXCEPTION 'Invite code is required';
  END IF;

  -- Upsert + row lock in one statement. New rows start with last_attempt_at
  -- one second in the past so the first attempt is not throttled.
  INSERT INTO public.household_join_attempts (user_id, last_attempt_at, failed_count)
  VALUES (current_user_id, now() - interval '1 second', 0)
  ON CONFLICT (user_id) DO UPDATE
    SET user_id = EXCLUDED.user_id
  RETURNING * INTO attempt;

  -- Reset the failure window once it has elapsed (persist to the table).
  IF attempt.failed_count >= 5
     AND attempt.last_attempt_at < now() - interval '5 minutes' THEN
    UPDATE public.household_join_attempts
    SET failed_count = 0
    WHERE user_id = current_user_id
    RETURNING * INTO attempt;
  END IF;

  -- Lock out after 5 recent failures (read-only; prior failures already committed).
  IF attempt.failed_count >= 5 THEN
    locked_until := attempt.last_attempt_at + interval '5 minutes';
    RAISE EXCEPTION 'Too many attempts, try again after %',
      to_char(locked_until, 'HH24:MI');
  END IF;

  -- Throttle rapid retries (1 second minimum between attempts).
  IF attempt.last_attempt_at > now() - interval '1 second' THEN
    RAISE EXCEPTION 'Please wait a moment before trying again';
  END IF;

  SELECT h.id
  INTO target_household_id
  FROM public.households h
  WHERE upper(h.invite_code) = upper(trim(code));

  IF target_household_id IS NULL THEN
    -- Persist the failure, then return NULL so the update commits.
    -- Callers treat NULL as an invalid invite code.
    UPDATE public.household_join_attempts
    SET last_attempt_at = now(),
        failed_count = attempt.failed_count + 1
    WHERE user_id = current_user_id;
    RETURN NULL;
  END IF;

  IF EXISTS (
    SELECT 1
    FROM public.household_members hm
    WHERE hm.household_id = target_household_id
      AND hm.user_id = current_user_id
  ) THEN
    RAISE EXCEPTION 'Already a member of this household';
  END IF;

  INSERT INTO public.household_members (household_id, user_id, role)
  VALUES (target_household_id, current_user_id, 'member')
  RETURNING * INTO new_member;

  -- Success: clear the user's attempt history.
  DELETE FROM public.household_join_attempts WHERE user_id = current_user_id;

  RETURN new_member;
END;
$$;

REVOKE ALL ON FUNCTION public.join_household(text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.join_household(text) TO authenticated;
