-- 046_recipe_favorites: per-user favorites in the recipe book
--
-- Favorites are personal even inside a household. A user may only favorite
-- recipes they can already see (own or household co-member).

CREATE TABLE public.recipe_favorites (
  user_id    uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  recipe_id  uuid NOT NULL REFERENCES public.recipes(id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, recipe_id)
);

CREATE INDEX idx_recipe_favorites_user
  ON public.recipe_favorites (user_id, created_at DESC);

ALTER TABLE public.recipe_favorites ENABLE ROW LEVEL SECURITY;

CREATE POLICY "recipe_favorites_select_own"
  ON public.recipe_favorites FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "recipe_favorites_insert_own"
  ON public.recipe_favorites FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.uid() = user_id
    AND EXISTS (
      SELECT 1
      FROM public.recipes r
      WHERE r.id = recipe_id
        AND (
          r.user_id = auth.uid()
          OR public.shares_household_with(r.user_id)
        )
    )
  );

CREATE POLICY "recipe_favorites_delete_own"
  ON public.recipe_favorites FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

REVOKE ALL ON TABLE public.recipe_favorites FROM PUBLIC, anon;
GRANT SELECT, INSERT, DELETE ON TABLE public.recipe_favorites TO authenticated;
GRANT ALL ON TABLE public.recipe_favorites TO service_role;
