-- Add missing columns to posts table
ALTER TABLE posts 
ADD COLUMN IF NOT EXISTS intro_text text,
ADD COLUMN IF NOT EXISTS intro_style text CHECK (intro_style IN ('quote', 'impact')),
ADD COLUMN IF NOT EXISTS gallery_items jsonb DEFAULT '[]'::jsonb;

-- Add comment descriptions
COMMENT ON COLUMN posts.intro_text IS 'Optional intro paragraph for the post';
COMMENT ON COLUMN posts.intro_style IS 'Style of intro: quote or impact statement';
COMMENT ON COLUMN posts.gallery_items IS 'Array of gallery items (images and YouTube links)';

-- Add validation check for gallery_items
ALTER TABLE posts DROP CONSTRAINT IF EXISTS gallery_items_check;
ALTER TABLE posts 
ADD CONSTRAINT gallery_items_check CHECK (
  (gallery_items IS NULL) OR (
    jsonb_array_length(gallery_items) >= 0 AND
    jsonb_typeof(gallery_items) = 'array' AND
    NOT EXISTS (
      SELECT 1
      FROM jsonb_array_elements(gallery_items) AS item
      WHERE NOT (
        jsonb_typeof(item->'type') = 'string' AND
        (item->>'type' IN ('image', 'youtube')) AND
        jsonb_typeof(item->'url') = 'string' AND
        CASE 
          WHEN item->>'type' = 'image' THEN
            jsonb_typeof(item->'caption') = 'string' OR item->'caption' IS NULL
          WHEN item->>'type' = 'youtube' THEN
            jsonb_typeof(item->'title') = 'string' OR item->'title' IS NULL
          ELSE false
        END
      )
    )
  )
);