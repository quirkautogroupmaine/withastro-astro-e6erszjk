-- Update Quirk Ford Augusta location data
UPDATE quirk_locations
SET city = 'Augusta'
WHERE title ILIKE '%Quirk Ford%Augusta%';

-- Add index for city search
CREATE INDEX IF NOT EXISTS idx_quirk_locations_city 
ON quirk_locations(city);