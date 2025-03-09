-- Drop existing triggers
DROP TRIGGER IF EXISTS queue_search_sync_iyc ON iyc;
DROP TRIGGER IF EXISTS queue_search_sync_jobs ON jobs;
DROP TRIGGER IF EXISTS queue_search_sync_posts ON posts;
DROP TRIGGER IF EXISTS queue_search_sync_locations ON quirk_locations;

-- Create function to queue search sync
CREATE OR REPLACE FUNCTION queue_search_sync()
RETURNS trigger AS $$
DECLARE
  operation_type text;
  content_type text := TG_TABLE_NAME;
  record_id uuid;
BEGIN
  -- Determine operation type and record ID
  CASE TG_OP
    WHEN 'INSERT' THEN
      operation_type := 'create';
      record_id := NEW.id;
    WHEN 'UPDATE' THEN
      operation_type := 'update';
      record_id := NEW.id;
    WHEN 'DELETE' THEN
      operation_type := 'delete';
      record_id := OLD.id;
  END CASE;

  -- Queue the sync operation
  INSERT INTO search_sync_queue (content_type, content_id, operation)
  VALUES (content_type, record_id, operation_type)
  ON CONFLICT (content_type, content_id, operation) 
  DO UPDATE SET 
    status = 'pending',
    error_message = NULL,
    retries = 0,
    processed_at = NULL,
    created_at = now();

  -- Return appropriate record based on operation
  IF TG_OP = 'DELETE' THEN
    RETURN OLD;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create new triggers for content types
CREATE TRIGGER queue_search_sync_iyc
  AFTER INSERT OR UPDATE OR DELETE ON iyc
  FOR EACH ROW
  EXECUTE FUNCTION queue_search_sync();

CREATE TRIGGER queue_search_sync_jobs
  AFTER INSERT OR UPDATE OR DELETE ON jobs
  FOR EACH ROW
  EXECUTE FUNCTION queue_search_sync();

CREATE TRIGGER queue_search_sync_posts
  AFTER INSERT OR UPDATE OR DELETE ON posts
  FOR EACH ROW
  EXECUTE FUNCTION queue_search_sync();

CREATE TRIGGER queue_search_sync_locations
  AFTER INSERT OR UPDATE OR DELETE ON quirk_locations
  FOR EACH ROW
  EXECUTE FUNCTION queue_search_sync();

-- Add comments for documentation
COMMENT ON FUNCTION queue_search_sync IS 'Queues content changes for search index updates with proper trigger handling';