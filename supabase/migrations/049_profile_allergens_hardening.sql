-- 049: Harden profile allergens after 048.
--
-- * Drop public SELECT on allergens (household/public peers must not read it).
-- * Constrain allowed allergen keys (NOT VALID, then VALIDATE).
-- * Expose own allergens via SECURITY DEFINER RPC.

ALTER TABLE public.profiles
  DROP CONSTRAINT IF EXISTS profiles_allergens_valid;

ALTER TABLE public.profiles
  ADD CONSTRAINT profiles_allergens_valid
  CHECK (
    allergens <@ ARRAY[
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
  ) NOT VALID;

ALTER TABLE public.profiles
  VALIDATE CONSTRAINT profiles_allergens_valid;

REVOKE SELECT ON public.profiles FROM anon, authenticated;
GRANT SELECT (id, username, avatar_url, created_at) ON public.profiles
  TO anon, authenticated;

GRANT UPDATE (allergens) ON public.profiles TO authenticated;

CREATE OR REPLACE FUNCTION public.get_own_allergens()
RETURNS text[]
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT COALESCE(allergens, '{}'::text[])
  FROM public.profiles
  WHERE id = auth.uid();
$$;

REVOKE ALL ON FUNCTION public.get_own_allergens() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.get_own_allergens() TO authenticated;
