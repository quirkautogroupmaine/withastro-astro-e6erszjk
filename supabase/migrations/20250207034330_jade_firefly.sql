```sql
-- Create table for Maine cities if it doesn't exist
CREATE TABLE IF NOT EXISTS maine_cities (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  slug text NOT NULL UNIQUE,
  created_at timestamptz DEFAULT now(),
  city text
);

-- Create index for city search
CREATE INDEX IF NOT EXISTS idx_maine_cities_city 
ON maine_cities(city);

-- Create IYC (It's Your Car) table
CREATE TABLE IF NOT EXISTS iyc (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  content TEXT NOT NULL,
  slug VARCHAR(255) NOT NULL UNIQUE,
  featured_image_url TEXT,
  excerpt TEXT,
  published_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  search_vector tsvector GENERATED ALWAYS AS (
    setweight(to_tsvector('english', title), 'A') ||
    setweight(to_tsvector('english', content), 'B') ||
    setweight(to_tsvector('english', COALESCE(excerpt, '')), 'C')
  ) STORED,
  quirk_location_id UUID NOT NULL REFERENCES quirk_locations(id),
  location_id UUID NOT NULL REFERENCES maine_cities(id),
  enhanced_content TEXT,
  facebook_post_id TEXT UNIQUE
);

-- Create employee relations table
CREATE TABLE IF NOT EXISTS iyc_employee_relations (
  iyc_id BIGINT NOT NULL,
  employee_id BIGINT NOT NULL,
  assigned_at TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (iyc_id, employee_id),
  FOREIGN KEY (iyc_id) REFERENCES iyc(id) ON DELETE CASCADE,
  FOREIGN KEY (employee_id) REFERENCES quirk_employees(id) ON DELETE CASCADE
);

-- Create indexes
CREATE INDEX idx_iyc_facebook_post_id ON iyc(facebook_post_id);
CREATE INDEX idx_iyc_search ON iyc USING gin(search_vector);
CREATE INDEX idx_iyc_published ON iyc(published_at DESC);
CREATE INDEX idx_iyc_location ON iyc(location_id);
CREATE INDEX idx_iyc_quirk_location ON iyc(quirk_location_id);

-- Enable RLS
ALTER TABLE iyc ENABLE ROW LEVEL SECURITY;
ALTER TABLE iyc_employee_relations ENABLE ROW LEVEL SECURITY;
ALTER TABLE maine_cities ENABLE ROW LEVEL SECURITY;

-- Add RLS policies
CREATE POLICY "Enable read access for all users"
ON iyc FOR SELECT
TO public
USING (true);

CREATE POLICY "Enable write access for authenticated users"
ON iyc FOR ALL
TO authenticated
USING (auth.role() = 'authenticated')
WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Enable read access for all users"
ON iyc_employee_relations FOR SELECT
TO public
USING (true);

CREATE POLICY "Enable write access for authenticated users"
ON iyc_employee_relations FOR ALL
TO authenticated
USING (auth.role() = 'authenticated')
WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Enable read access for all users"
ON maine_cities FOR SELECT
TO public
USING (true);

CREATE POLICY "Enable write access for authenticated users"
ON maine_cities FOR ALL
TO authenticated
USING (auth.role() = 'authenticated')
WITH CHECK (auth.role() = 'authenticated');

-- Create updated_at trigger
CREATE TRIGGER set_iyc_updated_at
  BEFORE UPDATE ON iyc
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```