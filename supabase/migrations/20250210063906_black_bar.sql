-- Create function to format location for search
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
    'quirk_location', jsonb_build_object(
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
      'featured_image_url', location_record.location_featured_image
    ),
    'url', 'https://me.quirkauto.com/locations/' || location_record.slug,
    'additional_data', jsonb_build_object(
      'slug', location_record.slug,
      'youtube_profile', location_record.youtube_profile,
      'created_at', location_record.created_at,
      'updated_at', location_record.updated_at
    ),
    '_created_at', EXTRACT(EPOCH FROM location_record.created_at),
    '_updated_at', EXTRACT(EPOCH FROM location_record.updated_at)
  );
END;
$$ LANGUAGE plpgsql;

-- Update format_job_for_search function to properly handle location featured image
CREATE OR REPLACE FUNCTION format_job_for_search(job_record jobs)
RETURNS jsonb AS $$
DECLARE
  location_data jsonb;
  featured_image_url text;
  job_url text;
BEGIN
  -- Get first location data and featured image
  SELECT 
    jsonb_build_object(
      'id', ql.id,
      'title', ql.title,
      'city', ql.city,
      'featured_image_url', ql.location_featured_image
    ),
    ql.location_featured_image INTO location_data, featured_image_url
  FROM job_locations jl
  JOIN quirk_locations ql ON jl.location_id = ql.id
  WHERE jl.job_id = job_record.id
  LIMIT 1;

  -- Build job URL
  job_url := 'https://me.quirkauto.com/careers/' || job_record.id;

  -- Return formatted document with featured image from location
  RETURN jsonb_build_object(
    'id', 'job_' || job_record.id,
    'type', 'job',
    'title', job_record.title,
    'description', COALESCE(
      job_record.description,
      'Join our team at Quirk Auto Group! This position offers competitive benefits, a great work environment, and opportunities for growth.'
    ),
    'featured_image_url', featured_image_url, -- Use location's featured image
    'quirk_location', location_data,
    'url', job_url,
    'additional_data', jsonb_build_object(
      'department', job_record.department,
      'employment_type', job_record.employment_type,
      'salary_range', job_record.salary_range,
      'requirements', job_record.requirements,
      'benefits', job_record.benefits,
      'application_url', job_record.application_url,
      'is_active', job_record.is_active,
      'created_at', job_record.created_at,
      'updated_at', job_record.updated_at
    ),
    '_created_at', EXTRACT(EPOCH FROM job_record.created_at),
    '_updated_at', EXTRACT(EPOCH FROM job_record.updated_at)
  );
END;
$$ LANGUAGE plpgsql;

-- Update sync_content_to_search function to use proper formatters
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
BEGIN
  -- Get Meilisearch config
  SELECT * INTO config FROM get_meilisearch_config();
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Meilisearch configuration not found';
  END IF;

  -- Set content type based on table
  content_type := TG_TABLE_NAME;

  -- Handle different operations
  CASE TG_OP
    WHEN 'DELETE' THEN
      -- Delete from index
      endpoint := config.host || '/indexes/content/documents/' || 
        CASE content_type
          WHEN 'iyc' THEN 'iyc_'
          WHEN 'jobs' THEN 'job_'
          WHEN 'posts' THEN 'post_'
          WHEN 'quirk_locations' THEN 'location_'
        END || OLD.id;
      
      -- Make DELETE request
      SELECT status, content::text
      INTO response_status, response_body
      FROM http_delete(
        endpoint,
        ARRAY[('Authorization', 'Bearer ' || config.api_key)::http_header]
      );

    WHEN 'INSERT', 'UPDATE' THEN
      -- Only index if content is active/published
      IF (content_type = 'jobs' AND NEW.is_active) OR 
         ((content_type = 'iyc' OR content_type = 'posts') AND NEW.published) OR
         content_type = 'quirk_locations' THEN
        
        -- Format document based on content type
        document := CASE content_type
          WHEN 'jobs' THEN
            format_job_for_search(NEW)
          WHEN 'quirk_locations' THEN
            format_location_for_search(NEW)
          ELSE
            format_content_for_search(
              content_type,
              NEW.id,
              NEW.title,
              COALESCE(NEW.excerpt, substring(NEW.content from 1 for 500)),
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

        -- Make POST request
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
COMMENT ON FUNCTION format_location_for_search IS 'Formats Quirk location for unified search index';
COMMENT ON FUNCTION format_job_for_search IS 'Formats job listing for unified search index with location featured image';
COMMENT ON FUNCTION sync_content_to_search IS 'Syncs all content types to unified search index with proper formatting';