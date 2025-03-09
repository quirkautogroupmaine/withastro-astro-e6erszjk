-- First create a temporary table with the new structure
CREATE TABLE iyc_employee_relations_new (
  iyc_id bigint NOT NULL,
  employee_id uuid NOT NULL,
  assigned_at timestamptz DEFAULT now(),
  PRIMARY KEY (iyc_id, employee_id)
);

-- Copy existing data with proper UUID conversion, avoiding duplicates
WITH unique_relations AS (
  SELECT DISTINCT ON (ier.iyc_id, qe.id)
    ier.iyc_id,
    qe.id as employee_id,
    ier.assigned_at
  FROM iyc_employee_relations ier
  JOIN quirk_employees qe ON qe.employee_first_name IS NOT NULL
  ORDER BY ier.iyc_id, qe.id, ier.assigned_at DESC
)
INSERT INTO iyc_employee_relations_new (iyc_id, employee_id, assigned_at)
SELECT 
  iyc_id,
  employee_id,
  assigned_at
FROM unique_relations;

-- Drop the old table
DROP TABLE iyc_employee_relations;

-- Rename the new table
ALTER TABLE iyc_employee_relations_new RENAME TO iyc_employee_relations;

-- Add foreign key constraints
ALTER TABLE iyc_employee_relations
ADD CONSTRAINT iyc_employee_relations_iyc_id_fkey 
FOREIGN KEY (iyc_id) 
REFERENCES iyc(id) 
ON DELETE CASCADE,
ADD CONSTRAINT iyc_employee_relations_employee_id_fkey 
FOREIGN KEY (employee_id) 
REFERENCES quirk_employees(id) 
ON DELETE CASCADE;

-- Add indexes for better query performance
CREATE INDEX idx_iyc_employee_relations_employee ON iyc_employee_relations(employee_id);
CREATE INDEX idx_iyc_employee_relations_iyc ON iyc_employee_relations(iyc_id);

-- Add comments for documentation
COMMENT ON TABLE iyc_employee_relations IS 'Junction table linking IYC posts to Quirk employees';
COMMENT ON COLUMN iyc_employee_relations.employee_id IS 'Reference to quirk_employees table';
COMMENT ON COLUMN iyc_employee_relations.iyc_id IS 'Reference to IYC post';