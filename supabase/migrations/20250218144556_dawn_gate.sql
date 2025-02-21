/*
  # Add storage bucket for logos

  1. New Storage
    - Creates a public bucket for storing business logos
    - Adds policies for authenticated users to manage files
    - Ensures proper file type restrictions
  
  2. Security
    - Enables public read access
    - Restricts uploads to authenticated users
    - Limits file types to images
*/

-- Create storage bucket if it doesn't exist
INSERT INTO storage.buckets (id, name, public)
VALUES ('logos', 'logos', true)
ON CONFLICT (id) DO NOTHING;

-- Allow public access to logos
CREATE POLICY "Public Access"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'logos');

-- Allow authenticated users to upload logos
CREATE POLICY "Authenticated users can upload logos"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'logos' AND
  (storage.extension(name) = 'png' OR
   storage.extension(name) = 'jpg' OR
   storage.extension(name) = 'jpeg' OR
   storage.extension(name) = 'gif' OR
   storage.extension(name) = 'webp')
);

-- Allow authenticated users to update their uploads
CREATE POLICY "Authenticated users can update logos"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'logos')
WITH CHECK (bucket_id = 'logos');

-- Allow authenticated users to delete logos
CREATE POLICY "Authenticated users can delete logos"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'logos');

-- Add comment
COMMENT ON TABLE storage.objects IS 'Storage for business logos with proper access control';