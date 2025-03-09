-- Create function to truncate jobs table with cascade
CREATE OR REPLACE FUNCTION truncate_jobs_cascade()
RETURNS void AS $$
BEGIN
  -- Truncate jobs table with cascade to clear job_locations
  TRUNCATE TABLE jobs CASCADE;
END;
$$ LANGUAGE plpgsql;

-- Add comment for documentation
COMMENT ON FUNCTION truncate_jobs_cascade IS 'Truncates the jobs table with CASCADE to also clear job_locations';

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION truncate_jobs_cascade TO authenticated;