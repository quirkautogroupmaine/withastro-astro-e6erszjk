-- Add quirk_location_id column to quirk_employees table
ALTER TABLE quirk_employees
ADD COLUMN quirk_location_id uuid REFERENCES quirk_locations(id) ON DELETE NO ACTION ON UPDATE NO ACTION;

-- Add index for performance
CREATE INDEX idx_quirk_employees_location ON quirk_employees(quirk_location_id);

-- Add comment for documentation
COMMENT ON COLUMN quirk_employees.quirk_location_id IS 'Reference to the Quirk location where the employee works';