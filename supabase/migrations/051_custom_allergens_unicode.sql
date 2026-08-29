-- 051: Allow Unicode letters in custom allergy labels (accents, etc.).
-- Stored form remains `custom:<lowercase label>`; display keeps accents.

CREATE OR REPLACE FUNCTION public.allergens_are_valid(arr text[])
RETURNS boolean
LANGUAGE sql
IMMUTABLE
AS $$
  SELECT
    cardinality(COALESCE(arr, '{}'::text[])) <= 20
    AND COALESCE(
      (
        SELECT bool_and(
          allergen = ANY(
            ARRAY[
              'gluten_free',
              'lactose_free',
              'dairy_free',
              'egg_free',
              'nut_free',
              'peanut_free',
              'soy_free',
              'fish_free',
              'shellfish_free',
              'sugar_free'
            ]::text[]
          )
          OR (
            allergen = lower(allergen)
            AND allergen ~ '^custom:[[:alnum:]][[:alnum:] _-]{0,39}$'
          )
        )
        FROM unnest(COALESCE(arr, '{}'::text[])) AS allergen
      ),
      true
    );
$$;
