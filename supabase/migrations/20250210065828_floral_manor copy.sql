-- Create function to format quirk location for search
CREATE OR REPLACE FUNCTION format_location_for_search(location_record quirk_locations)
RETURNS jsonb AS $$
BEGIN
  RETURN jsonb_build_object(
    'id', 'location_' || location_record.id,
    'type', 'location',
    'title', location_record.title,
    'description', COALESCE(
      location_record.content_description,
      'Visit ' || location_record.title || ' in ' || location_record.city || ', ' || location_record.state
    ),
    'featured_image_url', location_record.location_featured_image,
    'location', jsonb_build_object(
      'id', location_record.id,
      'title', location_record.title,
      'city', location_record.city,
      'state', location_record.state,
      'zip_code', location_record.zip_code,
      'physical_address', location_record.physical_address,
      'website', location_record.website,
      'facebook', location_record.facebook,
      'instagram', location_record.instagram,
      'gmb', location_record.gmb,
      'featured_image_url', location_record.location_featured_image,
      'logo_url', location_record.location_logo
    ),
    'url', 'https://me.quirkauto.com/locations/' || location_record.slug,
    'additional_data', jsonb_build_object(
      'slug', location_record.slug,
      'youtube_profile', location_record.youtube_profile,
      'created_at', location_record.created_at,
      'updated_at', location_record.updated_at,
      'content_description', location_record.content_description
    ),
    '_created_at', EXTRACT(EPOCH FROM location_record.created_at),
    '_updated_at', EXTRACT(EPOCH FROM location_record.updated_at),
    '_searchable_text', location_record.title || ' ' || 
                       location_record.city || ' ' || 
                       location_record.state || ' ' || 
                       COALESCE(location_record.content_description, '') || ' ' ||
                       COALESCE(location_record.physical_address, '')
  );
END;
$$ LANGUAGE plpgsql;

-- Update sync_to_unified_search function to handle location changes
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

-- Add comments for documentation
COMMENT ON FUNCTION format_location_for_search IS 'Formats Quirk location data for unified search index with enhanced searchable text';
COMMENT ON FUNCTION sync_to_unified_search IS 'Syncs all content types including locations to unified search index with improved handling';