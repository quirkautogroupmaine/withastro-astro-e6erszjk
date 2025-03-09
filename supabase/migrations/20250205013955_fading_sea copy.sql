-- Create table for imported Facebook posts
CREATE TABLE facebook_posts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  facebook_id text UNIQUE,
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

-- Enable RLS
ALTER TABLE facebook_posts ENABLE ROW LEVEL SECURITY;

-- Add RLS policies
CREATE POLICY "Enable read access for all users"
ON facebook_posts FOR SELECT TO public
USING (true);

CREATE POLICY "Enable all access for authenticated users"
ON facebook_posts FOR ALL TO authenticated
USING (auth.role() = 'authenticated')
WITH CHECK (auth.role() = 'authenticated');