-- Create search sync queue table
CREATE TABLE IF NOT EXISTS search_sync_queue (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  content_type text NOT NULL,
  content_id uuid NOT NULL,
  operation text NOT NULL CHECK (operation IN ('create', 'update', 'delete')),
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed')),
  error_message text,
  created_at timestamptz DEFAULT now(),
  processed_at timestamptz,
  retries integer DEFAULT 0,
  UNIQUE(content_type, content_id, operation)
);

-- Add indexes for performance
CREATE INDEX idx_search_sync_queue_status ON search_sync_queue(status);
CREATE INDEX idx_search_sync_queue_created ON search_sync_queue(created_at);

-- Enable RLS
ALTER TABLE search_sync_queue ENABLE ROW LEVEL SECURITY;

-- Add RLS policies
CREATE POLICY "Enable read access for all users"
ON search_sync_queue FOR SELECT
TO public
USING (true);

CREATE POLICY "Enable write access for authenticated users"
ON search_sync_queue FOR ALL
TO authenticated
USING (auth.role() = 'authenticated')
WITH CHECK (auth.role() = 'authenticated');

-- Add comments for documentation
COMMENT ON TABLE search_sync_queue IS 'Queue for processing search index updates';
COMMENT ON COLUMN search_sync_queue.content_type IS 'Type of content being synced (iyc, jobs, posts, etc)';
COMMENT ON COLUMN search_sync_queue.operation IS 'Operation to perform (create, update, delete)';
COMMENT ON COLUMN search_sync_queue.status IS 'Current status of the sync operation';
COMMENT ON COLUMN search_sync_queue.retries IS 'Number of retry attempts for failed operations';