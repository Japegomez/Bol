-- 035_share_og_mime_html: restrict share-og uploads to text/html only.

UPDATE storage.buckets
SET allowed_mime_types = ARRAY['text/html']
WHERE id = 'share-og';
