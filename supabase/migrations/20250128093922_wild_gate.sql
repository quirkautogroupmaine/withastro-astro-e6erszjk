/*
  # Add intro text and gallery functionality to posts

  1. New Fields
    - `intro_text` - For impactful intro paragraph
    - `intro_style` - For specifying intro style (quote/impact)
    - `gallery_items` - For storing gallery images and YouTube links

  2. Security
    - Maintain existing RLS policies
    - No data loss or destructive operations
*/

-- Add new columns to posts table
ALTER TABLE posts 
ADD COLUMN IF NOT EXISTS intro_text text,
ADD COLUMN IF NOT EXISTS intro_style text CHECK (intro_style IN ('quote', 'impact')),
ADD COLUMN IF NOT EXISTS gallery_items jsonb DEFAULT '[]'::jsonb;

-- Add comment descriptions
COMMENT ON COLUMN posts.intro_text IS 'Optional intro paragraph for the post';
COMMENT ON COLUMN posts.intro_style IS 'Style of intro: quote or impact statement';
COMMENT ON COLUMN posts.gallery_items IS 'Array of gallery items (images and YouTube links)';

-- Create type for gallery item validation
DO $$ BEGIN
  CREATE TYPE gallery_item_type AS ENUM ('image', 'youtube');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

-- Add validation check for gallery_items
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

-- Add sample data for existing posts
UPDATE posts
SET 
  intro_text = CASE 
    WHEN slug = 'umaine-black-bear-athletics' 
      THEN 'Through our enduring partnership with UMaine Athletics, we''ve witnessed firsthand how sports can transform lives and unite communities. This collaboration represents more than just sponsorship – it''s an investment in Maine''s future leaders.'
    WHEN slug = 'maine-mariners-hockey'
      THEN '"The partnership between the Maine Mariners and Quirk Auto Group exemplifies what community support should look like. Together, we''re not just growing hockey in Maine; we''re building stronger communities."'
    WHEN slug = 'maine-veterans-project-support'
      THEN 'Last year alone, our support helped provide emergency assistance to over 100 Maine veterans, demonstrating the tangible impact of community partnerships in action.'
    END,
  intro_style = CASE 
    WHEN slug = 'umaine-black-bear-athletics' THEN 'impact'
    WHEN slug = 'maine-mariners-hockey' THEN 'quote'
    WHEN slug = 'maine-veterans-project-support' THEN 'impact'
    END,
  gallery_items = CASE 
    WHEN slug = 'umaine-black-bear-athletics' 
      THEN '[
        {"type": "image", "url": "https://images.unsplash.com/photo-1461896836934-ffe607ba8211?auto=format&fit=crop&w=800&h=600", "caption": "UMaine Football Season Opener"},
        {"type": "youtube", "url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ", "title": "UMaine Athletics Highlight Reel"},
        {"type": "image", "url": "https://images.unsplash.com/photo-1519766304817-4f37bda74a26?auto=format&fit=crop&w=800&h=600", "caption": "Student Athletes in Action"}
      ]'::jsonb
    WHEN slug = 'maine-mariners-hockey'
      THEN '[
        {"type": "youtube", "url": "https://www.youtube.com/watch?v=jNQXAC9IVRw", "title": "Maine Mariners Season Highlights"},
        {"type": "image", "url": "https://images.unsplash.com/photo-1580748141549-71748dbe0bdc?auto=format&fit=crop&w=800&h=600", "caption": "Youth Hockey Night"},
        {"type": "image", "url": "https://images.unsplash.com/photo-1515703407324-5f73fb9696b4?auto=format&fit=crop&w=800&h=600", "caption": "Community Skating Event"}
      ]'::jsonb
    END
WHERE slug IN (
  'umaine-black-bear-athletics',
  'maine-mariners-hockey',
  'maine-veterans-project-support'
);