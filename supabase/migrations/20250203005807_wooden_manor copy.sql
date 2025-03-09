-- Add quirk_location_id to jobs table
ALTER TABLE jobs
ADD COLUMN quirk_location_id uuid REFERENCES quirk_locations(id);

-- Update existing jobs with their location IDs
WITH location_mapping AS (
  SELECT id, city
  FROM quirk_locations
)
UPDATE jobs j
SET quirk_location_id = l.id
FROM location_mapping l
WHERE j.location ILIKE '%' || l.city || '%';

-- Add index for performance
CREATE INDEX idx_jobs_quirk_location ON jobs(quirk_location_id);

-- Add NOT NULL constraint after data is migrated
ALTER TABLE jobs
ALTER COLUMN quirk_location_id SET NOT NULL;