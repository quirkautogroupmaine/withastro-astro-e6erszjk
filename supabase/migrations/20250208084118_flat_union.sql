-- Enable RLS on quirk_employees table
ALTER TABLE quirk_employees ENABLE ROW LEVEL SECURITY;

-- Add RLS policies
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

-- Add comment for documentation
COMMENT ON TABLE quirk_employees IS 'Stores Quirk Auto Group employee information with RLS policies';