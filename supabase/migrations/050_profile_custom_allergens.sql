-- 050: Allow custom allergy/intolerance entries on profiles.allergens.
--
-- Predefined keys remain the 10 *_free tags. Custom entries use the
-- prefix "custom:" followed by a normalized free-text substance label
-- (lowercase, letters/digits/spaces/hyphens/underscores, 1–40 chars).

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
          OR allergen ~ '^custom:[a-z0-9][a-z0-9 _-]{0,39}$'
        )
        FROM unnest(COALESCE(arr, '{}'::text[])) AS allergen
      ),
      true
    );
$$;

ALTER TABLE public.profiles
  DROP CONSTRAINT IF EXISTS profiles_allergens_valid;

ALTER TABLE public.profiles
  ADD CONSTRAINT profiles_allergens_valid
  CHECK (public.allergens_are_valid(allergens)) NOT VALID;

ALTER TABLE public.profiles
  VALIDATE CONSTRAINT profiles_allergens_valid;

REVOKE ALL ON FUNCTION public.allergens_are_valid(text[]) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.allergens_are_valid(text[]) TO authenticated;
