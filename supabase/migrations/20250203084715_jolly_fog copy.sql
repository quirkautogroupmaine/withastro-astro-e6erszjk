-- Create function to extract city from location string
CREATE OR REPLACE FUNCTION extract_city_from_location(location_str text)
RETURNS text AS $$
DECLARE
  city text;
BEGIN
  -- Extract city from "City, State" format
  -- Example: "Bangor, ME" -> "Bangor"
  city := split_part(location_str, ',', 1);
  
  -- Clean up any whitespace
  RETURN trim(city);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Create function to ensure city exists in locations
CREATE OR REPLACE FUNCTION ensure_city_location_exists(location_str text)
RETURNS uuid AS $$
DECLARE
  city_name text;
  existing_location_id uuid;
BEGIN
  -- Extract city
  city_name := extract_city_from_location(location_str);
  
  -- Check if location exists
  SELECT id INTO existing_location_id
  FROM locations
  WHERE LOWER(name) = LOWER(city_name)
  LIMIT 1;
  
  -- If location doesn't exist, create it
  IF existing_location_id IS NULL THEN
    INSERT INTO locations (
      name,
      slug,
      city
    ) VALUES (
      city_name,
      LOWER(REGEXP_REPLACE(city_name, '[^a-zA-Z0-9]+', '-', 'g')),
      city_name
    )
    RETURNING id INTO existing_location_id;
  END IF;
  
  RETURN existing_location_id;
END;
$$ LANGUAGE plpgsql;

-- Add comments for documentation
COMMENT ON FUNCTION extract_city_from_location IS 'Extracts city name from a location string in "City, State" format';
COMMENT ON FUNCTION ensure_city_location_exists IS 'Ensures a location exists for a given city, creating it if necessary';