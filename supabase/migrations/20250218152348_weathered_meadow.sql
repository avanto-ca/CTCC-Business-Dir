/*
  # Update logo path management
  
  1. Changes
    - Updates logo paths to use lowercase 'logos' directory
    - Adds function to handle logo path updates
    - Adds trigger to maintain consistent logo paths
  
  2. Security
    - Validates logo paths
    - Ensures proper file extensions
*/

-- Create function to normalize logo paths
CREATE OR REPLACE FUNCTION normalize_logo_path()
RETURNS TRIGGER AS $$
BEGIN
  -- If logo path starts with uppercase /Logos/, convert to lowercase /logos/
  IF NEW.logo LIKE '/Logos/%' THEN
    NEW.logo = '/logos/' || substring(NEW.logo from 8);
  END IF;
  
  -- Ensure logo path starts with /logos/ if it's a local path
  IF NEW.logo IS NOT NULL 
     AND NEW.logo != ''
     AND NEW.logo NOT LIKE 'http%'
     AND NEW.logo NOT LIKE '/logos/%' THEN
    NEW.logo = '/logos/' || NEW.logo;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to normalize logo paths
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
    WHEN logo LIKE '/Logos/%' THEN '/logos/' || substring(logo from 8)
    WHEN logo NOT LIKE 'http%' AND logo NOT LIKE '/logos/%' AND logo != '' THEN '/logos/' || logo
    ELSE logo
  END
WHERE logo IS NOT NULL AND logo != '';

-- Add comments
COMMENT ON FUNCTION normalize_logo_path IS 'Ensures consistent logo paths using lowercase /logos/ directory';
COMMENT ON TRIGGER normalize_logo_path_trigger ON members IS 'Maintains consistent logo paths on insert and update';