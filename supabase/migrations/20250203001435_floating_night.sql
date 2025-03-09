-- Check current job status
SELECT COUNT(*) as total_jobs,
       COUNT(*) FILTER (WHERE is_active = true) as active_jobs,
       COUNT(*) FILTER (WHERE is_active = false) as inactive_jobs,
       COUNT(*) FILTER (WHERE is_active IS NULL) as null_status_jobs
FROM jobs;

-- Update any NULL is_active values to true
UPDATE jobs
SET is_active = true
WHERE is_active IS NULL;

-- Add NOT NULL constraint with default true
ALTER TABLE jobs
ALTER COLUMN is_active SET DEFAULT true,
ALTER COLUMN is_active SET NOT NULL;