-- Create table to track Algolia sync status
CREATE TABLE algolia_sync_queue (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  object_type text NOT NULL,
  object_id uuid NOT NULL,
  operation text NOT NULL CHECK (operation IN ('create', 'update', 'delete')),
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed')),
  error_message text,
  created_at timestamptz DEFAULT now(),
  processed_at timestamptz,
  retries integer DEFAULT 0,
  UNIQUE(object_type, object_id, operation)
);

-- Add indexes for performance
CREATE INDEX idx_algolia_sync_queue_status ON algolia_sync_queue(status);
CREATE INDEX idx_algolia_sync_queue_created ON algolia_sync_queue(created_at);

-- Create function to queue Algolia sync
CREATE OR REPLACE FUNCTION queue_algolia_sync()
RETURNS trigger AS $$
DECLARE
  operation_type text;
BEGIN
  -- Determine operation type
  IF TG_OP = 'INSERT' THEN
    operation_type := 'create';
  ELSIF TG_OP = 'UPDATE' THEN
    operation_type := 'update';
  ELSE
    operation_type := 'delete';
  END IF;

  -- Queue the sync operation
  INSERT INTO algolia_sync_queue (object_type, object_id, operation)
  VALUES (
    TG_TABLE_NAME,
    CASE 
      WHEN TG_OP = 'DELETE' THEN OLD.id 
      ELSE NEW.id 
    END,
    operation_type
  )
  ON CONFLICT (object_type, object_id, operation) 
  DO UPDATE SET 
    status = 'pending',
    error_message = NULL,
    retries = 0,
    processed_at = NULL,
    created_at = now();

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for posts table
CREATE TRIGGER posts_algolia_sync
  AFTER INSERT OR UPDATE OR DELETE ON posts
  FOR EACH ROW
  WHEN (
    (TG_OP = 'INSERT') OR
    (TG_OP = 'UPDATE' AND (
      OLD.title IS DISTINCT FROM NEW.title OR
      OLD.excerpt IS DISTINCT FROM NEW.excerpt OR
      OLD.published IS DISTINCT FROM NEW.published OR
      OLD.published_at IS DISTINCT FROM NEW.published_at
    )) OR
    (TG_OP = 'DELETE')
  )
  EXECUTE FUNCTION queue_algolia_sync();

-- Create triggers for IYC posts
CREATE TRIGGER iyc_algolia_sync
  AFTER INSERT OR UPDATE OR DELETE ON iyc
  FOR EACH ROW
  WHEN (
    (TG_OP = 'INSERT') OR
    (TG_OP = 'UPDATE' AND (
      OLD.title IS DISTINCT FROM NEW.title OR
      OLD.excerpt IS DISTINCT FROM NEW.excerpt OR
      OLD.published_at IS DISTINCT FROM NEW.published_at
    )) OR
    (TG_OP = 'DELETE')
  )
  EXECUTE FUNCTION queue_algolia_sync();

-- Create triggers for locations
CREATE TRIGGER locations_algolia_sync
  AFTER INSERT OR UPDATE OR DELETE ON quirk_locations
  FOR EACH ROW
  WHEN (
    (TG_OP = 'INSERT') OR
    (TG_OP = 'UPDATE' AND (
      OLD.title IS DISTINCT FROM NEW.title OR
      OLD.content_description IS DISTINCT FROM NEW.content_description OR
      OLD.city IS DISTINCT FROM NEW.city
    )) OR
    (TG_OP = 'DELETE')
  )
  EXECUTE FUNCTION queue_algolia_sync();

-- Create triggers for jobs
CREATE TRIGGER jobs_algolia_sync
  AFTER INSERT OR UPDATE OR DELETE ON jobs
  FOR EACH ROW
  WHEN (
    (TG_OP = 'INSERT') OR
    (TG_OP = 'UPDATE' AND (
      OLD.title IS DISTINCT FROM NEW.title OR
      OLD.description IS DISTINCT FROM NEW.description OR
      OLD.is_active IS DISTINCT FROM NEW.is_active
    )) OR
    (TG_OP = 'DELETE')
  )
  EXECUTE FUNCTION queue_algolia_sync();

-- Create Edge Function to process queue
CREATE OR REPLACE FUNCTION process_algolia_queue() 
RETURNS void AS $$
DECLARE
  batch_size integer := 50;
  retry_limit integer := 3;
  edge_function text := 'algolia-sync';
BEGIN
  -- Get pending items
  WITH items AS (
    SELECT id
    FROM algolia_sync_queue
    WHERE status = 'pending'
    AND retries < retry_limit
    ORDER BY created_at
    LIMIT batch_size
    FOR UPDATE SKIP LOCKED
  )
  UPDATE algolia_sync_queue q
  SET status = 'processing'
  FROM items
  WHERE q.id = items.id;

  -- Invoke Edge Function to handle the sync
  PERFORM net.http_post(
    url := format(
      '%s/functions/v1/%s',
      current_setting('app.settings.supabase_url'),
      edge_function
    ),
    headers := jsonb_build_object(
      'Authorization', format('Bearer %s', current_setting('app.settings.service_role_key')),
      'Content-Type', 'application/json'
    ),
    body := '{}'
  );
END;
$$ LANGUAGE plpgsql;

-- Create cron job to process queue
SELECT cron.schedule(
  'process-algolia-queue',
  '* * * * *', -- Run every minute
  $$
  SELECT process_algolia_queue();
  $$
);