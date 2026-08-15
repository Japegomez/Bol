-- 048_profile_allergens: store per-user allergy/intolerance keys.
--
-- The keys reuse the "sin"/allergen-free recipe tag keys (gluten_free,
-- lactose_free, dairy_free, egg_free, nut_free, peanut_free, soy_free,
-- fish_free, shellfish_free, sugar_free) so the recipe assistant can both
-- filter ingredients and auto-apply the matching recipe tags.
--
-- Privilege hardening, CHECK constraint, and get_own_allergens() live in 049.

ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS allergens text[] NOT NULL DEFAULT '{}';
