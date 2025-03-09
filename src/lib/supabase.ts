import { createClient } from '@supabase/supabase-js';
import type { Database } from './database.types';

const supabaseUrl = import.meta.env.PUBLIC_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.PUBLIC_SUPABASE_ANON_KEY;

if (!supabaseUrl) {
  throw new Error('Missing PUBLIC_SUPABASE_URL environment variable');
}
if (!supabaseAnonKey) {
  throw new Error('Missing PUBLIC_SUPABASE_ANON_KEY environment variable');
}

export const supabase = createClient<Database>(
  supabaseUrl,
  supabaseAnonKey
);