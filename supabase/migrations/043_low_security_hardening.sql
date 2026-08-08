-- 043_low_security_hardening: batch of LOW-severity RLS / privilege fixes
--
-- * Force household creation through the create_household RPC by dropping the
--   direct INSERT policy on households (clients could otherwise create
--   orphan households with no membership row).
-- * Add WITH CHECK to households_update_admin so an admin can't redirect an
--   update at a household they no longer administer.
-- * recipe_has_active_share is no longer referenced by any RLS policy after
--   the C2 token-gate migration, so revoke direct client execution (it
--   leaked "does this recipe have a share link?" to any user).
-- * Hide profiles.is_admin from non-admin peers via column-level grants.
--   is_admin is still readable by service_role and through the SECURITY
--   DEFINER auth_is_admin() RPC; clients read their own admin status via
--   that RPC instead of the column.

-- 1) Household INSERT must go through create_household (SECURITY DEFINER).
DROP POLICY IF EXISTS "households_insert_authenticated" ON public.households;

-- 2) households_update_admin: add WITH CHECK mirroring USING.
DROP POLICY IF EXISTS "households_update_admin" ON public.households;
CREATE POLICY "households_update_admin"
  ON public.households FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.household_members hm
      WHERE hm.household_id = id
        AND hm.user_id = auth.uid()
        AND hm.role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.household_members hm
      WHERE hm.household_id = id
        AND hm.user_id = auth.uid()
        AND hm.role = 'admin'
    )
  );

-- 3) recipe_has_active_share: no longer used by RLS after C2; revoke client use.
REVOKE ALL ON FUNCTION public.recipe_has_active_share(uuid) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.recipe_has_active_share(uuid) FROM authenticated;

-- 4) profiles.is_admin: column-level grant so peers can't read each other's
--    admin flag. service_role (RLS-bypassing) and the auth_is_admin() RPC are
--    unaffected.
REVOKE SELECT ON public.profiles FROM anon, authenticated;
GRANT SELECT (id, username, avatar_url, created_at) ON public.profiles
  TO anon, authenticated;
