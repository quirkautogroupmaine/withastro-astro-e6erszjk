/*
  # Add search functionality to posts

  1. Changes
    - Add search_vector column to posts table
    - Create GIN index for fast searching
    - Add trigger to automatically update search vector
    - Update existing posts

  2. Security
    - No changes to RLS policies needed
    - Search vector is included in existing policies
*/

-- Add search vector column
ALTER TABLE posts ADD COLUMN IF NOT EXISTS search_vector tsvector;

-- Create GIN index for fast searching
CREATE INDEX IF NOT EXISTS posts_search_idx ON posts USING gin(search_vector);

-- Create function to update search vector
CREATE OR REPLACE FUNCTION posts_search_update() RETURNS trigger AS $$
BEGIN
  NEW.search_vector :=
    setweight(to_tsvector('english', COALESCE(NEW.title, '')), 'A') ||
    setweight(to_tsvector('english', COALESCE(NEW.excerpt, '')), 'B') ||
    setweight(to_tsvector('english', COALESCE(NEW.content, '')), 'C');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update search vector
DROP TRIGGER IF EXISTS posts_search_update ON posts;
CREATE TRIGGER posts_search_update
  BEFORE INSERT OR UPDATE ON posts
  FOR EACH ROW
  EXECUTE FUNCTION posts_search_update();

-- Update existing posts
UPDATE posts SET search_vector = 
  setweight(to_tsvector('english', COALESCE(title, '')), 'A') ||
  setweight(to_tsvector('english', COALESCE(excerpt, '')), 'B') ||
  setweight(to_tsvector('english', COALESCE(content, '')), 'C');