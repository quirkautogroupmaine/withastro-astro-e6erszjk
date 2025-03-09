-- Update sync_iyc_to_meilisearch function with better error handling
CREATE OR REPLACE FUNCTION sync_iyc_to_meilisearch()
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

  -- Make request to Meilisearch with error handling
  BEGIN
    IF TG_OP = 'DELETE' OR (TG_OP = 'UPDATE' AND NEW.published = false) THEN
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
      RAISE EXCEPTION 'Meilisearch API request failed with status % - %', response_status, response_body;
    END IF;

  EXCEPTION
    WHEN others THEN
      -- Log error but don't block the transaction
      RAISE WARNING 'Meilisearch sync error: %', SQLERRM;
  END;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add comment for documentation
COMMENT ON FUNCTION sync_iyc_to_meilisearch IS 'Syncs IYC posts to Meilisearch with improved error handling';