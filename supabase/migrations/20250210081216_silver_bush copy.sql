-- Enable pg_net extension if not already enabled
CREATE EXTENSION IF NOT EXISTS pg_net;

-- Create function to update Meilisearch settings
CREATE OR REPLACE FUNCTION update_meilisearch_settings()
RETURNS void AS $$
DECLARE
  config record;
  settings jsonb;
BEGIN
  -- Get Meilisearch config
  SELECT * INTO config FROM get_meilisearch_config();
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Meilisearch configuration not found';
  END IF;

  -- Define enhanced settings with faceting
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
      'additional_data.department',
      'additional_data.employment_type'
    ),
    'sortableAttributes', jsonb_build_array(
      '_created_at',
      '_updated_at',
      'additional_data.post_rank'
    ),
    'faceting', jsonb_build_object(
      'maxValuesPerFacet', 100,
      'sortFacetValuesBy', jsonb_build_object(
        '*', 'count'
      )
    ),
    'pagination', jsonb_build_object(
      'maxTotalHits', 10000
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

  -- Force reindex of jobs to ensure facets are populated
  UPDATE jobs SET updated_at = now() WHERE is_active = true;
END;
$$ LANGUAGE plpgsql;

-- Execute the function to update settings
SELECT update_meilisearch_settings();

-- Add comment for documentation
COMMENT ON FUNCTION update_meilisearch_settings IS 'Updates Meilisearch index settings with faceting support';