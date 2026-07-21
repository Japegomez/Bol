-- 026: harden household shopping rebuild + fork RPC; lock down internal RPCs

-- ── Preserve is_checked when rebuilding auto shopping items ─────────────────

CREATE OR REPLACE FUNCTION public.rebuild_shopping_from_plans(
  p_household_id uuid DEFAULT NULL,
  p_user_id uuid DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  week_from date := public.current_week_monday();
  list_id uuid;
BEGIN
  IF (p_household_id IS NULL) = (p_user_id IS NULL) THEN
    RAISE EXCEPTION 'Provide exactly one of p_household_id or p_user_id';
  END IF;

  IF p_household_id IS NOT NULL THEN
    SELECT sl.id
    INTO list_id
    FROM public.shopping_lists sl
    WHERE sl.household_id = p_household_id
    ORDER BY sl.created_at
    LIMIT 1;

    IF list_id IS NULL THEN
      INSERT INTO public.shopping_lists (household_id)
      VALUES (p_household_id)
      RETURNING id INTO list_id;
    END IF;
  ELSE
    SELECT sl.id
    INTO list_id
    FROM public.shopping_lists sl
    WHERE sl.user_id = p_user_id
    ORDER BY sl.created_at
    LIMIT 1;

    IF list_id IS NULL THEN
      INSERT INTO public.shopping_lists (user_id)
      VALUES (p_user_id)
      RETURNING id INTO list_id;
    END IF;
  END IF;

  CREATE TEMP TABLE _prev_auto_checked (
    plan_slot_id uuid,
    ingredient_id uuid,
    is_checked boolean NOT NULL
  ) ON COMMIT DROP;

  INSERT INTO _prev_auto_checked (plan_slot_id, ingredient_id, is_checked)
  SELECT si.plan_slot_id, si.ingredient_id, si.is_checked
  FROM public.shopping_items si
  WHERE si.shopping_list_id = list_id
    AND si.is_manual = false
    AND si.plan_slot_id IS NOT NULL
    AND si.ingredient_id IS NOT NULL;

  DELETE FROM public.shopping_items si
  WHERE si.shopping_list_id = list_id
    AND si.is_manual = false;

  INSERT INTO public.shopping_items (
    shopping_list_id,
    name,
    quantity,
    unit,
    category,
    is_checked,
    is_manual,
    plan_slot_id,
    ingredient_id
  )
  SELECT
    list_id,
    i.name,
    CASE
      WHEN i.quantity IS NULL THEN NULL
      WHEN r.servings <= 0 THEN ROUND(i.quantity)
      ELSE ROUND(i.quantity * ps.servings::numeric / r.servings::numeric)
    END,
    i.unit,
    i.category,
    COALESCE(prev.is_checked, false),
    false,
    ps.id,
    i.id
  FROM public.weekly_plans wp
  JOIN public.plan_slots ps ON ps.plan_id = wp.id
  JOIN public.recipes r ON r.id = ps.recipe_id
  JOIN public.ingredients i ON i.recipe_id = r.id
  LEFT JOIN _prev_auto_checked prev
    ON prev.plan_slot_id = ps.id
   AND prev.ingredient_id = i.id
  WHERE (
      (p_household_id IS NOT NULL AND wp.household_id = p_household_id)
      OR (p_user_id IS NOT NULL AND wp.user_id = p_user_id)
    )
    AND wp.week_start >= week_from
    AND COALESCE(ps.is_leftover, false) = false
    AND COALESCE(i.is_included, true) = true
    AND COALESCE(i.is_to_taste, false) = false;
END;
$$;

-- Internal helpers: not directly callable by clients
REVOKE ALL ON FUNCTION public.merge_user_plans_into_household(uuid, uuid) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.merge_user_plans_into_household(uuid, uuid) FROM authenticated;
REVOKE ALL ON FUNCTION public.snapshot_household_plans_to_user(uuid, uuid) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.snapshot_household_plans_to_user(uuid, uuid) FROM authenticated;
REVOKE ALL ON FUNCTION public.rebuild_shopping_from_plans(uuid, uuid) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.rebuild_shopping_from_plans(uuid, uuid) FROM authenticated;

-- Unique(token) already indexes token
DROP INDEX IF EXISTS public.idx_recipe_share_links_token;

-- ── Atomic fork into caller's recipe book ───────────────────────────────────

CREATE OR REPLACE FUNCTION public.fork_recipe_into_my_book(p_source_recipe_id uuid)
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

GRANT EXECUTE ON FUNCTION public.fork_recipe_into_my_book(uuid) TO authenticated;
