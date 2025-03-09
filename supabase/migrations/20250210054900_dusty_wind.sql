-- Drop existing triggers
DROP TRIGGER IF EXISTS content_search_sync ON iyc;
DROP TRIGGER IF EXISTS content_search_sync ON jobs;
DROP TRIGGER IF EXISTS content_search_sync ON posts;

-- Create enhanced format_content_for_search function
CREATE OR REPLACE FUNCTION format_content_for_search(
  content_type text,
  content_id uuid,
  title text,
  description text,
  featured_image_url text,
  quirk_location_id uuid,
  additional_data jsonb DEFAULT '{}'::jsonb
) RETURNS jsonb AS $$
DECLARE
  quirk_location_data jsonb;
  categories_data jsonb;
  employees_data jsonb;
  base_url text := 'https://me.quirkauto.com';
  url text;
  content_prefix text;
BEGIN
  -- Get Quirk location data
  SELECT jsonb_build_object(
    'id', ql.id,
    'title', ql.title,
    'city', ql.city,
    'featured_image_url', ql.location_featured_image
  ) INTO quirk_location_data
  FROM quirk_locations ql
  WHERE ql.id = quirk_location_id;

  -- Add content type specific prefix to ID to avoid collisions
  content_prefix := CASE content_type
    WHEN 'iyc' THEN 'iyc_'
    WHEN 'jobs' THEN 'job_'
    WHEN 'posts' THEN 'post_'
    ELSE ''
  END;

  -- Build URL based on content type
  url := CASE content_type
    WHEN 'iyc' THEN base_url || '/its-your-car/' || (additional_data->>'slug')
    WHEN 'jobs' THEN base_url || '/careers/' || content_id
    WHEN 'posts' THEN base_url || '/posts/' || (additional_data->>'slug')
    ELSE NULL
  END;

  -- Get categories for posts
  IF content_type = 'posts' THEN
    SELECT jsonb_agg(
      jsonb_build_object(
        'id', c.id,
        'name', c.name,
        'slug', c.slug
      )
    ) INTO categories_data
    FROM post_categories pc
    JOIN categories c ON pc.category_id = c.id
    WHERE pc.post_id = content_id;
  END IF;

  -- Get employee data for IYC posts
  IF content_type = 'iyc' THEN
    SELECT jsonb_agg(
      jsonb_build_object(
        'id', qe.id,
        'first_name', qe.employee_first_name,
        'last_name', qe.employee_lastname,
        'title', qe.employee_name_title,
        'photo', qe.employee_photo
      )
    ) INTO employees_data
    FROM iyc_employee_relations ier
    JOIN quirk_employees qe ON ier.employee_id = qe.id
    WHERE ier.iyc_id = content_id;
  END IF;

  -- Return formatted document with all relations
  RETURN jsonb_build_object(
    'id', content_prefix || content_id,
    'type', content_type,
    'title', title,
    'description', description,
    'featured_image_url', featured_image_url,
    'quirk_location', quirk_location_data,
    'categories', COALESCE(categories_data, '[]'::jsonb),
    'employees', COALESCE(employees_data, '[]'::jsonb),
    'url', url,
    'additional_data', additional_data,
    '_created_at', EXTRACT(EPOCH FROM (additional_data->>'created_at')::timestamptz),
    '_updated_at', EXTRACT(EPOCH FROM (additional_data->>'updated_at')::timestamptz)
  );
END;
$$ LANGUAGE plpgsql;

-- Update sync_content_to_search function
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
  additional_data jsonb;
BEGIN
  -- Get Meilisearch config
  SELECT * INTO config FROM get_meilisearch_config();
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Meilisearch configuration not found';
  END IF;

  -- Set content type based on table
  content_type := TG_TABLE_NAME;

  -- Build additional data based on content type
  CASE content_type
    WHEN 'iyc' THEN
      additional_data := jsonb_build_object(
        'slug', COALESCE(NEW.slug, OLD.slug),
        'excerpt', COALESCE(NEW.excerpt, OLD.excerpt),
        'created_at', COALESCE(NEW.created_at, OLD.created_at),
        'updated_at', COALESCE(NEW.updated_at, OLD.updated_at),
        'published_at', COALESCE(NEW.published_at, OLD.published_at),
        'enhanced_content', COALESCE(NEW.enhanced_content, OLD.enhanced_content)
      );
    WHEN 'jobs' THEN
      additional_data := jsonb_build_object(
        'department', COALESCE(NEW.department, OLD.department),
        'employment_type', COALESCE(NEW.employment_type, OLD.employment_type),
        'salary_range', COALESCE(NEW.salary_range, OLD.salary_range),
        'requirements', COALESCE(NEW.requirements, OLD.requirements),
        'benefits', COALESCE(NEW.benefits, OLD.benefits),
        'application_url', COALESCE(NEW.application_url, OLD.application_url),
        'created_at', COALESCE(NEW.created_at, OLD.created_at),
        'updated_at', COALESCE(NEW.updated_at, OLD.updated_at)
      );
    WHEN 'posts' THEN
      additional_data := jsonb_build_object(
        'slug', COALESCE(NEW.slug, OLD.slug),
        'excerpt', COALESCE(NEW.excerpt, OLD.excerpt),
        'intro_text', COALESCE(NEW.intro_text, OLD.intro_text),
        'intro_style', COALESCE(NEW.intro_style, OLD.intro_style),
        'post_rank', COALESCE(NEW.post_rank, OLD.post_rank),
        'is_sticky', COALESCE(NEW.is_sticky, OLD.is_sticky),
        'created_at', COALESCE(NEW.created_at, OLD.created_at),
        'updated_at', COALESCE(NEW.updated_at, OLD.updated_at),
        'published_at', COALESCE(NEW.published_at, OLD.published_at)
      );
  END CASE;

  -- Handle different operations
  CASE TG_OP
    WHEN 'INSERT' THEN
      -- Only index if content is active/published
      IF (content_type = 'jobs' AND NEW.is_active) OR 
         ((content_type = 'iyc' OR content_type = 'posts') AND NEW.published) THEN
        document := format_content_for_search(
          content_type,
          NEW.id,
          NEW.title,
          CASE content_type
            WHEN 'jobs' THEN NEW.description
            ELSE COALESCE(NEW.excerpt, substring(NEW.content from 1 for 500))
          END,
          NEW.featured_image_url,
          NEW.quirk_location_id,
          additional_data
        );
      ELSE
        RETURN NEW;
      END IF;
      
    WHEN 'UPDATE' THEN
      IF ((content_type = 'jobs' AND NEW.is_active) OR 
          ((content_type = 'iyc' OR content_type = 'posts') AND NEW.published)) THEN
        document := format_content_for_search(
          content_type,
          NEW.id,
          NEW.title,
          CASE content_type
            WHEN 'jobs' THEN NEW.description
            ELSE COALESCE(NEW.excerpt, substring(NEW.content from 1 for 500))
          END,
          NEW.featured_image_url,
          NEW.quirk_location_id,
          additional_data
        );
      ELSE
        -- Delete from index if inactive/unpublished
        endpoint := config.host || '/indexes/content/documents/' || 
          CASE content_type
            WHEN 'iyc' THEN 'iyc_'
            WHEN 'jobs' THEN 'job_'
            WHEN 'posts' THEN 'post_'
          END || NEW.id;
      END IF;
      
    WHEN 'DELETE' THEN
      -- Delete from index
      endpoint := config.host || '/indexes/content/documents/' || 
        CASE content_type
          WHEN 'iyc' THEN 'iyc_'
          WHEN 'jobs' THEN 'job_'
          WHEN 'posts' THEN 'post_'
        END || OLD.id;
  END CASE;

  -- Make request to Meilisearch
  BEGIN
    IF TG_OP = 'DELETE' OR 
       (TG_OP = 'UPDATE' AND (
         (content_type = 'jobs' AND NOT NEW.is_active) OR
         ((content_type = 'iyc' OR content_type = 'posts') AND NOT NEW.published)
       )) THEN
      -- DELETE request
      SELECT status, content::text
      INTO response_status, response_body
      FROM http_delete(
        endpoint,
        ARRAY[('Authorization', 'Bearer ' || config.api_key)::http_header]
      );
    ELSE
      -- POST request for INSERT or UPDATE
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

    -- Check response
    IF response_status NOT IN (200, 201, 202, 204) THEN
      RAISE WARNING 'Meilisearch API request failed with status % - %', response_status, response_body;
    END IF;

  EXCEPTION
    WHEN others THEN
      RAISE WARNING 'Meilisearch sync error: %', SQLERRM;
  END;

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

-- Add comments for documentation
COMMENT ON FUNCTION format_content_for_search IS 'Formats content for unified search index with proper relations';
COMMENT ON FUNCTION sync_content_to_search IS 'Syncs content to unified search index with improved state handling';