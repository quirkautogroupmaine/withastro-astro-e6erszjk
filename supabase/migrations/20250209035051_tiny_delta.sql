-- Update Meilisearch configuration with hosted instance details
UPDATE meilisearch_config 
SET 
  host = 'https://ms-f8a16cea-a05c-3a1e-7bf9.meilisearch.io',
  api_key = 'f8a16ceaa05c3a1e7bf91f518b78e80f9836b58a',
  updated_at = now();

-- Add comment for documentation
COMMENT ON TABLE meilisearch_config IS 'Configuration for Meilisearch hosted instance';