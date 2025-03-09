-- Create configuration table for Meilisearch settings
CREATE TABLE meilisearch_config (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  host text NOT NULL,
  api_key text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Add RLS policies
ALTER TABLE meilisearch_config ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow read access for authenticated users"
ON meilisearch_config FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Allow write access for super admins"
ON meilisearch_config FOR ALL
TO authenticated
USING (auth.role() = 'super_admin')
WITH CHECK (auth.role() = 'super_admin');

-- Insert default configuration
INSERT INTO meilisearch_config (host, api_key)
VALUES (
  'http://localhost:7700',
  'f8a16ceaa05c3a1e7bf91f518b78e80f9836b58a'
);

-- Create function to get Meilisearch config
CREATE OR REPLACE FUNCTION get_meilisearch_config()
RETURNS TABLE (host text, api_key text) AS $$
BEGIN
  RETURN QUERY
  SELECT mc.host, mc.api_key
  FROM meilisearch_config mc
  LIMIT 1;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Update format_iyc_for_meilisearch function
CREATE OR REPLACE FUNCTION format_iyc_for_meilisearch(post_record iyc)
RETURNS jsonb AS $$
DECLARE
  location_data jsonb;
  quirk_location_data jsonb;
BEGIN
  -- Get location data
  SELECT jsonb_build_object(
    'id', mc.id,
    'name', mc.name
  ) INTO location_data
  FROM maine_cities mc
  WHERE mc.id = post_record.location_id;

  -- Get Quirk location data
  SELECT jsonb_build_object(
    'id', ql.id,
    'title', ql.title,
    'city', ql.city
  ) INTO quirk_location_data
  FROM quirk_locations ql
  WHERE ql.id = post_record.quirk_location_id;

  -- Return formatted document
  RETURN jsonb_build_object(
    'id', post_record.id,
    'title', post_record.title,
    'slug', post_record.slug,
    'excerpt', post_record.excerpt,
    'content', post_record.content,
    'enhanced_content', post_record.enhanced_content,
    'featured_image_url', post_record.featured_image_url,
    'published_at', post_record.published_at,
    'created_at', post_record.created_at,
    'updated_at', post_record.updated_at,
    'published', post_record.published,
    'location', location_data,
    'quirk_location', quirk_location_data
  );
END;
$$ LANGUAGE plpgsql;

-- Update sync_iyc_to_meilisearch function
CREATE OR REPLACE FUNCTION sync_iyc_to_meilisearch()
RETURNS trigger AS $$
DECLARE
  config record;
  document jsonb;
  endpoint text;
  payload jsonb;
  response_status integer;
BEGIN
  -- Get Meilisearch config
  SELECT * INTO config FROM get_meilisearch_config();
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Meilisearch configuration not found';
  END IF;

  -- Handle different operations
  CASE TG_OP
    WHEN 'INSERT' THEN
      -- Only index if published is true
      IF NEW.published = true THEN
        document := format_iyc_for_meilisearch(NEW);
        endpoint := config.host || '/indexes/iyc/documents';
        payload := jsonb_build_array(document);
      ELSE
        -- Skip indexing for unpublished posts
        RETURN NEW;
      END IF;
      
    WHEN 'UPDATE' THEN
      IF NEW.published = true THEN
        -- Index/update the document if it's published
        document := format_iyc_for_meilisearch(NEW);
        endpoint := config.host || '/indexes/iyc/documents';
        payload := jsonb_build_array(document);
      ELSE
        -- Delete from index if unpublished
        endpoint := config.host || '/indexes/iyc/documents/' || NEW.id;
        -- No payload needed for DELETE
      END IF;
      
    WHEN 'DELETE' THEN
      -- Always delete from index
      endpoint := config.host || '/indexes/iyc/documents/' || OLD.id;
      -- No payload needed for DELETE
  END CASE;

  -- Make request to Meilisearch
  IF TG_OP = 'DELETE' OR (TG_OP = 'UPDATE' AND NEW.published = false) THEN
    -- DELETE request
    SELECT status INTO response_status FROM http_delete(
      endpoint,
      ARRAY[
        ('Authorization', 'Bearer ' || config.api_key)::http_header
      ]
    );
  ELSE
    -- POST request for INSERT or UPDATE
    SELECT status INTO response_status FROM http_post(
      endpoint,
      payload::text,
      ARRAY[
        ('Authorization', 'Bearer ' || config.api_key)::http_header,
        ('Content-Type', 'application/json')::http_header
      ]
    );
  END IF;

  -- Check response
  IF response_status NOT IN (200, 201, 202, 204) THEN
    RAISE EXCEPTION 'Meilisearch API request failed with status %', response_status;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Recreate trigger for IYC posts
DROP TRIGGER IF EXISTS iyc_meilisearch_sync ON iyc;
CREATE TRIGGER iyc_meilisearch_sync
  AFTER INSERT OR UPDATE OR DELETE ON iyc
  FOR EACH ROW
  EXECUTE FUNCTION sync_iyc_to_meilisearch();