-- Drop existing RLS policies
DROP POLICY IF EXISTS "Enable read access for all users" ON facebook_posts;
DROP POLICY IF EXISTS "Enable all access for authenticated users" ON facebook_posts;

-- Add new RLS policies
CREATE POLICY "Enable read access for all users"
ON facebook_posts FOR SELECT
TO public
USING (true);

CREATE POLICY "Enable insert for authenticated users"
ON facebook_posts FOR INSERT
TO authenticated
WITH CHECK (auth.role() IN ('authenticated', 'super_admin'));

CREATE POLICY "Enable update for authenticated users"
ON facebook_posts FOR UPDATE
TO authenticated
USING (auth.role() IN ('authenticated', 'super_admin'))
WITH CHECK (auth.role() IN ('authenticated', 'super_admin'));

CREATE POLICY "Enable delete for authenticated users"
ON facebook_posts FOR DELETE
TO authenticated
USING (auth.role() IN ('authenticated', 'super_admin'));

-- Add comment for documentation
COMMENT ON TABLE facebook_posts IS 'Stores imported Facebook posts with RLS policies for authenticated users';