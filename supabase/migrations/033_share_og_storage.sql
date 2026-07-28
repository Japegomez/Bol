-- 033_share_og_storage: public HTML pages for WhatsApp OG previews.
-- Supabase Edge Functions force Content-Type: text/plain on *.supabase.co,
-- which breaks crawlers. Storage can serve real text/html.

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'share-og',
  'share-og',
  true,
  512000,
  NULL
)
ON CONFLICT (id) DO UPDATE
SET
  public = true,
  file_size_limit = 512000,
  allowed_mime_types = NULL;

DROP POLICY IF EXISTS "Public read share-og" ON storage.objects;
CREATE POLICY "Public read share-og"
  ON storage.objects
  FOR SELECT
  TO public
  USING (bucket_id = 'share-og');
