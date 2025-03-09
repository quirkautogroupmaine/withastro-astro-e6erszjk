-- Add published column if it doesn't exist
ALTER TABLE iyc
ADD COLUMN IF NOT EXISTS published boolean DEFAULT false;

-- Update sync function to properly handle published state
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
      IF NEW.published THEN
        document := format_iyc_for_meilisearch(NEW);
        endpoint := config.host || '/indexes/iyc/documents';
        payload := jsonb_build_array(document);
      ELSE
        -- Skip indexing for unpublished posts
        RETURN NEW;
      END IF;
      
    WHEN 'UPDATE' THEN
      -- If post was published and is now unpublished, delete from index
      IF (OLD.published IS TRUE AND NEW.published IS FALSE) THEN
        endpoint := config.host || '/indexes/iyc/documents/' || NEW.id;
        -- DELETE request will be made
      -- If post was unpublished and is now published, add to index
      ELSIF (OLD.published IS NOT TRUE AND NEW.published IS TRUE) THEN
        document := format_iyc_for_meilisearch(NEW);
        endpoint := config.host || '/indexes/iyc/documents';
        payload := jsonb_build_array(document);
      -- If post remains published and content changed, update index
      ELSIF NEW.published IS TRUE AND (
        OLD.title IS DISTINCT FROM NEW.title OR
        OLD.excerpt IS DISTINCT FROM NEW.excerpt OR
        OLD.content IS DISTINCT FROM NEW.content OR
        OLD.enhanced_content IS DISTINCT FROM NEW.enhanced_content OR
        OLD.featured_image_url IS DISTINCT FROM NEW.featured_image_url OR
        OLD.location_id IS DISTINCT FROM NEW.location_id OR
        OLD.quirk_location_id IS DISTINCT FROM NEW.quirk_location_id
      ) THEN
        document := format_iyc_for_meilisearch(NEW);
        endpoint := config.host || '/indexes/iyc/documents';
        payload := jsonb_build_array(document);
      ELSE
        -- No index update needed
        RETURN NEW;
      END IF;
      
    WHEN 'DELETE' THEN
      -- Only delete from index if post was published
      IF OLD.published THEN
        endpoint := config.host || '/indexes/iyc/documents/' || OLD.id;
      ELSE
        -- Skip if post wasn't published
        RETURN OLD;
      END IF;
  END CASE;

  -- Make request to Meilisearch with error handling
  BEGIN
    IF (TG_OP = 'DELETE') OR (TG_OP = 'UPDATE' AND OLD.published IS TRUE AND NEW.published IS FALSE) THEN
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

-- Add comment for documentation
COMMENT ON FUNCTION sync_iyc_to_meilisearch IS 'Syncs IYC posts to Meilisearch with improved published state handling';

-- Recreate trigger
DROP TRIGGER IF EXISTS iyc_meilisearch_sync ON iyc;
CREATE TRIGGER iyc_meilisearch_sync
  AFTER INSERT OR UPDATE OR DELETE ON iyc
  FOR EACH ROW
  EXECUTE FUNCTION sync_iyc_to_meilisearch();