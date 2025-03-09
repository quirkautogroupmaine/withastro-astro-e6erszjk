-- Create function to format post for Meilisearch
CREATE OR REPLACE FUNCTION format_post_for_meilisearch(post_record posts)
RETURNS jsonb AS $$
DECLARE
  location_data jsonb;
  categories_data jsonb;
  quirk_location_data jsonb;
BEGIN
  -- Get Quirk location data
  SELECT jsonb_build_object(
    'QuirkLocationID', ql.id,
    'title', ql.title,
    'city', ql.city,
    'featured_image_url', ql.location_featured_image
  ) INTO quirk_location_data
  FROM quirk_locations ql
  WHERE ql.id = post_record.quirk_location_id;

  -- Get categories data
  SELECT jsonb_agg(
    jsonb_build_object(
      'CategoryID', c.id,
      'name', c.name,
      'slug', c.slug
    )
  ) INTO categories_data
  FROM post_categories pc
  JOIN categories c ON pc.category_id = c.id
  WHERE pc.post_id = post_record.id;

  -- Return formatted document
  RETURN jsonb_build_object(
    'ID', post_record.id,
    'title', post_record.title,
    'slug', post_record.slug,
    'excerpt', post_record.excerpt,
    'content', post_record.content,
    'featured_image_url', post_record.featured_image_url,
    'published_at', post_record.published_at,
    'created_at', post_record.created_at,
    'updated_at', post_record.updated_at,
    'published', post_record.published,
    'post_rank', post_record.post_rank,
    'is_sticky', post_record.is_sticky,
    'quirk_location', quirk_location_data,
    'categories', categories_data,
    'url', 'https://me.quirkauto.com/posts/' || post_record.slug
  );
END;
$$ LANGUAGE plpgsql;

-- Create function to sync post to Meilisearch
CREATE OR REPLACE FUNCTION sync_post_to_meilisearch()
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
      -- Only index if post is published
      IF NEW.published THEN
        document := format_post_for_meilisearch(NEW);
        endpoint := config.host || '/indexes/posts/documents';
        payload := jsonb_build_array(document);
      ELSE
        -- Skip indexing for unpublished posts
        RETURN NEW;
      END IF;
      
    WHEN 'UPDATE' THEN
      -- If post was published and is now unpublished, delete from index
      IF (OLD.published IS TRUE AND NEW.published IS FALSE) THEN
        endpoint := config.host || '/indexes/posts/documents/' || NEW.id;
        -- DELETE request will be made
      -- If post was unpublished and is now published, add to index
      ELSIF (OLD.published IS NOT TRUE AND NEW.published IS TRUE) THEN
        document := format_post_for_meilisearch(NEW);
        endpoint := config.host || '/indexes/posts/documents';
        payload := jsonb_build_array(document);
      -- If post remains published and content changed, update index
      ELSIF NEW.published IS TRUE AND (
        OLD.title IS DISTINCT FROM NEW.title OR
        OLD.excerpt IS DISTINCT FROM NEW.excerpt OR
        OLD.content IS DISTINCT FROM NEW.content OR
        OLD.featured_image_url IS DISTINCT FROM NEW.featured_image_url OR
        OLD.quirk_location_id IS DISTINCT FROM NEW.quirk_location_id OR
        OLD.post_rank IS DISTINCT FROM NEW.post_rank OR
        OLD.is_sticky IS DISTINCT FROM NEW.is_sticky
      ) THEN
        document := format_post_for_meilisearch(NEW);
        endpoint := config.host || '/indexes/posts/documents';
        payload := jsonb_build_array(document);
      ELSE
        -- No index update needed
        RETURN NEW;
      END IF;
      
    WHEN 'DELETE' THEN
      -- Only delete from index if post was published
      IF OLD.published THEN
        endpoint := config.host || '/indexes/posts/documents/' || OLD.id;
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

-- Create trigger for posts
DROP TRIGGER IF EXISTS posts_meilisearch_sync ON posts;
CREATE TRIGGER posts_meilisearch_sync
  AFTER INSERT OR UPDATE OR DELETE ON posts
  FOR EACH ROW
  EXECUTE FUNCTION sync_post_to_meilisearch();

-- Add comment for documentation
COMMENT ON FUNCTION sync_post_to_meilisearch IS 'Syncs posts to Meilisearch with improved published state handling';

-- Create function to handle post category changes
CREATE OR REPLACE FUNCTION sync_post_categories_to_meilisearch()
RETURNS trigger AS $$
DECLARE
  post_record posts;
BEGIN
  -- Get the affected post
  SELECT * INTO post_record
  FROM posts
  WHERE id = CASE
    WHEN TG_OP = 'DELETE' THEN OLD.post_id
    ELSE NEW.post_id
  END;

  -- Only sync if post exists and is published
  IF FOUND AND post_record.published THEN
    -- Trigger an update on the post to sync changes
    UPDATE posts
    SET updated_at = now()
    WHERE id = post_record.id;
  END IF;

  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for post_categories
DROP TRIGGER IF EXISTS post_categories_meilisearch_sync ON post_categories;
CREATE TRIGGER post_categories_meilisearch_sync
  AFTER INSERT OR UPDATE OR DELETE ON post_categories
  FOR EACH ROW
  EXECUTE FUNCTION sync_post_categories_to_meilisearch();

-- Add comment for documentation
COMMENT ON FUNCTION sync_post_categories_to_meilisearch IS 'Syncs post category changes to Meilisearch by triggering a post update';