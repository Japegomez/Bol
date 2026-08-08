-- 036_household_invite_og: OG metadata for household invite deep links.

CREATE OR REPLACE FUNCTION public.get_household_invite_og(p_code text)
RETURNS json
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  result json;
BEGIN
  IF p_code IS NULL OR trim(p_code) = '' THEN
    RETURN json_build_object('valid', false);
  END IF;

  SELECT json_build_object(
    'valid', true,
    'title', format('Únete a %s en Böl', h.name)
  )
  INTO result
  FROM public.households h
  WHERE upper(h.invite_code) = upper(trim(p_code))
  LIMIT 1;

  RETURN coalesce(result, json_build_object('valid', false));
END;
$$;

REVOKE ALL ON FUNCTION public.get_household_invite_og(text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.get_household_invite_og(text) TO service_role;
