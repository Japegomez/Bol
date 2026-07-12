-- 020_recipe_translations: source language + cached machine translations

ALTER TABLE public.recipes
  ADD COLUMN IF NOT EXISTS source_lang text NOT NULL DEFAULT 'es';

CREATE TABLE IF NOT EXISTS public.recipe_translations (
  recipe_id   uuid NOT NULL REFERENCES public.recipes(id) ON DELETE CASCADE,
  lang        text NOT NULL,
  payload     jsonb NOT NULL,
  status      text NOT NULL DEFAULT 'ready',
  created_at  timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (recipe_id, lang)
);

CREATE INDEX IF NOT EXISTS idx_recipe_translations_recipe_id
  ON public.recipe_translations(recipe_id);

ALTER TABLE public.recipe_translations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "recipe_translations_select_public_or_own"
  ON public.recipe_translations FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.recipes r
      WHERE r.id = recipe_id
        AND (r.is_public = true OR r.user_id = auth.uid())
    )
  );

-- Edge function uses service role for upserts; no client insert/update policy.
