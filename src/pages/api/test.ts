import type { APIRoute } from 'astro';
import { supabase } from '../../lib/supabase';

export const GET: APIRoute = async () => {
  try {
    console.log('Testing Supabase connection...');
    console.log('Supabase URL:', import.meta.env.SUPABASE_URL ? 'Set' : 'Not set');
    console.log('Supabase Key:', import.meta.env.SUPABASE_ANON_KEY ? 'Set' : 'Not set');

    // Test database connection by fetching a single category
    const { data, error } = await supabase
      .from('categories')
      .select('*')
      .limit(1);

    if (error) {
      console.error('Supabase query error:', error);
      throw error;
    }

    console.log('Query result:', data);

    // Return connection status and environment info
    return new Response(JSON.stringify({
      success: true,
      data,
      connection: {
        supabaseUrl: import.meta.env.SUPABASE_URL ? 'Set' : 'Not set',
        supabaseKey: import.meta.env.SUPABASE_ANON_KEY ? 'Set' : 'Not set',
        timestamp: new Date().toISOString()
      }
    }), {
      status: 200,
      headers: {
        'Content-Type': 'application/json',
        'Cache-Control': 'no-store, no-cache, must-revalidate'
      }
    });

  } catch (error) {
    console.error('Test endpoint error:', error);
    
    // Return detailed error information
    return new Response(JSON.stringify({
      success: false,
      error: {
        message: error.message,
        code: error.code,
        details: error.details,
        hint: error.hint
      },
      connection: {
        supabaseUrl: import.meta.env.SUPABASE_URL ? 'Set' : 'Not set',
        supabaseKey: import.meta.env.SUPABASE_ANON_KEY ? 'Set' : 'Not set',
        timestamp: new Date().toISOString()
      }
    }), {
      status: 500,
      headers: {
        'Content-Type': 'application/json',
        'Cache-Control': 'no-store, no-cache, must-revalidate'
      }
    });
  }
};