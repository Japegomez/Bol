-- 025_recipe_share_links: private recipe share tokens (30 days) + read via active link

CREATE TABLE public.recipe_share_links (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  recipe_id uuid NOT NULL REFERENCES public.recipes(id) ON DELETE CASCADE,
  token text NOT NULL UNIQUE,
  created_by uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now(),
  expires_at timestamptz NOT NULL
);

CREATE INDEX idx_recipe_share_links_recipe_active
  ON public.recipe_share_links (recipe_id, expires_at DESC);

CREATE INDEX idx_recipe_share_links_token
  ON public.recipe_share_links (token);

ALTER TABLE public.recipe_share_links ENABLE ROW LEVEL SECURITY;

CREATE POLICY "recipe_share_links_select_own"
  ON public.recipe_share_links FOR SELECT
  TO authenticated
  USING (created_by = auth.uid());

CREATE POLICY "recipe_share_links_insert_own"
  ON public.recipe_share_links FOR INSERT
  TO authenticated
  WITH CHECK (
    created_by = auth.uid()
    AND EXISTS (
      SELECT 1
      FROM public.recipes r
      WHERE r.id = recipe_id
        AND r.user_id = auth.uid()
    )
  );

-- Authenticated users may read a recipe (and children) while an active share link exists.
-- Discovery of private recipes still goes through the opaque token URL.
CREATE POLICY "recipes_select_active_share"
  ON public.recipes FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.recipe_share_links s
      WHERE s.recipe_id = recipes.id
        AND s.expires_at > now()
    )
  );

CREATE POLICY "ingredients_select_active_share_recipe"
  ON public.ingredients FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.recipe_share_links s
      WHERE s.recipe_id = ingredients.recipe_id
        AND s.expires_at > now()
    )
  );

CREATE POLICY "recipe_steps_select_active_share_recipe"
  ON public.recipe_steps FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.recipe_share_links s
      WHERE s.recipe_id = recipe_steps.recipe_id
        AND s.expires_at > now()
    )
  );

CREATE POLICY "nutrition_info_select_active_share_recipe"
  ON public.nutrition_info FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.recipe_share_links s
      WHERE s.recipe_id = nutrition_info.recipe_id
        AND s.expires_at > now()
    )
  );

CREATE OR REPLACE FUNCTION public.get_or_create_recipe_share_link(p_recipe_id uuid)
RETURNS public.recipe_share_links
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  current_user_id uuid := auth.uid();
  existing public.recipe_share_links;
  created public.recipe_share_links;
BEGIN
  IF current_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.recipes r
    WHERE r.id = p_recipe_id
      AND r.user_id = current_user_id
  ) THEN
    RAISE EXCEPTION 'Recipe not found or not owned';
  END IF;

  SELECT *
  INTO existing
  FROM public.recipe_share_links s
  WHERE s.recipe_id = p_recipe_id
    AND s.expires_at > now()
  ORDER BY s.created_at DESC
  LIMIT 1;

  IF existing.id IS NOT NULL THEN
    RETURN existing;
  END IF;

  INSERT INTO public.recipe_share_links (
    recipe_id,
    token,
    created_by,
    expires_at
  )
  VALUES (
    p_recipe_id,
    replace(gen_random_uuid()::text || gen_random_uuid()::text, '-', ''),
    current_user_id,
    now() + interval '30 days'
  )
  RETURNING * INTO created;

  RETURN created;
END;
$$;

CREATE OR REPLACE FUNCTION public.resolve_recipe_share(p_token text)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  current_user_id uuid := auth.uid();
  link public.recipe_share_links;
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

  IF NOT EXISTS (
    SELECT 1 FROM public.recipes r WHERE r.id = link.recipe_id
  ) THEN
    RAISE EXCEPTION 'Recipe not found';
  END IF;

  RETURN link.recipe_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_or_create_recipe_share_link(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.resolve_recipe_share(text) TO authenticated;
