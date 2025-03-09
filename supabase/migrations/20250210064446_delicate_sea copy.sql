-- Drop existing triggers
DROP TRIGGER IF EXISTS content_search_sync ON iyc;
DROP TRIGGER IF EXISTS content_search_sync ON jobs;
DROP TRIGGER IF EXISTS content_search_sync ON posts;
DROP TRIGGER IF EXISTS content_search_sync ON quirk_locations;

-- Create enhanced unified sync function
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
  content_prefix text;
  document_id text;
BEGIN
  -- Get Meilisearch config
  SELECT * INTO config FROM get_meilisearch_config();
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Meilisearch configuration not found';
  END IF;

  -- Set content type and prefix based on table
  content_type := TG_TABLE_NAME;
  content_prefix := CASE content_type
    WHEN 'iyc' THEN 'iyc_'
    WHEN 'jobs' THEN 'job_'
    WHEN 'posts' THEN 'post_'
    WHEN 'quirk_locations' THEN 'location_'
    ELSE ''
  END;

  -- Set document ID
  document_id := content_prefix || CASE 
    WHEN TG_OP = 'DELETE' THEN OLD.id
    ELSE NEW.id
  END;

  -- Handle different operations
  CASE TG_OP
    WHEN 'DELETE' THEN
      -- Delete from unified index
      endpoint := config.host || '/indexes/unified/documents/' || document_id;
      
      -- Make DELETE request
      SELECT status, content::text
      INTO response_status, response_body
      FROM http_delete(
        endpoint,
        ARRAY[('Authorization', 'Bearer ' || config.api_key)::http_header]
      );

    WHEN 'INSERT', 'UPDATE' THEN
      -- Only index if content is active/published (except locations which are always indexed)
      IF content_type = 'quirk_locations' OR
         (content_type = 'jobs' AND NEW.is_active) OR 
         ((content_type = 'iyc' OR content_type = 'posts') AND NEW.published) THEN
        
        -- Format document based on content type
        document := CASE content_type
          WHEN 'quirk_locations' THEN
            format_quirk_location_for_search(NEW)
          WHEN 'jobs' THEN
            format_job_for_search(NEW)
          ELSE
            format_content_for_search(
              content_type,
              NEW.id,
              NEW.title,
              CASE content_type
                WHEN 'jobs' THEN NEW.description
                ELSE COALESCE(NEW.excerpt, substring(NEW.content from 1 for 500))
              END,
              NEW.featured_image_url,
              NEW.quirk_location_id,
              jsonb_build_object(
                'slug', NEW.slug,
                'excerpt', NEW.excerpt,
                'content', NEW.content,
                'created_at', NEW.created_at,
                'updated_at', NEW.updated_at,
                'location_id', NEW.location_id
              )
            )
        END;

        -- Make POST request to unified index
        endpoint := config.host || '/indexes/unified/documents';
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
      ELSE
        -- If content becomes inactive/unpublished, delete from index
        endpoint := config.host || '/indexes/unified/documents/' || document_id;
        SELECT status, content::text
        INTO response_status, response_body
        FROM http_delete(
          endpoint,
          ARRAY[('Authorization', 'Bearer ' || config.api_key)::http_header]
        );
      END IF;
  END CASE;

  -- Check response
  IF response_status NOT IN (200, 201, 202, 204) THEN
    RAISE WARNING 'Meilisearch API request failed with status % - %', response_status, response_body;
  END IF;

  RETURN COALESCE(NEW, OLD);
EXCEPTION
  WHEN others THEN
    RAISE WARNING 'Meilisearch sync error: %', SQLERRM;
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

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

CREATE TRIGGER content_search_sync
  AFTER INSERT OR UPDATE OR DELETE ON quirk_locations
  FOR EACH ROW
  EXECUTE FUNCTION sync_content_to_search();

-- Add comments for documentation
COMMENT ON FUNCTION sync_content_to_search IS 'Syncs all content types to unified search index with proper formatting';