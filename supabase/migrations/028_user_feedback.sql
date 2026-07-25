-- 028_user_feedback: app-admin flag + in-app user feedback
-- Prefer existing profiles.is_admin; drop duplicate profiles.admin if present.

ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS is_admin boolean NOT NULL DEFAULT false;

-- Merge any values from the duplicate column before dropping it.
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'profiles'
      AND column_name = 'admin'
  ) THEN
    UPDATE public.profiles
    SET is_admin = true
    WHERE admin = true AND is_admin = false;

    ALTER TABLE public.profiles DROP COLUMN admin;
  END IF;
END $$;

CREATE OR REPLACE FUNCTION public.auth_is_admin()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.profiles
    WHERE id = auth.uid()
      AND is_admin = true
  );
$$;

REVOKE ALL ON FUNCTION public.auth_is_admin() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.auth_is_admin() TO authenticated;

CREATE OR REPLACE FUNCTION public.profiles_guard_admin_column()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Allow bootstrap / service-role / SQL editor (no JWT).
  IF auth.uid() IS NULL THEN
    RETURN NEW;
  END IF;

  IF TG_OP = 'INSERT' THEN
    IF NEW.is_admin = true AND NOT public.auth_is_admin() THEN
      RAISE EXCEPTION 'cannot_change_admin_flag' USING ERRCODE = '42501';
    END IF;
    RETURN NEW;
  END IF;

  IF TG_OP = 'UPDATE'
     AND NEW.is_admin IS DISTINCT FROM OLD.is_admin
     AND NOT public.auth_is_admin() THEN
    RAISE EXCEPTION 'cannot_change_admin_flag' USING ERRCODE = '42501';
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS profiles_guard_admin ON public.profiles;
CREATE TRIGGER profiles_guard_admin
  BEFORE INSERT OR UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.profiles_guard_admin_column();

DO $$ BEGIN
  CREATE POLICY "profiles_select_admin"
    ON public.profiles FOR SELECT
    TO authenticated
    USING (public.auth_is_admin());
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

CREATE TABLE IF NOT EXISTS public.user_feedback (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  category   text NOT NULL CHECK (category IN ('issue', 'feature', 'other')),
  message    text NOT NULL CHECK (char_length(trim(message)) >= 10),
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_user_feedback_created
  ON public.user_feedback (created_at DESC);

ALTER TABLE public.user_feedback ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  CREATE POLICY user_feedback_insert ON public.user_feedback
    FOR INSERT TO authenticated
    WITH CHECK (user_id = auth.uid());
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE POLICY user_feedback_select_own ON public.user_feedback
    FOR SELECT TO authenticated
    USING (user_id = auth.uid());
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE POLICY user_feedback_select_admin ON public.user_feedback
    FOR SELECT TO authenticated
    USING (public.auth_is_admin());
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;
