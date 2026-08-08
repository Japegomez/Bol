-- 037_fix_household_members_insert: close household membership bypass (C1)
--
-- Bug: "household_members_insert_self" only checked auth.uid() = user_id, so any
-- authenticated user could INSERT themselves into any household as 'admin'. It also
-- enabled a delete-self -> re-insert-as-admin privilege escalation.
--
-- Fix: drop the client INSERT policy. Plain INSERTs are now denied by RLS; only the
-- SECURITY DEFINER RPCs (create_household / join_household) can insert membership
-- rows (they bypass RLS). A defense-in-depth trigger blocks 'admin' self-assignment
-- except for the legitimate bootstrap (create_household) and admin-promotion paths.

DROP POLICY IF EXISTS "household_members_insert_self" ON public.household_members;

CREATE OR REPLACE FUNCTION public.guard_member_role()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = public
AS $$
DECLARE
  current_user_id uuid := auth.uid();
  existing_member_count int;
  caller_is_admin boolean;
BEGIN
  IF NEW.role = 'admin' THEN
    -- Bootstrap: creating a household inserts the founder as the first admin.
    SELECT COUNT(*) INTO existing_member_count
    FROM public.household_members hm
    WHERE hm.household_id = NEW.household_id;

    IF existing_member_count = 0 THEN
      RETURN NEW;
    END IF;

    -- Allow an existing household admin to add/promote another member to admin.
    SELECT EXISTS (
      SELECT 1
      FROM public.household_members hm
      WHERE hm.household_id = NEW.household_id
        AND hm.user_id = current_user_id
        AND hm.role = 'admin'
    ) INTO caller_is_admin;

    IF caller_is_admin THEN
      RETURN NEW;
    END IF;

    -- Otherwise block self-assignment of the admin role.
    RAISE EXCEPTION 'Cannot assign admin role';
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_guard_member_role
  BEFORE INSERT ON public.household_members
  FOR EACH ROW
  EXECUTE FUNCTION public.guard_member_role();
