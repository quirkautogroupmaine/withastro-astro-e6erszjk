-- Update storage policies for MEQuirk bucket
DROP POLICY IF EXISTS "Give public access to all files" ON storage.objects;
CREATE POLICY "Give public access to all files"
ON storage.objects FOR SELECT
TO public
USING (
  bucket_id = 'MEQuirk'
);

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

-- Grant necessary bucket permissions
GRANT ALL ON storage.objects TO authenticated;
GRANT SELECT ON storage.objects TO anon;
GRANT USAGE ON SCHEMA storage TO anon;
GRANT USAGE ON SCHEMA storage TO authenticated;

-- Update organizations table
ALTER TABLE organizations 
ADD COLUMN IF NOT EXISTS logo_url text;

COMMENT ON COLUMN organizations.logo_url IS 'URL to organization''s logo image stored in Supabase storage';

-- Update organization policies
DROP POLICY IF EXISTS "Super admins have full access to organizations" ON organizations;
CREATE POLICY "Super admins have full access to organizations"
ON organizations
FOR ALL
TO authenticated
USING (
  auth.get_user_role() = 'super_admin'
)
WITH CHECK (
  auth.get_user_role() = 'super_admin'
);

DROP POLICY IF EXISTS "Anyone can read organizations" ON organizations;
CREATE POLICY "Anyone can read organizations"
ON organizations
FOR SELECT
TO public
USING (true);