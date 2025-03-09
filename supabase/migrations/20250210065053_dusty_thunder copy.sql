-- Drop existing triggers
DROP TRIGGER IF EXISTS unified_search_sync ON iyc;
DROP TRIGGER IF EXISTS unified_search_sync ON jobs;
DROP TRIGGER IF EXISTS unified_search_sync ON posts;
DROP TRIGGER IF EXISTS unified_search_sync ON quirk_locations;

-- Create enhanced unified sync function
CREATE OR REPLACE FUNCTION sync_to_unified_search()
RETURNS trigger AS $$
DECLARE
  config record;
  document jsonb;
  endpoint text;
  payload jsonb;
  response_status integer;
  response_body text;
  content_type text;
  document_id text;
BEGIN
  -- Get Meilisearch config
  SELECT * INTO config FROM get_meilisearch_config();
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Meilisearch configuration not found';
  END IF;

  -- Set content type based on table
  content_type := TG_TABLE_NAME;

  -- Set document ID with prefix to avoid collisions
  document_id := CASE content_type
    WHEN 'iyc' THEN 'iyc_'
    WHEN 'jobs' THEN 'job_'
    WHEN 'posts' THEN 'post_'
    WHEN 'quirk_locations' THEN 'location_'
  END || CASE 
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
      -- Format document based on content type
      document := CASE content_type
        WHEN 'quirk_locations' THEN
          jsonb_build_object(
            'id', document_id,
            'type', 'location',
            'title', NEW.title,
            'description', COALESCE(
              NEW.content_description,
              'Visit ' || NEW.title || ' in ' || NEW.city || ', ' || NEW.state
            ),
            'featured_image_url', NEW.location_featured_image,
            'location', jsonb_build_object(
              'id', NEW.id,
              'title', NEW.title,
              'city', NEW.city,
              'state', NEW.state,
              'zip_code', NEW.zip_code,
              'physical_address', NEW.physical_address,
              'website', NEW.website,
              'facebook', NEW.facebook,
              'instagram', NEW.instagram,
              'gmb', NEW.gmb
            ),
            'url', 'https://me.quirkauto.com/locations/' || NEW.slug,
            'created_at', NEW.created_at,
            'updated_at', NEW.updated_at
          )
        ELSE
          jsonb_build_object(
            'id', document_id,
            'type', content_type,
            'title', NEW.title,
            'description', CASE content_type
              WHEN 'jobs' THEN NEW.description
              ELSE COALESCE(NEW.excerpt, substring(NEW.content from 1 for 500))
            END,
            'featured_image_url', COALESCE(
              NEW.featured_image_url,
              (SELECT location_featured_image 
               FROM quirk_locations 
               WHERE id = NEW.quirk_location_id)
            ),
            'location', (
              SELECT jsonb_build_object(
                'id', ql.id,
                'title', ql.title,
                'city', ql.city,
                'state', ql.state
              )
              FROM quirk_locations ql
              WHERE ql.id = NEW.quirk_location_id
            ),
            'url', CASE content_type
              WHEN 'iyc' THEN 'https://me.quirkauto.com/its-your-car/' || NEW.slug
              WHEN 'jobs' THEN 'https://me.quirkauto.com/careers/' || NEW.id
              WHEN 'posts' THEN 'https://me.quirkauto.com/posts/' || NEW.slug
            END,
            'created_at', NEW.created_at,
            'updated_at', NEW.updated_at
          )
      END;

      -- Only proceed if document should be indexed
      IF content_type = 'quirk_locations' OR
         (content_type = 'jobs' AND NEW.is_active) OR 
         ((content_type = 'iyc' OR content_type = 'posts') AND NEW.published) THEN
        
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
CREATE TRIGGER unified_search_sync
  AFTER INSERT OR UPDATE OR DELETE ON iyc
  FOR EACH ROW
  EXECUTE FUNCTION sync_to_unified_search();

CREATE TRIGGER unified_search_sync
  AFTER INSERT OR UPDATE OR DELETE ON jobs
  FOR EACH ROW
  EXECUTE FUNCTION sync_to_unified_search();

CREATE TRIGGER unified_search_sync
  AFTER INSERT OR UPDATE OR DELETE ON posts
  FOR EACH ROW
  EXECUTE FUNCTION sync_to_unified_search();

CREATE TRIGGER unified_search_sync
  AFTER INSERT OR UPDATE OR DELETE ON quirk_locations
  FOR EACH ROW
  EXECUTE FUNCTION sync_to_unified_search();

-- Add comments for documentation
COMMENT ON FUNCTION sync_to_unified_search IS 'Syncs all content types including locations to a single unified search index';