-- Drop existing foreign key if it exists
ALTER TABLE posts
DROP CONSTRAINT IF EXISTS posts_location_id_fkey;

-- Add correct foreign key constraint to quirk_locations
ALTER TABLE posts
ADD CONSTRAINT posts_quirk_location_id_fkey
FOREIGN KEY (quirk_location_id)
REFERENCES quirk_locations(id)
ON DELETE SET NULL;

-- Add index for better query performance
CREATE INDEX IF NOT EXISTS idx_posts_quirk_location_id 
ON posts(quirk_location_id);

-- Add comment for documentation
COMMENT ON CONSTRAINT posts_quirk_location_id_fkey ON posts IS 'Foreign key linking posts to Quirk locations';