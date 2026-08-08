-- 038_fix_share_link_token_gate: token-gate private share reads (C2)
--
-- Bug: 027_share_link_rls_definer granted SELECT on every recipe that has ANY
-- active share link to every authenticated user, with no token check. Anyone
-- could `SELECT * FROM recipes` and read all privately shared recipes plus
-- their ingredients/steps/nutrition. The opaque share token was effectively
-- unused for read access.
--
-- Fix: a single SECURITY DEFINER RPC returns the full recipe payload only when
-- the caller supplies a valid, unexpired token. The open SELECT policies on
-- recipes/ingredients/recipe_steps/nutrition_info (and the photo policy) are
-- dropped, so the token is the only way to read a privately shared recipe.
--
-- Note: shared-recipe photos currently rely on `recipe_photos_select_active_share`
-- for client-side signed-URL creation. Dropping it means shared recipes display
-- without a photo via the standard path. Restore photo support later via a
-- token-gated edge function that signs the photo URL.

CREATE OR REPLACE FUNCTION public.get_shared_recipe(p_token text)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  current_user_id uuid := auth.uid();
  link public.recipe_share_links;
  r public.recipes;
  ingredients_json jsonb;
  steps_json jsonb;
  nutrition_json jsonb;
BEGIN
  IF current_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  IF p_token IS NULL OR trim(p_token) = '' THEN
    RAISE EXCEPTION 'Invalid share link';
  END IF;

  SELECT *
  INTO link
  FROM public.recipe_share_links s
  WHERE s.token = trim(p_token)
  LIMIT 1;

  IF link.id IS NULL THEN
    RAISE EXCEPTION 'Invalid share link';
  END IF;

  IF link.expires_at <= now() THEN
    RAISE EXCEPTION 'Share link expired';
  END IF;

  SELECT *
  INTO r
  FROM public.recipes
  WHERE id = link.recipe_id;

  IF r.id IS NULL THEN
    RAISE EXCEPTION 'Recipe not found';
  END IF;

  SELECT COALESCE(
    jsonb_agg(
      jsonb_build_object(
        'id', i.id,
        'recipe_id', i.recipe_id,
        'name', i.name,
        'quantity', i.quantity,
        'unit', i.unit,
        'category', i.category,
        'position', i.position,
        'is_optional', COALESCE(i.is_optional, false),
        'is_included', COALESCE(i.is_included, true),
        'is_to_taste', COALESCE(i.is_to_taste, false)
      )
      ORDER BY i.position
    ),
    '[]'::jsonb
  )
  INTO ingredients_json
  FROM public.ingredients i
  WHERE i.recipe_id = r.id;

  SELECT COALESCE(
    jsonb_agg(
      jsonb_build_object(
        'id', s.id,
        'recipe_id', s.recipe_id,
        'position', s.position,
        'description', s.description,
        'is_optional', COALESCE(s.is_optional, false)
      )
      ORDER BY s.position
    ),
    '[]'::jsonb
  )
  INTO steps_json
  FROM public.recipe_steps s
  WHERE s.recipe_id = r.id;

  SELECT to_jsonb(n) - 'id'
  INTO nutrition_json
  FROM public.nutrition_info n
  WHERE n.recipe_id = r.id
  LIMIT 1;

  RETURN jsonb_build_object(
    'recipe', to_jsonb(r),
    'ingredients', ingredients_json,
    'steps', steps_json,
    'nutrition', nutrition_json,
    'photo_url', r.photo_url
  );
END;
$$;

REVOKE ALL ON FUNCTION public.get_shared_recipe(text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.get_shared_recipe(text) TO authenticated;

-- Drop the open SELECT policies that let any authenticated user read any
-- actively-shared recipe without the token.
DROP POLICY IF EXISTS "recipes_select_active_share" ON public.recipes;
DROP POLICY IF EXISTS "ingredients_select_active_share_recipe" ON public.ingredients;
DROP POLICY IF EXISTS "recipe_steps_select_active_share_recipe" ON public.recipe_steps;
DROP POLICY IF EXISTS "nutrition_info_select_active_share_recipe" ON public.nutrition_info;
DROP POLICY IF EXISTS "recipe_photos_select_active_share" ON storage.objects;

-- resolve_recipe_share is retained: it only returns a recipe id for a valid
-- token and exposes no recipe content. get_shared_recipe supersedes it for
-- reading the full payload.
