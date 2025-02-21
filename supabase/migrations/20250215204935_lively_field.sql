/*
  # Fix Gowreesan Yoga profile data

  1. Updates
    - Add missing Firstname and Lastname for Gowreesan Yoga profile
    - Ensure proper name formatting
  
  2. Changes
    - Updates member record with proper name fields
*/

UPDATE members
SET 
  "Firstname" = 'Gowreesan',
  "Lastname" = 'Yoga'
WHERE type = 'Yoga' 
  AND (
    ("Name" ILIKE '%Gowreesan%' AND "Name" ILIKE '%Yoga%')
    OR ("aboutus" ILIKE '%Gowreesan%' AND "aboutus" ILIKE '%Yoga%')
  )
  AND ("Firstname" IS NULL OR "Lastname" IS NULL);