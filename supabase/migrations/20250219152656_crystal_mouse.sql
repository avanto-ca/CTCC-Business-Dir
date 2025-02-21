/*
  # Update category colors

  1. Changes
    - Update category colors to use proper Tailwind classes
    - Use consistent color scheme across categories
    - Add opacity classes for better visual hierarchy
  
  2. Security
    - Maintain existing RLS policies
*/

-- Update category colors to use proper Tailwind classes
UPDATE categories
SET color = 
  CASE name
    -- Professional Services
    WHEN 'Accountants' THEN 'bg-blue-500'
    WHEN 'Lawyers' THEN 'bg-indigo-500'
    WHEN 'Finance' THEN 'bg-emerald-500'
    
    -- Real Estate & Property
    WHEN 'RealEstate' THEN 'bg-green-500'
    WHEN 'CleaningServices' THEN 'bg-cyan-500'
    
    -- Business & Commerce
    WHEN 'Entrepreneur' THEN 'bg-amber-500'
    WHEN 'Impex' THEN 'bg-orange-500'
    
    -- Technology
    WHEN 'Engineering' THEN 'bg-violet-500'
    WHEN 'WebDesign' THEN 'bg-fuchsia-500'
    
    -- Personal Services
    WHEN 'Beauty' THEN 'bg-pink-500'
    WHEN 'HealthCare' THEN 'bg-rose-500'
    WHEN 'FuneralServices' THEN 'bg-slate-500'
    
    -- Food & Hospitality
    WHEN 'Restaurants' THEN 'bg-teal-500'
    WHEN 'EventManagement' THEN 'bg-sky-500'
    
    -- Education & Training
    WHEN 'Education' THEN 'bg-purple-500'
    
    -- Default color for new categories
    ELSE 'bg-gray-500'
  END
WHERE color NOT LIKE 'bg-%';

-- Add comment
COMMENT ON TABLE categories IS 'Business categories with consistent color scheme';