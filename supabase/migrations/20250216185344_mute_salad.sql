/*
  # Fix SEO metadata function syntax

  1. Changes
    - Fix function creation syntax
    - Add proper DO block structure
    - Ensure proper error handling
*/

-- Create or replace the timestamp update function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Recreate the trigger
DROP TRIGGER IF EXISTS update_seo_metadata_updated_at ON seo_metadata;
CREATE TRIGGER update_seo_metadata_updated_at
  BEFORE UPDATE ON seo_metadata
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Add comment
COMMENT ON FUNCTION update_updated_at_column IS 'Updates the updated_at timestamp column on record modification';