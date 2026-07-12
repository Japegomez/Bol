-- Rename ingredient/shopping category Panadería -> Repostería.
-- Also renames recipe tags panaderia/panadería -> reposteria if present.

UPDATE public.ingredients
SET category = 'Repostería'
WHERE category = 'Panadería';

UPDATE public.shopping_items
SET category = 'Repostería'
WHERE category = 'Panadería';

UPDATE public.recipes r
SET tags = sub.new_tags
FROM (
  SELECT
    id,
    array_agg(
      CASE
        WHEN lower(tag) IN ('panadería', 'panaderia') THEN 'reposteria'
        ELSE tag
      END
      ORDER BY ord
    ) AS new_tags
  FROM public.recipes,
    unnest(tags) WITH ORDINALITY AS t(tag, ord)
  GROUP BY id
) AS sub
WHERE r.id = sub.id
  AND EXISTS (
    SELECT 1
    FROM unnest(r.tags) AS tag
    WHERE lower(tag) IN ('panadería', 'panaderia')
  );
