-- 027_share_link_rls_definer: recipients can read shared recipes
--
-- Bug: recipes_select_active_share used EXISTS on recipe_share_links, but that
-- table only allows SELECT for created_by = auth.uid(). Recipients therefore
-- always failed the EXISTS check and got no recipe row ("Receta no encontrada").

CREATE OR REPLACE FUNCTION public.recipe_has_active_share(p_recipe_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.recipe_share_links s
    WHERE s.recipe_id = p_recipe_id
      AND s.expires_at > now()
  );
$$;

REVOKE ALL ON FUNCTION public.recipe_has_active_share(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.recipe_has_active_share(uuid) TO authenticated;

DROP POLICY IF EXISTS "recipes_select_active_share" ON public.recipes;
CREATE POLICY "recipes_select_active_share"
  ON public.recipes FOR SELECT
  TO authenticated
  USING (public.recipe_has_active_share(id));

DROP POLICY IF EXISTS "ingredients_select_active_share_recipe" ON public.ingredients;
CREATE POLICY "ingredients_select_active_share_recipe"
  ON public.ingredients FOR SELECT
  TO authenticated
  USING (public.recipe_has_active_share(recipe_id));

DROP POLICY IF EXISTS "recipe_steps_select_active_share_recipe" ON public.recipe_steps;
CREATE POLICY "recipe_steps_select_active_share_recipe"
  ON public.recipe_steps FOR SELECT
  TO authenticated
  USING (public.recipe_has_active_share(recipe_id));

DROP POLICY IF EXISTS "nutrition_info_select_active_share_recipe" ON public.nutrition_info;
CREATE POLICY "nutrition_info_select_active_share_recipe"
  ON public.nutrition_info FOR SELECT
  TO authenticated
  USING (public.recipe_has_active_share(recipe_id));

-- Photos for recipes with an active private share link
DROP POLICY IF EXISTS "recipe_photos_select_active_share" ON storage.objects;
CREATE POLICY "recipe_photos_select_active_share"
  ON storage.objects FOR SELECT
  TO authenticated
  USING (
    bucket_id = 'recipe-photos'
    AND EXISTS (
      SELECT 1
      FROM public.recipes r
      WHERE r.photo_url = name
        AND public.recipe_has_active_share(r.id)
    )
  );
