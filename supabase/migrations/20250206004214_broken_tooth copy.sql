-- Drop existing function
DROP FUNCTION IF EXISTS public.truncate_jobs_cascade();

-- Create function with proper schema and parameters
CREATE OR REPLACE FUNCTION public.truncate_jobs_cascade()
RETURNS void AS $$
BEGIN
  -- Temporarily disable triggers
  ALTER TABLE job_locations DISABLE TRIGGER ALL;
  ALTER TABLE jobs DISABLE TRIGGER ALL;
  
  -- First truncate the job_locations junction table
  TRUNCATE TABLE job_locations;
  
  -- Then truncate the jobs table
  TRUNCATE TABLE jobs;
  
  -- Re-enable triggers
  ALTER TABLE jobs ENABLE TRIGGER ALL;
  ALTER TABLE job_locations ENABLE TRIGGER ALL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Add comment for documentation
COMMENT ON FUNCTION public.truncate_jobs_cascade IS 'Truncates job_locations and jobs tables in the correct order';

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.truncate_jobs_cascade TO authenticated;