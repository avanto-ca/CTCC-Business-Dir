/*
  # Fix logo upload functionality
  
  1. Changes
    - Adds proper storage configuration
    - Creates logos bucket with correct permissions
    - Updates RLS policies for file access
  
  2. Security
    - Enables RLS on storage tables
    - Adds proper access policies
    - Validates file types
*/

-- First ensure we're operating as superuser
SET ROLE postgres;

-- Create storage schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS storage;

-- Create storage.buckets table if it doesn't exist
CREATE TABLE IF NOT EXISTS storage.buckets (
  id text PRIMARY KEY,
  name text NOT NULL UNIQUE,
  owner uuid REFERENCES auth.users,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  public boolean DEFAULT false,
  avif_autodetection boolean DEFAULT false,
  file_size_limit bigint,
  allowed_mime_types text[]
);

-- Create storage.objects table if it doesn't exist
CREATE TABLE IF NOT EXISTS storage.objects (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  bucket_id text NOT NULL REFERENCES storage.buckets(id),
  name text NOT NULL,
  owner uuid REFERENCES auth.users,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  last_accessed_at timestamptz DEFAULT now(),
  metadata jsonb DEFAULT '{}'::jsonb,
  path_tokens text[] GENERATED ALWAYS AS (string_to_array(name, '/')) STORED,
  size bigint,
  mime_type text,
  UNIQUE(bucket_id, name)
);

-- Set proper ownership
ALTER TABLE storage.buckets OWNER TO postgres;
ALTER TABLE storage.objects OWNER TO postgres;

-- Enable RLS
ALTER TABLE storage.buckets ENABLE ROW LEVEL SECURITY;
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- Create logos bucket if it doesn't exist
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
DROP POLICY IF EXISTS "Auth Users Can Update Logos" ON storage.objects;
DROP POLICY IF EXISTS "Auth Users Can Delete Logos" ON storage.objects;

-- Create bucket policies
CREATE POLICY "Public Access to Logos Bucket"
  ON storage.buckets FOR SELECT
  TO public
  USING (name = 'logos');

CREATE POLICY "Auth Users Can Create Buckets"
  ON storage.buckets FOR INSERT
  TO authenticated
  WITH CHECK (true);

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
    (mime_type = 'image/png' OR
     mime_type = 'image/jpeg' OR
     mime_type = 'image/gif' OR
     mime_type = 'image/webp')
  );

CREATE POLICY "Auth Users Can Update Logos"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (bucket_id = 'logos');

CREATE POLICY "Auth Users Can Delete Logos"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (bucket_id = 'logos');

-- Grant necessary permissions
GRANT USAGE ON SCHEMA storage TO authenticated;
GRANT ALL ON storage.buckets TO authenticated;
GRANT ALL ON storage.objects TO authenticated;

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS bname ON storage.buckets(name);
CREATE INDEX IF NOT EXISTS objects_bucketid_index ON storage.objects(bucket_id);
CREATE INDEX IF NOT EXISTS objects_name_index ON storage.objects(name);

-- Add comments
COMMENT ON SCHEMA storage IS 'Schema for storing files and assets';
COMMENT ON TABLE storage.buckets IS 'Storage buckets for organizing files';
COMMENT ON TABLE storage.objects IS 'Storage objects (files) with proper access control';