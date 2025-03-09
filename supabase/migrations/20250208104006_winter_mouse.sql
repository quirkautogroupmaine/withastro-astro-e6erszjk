-- Create function to get location post counts
CREATE OR REPLACE FUNCTION get_location_post_counts()
RETURNS TABLE (
  location_id uuid,
  location_title text,
  post_count bigint
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    ql.id as location_id,
    ql.title as location_title,
    COUNT(i.id)::bigint as post_count
  FROM quirk_locations ql
  LEFT JOIN iyc i ON i.quirk_location_id = ql.id
  GROUP BY ql.id, ql.title
  HAVING COUNT(i.id) > 0
  ORDER BY ql.title;
END;
$$ LANGUAGE plpgsql;

-- Create function to get town post counts
CREATE OR REPLACE FUNCTION get_town_post_counts()
RETURNS TABLE (
  town_id uuid,
  town_name text,
  post_count bigint
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    mc.id as town_id,
    mc.name as town_name,
    COUNT(i.id)::bigint as post_count
  FROM maine_cities mc
  LEFT JOIN iyc i ON i.location_id = mc.id
  GROUP BY mc.id, mc.name
  HAVING COUNT(i.id) > 0
  ORDER BY mc.name;
END;
$$ LANGUAGE plpgsql;

-- Add comments for documentation
COMMENT ON FUNCTION get_location_post_counts IS 'Returns post counts for each Quirk location';
COMMENT ON FUNCTION get_town_post_counts IS 'Returns post counts for each Maine town';