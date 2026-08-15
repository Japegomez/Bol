-- 048_profile_allergens: store per-user allergy/intolerance keys.
--
-- The keys reuse the "sin"/allergen-free recipe tag keys (gluten_free,
-- lactose_free, dairy_free, egg_free, nut_free, peanut_free, soy_free,
-- fish_free, shellfish_free, sugar_free) so the recipe assistant can both
-- filter ingredients and auto-apply the matching recipe tags.
--
-- Column-level SELECT grant is updated to match migration 043's hardening:
-- anon/authenticated may only read the explicitly granted columns.

ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS allergens text[] NOT NULL DEFAULT '{}';

REVOKE SELECT ON public.profiles FROM anon, authenticated;
GRANT SELECT (id, username, avatar_url, created_at, allergens) ON public.profiles
  TO anon, authenticated;

GRANT UPDATE (allergens) ON public.profiles TO authenticated;
