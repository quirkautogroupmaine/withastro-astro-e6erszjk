-- Drop existing function
DROP FUNCTION IF EXISTS queue_search_sync();

-- Create updated function with unambiguous column references
CREATE OR REPLACE FUNCTION queue_search_sync()
RETURNS trigger AS $$
DECLARE
  operation_type text;
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

  -- Queue the sync operation with explicit column names
  INSERT INTO search_sync_queue 
    (content_type, content_id, operation, status, error_message, retries, processed_at, created_at)
  VALUES 
    (TG_TABLE_NAME, record_id, operation_type, 'pending', NULL, 0, NULL, now())
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

-- Add comment for documentation
COMMENT ON FUNCTION queue_search_sync IS 'Queues content changes for search index updates with explicit column references';

-- Recreate triggers with new function
DROP TRIGGER IF EXISTS queue_search_sync ON iyc;
DROP TRIGGER IF EXISTS queue_search_sync ON jobs;
DROP TRIGGER IF EXISTS queue_search_sync ON posts;
DROP TRIGGER IF EXISTS queue_search_sync ON quirk_locations;

CREATE TRIGGER queue_search_sync
  AFTER INSERT OR UPDATE OR DELETE ON iyc
  FOR EACH ROW
  EXECUTE FUNCTION queue_search_sync();

CREATE TRIGGER queue_search_sync
  AFTER INSERT OR UPDATE OR DELETE ON jobs
  FOR EACH ROW
  EXECUTE FUNCTION queue_search_sync();

CREATE TRIGGER queue_search_sync
  AFTER INSERT OR UPDATE OR DELETE ON posts
  FOR EACH ROW
  EXECUTE FUNCTION queue_search_sync();

CREATE TRIGGER queue_search_sync
  AFTER INSERT OR UPDATE OR DELETE ON quirk_locations
  FOR EACH ROW
  EXECUTE FUNCTION queue_search_sync();