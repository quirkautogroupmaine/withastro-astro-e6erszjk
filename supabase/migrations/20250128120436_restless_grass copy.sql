-- Add composite indexes for frequently queried columns
CREATE INDEX IF NOT EXISTS idx_posts_published_date ON posts (published, published_at DESC);
CREATE INDEX IF NOT EXISTS idx_posts_slug ON posts (slug) WHERE published = true;
CREATE INDEX IF NOT EXISTS idx_post_categories_category ON post_categories (category_id, post_id);
CREATE INDEX IF NOT EXISTS idx_posts_location ON posts (location_id) WHERE published = true;

-- Add GiST index for full text search
CREATE INDEX IF NOT EXISTS idx_posts_search_gist ON posts USING gist(search_vector);

-- Add index for category filtering
CREATE INDEX IF NOT EXISTS idx_categories_slug ON categories (slug);

-- Add index for location filtering
CREATE INDEX IF NOT EXISTS idx_locations_slug ON locations (slug);

-- Add index for organization filtering
CREATE INDEX IF NOT EXISTS idx_organizations_slug ON organizations (slug);

-- Add partial index for published posts
CREATE INDEX IF NOT EXISTS idx_posts_published ON posts (id) WHERE published = true;

-- Add index for post images
CREATE INDEX IF NOT EXISTS idx_post_images_post ON post_images (post_id, sort_order);

-- Add index for post categories join
CREATE INDEX IF NOT EXISTS idx_post_categories_join ON post_categories (post_id, category_id);

-- Add index for organization posts
CREATE INDEX IF NOT EXISTS idx_posts_organization ON posts (organization_id) WHERE published = true;

-- Add index for subcategory posts
CREATE INDEX IF NOT EXISTS idx_posts_subcategory ON posts (subcategory_id) WHERE published = true;

-- Add index for post dates
CREATE INDEX IF NOT EXISTS idx_posts_dates ON posts (created_at, updated_at);

-- Add index for organization names
CREATE INDEX IF NOT EXISTS idx_organizations_name ON organizations (name);

-- Add index for location names
CREATE INDEX IF NOT EXISTS idx_locations_name ON locations (name);

-- Add index for category names
CREATE INDEX IF NOT EXISTS idx_categories_name ON categories (name);

-- Add index for subcategory names
CREATE INDEX IF NOT EXISTS idx_subcategories_name ON subcategories (name);

-- Add materialized view for post summaries
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_post_summaries AS
SELECT 
  p.id,
  p.title,
  p.slug,
  p.excerpt,
  p.featured_image_url,
  p.published_at,
  p.location_id,
  l.name as location_name,
  array_agg(DISTINCT c.name) as category_names,
  array_agg(DISTINCT c.slug) as category_slugs
FROM posts p
LEFT JOIN locations l ON p.location_id = l.id
LEFT JOIN post_categories pc ON p.id = pc.post_id
LEFT JOIN categories c ON pc.category_id = c.id
WHERE p.published = true
GROUP BY p.id, p.title, p.slug, p.excerpt, p.featured_image_url, p.published_at, p.location_id, l.name;

-- Create unique index on materialized view
CREATE UNIQUE INDEX IF NOT EXISTS idx_mv_post_summaries_id ON mv_post_summaries (id);

-- Create function to refresh materialized view
CREATE OR REPLACE FUNCTION refresh_post_summaries()
RETURNS trigger AS $$
BEGIN
  REFRESH MATERIALIZED VIEW CONCURRENTLY mv_post_summaries;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to refresh materialized view
DROP TRIGGER IF EXISTS refresh_post_summaries_trigger ON posts;
CREATE TRIGGER refresh_post_summaries_trigger
AFTER INSERT OR UPDATE OR DELETE ON posts
FOR EACH STATEMENT
EXECUTE FUNCTION refresh_post_summaries();

-- Add comments
COMMENT ON MATERIALIZED VIEW mv_post_summaries IS 'Cached view of post summaries with categories and location';
COMMENT ON FUNCTION refresh_post_summaries() IS 'Function to refresh post summaries materialized view';