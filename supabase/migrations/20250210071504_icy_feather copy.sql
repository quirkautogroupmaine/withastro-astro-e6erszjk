-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS pg_net;

-- Update Meilisearch index settings for unified search
DO $$
DECLARE
  config record;
  settings jsonb;
  response jsonb;
BEGIN
  -- Get Meilisearch config
  SELECT * INTO config FROM get_meilisearch_config();
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Meilisearch configuration not found';
  END IF;

  -- Define enhanced settings
  settings := jsonb_build_object(
    'searchableAttributes', jsonb_build_array(
      'title',
      'description',
      '_searchable_text',
      'location.title',
      'location.city',
      'location.state',
      'additional_data.content_description',
      'additional_data.excerpt',
      'additional_data.content'
    ),
    'filterableAttributes', jsonb_build_array(
      'type',
      'location.id',
      'location.city',
      'location.state',
      'additional_data.published',
      'additional_data.is_active',
      'additional_data.post_rank',
      'additional_data.is_sticky',
      'additional_data.department',
      'additional_data.employment_type'
    ),
    'sortableAttributes', jsonb_build_array(
      '_created_at',
      '_updated_at',
      'additional_data.post_rank'
    ),
    'rankingRules', jsonb_build_array(
      'words',
      'typo',
      'proximity',
      'attribute',
      'sort',
      'exactness'
    ),
    'distinctAttribute', 'id'
  );

  -- Update index settings using net.http_post
  PERFORM net.http_post(
    url := config.host || '/indexes/unified/settings',
    headers := jsonb_build_object(
      'Authorization', 'Bearer ' || config.api_key,
      'Content-Type', 'application/json'
    ),
    body := settings
  );

  -- Force reindex of all content
  UPDATE quirk_locations SET updated_at = now();
  UPDATE iyc SET updated_at = now() WHERE published = true;
  UPDATE jobs SET updated_at = now() WHERE is_active = true;
  UPDATE posts SET updated_at = now() WHERE published = true;
END $$;

-- Update sync_to_unified_search function to use net.http functions
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

      -- Only proceed if document should be indexed
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

-- Add comments for documentation
COMMENT ON FUNCTION sync_to_unified_search IS 'Syncs all content types to unified search index using net.http functions';