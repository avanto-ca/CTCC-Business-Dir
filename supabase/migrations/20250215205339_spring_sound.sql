/*
  # Fix Gowreesan Yoga profile data

  1. Changes
    - Update Firstname and Lastname for Gowreesan Yoga's profile
    - Ensure profile is clickable by setting required fields

  2. Security
    - No changes to security policies
*/

UPDATE members
SET 
  "Firstname" = 'Gowreesan',
  "Lastname" = 'Yoga'
WHERE type = 'Yoga' 
  AND (
    ("Name" ILIKE '%Gowreesan%' AND "Name" ILIKE '%Yoga%')
    OR ("aboutus" ILIKE '%Gowreesan%' AND "aboutus" ILIKE '%Yoga%')
    OR ("website" ILIKE '%gowreesan%' AND "website" ILIKE '%yoga%')
  )
  AND ("Firstname" IS NULL OR "Lastname" IS NULL);