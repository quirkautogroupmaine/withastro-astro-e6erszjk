-- Add comment to document SHARE keyword
COMMENT ON SCHEMA public IS 'Files marked with SHARE_ prefix should be distributed across all Quirk Auto Group projects';

-- Add comment to document in README
COMMENT ON DATABASE postgres IS 'Migration files prefixed with SHARE_ should be synchronized across all Quirk Auto Group projects';