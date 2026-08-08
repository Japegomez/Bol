-- 040_share_link_revoke: allow owners to revoke private share links (H3)
--
-- Bug: recipe_share_links only had SELECT + INSERT policies. Owners could
-- not revoke a leaked link; it stayed valid until expires_at (30 days).
--
-- Fix: add DELETE and UPDATE policies so the owner can kill a link or expire
-- it immediately. Combined with C2 (token-gated reads), revoking the link
-- removes read access at the source.

CREATE POLICY "recipe_share_links_delete_owner"
  ON public.recipe_share_links FOR DELETE
  TO authenticated
  USING (created_by = auth.uid());

CREATE POLICY "recipe_share_links_update_owner"
  ON public.recipe_share_links FOR UPDATE
  TO authenticated
  USING (created_by = auth.uid())
  WITH CHECK (created_by = auth.uid());
