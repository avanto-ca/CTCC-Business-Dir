-- First ensure we're operating as superuser
SET ROLE postgres;

-- Drop existing policies to avoid conflicts
DROP POLICY IF EXISTS "Public Access to Logos Bucket" ON storage.buckets;
DROP POLICY IF EXISTS "Public Read Access for Logos" ON storage.objects;
DROP POLICY IF EXISTS "Auth Users Can Upload Logos" ON storage.objects;
DROP POLICY IF EXISTS "Auth Users Can Update Own Logos" ON storage.objects;
DROP POLICY IF EXISTS "Auth Users Can Delete Own Logos" ON storage.objects;

-- Create bucket policies with proper access
CREATE POLICY "Public Access to Logos Bucket"
  ON storage.buckets FOR SELECT
  TO public
  USING (name = 'logos');

CREATE POLICY "Auth Users Can Create Buckets"
  ON storage.buckets FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Auth Users Can Update Buckets"
  ON storage.buckets FOR UPDATE
  TO authenticated
  USING (true);

-- Create object policies with proper access
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

CREATE POLICY "Auth Users Can Update Logos"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (bucket_id = 'logos');

CREATE POLICY "Auth Users Can Delete Logos"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (bucket_id = 'logos');

-- Ensure proper grants
GRANT ALL ON storage.buckets TO authenticated;
GRANT ALL ON storage.objects TO authenticated;

-- Add comments
COMMENT ON POLICY "Public Access to Logos Bucket" ON storage.buckets IS 'Allow public read access to logos bucket';
COMMENT ON POLICY "Auth Users Can Create Buckets" ON storage.buckets IS 'Allow authenticated users to create buckets';
COMMENT ON POLICY "Auth Users Can Update Buckets" ON storage.buckets IS 'Allow authenticated users to update buckets';
COMMENT ON POLICY "Public Read Access for Logos" ON storage.objects IS 'Allow public read access to logo files';
COMMENT ON POLICY "Auth Users Can Upload Logos" ON storage.objects IS 'Allow authenticated users to upload logo files';
COMMENT ON POLICY "Auth Users Can Update Logos" ON storage.objects IS 'Allow authenticated users to update logo files';
COMMENT ON POLICY "Auth Users Can Delete Logos" ON storage.objects IS 'Allow authenticated users to delete logo files';