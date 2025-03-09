-- Add foreign key constraint for maine_cities
ALTER TABLE iyc
ADD CONSTRAINT iyc_location_id_fkey
FOREIGN KEY (location_id)
REFERENCES maine_cities(id)
ON DELETE RESTRICT;

-- Add index for better query performance
CREATE INDEX IF NOT EXISTS idx_iyc_location_id ON iyc(location_id);

-- Add comment for documentation
COMMENT ON CONSTRAINT iyc_location_id_fkey ON iyc IS 'Foreign key linking IYC posts to Maine cities';