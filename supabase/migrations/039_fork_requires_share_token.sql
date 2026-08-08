-- 039_fork_requires_share_token: close fork-without-token bypass (H1)
--
-- Bug: fork_recipe_into_my_book treated "has any active share link" as
-- sufficient authorization, so (combined with C2) any user could permanently
-- copy every privately shared recipe without knowing the share URL.
--
-- Fix: add an optional p_share_token parameter. When the recipe is not public
-- and not from a household co-member, the caller MUST supply the token of an
-- active share link for that recipe.

DROP FUNCTION IF EXISTS public.fork_recipe_into_my_book(uuid);

CREATE FUNCTION public.fork_recipe_into_my_book(
  p_source_recipe_id uuid,
  p_share_token text DEFAULT NULL
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  current_user_id uuid := auth.uid();
  source public.recipes;
  new_id uuid;
BEGIN
  IF current_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  SELECT *
  INTO source
  FROM public.recipes r
  WHERE r.id = p_source_recipe_id;

  IF source.id IS NULL THEN
    RAISE EXCEPTION 'Recipe not found';
  END IF;

  IF source.user_id = current_user_id THEN
    RAISE EXCEPTION 'Cannot fork own recipe';
  END IF;

  IF NOT (
    source.is_public = true
    OR public.shares_household_with(source.user_id)
    OR EXISTS (
      SELECT 1
      FROM public.recipe_share_links s
      WHERE s.recipe_id = source.id
        AND s.expires_at > now()
        AND (
          p_share_token IS NOT NULL
          AND s.token = trim(p_share_token)
        )
    )
  ) THEN
    RAISE EXCEPTION 'Recipe not accessible';
  END IF;

  INSERT INTO public.recipes (
    user_id,
    title,
    servings,
    prep_time,
    cook_time,
    tags,
    is_public,
    tips,
    forked_from_id,
    source_lang
  )
  VALUES (
    current_user_id,
    source.title,
    source.servings,
    source.prep_time,
    source.cook_time,
    source.tags,
    false,
    source.tips,
    source.id,
    COALESCE(source.source_lang, 'es')
  )
  RETURNING id INTO new_id;

  INSERT INTO public.ingredients (
    recipe_id,
    name,
    quantity,
    unit,
    category,
    position,
    is_optional,
    is_included,
    is_to_taste
  )
  SELECT
    new_id,
    i.name,
    i.quantity,
    i.unit,
    i.category,
    i.position,
    COALESCE(i.is_optional, false),
    COALESCE(i.is_included, true),
    COALESCE(i.is_to_taste, false)
  FROM public.ingredients i
  WHERE i.recipe_id = source.id
  ORDER BY i.position;

  INSERT INTO public.recipe_steps (
    recipe_id,
    position,
    description,
    is_optional
  )
  SELECT
    new_id,
    s.position,
    s.description,
    COALESCE(s.is_optional, false)
  FROM public.recipe_steps s
  WHERE s.recipe_id = source.id
  ORDER BY s.position;

  INSERT INTO public.nutrition_info (
    recipe_id,
    calories,
    protein,
    carbohydrates,
    fat,
    fiber
  )
  SELECT
    new_id,
    n.calories,
    n.protein,
    n.carbohydrates,
    n.fat,
    n.fiber
  FROM public.nutrition_info n
  WHERE n.recipe_id = source.id;

  RETURN new_id;
END;
$$;

REVOKE ALL ON FUNCTION public.fork_recipe_into_my_book(uuid, text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.fork_recipe_into_my_book(uuid, text) TO authenticated;
