/*
  # Update Herbal Moon Beauty Centre logo path
  
  Updates the logo path for Herbal Moon Beauty Centre to ensure it displays correctly.
*/

UPDATE members 
SET logo = '/Logos/HerbalMoon.png'
WHERE "Name" ILIKE '%Herbal Moon Beauty Centre%'
   OR ("Firstname" ILIKE '%Herbal%' AND "Lastname" ILIKE '%Moon%');