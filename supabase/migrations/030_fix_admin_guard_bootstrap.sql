-- Allow bootstrapping profiles.is_admin from SQL editor / service role.
-- Also reject client INSERT/UPDATE that set is_admin without authorization.

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
