-- Create function to reindex content while preserving settings
CREATE OR REPLACE FUNCTION reindex_content_type(content_type text)
RETURNS void AS $$
DECLARE
  config record;
  index_settings jsonb;
  task_info jsonb;
  response_status integer;
  response_body text;
BEGIN
  -- Get Meilisearch config
  SELECT * INTO config FROM get_meilisearch_config();
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Meilisearch configuration not found';
  END IF;

  -- Get current index settings
  SELECT 
    content::jsonb INTO index_settings
  FROM http_get(
    config.host || '/indexes/' || content_type || '/settings',
    ARRAY[
      ('Authorization', 'Bearer ' || config.api_key)::http_header
    ]
  );

  -- Delete existing index
  PERFORM http_delete(
    config.host || '/indexes/' || content_type,
    ARRAY[
      ('Authorization', 'Bearer ' || config.api_key)::http_header
    ]
  );

  -- Create new index
  SELECT 
    status,
    content::text INTO 
    response_status,
    response_body
  FROM http_post(
    config.host || '/indexes',
    jsonb_build_object(
      'uid', content_type,
      'primaryKey', 'id'
    )::text,
    ARRAY[
      ('Authorization', 'Bearer ' || config.api_key)::http_header,
      ('Content-Type', 'application/json')::http_header
    ]
  );

  IF response_status != 201 THEN
    RAISE EXCEPTION 'Failed to create index: %', response_body;
  END IF;

  -- Wait for task completion
  task_info := response_body::jsonb;
  PERFORM pg_sleep(1); -- Brief pause to ensure index is ready

  -- Restore index settings
  IF index_settings IS NOT NULL THEN
    PERFORM http_patch(
      config.host || '/indexes/' || content_type || '/settings',
      index_settings::text,
      ARRAY[
        ('Authorization', 'Bearer ' || config.api_key)::http_header,
        ('Content-Type', 'application/json')::http_header
      ]
    );
  END IF;

  -- Reindex will happen through normal triggers
  CASE content_type
    WHEN 'iyc' THEN
      UPDATE iyc SET updated_at = now() WHERE published = true;
    WHEN 'jobs' THEN
      UPDATE jobs SET updated_at = now() WHERE is_active = true;
    WHEN 'posts' THEN
      UPDATE posts SET updated_at = now() WHERE published = true;
    WHEN 'content' THEN
      -- Unified search needs all content types
      UPDATE iyc SET updated_at = now() WHERE published = true;
      UPDATE jobs SET updated_at = now() WHERE is_active = true;
      UPDATE posts SET updated_at = now() WHERE published = true;
    ELSE
      RAISE EXCEPTION 'Unknown content type: %', content_type;
  END CASE;
END;
$$ LANGUAGE plpgsql;

-- Add comment for documentation
COMMENT ON FUNCTION reindex_content_type IS 'Reindexes specified content type while preserving Meilisearch settings';