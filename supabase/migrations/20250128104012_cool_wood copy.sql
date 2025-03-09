-- Add missing columns to posts table
ALTER TABLE posts 
ADD COLUMN IF NOT EXISTS intro_text text,
ADD COLUMN IF NOT EXISTS intro_style text CHECK (intro_style IN ('quote', 'impact')),
ADD COLUMN IF NOT EXISTS gallery_items jsonb DEFAULT '[]'::jsonb;

-- Add comment descriptions
COMMENT ON COLUMN posts.intro_text IS 'Optional intro paragraph for the post';
COMMENT ON COLUMN posts.intro_style IS 'Style of intro: quote or impact statement';
COMMENT ON COLUMN posts.gallery_items IS 'Array of gallery items (images and YouTube links)';

-- Create a function to validate gallery items
CREATE OR REPLACE FUNCTION validate_gallery_item(item jsonb)
RETURNS boolean AS $$
BEGIN
  -- Check if item has required fields
  IF NOT (
    item ? 'type' AND 
    item ? 'url' AND
    (item->>'type' IN ('image', 'youtube'))
  ) THEN
    RETURN false;
  END IF;

  -- Check type-specific fields
  IF item->>'type' = 'image' THEN
    -- For image type, caption is optional
    RETURN true;
  ELSIF item->>'type' = 'youtube' THEN
    -- For youtube type, title is optional
    RETURN true;
  END IF;

  RETURN false;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Add validation check for gallery_items
ALTER TABLE posts DROP CONSTRAINT IF EXISTS gallery_items_check;
ALTER TABLE posts 
ADD CONSTRAINT gallery_items_check CHECK (
  gallery_items IS NULL OR (
    jsonb_typeof(gallery_items) = 'array' AND
    (
      jsonb_array_length(gallery_items) = 0 OR
      NOT EXISTS (
        SELECT element 
        FROM jsonb_array_elements(gallery_items) element 
        WHERE NOT validate_gallery_item(element)
      )
    )
  )
);