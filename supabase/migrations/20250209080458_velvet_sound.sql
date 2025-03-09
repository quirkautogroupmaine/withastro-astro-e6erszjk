-- Add documentation for shared migrations
COMMENT ON SCHEMA public IS 'Migration files prefixed with SHARE_ should be synchronized across all Quirk Auto Group projects';

-- Create table to track shared migrations
CREATE TABLE IF NOT EXISTS shared_migrations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  filename text NOT NULL UNIQUE,
  description text,
  applied_at timestamptz DEFAULT now(),
  shared_hash text NOT NULL,
  CONSTRAINT shared_migrations_filename_check CHECK (filename LIKE 'SHARE_%')
);

-- Add RLS policies
ALTER TABLE shared_migrations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Enable read access for all users"
ON shared_migrations FOR SELECT
TO public
USING (true);

CREATE POLICY "Enable write access for authenticated users"
ON shared_migrations FOR ALL
TO authenticated
USING (auth.role() = 'authenticated')
WITH CHECK (auth.role() = 'authenticated');

-- Add comments
COMMENT ON TABLE shared_migrations IS 'Tracks migrations that should be shared across all Quirk Auto Group projects';
COMMENT ON COLUMN shared_migrations.filename IS 'Migration filename (must start with SHARE_)';
COMMENT ON COLUMN shared_migrations.shared_hash IS 'Hash of migration contents to verify consistency';

-- Insert documentation into shared migrations table
INSERT INTO shared_migrations (filename, description, shared_hash) VALUES
('SHARE_schema_base.sql', 'Core schema definitions for posts, categories, etc', 'base_schema_v1'),
('SHARE_auth_policies.sql', 'Shared authentication and authorization policies', 'auth_policies_v1'),
('SHARE_search_sync.sql', 'Search integration and sync functionality', 'search_sync_v1'),
('SHARE_storage_policies.sql', 'Storage bucket and access policies', 'storage_policies_v1');