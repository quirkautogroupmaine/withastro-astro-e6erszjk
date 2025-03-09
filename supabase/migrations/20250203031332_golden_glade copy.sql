-- Add post_rank and isSticky columns to posts table
ALTER TABLE posts
ADD COLUMN post_rank integer NOT NULL DEFAULT 99,
ADD COLUMN is_sticky boolean NOT NULL DEFAULT false;

-- Add index for post sorting
CREATE INDEX idx_posts_rank_sticky ON posts(is_sticky DESC, post_rank ASC, updated_at DESC);

-- Add comments for documentation
COMMENT ON COLUMN posts.post_rank IS 'Lower numbers appear first in listings (default: 99)';
COMMENT ON COLUMN posts.is_sticky IS 'Whether the post should appear at the top of listings';

-- Update materialized view to include new sorting fields
DROP MATERIALIZED VIEW IF EXISTS mv_post_summaries;
CREATE MATERIALIZED VIEW mv_post_summaries AS
SELECT 
  p.id,
  p.title,
  p.slug,
  p.excerpt,
  p.featured_image_url,
  p.published_at,
  p.created_at,
  p.updated_at,
  p.location_id,
  p.post_rank,
  p.is_sticky,
  l.name as location_name,
  array_agg(DISTINCT c.name) as category_names,
  array_agg(DISTINCT c.slug) as category_slugs
FROM posts p
LEFT JOIN locations l ON p.location_id = l.id
LEFT JOIN post_categories pc ON p.id = pc.post_id
LEFT JOIN categories c ON pc.category_id = c.id
WHERE p.published = true
GROUP BY p.id, p.title, p.slug, p.excerpt, p.featured_image_url, p.published_at, 
         p.created_at, p.updated_at, p.location_id, p.post_rank, p.is_sticky, l.name
ORDER BY p.is_sticky DESC, p.post_rank ASC, p.updated_at DESC;

-- Create unique index on materialized view
CREATE UNIQUE INDEX idx_mv_post_summaries_id ON mv_post_summaries (id);