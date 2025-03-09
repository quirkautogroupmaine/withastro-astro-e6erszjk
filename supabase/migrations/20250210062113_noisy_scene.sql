-- Update format_job_for_meilisearch function to include location featured image
CREATE OR REPLACE FUNCTION format_job_for_meilisearch(job_record jobs)
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
    'featured_image_url', featured_image_url, -- Use location's featured image
    'url', job_url
  );
END;
$$ LANGUAGE plpgsql;

-- Add comment for documentation
COMMENT ON FUNCTION format_job_for_meilisearch IS 'Formats job data for Meilisearch including location featured image';