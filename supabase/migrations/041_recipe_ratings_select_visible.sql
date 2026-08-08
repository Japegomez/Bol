-- 041_recipe_ratings_select_visible: stop leaking private recipes' ratings (M2)
--
-- Bug: recipe_ratings_select_all used USING (true), so every authenticated
-- user could read the full ratings table, including ratings on private
-- recipes they cannot otherwise see (leaking who rated whose private
-- recipes and the scores).
--
-- Fix: replace it with a policy that only exposes ratings for recipes the
-- caller can already see (public, own, or household co-member), plus the
-- caller's own ratings. list_public_recipes (LANGUAGE sql, invoker) only
-- joins ratings for public recipes, so it keeps working.

DROP POLICY IF EXISTS "recipe_ratings_select_all" ON public.recipe_ratings;

CREATE POLICY "recipe_ratings_select_visible"
  ON public.recipe_ratings FOR SELECT
  TO authenticated
  USING (
    user_id = auth.uid()
    OR EXISTS (
      SELECT 1
      FROM public.recipes r
      WHERE r.id = public.recipe_ratings.recipe_id
        AND (
          r.is_public = true
          OR r.user_id = auth.uid()
          OR public.shares_household_with(r.user_id)
        )
    )
  );
