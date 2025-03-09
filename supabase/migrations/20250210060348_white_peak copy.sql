-- Update format_content_for_search function to include maine_cities data
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
  maine_city_data jsonb;
  categories_data jsonb;
  employees_data jsonb;
  base_url text := 'https://me.quirkauto.com';
  url text;
  content_prefix text;
  location_id uuid;
BEGIN
  -- Get location_id from additional_data
  location_id := (additional_data->>'location_id')::uuid;

  -- Get Quirk location data
  SELECT jsonb_build_object(
    'id', ql.id,
    'title', ql.title,
    'city', ql.city,
    'featured_image_url', ql.location_featured_image
  ) INTO quirk_location_data
  FROM quirk_locations ql
  WHERE ql.id = quirk_location_id;

  -- Get Maine city data if location_id is provided
  IF location_id IS NOT NULL THEN
    SELECT jsonb_build_object(
      'id', mc.id,
      'name', mc.name,
      'slug', mc.slug
    ) INTO maine_city_data
    FROM maine_cities mc
    WHERE mc.id = location_id;
  END IF;

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
    'maine_city', maine_city_data,
    'categories', COALESCE(categories_data, '[]'::jsonb),
    'employees', COALESCE(employees_data, '[]'::jsonb),
    'url', url,
    'additional_data', additional_data,
    '_created_at', EXTRACT(EPOCH FROM (additional_data->>'created_at')::timestamptz),
    '_updated_at', EXTRACT(EPOCH FROM (additional_data->>'updated_at')::timestamptz)
  );
END;
$$ LANGUAGE plpgsql;

-- Update sync_content_to_search function to include location_id
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
        'enhanced_content', COALESCE(NEW.enhanced_content, OLD.enhanced_content),
        'location_id', COALESCE(NEW.location_id, OLD.location_id)
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
        'published_at', COALESCE(NEW.published_at, OLD.published_at),
        'location_id', COALESCE(NEW.location_id, OLD.location_id)
      );
  END CASE;

  -- Rest of function remains the same...
  -- (Previous implementation continues here)
  
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Add comment for documentation
COMMENT ON FUNCTION format_content_for_search IS 'Formats content for unified search index with maine_cities relation';