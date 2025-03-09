-- Create unified search index configuration
CREATE OR REPLACE FUNCTION format_content_for_search(
  content_type text,
  content_id uuid,
  title text,
  description text,
  featured_image_url text,
  quirk_location_id uuid,
  additional_data jsonb DEFAULT '{}'::jsonb
) RETURNS jsonb AS $$
DECLARE
  quirk_location_data jsonb;
  base_url text := 'https://me.quirkauto.com';
  url text;
BEGIN
  -- Get Quirk location data
  SELECT jsonb_build_object(
    'id', ql.id,
    'title', ql.title,
    'city', ql.city
  ) INTO quirk_location_data
  FROM quirk_locations ql
  WHERE ql.id = quirk_location_id;

  -- Build URL based on content type
  url := CASE content_type
    WHEN 'iyc' THEN base_url || '/its-your-car/' || (additional_data->>'slug')
    WHEN 'job' THEN base_url || '/careers/' || content_id
    WHEN 'post' THEN base_url || '/posts/' || (additional_data->>'slug')
    ELSE NULL
  END;

  -- Return formatted document
  RETURN jsonb_build_object(
    'id', content_id,
    'type', content_type,
    'title', title,
    'description', description,
    'featured_image_url', featured_image_url,
    'quirk_location', quirk_location_data,
    'url', url,
    'additional_data', additional_data,
    '_created_at', EXTRACT(EPOCH FROM (additional_data->>'created_at')::timestamptz),
    '_updated_at', EXTRACT(EPOCH FROM (additional_data->>'updated_at')::timestamptz)
  );
END;
$$ LANGUAGE plpgsql;

-- Create function to sync content to search
CREATE OR REPLACE FUNCTION sync_content_to_search()
RETURNS trigger AS $$
DECLARE
  config record;
  document jsonb;
  endpoint text;
  payload jsonb;
  response_status integer;
  response_body text;
  content_type text;
  additional_data jsonb;
BEGIN
  -- Get Meilisearch config
  SELECT * INTO config FROM get_meilisearch_config();
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Meilisearch configuration not found';
  END IF;

  -- Set content type based on table
  content_type := TG_TABLE_NAME;

  -- Build additional data based on content type
  CASE content_type
    WHEN 'iyc' THEN
      additional_data := jsonb_build_object(
        'slug', COALESCE(NEW.slug, OLD.slug),
        'excerpt', COALESCE(NEW.excerpt, OLD.excerpt),
        'created_at', COALESCE(NEW.created_at, OLD.created_at),
        'updated_at', COALESCE(NEW.updated_at, OLD.updated_at),
        'published_at', COALESCE(NEW.published_at, OLD.published_at)
      );
    WHEN 'jobs' THEN
      additional_data := jsonb_build_object(
        'department', COALESCE(NEW.department, OLD.department),
        'employment_type', COALESCE(NEW.employment_type, OLD.employment_type),
        'created_at', COALESCE(NEW.created_at, OLD.created_at),
        'updated_at', COALESCE(NEW.updated_at, OLD.updated_at)
      );
    WHEN 'posts' THEN
      additional_data := jsonb_build_object(
        'slug', COALESCE(NEW.slug, OLD.slug),
        'excerpt', COALESCE(NEW.excerpt, OLD.excerpt),
        'created_at', COALESCE(NEW.created_at, OLD.created_at),
        'updated_at', COALESCE(NEW.updated_at, OLD.updated_at),
        'published_at', COALESCE(NEW.published_at, OLD.published_at)
      );
  END CASE;

  -- Handle different operations
  CASE TG_OP
    WHEN 'INSERT' THEN
      -- Only index if content is active/published
      IF (content_type = 'jobs' AND NEW.is_active) OR 
         ((content_type = 'iyc' OR content_type = 'posts') AND NEW.published) THEN
        document := format_content_for_search(
          content_type,
          NEW.id,
          NEW.title,
          CASE content_type
            WHEN 'jobs' THEN NEW.description
            ELSE COALESCE(NEW.excerpt, substring(NEW.content from 1 for 500))
          END,
          NEW.featured_image_url,
          NEW.quirk_location_id,
          additional_data
        );
      ELSE
        RETURN NEW;
      END IF;
      
    WHEN 'UPDATE' THEN
      IF ((content_type = 'jobs' AND NEW.is_active) OR 
          ((content_type = 'iyc' OR content_type = 'posts') AND NEW.published)) THEN
        document := format_content_for_search(
          content_type,
          NEW.id,
          NEW.title,
          CASE content_type
            WHEN 'jobs' THEN NEW.description
            ELSE COALESCE(NEW.excerpt, substring(NEW.content from 1 for 500))
          END,
          NEW.featured_image_url,
          NEW.quirk_location_id,
          additional_data
        );
      ELSE
        -- Delete from index if inactive/unpublished
        endpoint := config.host || '/indexes/content/documents/' || NEW.id;
        -- No payload needed for DELETE
      END IF;
      
    WHEN 'DELETE' THEN
      -- Delete from index
      endpoint := config.host || '/indexes/content/documents/' || OLD.id;
      -- No payload needed for DELETE
  END CASE;

  -- Make request to Meilisearch
  BEGIN
    IF TG_OP = 'DELETE' OR 
       (TG_OP = 'UPDATE' AND (
         (content_type = 'jobs' AND NOT NEW.is_active) OR
         ((content_type = 'iyc' OR content_type = 'posts') AND NOT NEW.published)
       )) THEN
      -- DELETE request
      SELECT status, content::text
      INTO response_status, response_body
      FROM http_delete(
        endpoint,
        ARRAY[('Authorization', 'Bearer ' || config.api_key)::http_header]
      );
    ELSE
      -- POST request for INSERT or UPDATE
      endpoint := config.host || '/indexes/content/documents';
      payload := jsonb_build_array(document);
      
      SELECT status, content::text
      INTO response_status, response_body
      FROM http_post(
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
      RAISE WARNING 'Meilisearch API request failed with status % - %', response_status, response_body;
    END IF;

  EXCEPTION
    WHEN others THEN
      RAISE WARNING 'Meilisearch sync error: %', SQLERRM;
  END;

  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Drop existing triggers
DROP TRIGGER IF EXISTS iyc_meilisearch_sync ON iyc;
DROP TRIGGER IF EXISTS jobs_meilisearch_sync ON jobs;
DROP TRIGGER IF EXISTS posts_meilisearch_sync ON posts;

-- Create new triggers for unified search
CREATE TRIGGER content_search_sync
  AFTER INSERT OR UPDATE OR DELETE ON iyc
  FOR EACH ROW
  EXECUTE FUNCTION sync_content_to_search();

CREATE TRIGGER content_search_sync
  AFTER INSERT OR UPDATE OR DELETE ON jobs
  FOR EACH ROW
  EXECUTE FUNCTION sync_content_to_search();

CREATE TRIGGER content_search_sync
  AFTER INSERT OR UPDATE OR DELETE ON posts
  FOR EACH ROW
  EXECUTE FUNCTION sync_content_to_search();