-- Add function to handle custom dates for posts
CREATE OR REPLACE FUNCTION handle_post_dates()
RETURNS trigger AS $$
BEGIN
  -- For new posts
  IF TG_OP = 'INSERT' THEN
    -- If created_at is not provided, use current timestamp
    IF NEW.created_at IS NULL THEN
      NEW.created_at = now();
    END IF;
    -- If updated_at is not provided, use created_at
    IF NEW.updated_at IS NULL THEN
      NEW.updated_at = NEW.created_at;
    END IF;
  -- For updates
  ELSIF TG_OP = 'UPDATE' THEN
    -- If updated_at is not explicitly set, use current timestamp
    IF NEW.updated_at = OLD.updated_at THEN
      NEW.updated_at = now();
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for post dates
DROP TRIGGER IF EXISTS handle_post_dates_trigger ON posts;
CREATE TRIGGER handle_post_dates_trigger
  BEFORE INSERT OR UPDATE ON posts
  FOR EACH ROW
  EXECUTE FUNCTION handle_post_dates();

-- Update materialized view to use updated_at for sorting
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
GROUP BY p.id, p.title, p.slug, p.excerpt, p.featured_image_url, p.published_at, p.created_at, p.updated_at, p.location_id, l.name;

-- Create unique index on materialized view
CREATE UNIQUE INDEX idx_mv_post_summaries_id ON mv_post_summaries (id);

-- Add index for updated_at sorting
CREATE INDEX IF NOT EXISTS idx_posts_updated_at ON posts(updated_at DESC);

-- Update existing queries to sort by updated_at
CREATE OR REPLACE FUNCTION get_posts_by_category(category_slug text, limit_val integer)
RETURNS TABLE (
  id uuid,
  title text,
  slug text,
  excerpt text,
  featured_image_url text,
  published_at timestamptz,
  updated_at timestamptz
) AS $$
BEGIN
  RETURN QUERY
  SELECT DISTINCT p.id, p.title, p.slug, p.excerpt, p.featured_image_url, p.published_at, p.updated_at
  FROM posts p
  JOIN post_categories pc ON p.id = pc.post_id
  JOIN categories c ON pc.category_id = c.id
  WHERE c.slug = category_slug
  AND p.published = true
  ORDER BY p.updated_at DESC
  LIMIT limit_val;
END;
$$ LANGUAGE plpgsql;