-- 024_household_planner_migration:
-- Additive merge of individual planner into household on create/join,
-- snapshot household → individual on leave, rebuild shopping from plans,
-- allow household members to read each other's recipes.

-- ── Helpers ──────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.current_week_monday()
RETURNS date
LANGUAGE sql
STABLE
AS $$
  SELECT (CURRENT_DATE - ((EXTRACT(ISODOW FROM CURRENT_DATE)::int) - 1));
$$;

CREATE OR REPLACE FUNCTION public.shares_household_with(other_user_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.household_members me
    JOIN public.household_members other
      ON other.household_id = me.household_id
    WHERE me.user_id = auth.uid()
      AND other.user_id = other_user_id
  );
$$;

-- ── Merge individual plans (current + future) into household ─────────────────

CREATE OR REPLACE FUNCTION public.merge_user_plans_into_household(
  p_user_id uuid,
  p_household_id uuid
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  week_from date := public.current_week_monday();
BEGIN
  -- Ensure household weekly_plans exist for each user week being merged.
  INSERT INTO public.weekly_plans (household_id, week_start)
  SELECT p_household_id, up.week_start
  FROM public.weekly_plans up
  WHERE up.user_id = p_user_id
    AND up.week_start >= week_from
  ON CONFLICT ON CONSTRAINT weekly_plans_household_id_week_start_key DO NOTHING;

  -- Copy slots additively; append after existing positions per day/meal.
  INSERT INTO public.plan_slots (
    plan_id,
    day_of_week,
    meal_type,
    recipe_id,
    servings,
    position,
    is_leftover,
    notes
  )
  SELECT
    hp.id,
    ps.day_of_week,
    ps.meal_type,
    ps.recipe_id,
    ps.servings,
    COALESCE(pos.max_pos, -1) + ROW_NUMBER() OVER (
      PARTITION BY hp.id, ps.day_of_week, ps.meal_type
      ORDER BY ps.position, ps.id
    ),
    ps.is_leftover,
    ps.notes
  FROM public.weekly_plans up
  JOIN public.plan_slots ps ON ps.plan_id = up.id
  JOIN public.weekly_plans hp
    ON hp.household_id = p_household_id
   AND hp.week_start = up.week_start
  LEFT JOIN LATERAL (
    SELECT MAX(existing.position) AS max_pos
    FROM public.plan_slots existing
    WHERE existing.plan_id = hp.id
      AND existing.day_of_week = ps.day_of_week
      AND existing.meal_type = ps.meal_type
  ) pos ON true
  WHERE up.user_id = p_user_id
    AND up.week_start >= week_from;
END;
$$;

-- ── Snapshot household plans → individual (replace current + future weeks) ───

CREATE OR REPLACE FUNCTION public.snapshot_household_plans_to_user(
  p_user_id uuid,
  p_household_id uuid
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  week_from date := public.current_week_monday();
BEGIN
  -- Clear existing individual slots for current + future weeks.
  DELETE FROM public.plan_slots ps
  USING public.weekly_plans wp
  WHERE ps.plan_id = wp.id
    AND wp.user_id = p_user_id
    AND wp.week_start >= week_from;

  -- Ensure individual weekly_plans for household weeks.
  INSERT INTO public.weekly_plans (user_id, week_start)
  SELECT p_user_id, hp.week_start
  FROM public.weekly_plans hp
  WHERE hp.household_id = p_household_id
    AND hp.week_start >= week_from
  ON CONFLICT ON CONSTRAINT weekly_plans_user_id_week_start_key DO NOTHING;

  -- Copy slots; foreign recipes become free-text notes with the title.
  INSERT INTO public.plan_slots (
    plan_id,
    day_of_week,
    meal_type,
    recipe_id,
    servings,
    position,
    is_leftover,
    notes
  )
  SELECT
    up.id,
    ps.day_of_week,
    ps.meal_type,
    CASE
      WHEN r.id IS NOT NULL AND r.user_id = p_user_id THEN ps.recipe_id
      ELSE NULL
    END,
    ps.servings,
    ps.position,
    ps.is_leftover,
    CASE
      WHEN ps.recipe_id IS NOT NULL
        AND (r.id IS NULL OR r.user_id <> p_user_id)
      THEN COALESCE(NULLIF(BTRIM(r.title), ''), NULLIF(BTRIM(ps.notes), ''), 'Recipe')
      ELSE ps.notes
    END
  FROM public.weekly_plans hp
  JOIN public.plan_slots ps ON ps.plan_id = hp.id
  JOIN public.weekly_plans up
    ON up.user_id = p_user_id
   AND up.week_start = hp.week_start
  LEFT JOIN public.recipes r ON r.id = ps.recipe_id
  WHERE hp.household_id = p_household_id
    AND hp.week_start >= week_from;
END;
$$;

-- ── Rebuild shopping list from plan slots (keep manual items) ────────────────

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

  -- Drop auto-generated items; keep manual ones.
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
    false,
    false,
    ps.id,
    i.id
  FROM public.weekly_plans wp
  JOIN public.plan_slots ps ON ps.plan_id = wp.id
  JOIN public.recipes r ON r.id = ps.recipe_id
  JOIN public.ingredients i ON i.recipe_id = r.id
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

-- ── Patch create / join / leave ──────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.create_household(name text)
RETURNS public.households
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  current_user_id uuid := auth.uid();
  new_invite_code text;
  new_household public.households;
BEGIN
  IF current_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  IF trim(name) = '' THEN
    RAISE EXCEPTION 'Household name is required';
  END IF;

  LOOP
    new_invite_code := public.generate_invite_code();
    EXIT WHEN NOT EXISTS (
      SELECT 1 FROM public.households h WHERE h.invite_code = new_invite_code
    );
  END LOOP;

  INSERT INTO public.households (name, invite_code, created_by)
  VALUES (trim(name), new_invite_code, current_user_id)
  RETURNING * INTO new_household;

  INSERT INTO public.household_members (household_id, user_id, role)
  VALUES (new_household.id, current_user_id, 'admin');

  PERFORM public.merge_user_plans_into_household(current_user_id, new_household.id);
  PERFORM public.rebuild_shopping_from_plans(p_household_id := new_household.id);

  RETURN new_household;
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
BEGIN
  IF current_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  IF trim(code) = '' THEN
    RAISE EXCEPTION 'Invite code is required';
  END IF;

  SELECT h.id
  INTO target_household_id
  FROM public.households h
  WHERE upper(h.invite_code) = upper(trim(code));

  IF target_household_id IS NULL THEN
    RAISE EXCEPTION 'Invalid invite code';
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

  PERFORM public.merge_user_plans_into_household(current_user_id, target_household_id);
  PERFORM public.rebuild_shopping_from_plans(p_household_id := target_household_id);

  RETURN new_member;
END;
$$;

CREATE OR REPLACE FUNCTION public.leave_household(p_household_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  current_user_id uuid := auth.uid();
BEGIN
  IF current_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.household_members hm
    WHERE hm.household_id = p_household_id
      AND hm.user_id = current_user_id
  ) THEN
    RAISE EXCEPTION 'Not a member of this household';
  END IF;

  -- Snapshot while membership still allows reading household data via DEFINER.
  PERFORM public.snapshot_household_plans_to_user(current_user_id, p_household_id);
  PERFORM public.rebuild_shopping_from_plans(p_user_id := current_user_id);

  DELETE FROM public.household_members hm
  WHERE hm.household_id = p_household_id
    AND hm.user_id = current_user_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.current_week_monday() TO authenticated;
GRANT EXECUTE ON FUNCTION public.shares_household_with(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.merge_user_plans_into_household(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.snapshot_household_plans_to_user(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.rebuild_shopping_from_plans(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.create_household(text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.join_household(text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.leave_household(uuid) TO authenticated;

-- ── RLS: household members can read each other's recipes ─────────────────────

CREATE POLICY "recipes_select_household_member"
  ON public.recipes FOR SELECT
  USING (public.shares_household_with(user_id));

CREATE POLICY "ingredients_select_household_recipe"
  ON public.ingredients FOR SELECT
  USING (
    EXISTS (
      SELECT 1
      FROM public.recipes r
      WHERE r.id = recipe_id
        AND public.shares_household_with(r.user_id)
    )
  );

CREATE POLICY "recipe_steps_select_household_recipe"
  ON public.recipe_steps FOR SELECT
  USING (
    EXISTS (
      SELECT 1
      FROM public.recipes r
      WHERE r.id = recipe_id
        AND public.shares_household_with(r.user_id)
    )
  );

CREATE POLICY "nutrition_info_select_household_recipe"
  ON public.nutrition_info FOR SELECT
  USING (
    EXISTS (
      SELECT 1
      FROM public.recipes r
      WHERE r.id = recipe_id
        AND public.shares_household_with(r.user_id)
    )
  );

-- Recipe photos of household co-members
CREATE POLICY "recipe_photos_select_household"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'recipe-photos'
    AND public.shares_household_with(((storage.foldername(name))[1])::uuid)
  );
