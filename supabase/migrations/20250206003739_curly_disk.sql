-- Drop existing function
DROP FUNCTION IF EXISTS truncate_jobs_cascade;

-- Create updated function to truncate jobs and job_locations tables
CREATE OR REPLACE FUNCTION truncate_jobs_cascade()
RETURNS void AS $$
BEGIN
  -- First truncate the job_locations junction table
  TRUNCATE TABLE job_locations;
  
  -- Then truncate the jobs table
  TRUNCATE TABLE jobs;
END;
$$ LANGUAGE plpgsql;

-- Add comment for documentation
COMMENT ON FUNCTION truncate_jobs_cascade IS 'Truncates job_locations and jobs tables in the correct order';

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION truncate_jobs_cascade TO authenticated;