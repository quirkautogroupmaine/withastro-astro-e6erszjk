```sql
-- Add employee_email column to quirk_employees table
ALTER TABLE quirk_employees
ADD COLUMN employee_email text;

-- Add comment for documentation
COMMENT ON COLUMN quirk_employees.employee_email IS 'Email address for employee contact';

-- Add index for email lookups
CREATE INDEX idx_quirk_employees_email ON quirk_employees(employee_email);

-- Update EmployeeList component to use new field
UPDATE quirk_employees 
SET employee_email = email 
WHERE email IS NOT NULL;
```