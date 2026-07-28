-- 032_share_og_metadata: public OG metadata for WhatsApp/link previews (no auth)

CREATE OR REPLACE FUNCTION public.get_private_share_og(p_token text)
RETURNS json
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  result json;
BEGIN
  IF p_token IS NULL OR trim(p_token) = '' THEN
    RETURN json_build_object('valid', false);
  END IF;

  SELECT json_build_object(
    'valid', true,
    'title', r.title,
    'photo_path', r.photo_url
  )
  INTO result
  FROM public.recipe_share_links s
  JOIN public.recipes r ON r.id = s.recipe_id
  WHERE s.token = trim(p_token)
    AND s.expires_at > now()
  LIMIT 1;

  RETURN coalesce(result, json_build_object('valid', false));
END;
$$;

CREATE OR REPLACE FUNCTION public.get_public_recipe_og(p_recipe_id uuid)
RETURNS json
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  result json;
BEGIN
  IF p_recipe_id IS NULL THEN
    RETURN json_build_object('valid', false);
  END IF;

  SELECT json_build_object(
    'valid', true,
    'title', r.title,
    'photo_path', r.photo_url
  )
  INTO result
  FROM public.recipes r
  WHERE r.id = p_recipe_id
    AND r.is_public = true
  LIMIT 1;

  RETURN coalesce(result, json_build_object('valid', false));
END;
$$;

REVOKE ALL ON FUNCTION public.get_private_share_og(text) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.get_public_recipe_og(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.get_private_share_og(text) TO service_role;
GRANT EXECUTE ON FUNCTION public.get_public_recipe_og(uuid) TO service_role;
