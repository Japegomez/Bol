-- Fix duplicate admin columns: keep profiles.is_admin, drop profiles.admin

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
