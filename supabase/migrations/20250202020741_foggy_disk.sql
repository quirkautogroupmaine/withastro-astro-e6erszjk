-- Update materialized view to sort by updated_at
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
  l.name as location_name,
  array_agg(DISTINCT c.name) as category_names,
  array_agg(DISTINCT c.slug) as category_slugs
FROM posts p
LEFT JOIN locations l ON p.location_id = l.id
LEFT JOIN post_categories pc ON p.id = pc.post_id
LEFT JOIN categories c ON pc.category_id = c.id
WHERE p.published = true
GROUP BY p.id, p.title, p.slug, p.excerpt, p.featured_image_url, p.published_at, p.created_at, p.updated_at, p.location_id, l.name
ORDER BY p.updated_at DESC;

-- Create unique index on materialized view
CREATE UNIQUE INDEX IF NOT EXISTS idx_mv_post_summaries_id ON mv_post_summaries (id);

-- Add index for updated_at sorting if not exists
CREATE INDEX IF NOT EXISTS idx_posts_updated_at ON posts(updated_at DESC);

-- Update refresh function to maintain order
CREATE OR REPLACE FUNCTION refresh_post_summaries()
RETURNS trigger AS $$
BEGIN
  REFRESH MATERIALIZED VIEW CONCURRENTLY mv_post_summaries;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;