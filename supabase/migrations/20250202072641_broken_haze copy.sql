-- Update existing job descriptions to be more concise
UPDATE jobs
SET description = CASE 
  WHEN title = 'Automotive Service Technician'
    THEN 'Experience with diagnostic equipment and various vehicle repairs required.'
  WHEN title = 'Sales Consultant'
    THEN 'Join our award-winning sales team. Previous automotive sales experience preferred but not required.'
  WHEN title = 'Parts Specialist'
    THEN 'Assist customers and service department with parts needs.'
  WHEN title = 'Service Advisor'
    THEN 'Act as liaison between customers and service department.'
  WHEN title = 'Finance Manager'
    THEN 'Assist customers with vehicle financing and F&I products.'
  END,
employment_type = CASE
  WHEN employment_type = 'Full-time' THEN 'FT'
  ELSE employment_type
  END
WHERE employment_type = 'Full-time';

-- Add check constraint for employment type abbreviations
ALTER TABLE jobs
ADD CONSTRAINT employment_type_check 
CHECK (employment_type IN ('FT', 'PT', 'Contract', 'Temp'));

-- Update comment to reflect new employment type format
COMMENT ON COLUMN jobs.employment_type IS 'Type of employment (FT, PT, Contract, Temp)';