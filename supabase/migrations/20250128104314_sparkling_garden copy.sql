-- Add missing columns to posts table
ALTER TABLE posts 
ADD COLUMN IF NOT EXISTS intro_text text,
ADD COLUMN IF NOT EXISTS intro_style text,
ADD COLUMN IF NOT EXISTS gallery_items jsonb DEFAULT '[]'::jsonb;

-- Add comment descriptions
COMMENT ON COLUMN posts.intro_text IS 'Optional intro paragraph for the post';
COMMENT ON COLUMN posts.intro_style IS 'Style of intro: quote or impact statement';
COMMENT ON COLUMN posts.gallery_items IS 'Array of gallery items (images and YouTube links)';

-- Add basic check constraint for intro_style
ALTER TABLE posts ADD CONSTRAINT posts_intro_style_check 
  CHECK (intro_style IS NULL OR intro_style IN ('quote', 'impact'));

-- Add basic check constraint for gallery_items array type
ALTER TABLE posts ADD CONSTRAINT posts_gallery_items_check 
  CHECK (gallery_items IS NULL OR jsonb_typeof(gallery_items) = 'array');