/*
  # Fix storage schema permissions

  1. Schema Setup
    - Creates storage schema with proper ownership
    - Grants necessary permissions to roles
    - Sets up required extensions
  
  2. Bucket Configuration
    - Creates logos bucket with proper settings
    - Sets up RLS policies for public access and authenticated uploads
*/

-- First ensure we're operating as superuser
SET ROLE postgres;

-- Create extensions if they don't exist
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;
CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA public;

-- Create storage schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS storage;

-- Set proper ownership
ALTER SCHEMA storage OWNER TO postgres;

-- Create required roles if they don't exist
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'authenticated') THEN
    CREATE ROLE authenticated;
  END IF;
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'anon') THEN
    CREATE ROLE anon;
  END IF;
END
$$;

-- Grant proper permissions
GRANT USAGE ON SCHEMA storage TO postgres, authenticated, anon;
GRANT ALL ON SCHEMA storage TO postgres;

-- Create storage.buckets table if it doesn't exist
CREATE TABLE IF NOT EXISTS storage.buckets (
  id text PRIMARY KEY,
  name text NOT NULL,
  owner uuid REFERENCES auth.users,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  public boolean DEFAULT false,
  avif_autodetection boolean DEFAULT false,
  file_size_limit bigint,
  allowed_mime_types text[],
  UNIQUE(name)
);

-- Create storage.objects table if it doesn't exist
CREATE TABLE IF NOT EXISTS storage.objects (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  bucket_id text NOT NULL REFERENCES storage.buckets(id),
  name text NOT NULL,
  owner uuid REFERENCES auth.users,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  last_accessed_at timestamptz DEFAULT now(),
  metadata jsonb DEFAULT '{}'::jsonb,
  path_tokens text[] GENERATED ALWAYS AS (string_to_array(name, '/')) STORED,
  UNIQUE(bucket_id, name)
);

-- Set proper table ownership
ALTER TABLE storage.buckets OWNER TO postgres;
ALTER TABLE storage.objects OWNER TO postgres;

-- Enable RLS
ALTER TABLE storage.buckets ENABLE ROW LEVEL SECURITY;
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- Grant table permissions
GRANT ALL ON storage.buckets TO postgres;
GRANT ALL ON storage.objects TO postgres;
GRANT SELECT ON storage.buckets TO authenticated, anon;
GRANT SELECT ON storage.objects TO authenticated, anon;
GRANT INSERT, UPDATE, DELETE ON storage.objects TO authenticated;

-- Create logos bucket with proper configuration
INSERT INTO storage.buckets (id, name, public, allowed_mime_types, file_size_limit)
VALUES (
  'logos',
  'logos',
  true,
  ARRAY[
    'image/png',
    'image/jpeg',
    'image/gif',
    'image/webp'
  ],
  10485760  -- 10MB limit
)
ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public,
  allowed_mime_types = EXCLUDED.allowed_mime_types,
  file_size_limit = EXCLUDED.file_size_limit;

-- Drop existing policies
DROP POLICY IF EXISTS "Public Access to Logos Bucket" ON storage.buckets;
DROP POLICY IF EXISTS "Public Read Access for Logos" ON storage.objects;
DROP POLICY IF EXISTS "Auth Users Can Upload Logos" ON storage.objects;
DROP POLICY IF EXISTS "Auth Users Can Update Own Logos" ON storage.objects;
DROP POLICY IF EXISTS "Auth Users Can Delete Own Logos" ON storage.objects;

-- Create bucket policies
CREATE POLICY "Public Access to Logos Bucket"
  ON storage.buckets FOR SELECT
  TO public
  USING (name = 'logos');

-- Create object policies
CREATE POLICY "Public Read Access for Logos"
  ON storage.objects FOR SELECT
  TO public
  USING (bucket_id = 'logos');

CREATE POLICY "Auth Users Can Upload Logos"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'logos' AND
    (CASE WHEN RIGHT(LOWER(name), 4) = '.png' THEN true
          WHEN RIGHT(LOWER(name), 4) = '.jpg' THEN true
          WHEN RIGHT(LOWER(name), 5) = '.jpeg' THEN true
          WHEN RIGHT(LOWER(name), 4) = '.gif' THEN true
          WHEN RIGHT(LOWER(name), 5) = '.webp' THEN true
          ELSE false
    END)
  );

CREATE POLICY "Auth Users Can Update Own Logos"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (bucket_id = 'logos')
  WITH CHECK (bucket_id = 'logos');

CREATE POLICY "Auth Users Can Delete Own Logos"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (bucket_id = 'logos');

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS bname ON storage.buckets(name);
CREATE INDEX IF NOT EXISTS objects_bucketid_index ON storage.objects(bucket_id);
CREATE INDEX IF NOT EXISTS objects_name_index ON storage.objects(name);

-- Add comments
COMMENT ON SCHEMA storage IS 'Schema for storing files and assets';
COMMENT ON TABLE storage.buckets IS 'Storage buckets for organizing files';
COMMENT ON TABLE storage.objects IS 'Storage objects (files) with proper access control';