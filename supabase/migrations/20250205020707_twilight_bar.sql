-- Drop existing table and policies if they exist
DROP TABLE IF EXISTS facebook_posts CASCADE;

-- Create facebook_posts table
CREATE TABLE facebook_posts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  facebook_id text UNIQUE NOT NULL,
  title text NOT NULL,
  content text NOT NULL,
  featured_image_url text,
  created_at timestamptz NOT NULL,
  imported_at timestamptz DEFAULT now(),
  quirk_location_id uuid REFERENCES quirk_locations(id),
  category text,
  processed boolean DEFAULT false,
  import_batch text
);

-- Add indexes
CREATE INDEX idx_facebook_posts_created ON facebook_posts(created_at DESC);
CREATE INDEX idx_facebook_posts_location ON facebook_posts(quirk_location_id);
CREATE INDEX idx_facebook_posts_batch ON facebook_posts(import_batch);
CREATE INDEX idx_facebook_posts_facebook_id ON facebook_posts(facebook_id);

-- Disable RLS temporarily
ALTER TABLE facebook_posts DISABLE ROW LEVEL SECURITY;

-- Grant necessary permissions
GRANT ALL ON facebook_posts TO authenticated;
GRANT SELECT ON facebook_posts TO anon;

-- Add comment for documentation
COMMENT ON TABLE facebook_posts IS 'Stores imported Facebook posts';