-- Drop existing foreign key constraints
ALTER TABLE iyc
DROP CONSTRAINT IF EXISTS iyc_city_fk,
DROP CONSTRAINT IF EXISTS iyc_location_id_fkey;

-- Add single foreign key constraint for location_id
ALTER TABLE iyc
ADD CONSTRAINT iyc_location_id_fkey
FOREIGN KEY (location_id)
REFERENCES maine_cities(id)
ON DELETE RESTRICT;

-- Update IYCPostList component queries
CREATE OR REPLACE VIEW iyc_with_relations AS
SELECT 
  i.*,
  ql.title as quirk_location_title,
  ql.city as quirk_location_city,
  mc.name as location_name
FROM iyc i
LEFT JOIN quirk_locations ql ON i.quirk_location_id = ql.id
LEFT JOIN maine_cities mc ON i.location_id = mc.id;

-- Add comments for documentation
COMMENT ON VIEW iyc_with_relations IS 'View for IYC posts with location relations';
COMMENT ON CONSTRAINT iyc_location_id_fkey ON iyc IS 'Foreign key linking IYC posts to Maine cities';