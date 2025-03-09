-- Add "It's Your Car" category if it doesn't exist
INSERT INTO categories (name, slug)
VALUES ('It''s Your Car', 'its-your-car')
ON CONFLICT (slug) DO NOTHING;

-- Add category association to existing posts
INSERT INTO post_categories (post_id, category_id)
SELECT p.id, c.id
FROM posts p
CROSS JOIN categories c
WHERE c.slug = 'its-your-car'
AND p.title ILIKE '%It''s Your Car%'
AND NOT EXISTS (
  SELECT 1 FROM post_categories pc 
  WHERE pc.post_id = p.id 
  AND pc.category_id = c.id
);