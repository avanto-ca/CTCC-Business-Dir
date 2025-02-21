/*
  # Fix logo handling and RLS policies

  1. Changes
    - Remove storage schema and policies
    - Add RLS policies for members table
    - Add function to handle local logo paths
  
  2. Security
    - Enable RLS on members table
    - Add policies for public read access
    - Add policies for authenticated users to manage members
*/

-- Drop storage schema and its contents
DROP SCHEMA IF EXISTS storage CASCADE;

-- Enable RLS on members table
ALTER TABLE members ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for members table
CREATE POLICY "Allow public read access"
  ON members
  FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Allow authenticated users to manage members"
  ON members
  FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Create function to handle logo paths
CREATE OR REPLACE FUNCTION handle_logo_path()
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

-- Create trigger for logo path handling
DROP TRIGGER IF EXISTS handle_logo_path_trigger ON members;
CREATE TRIGGER handle_logo_path_trigger
  BEFORE INSERT OR UPDATE OF logo
  ON members
  FOR EACH ROW
  EXECUTE FUNCTION handle_logo_path();

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
COMMENT ON TABLE members IS 'Member profiles with proper RLS policies';
COMMENT ON FUNCTION handle_logo_path IS 'Ensures consistent logo paths using /logos/ directory';
COMMENT ON TRIGGER handle_logo_path_trigger ON members IS 'Maintains consistent logo paths on insert and update';