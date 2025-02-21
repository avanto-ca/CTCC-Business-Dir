/*
  # Fix storage bucket setup

  1. Storage Setup
    - Ensures storage schema exists
    - Creates logos bucket with proper configuration
    - Sets up all required policies
  
  2. Security
    - Enables public read access
    - Restricts uploads to authenticated users
    - Adds proper file type validation
*/

-- Create storage schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS storage;

-- Create storage.buckets table if it doesn't exist
CREATE TABLE IF NOT EXISTS storage.buckets (
  id text PRIMARY KEY,
  name text NOT NULL,
  owner uuid,
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
  bucket_id text REFERENCES storage.buckets(id),
  name text NOT NULL,
  owner uuid,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  last_accessed_at timestamptz DEFAULT now(),
  metadata jsonb,
  path_tokens text[] GENERATED ALWAYS AS (string_to_array(name, '/')) STORED
);

-- Enable RLS
ALTER TABLE storage.buckets ENABLE ROW LEVEL SECURITY;
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- Create logos bucket
INSERT INTO storage.buckets (id, name, public, allowed_mime_types)
VALUES (
  'logos',
  'logos',
  true,
  ARRAY[
    'image/png',
    'image/jpeg',
    'image/gif',
    'image/webp'
  ]
) ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

-- Create policies for buckets
CREATE POLICY "Public Access to Logos Bucket"
  ON storage.buckets FOR SELECT
  TO public
  USING (name = 'logos');

-- Create policies for objects
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
  USING (bucket_id = 'logos' AND owner = auth.uid())
  WITH CHECK (bucket_id = 'logos');

CREATE POLICY "Auth Users Can Delete Own Logos"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (bucket_id = 'logos' AND owner = auth.uid());

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS bname ON storage.buckets(name);
CREATE INDEX IF NOT EXISTS objects_bucketid_index ON storage.objects(bucket_id);
CREATE INDEX IF NOT EXISTS objects_name_index ON storage.objects(name);

-- Add comments
COMMENT ON TABLE storage.buckets IS 'Storage buckets for file management';
COMMENT ON TABLE storage.objects IS 'Storage objects (files) with proper access control';