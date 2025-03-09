-- Create job_locations junction table
CREATE TABLE job_locations (
  job_id uuid REFERENCES jobs(id) ON DELETE CASCADE,
  location_id uuid REFERENCES quirk_locations(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  PRIMARY KEY (job_id, location_id)
);

-- Add indexes for performance
CREATE INDEX idx_job_locations_job ON job_locations(job_id);
CREATE INDEX idx_job_locations_location ON job_locations(location_id);

-- Enable RLS
ALTER TABLE job_locations ENABLE ROW LEVEL SECURITY;

-- Add RLS policies
CREATE POLICY "Enable read access for all users"
ON job_locations
FOR SELECT
TO public
USING (true);

CREATE POLICY "Enable all access for authenticated users"
ON job_locations
FOR ALL
TO authenticated
USING (auth.role() = 'authenticated')
WITH CHECK (auth.role() = 'authenticated');

-- Drop the quirk_location_id column from jobs since we're using a junction table
ALTER TABLE jobs DROP COLUMN IF EXISTS quirk_location_id;

-- Add breezy_id column to jobs table for tracking
ALTER TABLE jobs 
ADD COLUMN breezy_id text UNIQUE,
ADD COLUMN raw_data jsonb;