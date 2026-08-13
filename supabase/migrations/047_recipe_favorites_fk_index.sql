-- 047: FK cleanup index + qualify insert policy recipe_id
--
-- ON DELETE CASCADE on recipe_favorites.recipe_id needs a leading recipe_id
-- index. The insert policy compares the outer favorite row explicitly.

CREATE INDEX IF NOT EXISTS idx_recipe_favorites_recipe
  ON public.recipe_favorites (recipe_id);

DROP POLICY IF EXISTS "recipe_favorites_insert_own" ON public.recipe_favorites;

CREATE POLICY "recipe_favorites_insert_own"
  ON public.recipe_favorites FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.uid() = user_id
    AND EXISTS (
      SELECT 1
      FROM public.recipes r
      WHERE r.id = public.recipe_favorites.recipe_id
        AND (
          r.user_id = auth.uid()
          OR public.shares_household_with(r.user_id)
        )
    )
  );
