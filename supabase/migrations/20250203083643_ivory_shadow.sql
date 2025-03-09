-- Add import_identifier column to posts table
ALTER TABLE posts
ADD COLUMN import_identifier text;

-- Add index for faster deletion queries
CREATE INDEX idx_posts_import_identifier ON posts(import_identifier);

-- Add comment for documentation
COMMENT ON COLUMN posts.import_identifier IS 'Identifier for imported posts (e.g. "Quirk Chevrolet Bangor_20240203071234")';

-- Create function to delete imported posts by identifier
CREATE OR REPLACE FUNCTION delete_imported_posts(identifier text)
RETURNS integer AS $$
DECLARE
  deleted_count integer;
BEGIN
  -- Delete post categories first
  DELETE FROM post_categories
  WHERE post_id IN (
    SELECT id FROM posts WHERE import_identifier = identifier
  );
  
  -- Delete the posts
  WITH deleted AS (
    DELETE FROM posts 
    WHERE import_identifier = identifier
    RETURNING id
  )
  SELECT COUNT(*) INTO deleted_count FROM deleted;
  
  RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- Add comment for function documentation
COMMENT ON FUNCTION delete_imported_posts IS 'Deletes all posts and their category associations for a given import identifier';