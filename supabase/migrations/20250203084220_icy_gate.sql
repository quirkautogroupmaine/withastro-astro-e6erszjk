-- Add city column to locations table if it doesn't exist
ALTER TABLE locations 
ADD COLUMN IF NOT EXISTS city text;

-- Add index for city search
CREATE INDEX IF NOT EXISTS idx_locations_city 
ON locations(city);

-- Add comment for documentation
COMMENT ON COLUMN locations.city IS 'City where the location is based';

-- Create function to ensure city exists
CREATE OR REPLACE FUNCTION ensure_city_exists(city_name text)
RETURNS uuid AS $$
DECLARE
  existing_city_id uuid;
BEGIN
  -- Check if city exists in locations
  SELECT id INTO existing_city_id
  FROM locations
  WHERE LOWER(city) = LOWER(city_name)
  LIMIT 1;
  
  -- If city doesn't exist, create it
  IF existing_city_id IS NULL THEN
    INSERT INTO locations (name, slug, city)
    VALUES (
      city_name, 
      LOWER(REGEXP_REPLACE(city_name, '[^a-zA-Z0-9]+', '-', 'g')),
      city_name
    )
    RETURNING id INTO existing_city_id;
  END IF;
  
  RETURN existing_city_id;
END;
$$ LANGUAGE plpgsql;

-- Add comment for function documentation
COMMENT ON FUNCTION ensure_city_exists IS 'Ensures a city exists in the locations table, creating it if necessary';