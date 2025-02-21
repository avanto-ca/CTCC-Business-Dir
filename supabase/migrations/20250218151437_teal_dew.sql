/*
  # Fix Herbal Moon Beauty Centre logo path
  
  Updates the logo path for Herbal Moon Beauty Centre to ensure it displays correctly
  and handles both the database update and file path.
*/

-- First verify the business exists
DO $$
DECLARE
  business_id integer;
BEGIN
  -- Get the business ID
  SELECT id INTO business_id
  FROM members
  WHERE "Name" ILIKE '%Herbal Moon Beauty Centre%'
     OR ("Firstname" ILIKE '%Herbal%' AND "Lastname" ILIKE '%Moon%');

  -- Only update if business exists
  IF business_id IS NOT NULL THEN
    -- Update the logo path
    UPDATE members 
    SET logo = '/Logos/HerbalMoon.png',
        updated_at = NOW()
    WHERE id = business_id;
  END IF;
END $$;