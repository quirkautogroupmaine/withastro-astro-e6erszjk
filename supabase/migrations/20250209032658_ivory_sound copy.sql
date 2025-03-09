-- Create function to format IYC post for Meilisearch
CREATE OR REPLACE FUNCTION format_iyc_for_meilisearch(post_record iyc)
RETURNS jsonb AS $$
DECLARE
  location_data jsonb;
  quirk_location_data jsonb;
BEGIN
  -- Get location data
  SELECT jsonb_build_object(
    'id', mc.id,
    'name', mc.name
  ) INTO location_data
  FROM maine_cities mc
  WHERE mc.id = post_record.location_id;

  -- Get Quirk location data
  SELECT jsonb_build_object(
    'id', ql.id,
    'title', ql.title,
    'city', ql.city
  ) INTO quirk_location_data
  FROM quirk_locations ql
  WHERE ql.id = post_record.quirk_location_id;

  -- Return formatted document
  RETURN jsonb_build_object(
    'id', post_record.id,
    'title', post_record.title,
    'slug', post_record.slug,
    'excerpt', post_record.excerpt,
    'content', post_record.content,
    'enhanced_content', post_record.enhanced_content,
    'featured_image_url', post_record.featured_image_url,
    'published_at', post_record.published_at,
    'created_at', post_record.created_at,
    'updated_at', post_record.updated_at,
    'location', location_data,
    'quirk_location', quirk_location_data
  );
END;
$$ LANGUAGE plpgsql;

-- Create function to sync IYC post to Meilisearch
CREATE OR REPLACE FUNCTION sync_iyc_to_meilisearch()
RETURNS trigger AS $$
DECLARE
  meilisearch_host text;
  meilisearch_api_key text;
  document jsonb;
  endpoint text;
  payload jsonb;
  response_status integer;
BEGIN
  -- Get Meilisearch credentials from settings
  meilisearch_host := current_setting('app.settings.meilisearch_host');
  meilisearch_api_key := current_setting('app.settings.meilisearch_api_key');

  -- Format document
  IF (TG_OP = 'DELETE') THEN
    document := jsonb_build_object('id', OLD.id);
  ELSE
    document := format_iyc_for_meilisearch(NEW);
  END IF;

  -- Set endpoint and payload based on operation
  CASE TG_OP
    WHEN 'INSERT', 'UPDATE' THEN
      endpoint := meilisearch_host || '/indexes/iyc/documents';
      payload := jsonb_build_array(document);
    WHEN 'DELETE' THEN
      endpoint := meilisearch_host || '/indexes/iyc/documents/' || OLD.id;
  END CASE;

  -- Make request to Meilisearch
  SELECT status INTO response_status FROM http_post(
    endpoint,
    payload::text,
    ARRAY[
      ('Authorization', 'Bearer ' || meilisearch_api_key)::http_header,
      ('Content-Type', 'application/json')::http_header
    ]
  );

  -- Check response
  IF response_status NOT IN (200, 201, 202, 204) THEN
    RAISE EXCEPTION 'Meilisearch API request failed with status %', response_status;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for IYC posts
DROP TRIGGER IF EXISTS iyc_meilisearch_sync ON iyc;
CREATE TRIGGER iyc_meilisearch_sync
  AFTER INSERT OR UPDATE OR DELETE ON iyc
  FOR EACH ROW
  EXECUTE FUNCTION sync_iyc_to_meilisearch();

-- Add settings for Meilisearch credentials
ALTER DATABASE postgres SET app.settings.meilisearch_host = 'http://localhost:7700';
ALTER DATABASE postgres SET app.settings.meilisearch_api_key = 'f8a16ceaa05c3a1e7bf91f518b78e80f9836b58a';