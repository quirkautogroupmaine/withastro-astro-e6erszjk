-- Create function to handle Facebook image imports
CREATE OR REPLACE FUNCTION process_facebook_image(
  image_url text,
  post_title text,
  post_date timestamptz
) RETURNS text AS $$
DECLARE
  filename text;
  storage_path text;
  public_url text;
BEGIN
  -- Generate filename from title and date
  filename := LOWER(REGEXP_REPLACE(
    post_title || '_' || to_char(post_date, 'YYYYMMDD'),
    '[^a-z0-9]+',
    '-',
    'g'
  )) || '.jpg';
  
  -- Set storage path
  storage_path := 'post-featured/iyc/' || filename;
  
  -- Generate public URL
  public_url := storage.get_public_url('MEQuirk', storage_path);
  
  RETURN public_url;
END;
$$ LANGUAGE plpgsql;

-- Add comment for documentation
COMMENT ON FUNCTION process_facebook_image IS 'Processes Facebook image imports and returns the public URL for the stored image';

-- Update storage policies for the iyc subfolder
CREATE POLICY "Allow access to iyc folder"
ON storage.objects FOR SELECT
TO public
USING (
  bucket_id = 'MEQuirk' AND
  (storage.foldername(name))[1] = 'post-featured' AND
  (storage.foldername(name))[2] = 'iyc'
);

CREATE POLICY "Allow uploads to iyc folder"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'MEQuirk' AND
  (storage.foldername(name))[1] = 'post-featured' AND
  (storage.foldername(name))[2] = 'iyc' AND
  (auth.role() = 'authenticated' OR auth.role() = 'super_admin')
);

-- Create helper function to get folder name parts
CREATE OR REPLACE FUNCTION storage.foldername(path text)
RETURNS text[] AS $$
  SELECT string_to_array(path, '/');
$$ LANGUAGE sql IMMUTABLE;

-- Add index for iyc folder queries
CREATE INDEX idx_storage_iyc_folder
ON storage.objects ((storage.foldername(name))[1], (storage.foldername(name))[2])
WHERE bucket_id = 'MEQuirk';