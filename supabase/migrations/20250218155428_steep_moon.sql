/*
  # Fix logo path handling

  1. Changes
    - Add function to normalize logo paths
    - Add trigger for automatic path normalization
    - Update existing logo paths to use consistent format
  
  2. Security
    - Maintain existing RLS policies
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

  -- Extract filename from path
  NEW.logo = regexp_replace(NEW.logo, '^.*[/\\]', '');
  
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

-- Update existing logo paths to only keep filenames
UPDATE members
SET logo = 
  CASE 
    WHEN logo LIKE 'http%' THEN logo
    ELSE regexp_replace(logo, '^.*[/\\]', '')
  END
WHERE logo IS NOT NULL;

-- Add comments
COMMENT ON FUNCTION normalize_logo_path IS 'Ensures consistent logo paths by storing only filenames';
COMMENT ON TRIGGER normalize_logo_path_trigger ON members IS 'Maintains consistent logo paths on insert and update';