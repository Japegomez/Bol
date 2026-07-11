-- Multi-tag filter for public recipe exploration (AND: recipe must contain all tags).

DROP FUNCTION IF EXISTS public.list_public_recipes(text, text, text, int, int);

CREATE OR REPLACE FUNCTION public.list_public_recipes(
  p_search  text DEFAULT NULL,
  p_tags    text[] DEFAULT NULL,
  p_sort    text DEFAULT 'recent',
  p_limit   int DEFAULT 20,
  p_offset  int DEFAULT 0
)
RETURNS TABLE (
  id uuid,
  user_id uuid,
  title text,
  photo_url text,
  servings int,
  tags text[],
  created_at timestamptz,
  author_name text,
  avg_score numeric,
  rating_count bigint
)
LANGUAGE sql
STABLE
SECURITY INVOKER
SET search_path = public
AS $$
  SELECT
    r.id,
    r.user_id,
    r.title,
    r.photo_url,
    r.servings,
    r.tags,
    r.created_at,
    p.username AS author_name,
    COALESCE(stats.avg_score, 0) AS avg_score,
    COALESCE(stats.rating_count, 0)::bigint AS rating_count
  FROM public.recipes r
  JOIN public.profiles p ON p.id = r.user_id
  LEFT JOIN LATERAL (
    SELECT
      AVG(rr.score)::numeric AS avg_score,
      COUNT(rr.id) AS rating_count
    FROM public.recipe_ratings rr
    WHERE rr.recipe_id = r.id
  ) stats ON true
  WHERE r.is_public = true
    AND (p_search IS NULL OR btrim(p_search) = '' OR r.title ILIKE '%' || p_search || '%')
    AND (
      p_tags IS NULL
      OR cardinality(p_tags) = 0
      OR r.tags @> p_tags
    )
  ORDER BY
    CASE WHEN p_sort = 'top' THEN COALESCE(stats.avg_score, 0) END DESC NULLS LAST,
    r.created_at DESC
  LIMIT GREATEST(p_limit, 1)
  OFFSET GREATEST(p_offset, 0);
$$;

GRANT EXECUTE ON FUNCTION public.list_public_recipes(text, text[], text, int, int)
  TO authenticated;
