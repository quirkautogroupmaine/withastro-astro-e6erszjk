-- Create post-featured bucket if it doesn't exist
INSERT INTO storage.buckets (id, name)
VALUES ('post-featured', 'post-featured')
ON CONFLICT (id) DO NOTHING;

-- Update bucket settings
UPDATE storage.buckets
SET public = true,
    file_size_limit = 52428800, -- 50MB
    allowed_mime_types = ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp']
WHERE id = 'post-featured';

-- Create function to generate filename-safe strings
CREATE OR REPLACE FUNCTION slugify(text)
RETURNS text AS $$
  -- Convert to lowercase
  WITH lowercase AS (
    SELECT lower($1) AS text
  ),
  -- Replace spaces and special chars with hyphens
  replaced AS (
    SELECT regexp_replace(text, '[^a-z0-9]+', '-', 'g') AS text 
    FROM lowercase
  ),
  -- Remove leading/trailing hyphens
  trimmed AS (
    SELECT regexp_replace(text, '^-+|-+$', '', 'g') AS text 
    FROM replaced
  )
  SELECT text FROM trimmed;
$$ LANGUAGE SQL IMMUTABLE STRICT;

-- Add storage policies for post-featured bucket
CREATE POLICY "Give public access to featured images"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'post-featured');

CREATE POLICY "Allow authenticated uploads to featured images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'post-featured' AND
  (auth.role() = 'authenticated' OR auth.role() = 'super_admin')
);

CREATE POLICY "Allow authenticated updates to featured images"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'post-featured' AND
  (auth.role() = 'authenticated' OR auth.role() = 'super_admin')
)
WITH CHECK (
  bucket_id = 'post-featured' AND
  (auth.role() = 'authenticated' OR auth.role() = 'super_admin')
);

CREATE POLICY "Allow authenticated deletes of featured images"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'post-featured' AND
  (auth.role() = 'authenticated' OR auth.role() = 'super_admin')
);

-- Create trigger function to handle featured image uploads
CREATE OR REPLACE FUNCTION handle_featured_image()
RETURNS trigger AS $$
DECLARE
  old_image_path text;
  new_image_path text;
BEGIN
  -- If this is an update and the featured_image_url has changed
  IF TG_OP = 'UPDATE' AND OLD.featured_image_url IS DISTINCT FROM NEW.featured_image_url THEN
    -- Extract old image path if it exists and is in our bucket
    IF OLD.featured_image_url LIKE '%/storage/v1/object/public/post-featured/%' THEN
      old_image_path := substring(OLD.featured_image_url from '/post-featured/(.*)$');
      
      -- Delete old image
      DELETE FROM storage.objects 
      WHERE bucket_id = 'post-featured' 
      AND name = old_image_path;
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for featured image handling
DROP TRIGGER IF EXISTS handle_featured_image_trigger ON posts;
CREATE TRIGGER handle_featured_image_trigger
  AFTER UPDATE ON posts
  FOR EACH ROW
  EXECUTE FUNCTION handle_featured_image();

-- Grant necessary permissions
GRANT USAGE ON SCHEMA storage TO authenticated;
GRANT ALL ON storage.objects TO authenticated;
GRANT SELECT ON storage.objects TO anon;