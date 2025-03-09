-- Create function to format job for Meilisearch
CREATE OR REPLACE FUNCTION format_job_for_meilisearch(job_record jobs)
RETURNS jsonb AS $$
DECLARE
  location_data jsonb;
  job_url text;
  featured_image_url text;
BEGIN
  -- Get first location data and featured image
  SELECT 
    jsonb_build_object(
      'LocationID', ql.id,
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

  -- Return formatted document
  RETURN jsonb_build_object(
    'id', job_record.id,
    'title', job_record.title,
    'department', job_record.department,
    'description', COALESCE(
      job_record.description,
      'Join our team at Quirk Auto Group! This position offers competitive benefits, a great work environment, and opportunities for growth.'
    ),
    'employment_type', job_record.employment_type,
    'is_active', job_record.is_active,
    'created_at', job_record.created_at,
    'updated_at', job_record.updated_at,
    'quirk_location', location_data,
    'featured_image_url', featured_image_url,
    'url', job_url
  );
END;
$$ LANGUAGE plpgsql;

-- Create function to sync job to Meilisearch
CREATE OR REPLACE FUNCTION sync_job_to_meilisearch()
RETURNS trigger AS $$
DECLARE
  config record;
  document jsonb;
  endpoint text;
  payload jsonb;
  response_status integer;
  response_body text;
BEGIN
  -- Get Meilisearch config
  SELECT * INTO config FROM get_meilisearch_config();
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Meilisearch configuration not found';
  END IF;

  -- Handle different operations
  CASE TG_OP
    WHEN 'INSERT' THEN
      -- Only index if job is active
      IF NEW.is_active THEN
        document := format_job_for_meilisearch(NEW);
        endpoint := config.host || '/indexes/jobs/documents';
        payload := jsonb_build_array(document);
      ELSE
        -- Skip indexing for inactive jobs
        RETURN NEW;
      END IF;
      
    WHEN 'UPDATE' THEN
      IF NEW.is_active THEN
        -- Index/update the document if it's active
        document := format_job_for_meilisearch(NEW);
        endpoint := config.host || '/indexes/jobs/documents';
        payload := jsonb_build_array(document);
      ELSE
        -- Delete from index if inactive
        endpoint := config.host || '/indexes/jobs/documents/' || NEW.id;
        -- No payload needed for DELETE
      END IF;
      
    WHEN 'DELETE' THEN
      -- Always delete from index
      endpoint := config.host || '/indexes/jobs/documents/' || OLD.id;
      -- No payload needed for DELETE
  END CASE;

  -- Make request to Meilisearch with error handling
  BEGIN
    IF (TG_OP = 'DELETE') OR (TG_OP = 'UPDATE' AND NOT NEW.is_active) THEN
      -- DELETE request
      SELECT 
        status,
        content::text
      INTO 
        response_status,
        response_body
      FROM http_delete(
        endpoint,
        ARRAY[
          ('Authorization', 'Bearer ' || config.api_key)::http_header
        ]
      );
    ELSE
      -- POST request for INSERT or UPDATE
      SELECT 
        status,
        content::text
      INTO 
        response_status,
        response_body
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
      -- Log error but don't block the transaction
      RAISE WARNING 'Meilisearch sync error: %', SQLERRM;
  END;

  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Create trigger for jobs
DROP TRIGGER IF EXISTS jobs_meilisearch_sync ON jobs;
CREATE TRIGGER jobs_meilisearch_sync
  AFTER INSERT OR UPDATE OR DELETE ON jobs
  FOR EACH ROW
  EXECUTE FUNCTION sync_job_to_meilisearch();

-- Add comment for documentation
COMMENT ON FUNCTION sync_job_to_meilisearch IS 'Syncs jobs to Meilisearch with improved active state handling';