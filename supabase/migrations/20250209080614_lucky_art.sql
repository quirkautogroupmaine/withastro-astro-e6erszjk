-- Add documentation for shared migrations
COMMENT ON SCHEMA public IS 'Migration files prefixed with SHARE_ should be synchronized across all Quirk Auto Group projects';

-- Create table to track shared migrations
CREATE TABLE IF NOT EXISTS shared_migrations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  filename text NOT NULL UNIQUE,
  description text,
  applied_at timestamptz DEFAULT now(),
  shared_hash text NOT NULL,
  CONSTRAINT shared_migrations_filename_check CHECK (filename LIKE 'SHARE\_%')
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

-- Document existing migrations that should be shared
INSERT INTO shared_migrations (filename, description, shared_hash) VALUES
('20250128055706_precious_scene.sql', 'Core schema definitions', 'base_schema_v1'),
('20250128080201_falling_harbor.sql', 'Search vector setup', 'search_vector_v1'),
('20250128162722_wild_fire.sql', 'Authentication policies', 'auth_policies_v1'),
('20250128164106_restless_wildflower.sql', 'Role-based access control', 'rbac_v1'),
('20250201082801_dark_paper.sql', 'Storage base configuration', 'storage_base_v1'),
('20250201082928_fragrant_temple.sql', 'Storage policies', 'storage_policies_v1');

-- Add function to check if migration should be shared
CREATE OR REPLACE FUNCTION is_shared_migration(filename text)
RETURNS boolean AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM shared_migrations 
    WHERE shared_migrations.filename = filename
  );
END;
$$ LANGUAGE plpgsql;

-- Add function to verify shared migration hash
CREATE OR REPLACE FUNCTION verify_shared_migration(filename text, content text)
RETURNS boolean AS $$
DECLARE
  expected_hash text;
BEGIN
  SELECT shared_hash INTO expected_hash
  FROM shared_migrations
  WHERE shared_migrations.filename = filename;

  RETURN md5(content) = expected_hash;
END;
$$ LANGUAGE plpgsql;