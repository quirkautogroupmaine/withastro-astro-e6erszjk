-- Create view for sync counts
CREATE OR REPLACE VIEW content_sync_counts AS
SELECT
  (SELECT COUNT(*) FROM iyc WHERE published = true) as iyc_count,
  (SELECT COUNT(*) FROM jobs WHERE is_active = true) as jobs_count,
  (SELECT COUNT(*) FROM posts WHERE published = true) as posts_count,
  (SELECT COUNT(*) FROM quirk_locations) as locations_count,
  (SELECT COUNT(*) FROM iyc WHERE published = true) +
  (SELECT COUNT(*) FROM jobs WHERE is_active = true) +
  (SELECT COUNT(*) FROM posts WHERE published = true) +
  (SELECT COUNT(*) FROM quirk_locations) as total_count;

-- Update unified search sync function to properly handle locations
CREATE OR REPLACE FUNCTION sync_to_unified_search()
RETURNS trigger AS $$
DECLARE
  config record;
  document jsonb;
  endpoint text;
  payload jsonb;
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
      PERFORM net.http_delete(
        url := config.host || '/indexes/unified/documents/' || document_id,
        headers := jsonb_build_object(
          'Authorization', 'Bearer ' || config.api_key
        )
      );

    WHEN 'INSERT', 'UPDATE' THEN
      -- Format document based on content type
      document := CASE content_type
        WHEN 'quirk_locations' THEN
          format_location_for_search(NEW)
        ELSE
          format_content_for_search(
            content_type,
            NEW.id,
            NEW.title,
            CASE content_type
              WHEN 'jobs' THEN NEW.description
              ELSE COALESCE(NEW.excerpt, substring(NEW.content from 1 for 500))
            END,
            COALESCE(NEW.featured_image_url, 
              (SELECT location_featured_image 
               FROM quirk_locations 
               WHERE id = NEW.quirk_location_id)
            ),
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

      -- Always index locations, check conditions for other content types
      IF content_type = 'quirk_locations' OR
         (content_type = 'jobs' AND NEW.is_active) OR 
         ((content_type = 'iyc' OR content_type = 'posts') AND NEW.published) THEN
        
        -- Make POST request to unified index
        PERFORM net.http_post(
          url := config.host || '/indexes/unified/documents',
          headers := jsonb_build_object(
            'Authorization', 'Bearer ' || config.api_key,
            'Content-Type', 'application/json'
          ),
          body := jsonb_build_array(document)
        );
      ELSE
        -- If content becomes inactive/unpublished, delete from index
        PERFORM net.http_delete(
          url := config.host || '/indexes/unified/documents/' || document_id,
          headers := jsonb_build_object(
            'Authorization', 'Bearer ' || config.api_key
          )
        );
      END IF;
  END CASE;

  RETURN COALESCE(NEW, OLD);
EXCEPTION
  WHEN others THEN
    RAISE WARNING 'Meilisearch sync error: %', SQLERRM;
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Update unified page to use new view
CREATE OR REPLACE FUNCTION get_sync_counts()
RETURNS TABLE (
  iyc_count bigint,
  jobs_count bigint,
  posts_count bigint,
  locations_count bigint,
  total_count bigint
) AS $$
BEGIN
  RETURN QUERY
  SELECT * FROM content_sync_counts;
END;
$$ LANGUAGE plpgsql;

-- Add comments for documentation
COMMENT ON VIEW content_sync_counts IS 'View providing counts of content ready for search indexing';
COMMENT ON FUNCTION get_sync_counts IS 'Function to retrieve content counts for search sync';