-- Enable Storage policies for MEQuirk bucket

-- Allow public read access to all files
CREATE POLICY "Give public access to all files"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'MEQuirk');

-- Allow authenticated users to upload files
CREATE POLICY "Allow authenticated uploads"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'MEQuirk' AND
  (auth.role() = 'authenticated' OR auth.role() = 'super_admin')
);

-- Allow authenticated users to update their own files
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

-- Allow authenticated users to delete their own files
CREATE POLICY "Allow authenticated deletes"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'MEQuirk' AND
  (auth.role() = 'authenticated' OR auth.role() = 'super_admin')
);

-- Enable RLS
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;