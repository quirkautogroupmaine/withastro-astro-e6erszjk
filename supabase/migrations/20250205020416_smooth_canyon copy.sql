-- First disable RLS to reset policies
ALTER TABLE facebook_posts DISABLE ROW LEVEL SECURITY;

-- Re-enable RLS
ALTER TABLE facebook_posts ENABLE ROW LEVEL SECURITY;

-- Drop all existing policies
DROP POLICY IF EXISTS "Public read access" ON facebook_posts;
DROP POLICY IF EXISTS "Authenticated insert access" ON facebook_posts;
DROP POLICY IF EXISTS "Authenticated update access" ON facebook_posts;
DROP POLICY IF EXISTS "Authenticated delete access" ON facebook_posts;

-- Create new simplified policies
CREATE POLICY "Public read access"
ON facebook_posts FOR SELECT
TO public
USING (true);

CREATE POLICY "Authenticated write access"
ON facebook_posts
FOR ALL 
TO authenticated
USING (true)
WITH CHECK (true);

-- Grant necessary permissions
GRANT ALL ON facebook_posts TO authenticated;
GRANT SELECT ON facebook_posts TO anon;

-- Add comment for documentation
COMMENT ON TABLE facebook_posts IS 'Stores imported Facebook posts with simplified RLS policies';