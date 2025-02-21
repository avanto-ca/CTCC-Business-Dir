import { createClient } from '@supabase/supabase-js';
import type { Database } from '../types/supabase';

const supabaseUrl = import.meta.env.VITE_PUBLIC_SUPABASE_URL || '';
const supabaseAnonKey = import.meta.env.VITE_PUBLIC_SUPABASE_ANON_KEY || '';

// Create client with retry logic
const createSupabaseClient = () => {
  if (!supabaseUrl || !supabaseAnonKey) {
    console.error('Missing Supabase credentials. Please check your .env file.');
    return null;
  }

  try {
    return createClient<Database>(
      supabaseUrl,
      supabaseAnonKey,
      {
        auth: {
          autoRefreshToken: true,
          persistSession: true,
          detectSessionInUrl: true
        },
        global: {
          headers: { 'x-application-name': 'CTCC Directory' }
        },
        db: {
          schema: 'public'
        }
      }
    );
  } catch (error) {
    console.error('Failed to create Supabase client:', error);
    return null;
  }
};

export const supabase = createSupabaseClient();