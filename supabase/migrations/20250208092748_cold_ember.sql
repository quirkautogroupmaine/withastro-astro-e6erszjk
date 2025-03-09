-- Begin transaction
BEGIN;

-- Create temporary table with UUID id
CREATE TABLE quirk_employees_new (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  employee_first_name text NOT NULL,
  employee_lastname text NOT NULL,
  employee_name_title text,
  employee_email text,
  employee_photo text,
  employee_phone text,
  quirk_location_id uuid REFERENCES quirk_locations(id),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Copy data to new table with generated UUIDs
INSERT INTO quirk_employees_new (
  employee_first_name,
  employee_lastname,
  employee_name_title,
  employee_email,
  employee_photo,
  employee_phone,
  quirk_location_id,
  created_at,
  updated_at
)
SELECT
  employee_first_name,
  employee_lastname,
  employee_name_title,
  employee_email,
  employee_photo,
  employee_phone,
  quirk_location_id,
  created_at,
  updated_at
FROM quirk_employees;

-- Drop old table and rename new table
DROP TABLE quirk_employees CASCADE;
ALTER TABLE quirk_employees_new RENAME TO quirk_employees;

-- Recreate indexes
CREATE INDEX idx_quirk_employees_location ON quirk_employees(quirk_location_id);
CREATE INDEX idx_quirk_employees_email ON quirk_employees(employee_email);

-- Enable RLS
ALTER TABLE quirk_employees ENABLE ROW LEVEL SECURITY;

-- Recreate RLS policies
CREATE POLICY "Enable read access for all users"
ON quirk_employees FOR SELECT
TO public
USING (true);

CREATE POLICY "Enable write access for authenticated users"
ON quirk_employees
FOR ALL 
TO authenticated
USING (auth.role() = 'authenticated')
WITH CHECK (auth.role() = 'authenticated');

-- Add updated_at trigger
CREATE TRIGGER set_quirk_employees_updated_at
  BEFORE UPDATE ON quirk_employees
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

COMMIT;