-- Drop existing function
DROP FUNCTION IF EXISTS public.truncate_jobs_cascade();

-- Create function with proper schema and parameters
CREATE OR REPLACE FUNCTION public.truncate_jobs_cascade()
RETURNS void AS $$
BEGIN
  -- Delete all records with explicit WHERE clauses
  DELETE FROM job_locations WHERE true;
  DELETE FROM jobs WHERE true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Add comment for documentation
COMMENT ON FUNCTION public.truncate_jobs_cascade IS 'Deletes all records from job_locations and jobs tables in the correct order';

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.truncate_jobs_cascade TO authenticated;