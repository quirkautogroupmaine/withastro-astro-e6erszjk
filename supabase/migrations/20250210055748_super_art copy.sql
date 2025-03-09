-- First drop existing foreign key constraint if it exists
ALTER TABLE iyc_employee_relations 
DROP CONSTRAINT IF EXISTS iyc_employee_relations_employee_id_fkey;

-- Add the correct foreign key constraint
ALTER TABLE iyc_employee_relations
ADD CONSTRAINT iyc_employee_relations_employee_id_fkey 
FOREIGN KEY (employee_id) 
REFERENCES quirk_employees(id) 
ON DELETE CASCADE;

-- Add comment for documentation
COMMENT ON CONSTRAINT iyc_employee_relations_employee_id_fkey ON iyc_employee_relations IS 'Foreign key linking to quirk_employees table';