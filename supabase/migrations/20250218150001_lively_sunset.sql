/*
  # Update Herbal Moon Beauty Centre logo path

  Updates the logo path for Herbal Moon Beauty Centre to use the correct file path.
*/

UPDATE members
SET logo = '/Logos/HerbalMoon.png'
WHERE "Name" = 'Herbal Moon Beauty Centre'
OR ("Firstname" = 'Herbal' AND "Lastname" = 'Moon');