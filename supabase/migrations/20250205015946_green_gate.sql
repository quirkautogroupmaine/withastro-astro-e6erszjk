-- Drop existing RLS policies
DROP POLICY IF EXISTS "Enable read access for all users" ON facebook_posts;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON facebook_posts;
DROP POLICY IF EXISTS "Enable update for authenticated users" ON facebook_posts;
DROP POLICY IF EXISTS "Enable delete for authenticated users" ON facebook_posts;

-- Enable RLS
ALTER TABLE facebook_posts ENABLE ROW LEVEL SECURITY;

-- Add simplified RLS policies
CREATE POLICY "Enable read access for all users"
ON facebook_posts FOR SELECT
TO public
USING (true);

CREATE POLICY "Enable write access for authenticated users"
ON facebook_posts
FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- Add comment for documentation
COMMENT ON TABLE facebook_posts IS 'Stores imported Facebook posts with simplified RLS policies';