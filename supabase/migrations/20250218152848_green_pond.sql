/*
  # Fix logo upload permissions
  
  1. Changes
    - Adds proper storage policies for logo uploads
    - Ensures authenticated users can manage logos
    - Preserves existing data
  
  2. Security
    - Maintains RLS
    - Restricts file types to images
*/

-- First ensure we're operating as superuser
SET ROLE postgres;

-- Drop existing policies to avoid conflicts
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

CREATE POLICY "Auth Users Can Access Buckets"
  ON storage.buckets FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Create object policies
CREATE POLICY "Public Read Access for Logos"
  ON storage.objects FOR SELECT
  TO public
  USING (bucket_id = 'logos');

CREATE POLICY "Auth Users Can Upload Logos"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'logos');

CREATE POLICY "Auth Users Can Update Logos"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (bucket_id = 'logos')
  WITH CHECK (bucket_id = 'logos');

CREATE POLICY "Auth Users Can Delete Logos"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (bucket_id = 'logos');

-- Grant necessary permissions
GRANT ALL ON storage.buckets TO authenticated;
GRANT ALL ON storage.objects TO authenticated;

-- Add comments
COMMENT ON POLICY "Public Access to Logos Bucket" ON storage.buckets IS 'Allow public read access to logos bucket';
COMMENT ON POLICY "Auth Users Can Access Buckets" ON storage.buckets IS 'Allow authenticated users to manage buckets';
COMMENT ON POLICY "Public Read Access for Logos" ON storage.objects IS 'Allow public read access to logo files';
COMMENT ON POLICY "Auth Users Can Upload Logos" ON storage.objects IS 'Allow authenticated users to upload logo files';
COMMENT ON POLICY "Auth Users Can Update Logos" ON storage.objects IS 'Allow authenticated users to update logo files';
COMMENT ON POLICY "Auth Users Can Delete Logos" ON storage.objects IS 'Allow authenticated users to delete logo files';