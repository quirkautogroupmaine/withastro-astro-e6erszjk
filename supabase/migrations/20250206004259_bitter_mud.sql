-- Drop existing function
DROP FUNCTION IF EXISTS public.truncate_jobs_cascade();

-- Create function with proper schema and parameters
CREATE OR REPLACE FUNCTION public.truncate_jobs_cascade()
RETURNS void AS $$
BEGIN
  -- Set session_replication_role to replica temporarily to bypass triggers
  SET session_replication_role = 'replica';
  
  -- First truncate the job_locations junction table
  TRUNCATE TABLE job_locations;
  
  -- Then truncate the jobs table
  TRUNCATE TABLE jobs;
  
  -- Reset session_replication_role back to default
  SET session_replication_role = 'origin';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Add comment for documentation
COMMENT ON FUNCTION public.truncate_jobs_cascade IS 'Truncates job_locations and jobs tables in the correct order, bypassing system triggers';

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.truncate_jobs_cascade TO authenticated;