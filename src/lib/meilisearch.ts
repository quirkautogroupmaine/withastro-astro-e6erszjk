import { MeiliSearch } from 'meilisearch';

const host = import.meta.env.PUBLIC_MEILISEARCH_HOST;
const apiKey = import.meta.env.PUBLIC_MEILISEARCH_API_KEY;

if (!host) {
  throw new Error('Missing PUBLIC_MEILISEARCH_HOST environment variable');
}

if (!apiKey) {
  throw new Error('Missing PUBLIC_MEILISEARCH_API_KEY environment variable');
}

export const client = new MeiliSearch({
  host,
  apiKey
});