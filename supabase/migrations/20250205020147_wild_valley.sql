-- First disable RLS to reset policies
ALTER TABLE facebook_posts DISABLE ROW LEVEL SECURITY;

-- Re-enable RLS
ALTER TABLE facebook_posts ENABLE ROW LEVEL SECURITY;

-- Drop all existing policies
DROP POLICY IF EXISTS "Enable read access for all users" ON facebook_posts;
DROP POLICY IF EXISTS "Enable write access for authenticated users" ON facebook_posts;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON facebook_posts;
DROP POLICY IF EXISTS "Enable update for authenticated users" ON facebook_posts;
DROP POLICY IF EXISTS "Enable delete for authenticated users" ON facebook_posts;

-- Create new simplified policies
CREATE POLICY "Public read access"
ON facebook_posts FOR SELECT
TO public
USING (true);

CREATE POLICY "Authenticated insert access"
ON facebook_posts FOR INSERT
TO authenticated
WITH CHECK (true);

CREATE POLICY "Authenticated update access"
ON facebook_posts FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

CREATE POLICY "Authenticated delete access"
ON facebook_posts FOR DELETE
TO authenticated
USING (true);

-- Grant necessary permissions
GRANT ALL ON facebook_posts TO authenticated;
GRANT SELECT ON facebook_posts TO anon;