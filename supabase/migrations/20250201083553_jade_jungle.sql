-- Create MEQuirk bucket if it doesn't exist
INSERT INTO storage.buckets (id, name)
VALUES ('MEQuirk', 'MEQuirk')
ON CONFLICT (id) DO NOTHING;

-- Update bucket settings
UPDATE storage.buckets
SET public = true,
    file_size_limit = 52428800, -- 50MB
    allowed_mime_types = ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp']
WHERE id = 'MEQuirk';

-- Ensure storage schema access
GRANT USAGE ON SCHEMA storage TO authenticated;
GRANT USAGE ON SCHEMA storage TO anon;

-- Grant bucket access
GRANT ALL ON storage.buckets TO authenticated;
GRANT ALL ON storage.objects TO authenticated;
GRANT SELECT ON storage.buckets TO anon;
GRANT SELECT ON storage.objects TO anon;

-- Update storage policies
DROP POLICY IF EXISTS "Give public access to all files" ON storage.objects;
CREATE POLICY "Give public access to all files"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'MEQuirk');

DROP POLICY IF EXISTS "Allow authenticated uploads" ON storage.objects;
CREATE POLICY "Allow authenticated uploads"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'MEQuirk' AND
  (auth.role() = 'authenticated' OR auth.role() = 'super_admin')
);

DROP POLICY IF EXISTS "Allow authenticated updates" ON storage.objects;
CREATE POLICY "Allow authenticated updates"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'MEQuirk' AND
  (auth.role() = 'authenticated' OR auth.role() = 'super_admin')
)
WITH CHECK (
  bucket_id = 'MEQuirk' AND
  (auth.role() = 'authenticated' OR auth.role() = 'super_admin')
);

DROP POLICY IF EXISTS "Allow authenticated deletes" ON storage.objects;
CREATE POLICY "Allow authenticated deletes"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'MEQuirk' AND
  (auth.role() = 'authenticated' OR auth.role() = 'super_admin')
);

-- Ensure RLS is enabled
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;