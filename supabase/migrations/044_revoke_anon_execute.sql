-- 044_revoke_anon_execute: stop unauthenticated PostgREST calls to privileged RPCs
--
-- Supabase grants EXECUTE to anon separately from PUBLIC, so REVOKE FROM PUBLIC
-- (037–043) left the anon key able to invoke SECURITY DEFINER functions.
--
-- Keep EXECUTE for anon only on helpers referenced by RLS policies (a missing
-- grant makes anonymous SELECTs error instead of returning no rows).
-- Open Graph RPCs stay service_role-only: share-landing uses the service key.

-- ── 1) Internal / service_role only ──────────────────────────────────────────

REVOKE ALL ON FUNCTION public.check_and_increment_ai_usage(uuid, integer, integer, integer) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.check_and_increment_ai_usage(uuid, integer, integer, integer) TO service_role;

REVOKE ALL ON FUNCTION public.merge_user_plans_into_household(uuid, uuid) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.merge_user_plans_into_household(uuid, uuid) TO service_role;

REVOKE ALL ON FUNCTION public.snapshot_household_plans_to_user(uuid, uuid) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.snapshot_household_plans_to_user(uuid, uuid) TO service_role;

REVOKE ALL ON FUNCTION public.rebuild_shopping_from_plans(uuid, uuid) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.rebuild_shopping_from_plans(uuid, uuid) TO service_role;

REVOKE ALL ON FUNCTION public.recipe_has_active_share(uuid) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.recipe_has_active_share(uuid) TO service_role;

REVOKE ALL ON FUNCTION public.get_household_invite_og(text) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_household_invite_og(text) TO service_role;

REVOKE ALL ON FUNCTION public.get_private_share_og(text) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_private_share_og(text) TO service_role;

REVOKE ALL ON FUNCTION public.get_public_recipe_og(uuid) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_public_recipe_og(uuid) TO service_role;

REVOKE ALL ON FUNCTION public.generate_invite_code(integer) FROM PUBLIC, anon, authenticated;

-- ── 2) Triggers: not callable by clients (owner still executes them) ─────────

REVOKE ALL ON FUNCTION public.handle_new_user() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.guard_profiles_is_admin() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.profiles_guard_admin_column() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.guard_member_role() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.set_recipes_updated_at() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.rls_auto_enable() FROM PUBLIC, anon, authenticated;

-- ── 3) Authenticated client RPCs ─────────────────────────────────────────────

REVOKE ALL ON FUNCTION public.create_household(text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.create_household(text) TO authenticated;

REVOKE ALL ON FUNCTION public.join_household(text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.join_household(text) TO authenticated;

REVOKE ALL ON FUNCTION public.leave_household(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.leave_household(uuid) TO authenticated;

REVOKE ALL ON FUNCTION public.regenerate_invite_code(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.regenerate_invite_code(uuid) TO authenticated;

REVOKE ALL ON FUNCTION public.delete_user_account() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.delete_user_account() TO authenticated;

REVOKE ALL ON FUNCTION public.fork_recipe_into_my_book(uuid, text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.fork_recipe_into_my_book(uuid, text) TO authenticated;

REVOKE ALL ON FUNCTION public.get_or_create_recipe_share_link(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_or_create_recipe_share_link(uuid) TO authenticated;

REVOKE ALL ON FUNCTION public.get_or_create_weekly_plan(date) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_or_create_weekly_plan(date) TO authenticated;

REVOKE ALL ON FUNCTION public.get_shared_recipe(text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_shared_recipe(text) TO authenticated;

REVOKE ALL ON FUNCTION public.resolve_recipe_share(text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.resolve_recipe_share(text) TO authenticated;

REVOKE ALL ON FUNCTION public.list_public_recipes(text, text[], text, integer, integer) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.list_public_recipes(text, text[], text, integer, integer) TO authenticated;

REVOKE ALL ON FUNCTION public.current_week_monday() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.current_week_monday() TO authenticated;

-- ── 4) RLS helpers: anon must keep EXECUTE so policies do not error ──────────

REVOKE ALL ON FUNCTION public.auth_is_admin() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.auth_is_admin() TO anon, authenticated;

REVOKE ALL ON FUNCTION public.is_household_member(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.is_household_member(uuid) TO anon, authenticated;

REVOKE ALL ON FUNCTION public.shares_household_with(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.shares_household_with(uuid) TO anon, authenticated;

REVOKE ALL ON FUNCTION public.can_access_shopping_list(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.can_access_shopping_list(uuid) TO anon, authenticated;

REVOKE ALL ON FUNCTION public.can_access_weekly_plan(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.can_access_weekly_plan(uuid) TO anon, authenticated;
