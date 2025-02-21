/*
  # Fix logo paths and storage configuration
  
  1. Changes
    - Updates logo paths to use lowercase /logos/
    - Adds function to normalize paths
    - Updates existing records
  
  2. Security
    - Maintains existing RLS policies
    - Preserves file access controls
*/

-- Create function to normalize logo paths
CREATE OR REPLACE FUNCTION normalize_logo_path()
RETURNS TRIGGER AS $$
BEGIN
  -- Skip if logo is null or empty
  IF NEW.logo IS NULL OR NEW.logo = '' THEN
    RETURN NEW;
  END IF;

  -- Don't modify external URLs
  IF NEW.logo LIKE 'http%' THEN
    RETURN NEW;
  END IF;

  -- Convert /Logos/ to /logos/
  IF NEW.logo LIKE '/Logos/%' THEN
    NEW.logo = '/logos/' || substring(NEW.logo from 8);
  END IF;
  
  -- Add /logos/ prefix if missing
  IF NEW.logo NOT LIKE '/logos/%' THEN
    NEW.logo = '/logos/' || regexp_replace(NEW.logo, '^/*', '');
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for normalizing paths
DROP TRIGGER IF EXISTS normalize_logo_path_trigger ON members;
CREATE TRIGGER normalize_logo_path_trigger
  BEFORE INSERT OR UPDATE OF logo
  ON members
  FOR EACH ROW
  EXECUTE FUNCTION normalize_logo_path();

-- Update existing logo paths
UPDATE members
SET logo = 
  CASE 
    WHEN logo LIKE 'http%' THEN logo
    WHEN logo LIKE '/Logos/%' THEN '/logos/' || substring(logo from 8)
    WHEN logo != '' AND logo IS NOT NULL THEN '/logos/' || regexp_replace(logo, '^/*', '')
    ELSE logo
  END
WHERE logo IS NOT NULL;

-- Add comments
COMMENT ON FUNCTION normalize_logo_path IS 'Ensures consistent logo paths using lowercase /logos/ directory';
COMMENT ON TRIGGER normalize_logo_path_trigger ON members IS 'Maintains consistent logo paths on insert and update';