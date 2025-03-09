-- First remove any existing constraints and functions
ALTER TABLE posts DROP CONSTRAINT IF EXISTS gallery_items_check;
DROP TRIGGER IF EXISTS validate_gallery_items_trigger ON posts;
DROP FUNCTION IF EXISTS validate_gallery_items();
DROP FUNCTION IF EXISTS is_valid_gallery_item();

-- Create a simpler validation function
CREATE OR REPLACE FUNCTION is_valid_gallery_item(item jsonb)
RETURNS boolean AS $$
BEGIN
  RETURN (
    item ? 'type' AND
    item ? 'url' AND
    (item->>'type' = 'image' OR item->>'type' = 'youtube')
  );
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Create a trigger function to validate gallery items
CREATE OR REPLACE FUNCTION validate_gallery_items()
RETURNS trigger AS $$
DECLARE
  item jsonb;
BEGIN
  IF NEW.gallery_items IS NOT NULL THEN
    FOR item IN SELECT * FROM jsonb_array_elements(NEW.gallery_items)
    LOOP
      IF NOT is_valid_gallery_item(item) THEN
        RAISE EXCEPTION 'Invalid gallery item: %', item;
      END IF;
    END LOOP;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add a basic check constraint for array type
ALTER TABLE posts ADD CONSTRAINT gallery_items_check 
  CHECK (gallery_items IS NULL OR jsonb_typeof(gallery_items) = 'array');

-- Create trigger for detailed validation
CREATE TRIGGER validate_gallery_items_trigger
  BEFORE INSERT OR UPDATE ON posts
  FOR EACH ROW
  EXECUTE FUNCTION validate_gallery_items();