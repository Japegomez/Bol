-- 021_recipe_title_translations: lightweight per-title machine translation cache
-- Used to translate recipe titles shown in lists (Explore, Feed, recipe book)
-- without translating the whole recipe.

CREATE TABLE IF NOT EXISTS public.recipe_title_translations (
  recipe_id   uuid NOT NULL REFERENCES public.recipes(id) ON DELETE CASCADE,
  lang        text NOT NULL,
  title       text NOT NULL,
  created_at  timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (recipe_id, lang)
);

ALTER TABLE public.recipe_title_translations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "recipe_title_translations_select_public_or_own"
  ON public.recipe_title_translations FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.recipes r
      WHERE r.id = recipe_id
        AND (r.is_public = true OR r.user_id = auth.uid())
    )
  );

-- Edge function uses the service role for upserts; no client insert/update policy.
