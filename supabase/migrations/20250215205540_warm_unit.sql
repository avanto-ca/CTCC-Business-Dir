/*
  # Fix Gowreesan's profile category

  Updates Gowreesan's profile to use the correct category type that matches
  the defined categories in the application.
*/

UPDATE members
SET type = 'Entrepreneur'
WHERE "Firstname" = 'Gowreesan' 
  AND "Lastname" = 'Yoga';

-- Add comment explaining the category assignment
COMMENT ON TABLE members IS 'Member profiles with standardized business categories';