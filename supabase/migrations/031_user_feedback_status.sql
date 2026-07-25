-- Feedback moderation status for admin panel (resolve / ignore).

ALTER TABLE public.user_feedback
  ADD COLUMN IF NOT EXISTS status text NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'resolved', 'ignored'));

CREATE INDEX IF NOT EXISTS idx_user_feedback_status_created
  ON public.user_feedback (status, created_at DESC);

DO $$ BEGIN
  CREATE POLICY user_feedback_update_admin ON public.user_feedback
    FOR UPDATE TO authenticated
    USING (public.auth_is_admin())
    WITH CHECK (public.auth_is_admin());
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;
