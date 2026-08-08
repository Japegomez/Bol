-- 040_share_link_revoke: allow owners to revoke private share links (H3)
--
-- Bug: recipe_share_links only had SELECT + INSERT policies. Owners could
-- not revoke a leaked link; it stayed valid until expires_at (30 days).
--
-- Fix: add DELETE and UPDATE policies so the owner can kill a link or expire
-- it immediately. Combined with C2 (token-gated reads), revoking the link
-- removes read access at the source.
-- UPDATE is column-restricted to expires_at so owners cannot reassign
-- recipe_id / token / created_by via a crafted update.

DROP POLICY IF EXISTS "recipe_share_links_delete_owner" ON public.recipe_share_links;
CREATE POLICY "recipe_share_links_delete_owner"
  ON public.recipe_share_links FOR DELETE
  TO authenticated
  USING (created_by = auth.uid());

DROP POLICY IF EXISTS "recipe_share_links_update_owner" ON public.recipe_share_links;
CREATE POLICY "recipe_share_links_update_owner"
  ON public.recipe_share_links FOR UPDATE
  TO authenticated
  USING (created_by = auth.uid())
  WITH CHECK (created_by = auth.uid());

-- Column-level grant: only expires_at may be updated by clients.
REVOKE UPDATE ON public.recipe_share_links FROM authenticated;
GRANT UPDATE (expires_at) ON public.recipe_share_links TO authenticated;
