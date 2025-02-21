/*
  # Update category colors

  1. Changes
    - Update all category colors to use lighter, more professional shades
    - Use consistent color scheme across categories
    - Maintain proper contrast for accessibility
*/

-- Update category colors to lighter, more professional shades
UPDATE categories
SET color = 
  CASE name
    -- Professional Services
    WHEN 'Accountants' THEN 'bg-blue-100'
    WHEN 'Lawyers' THEN 'bg-indigo-100'
    WHEN 'Finance' THEN 'bg-emerald-100'
    
    -- Real Estate & Property
    WHEN 'RealEstate' THEN 'bg-green-100'
    WHEN 'CleaningServices' THEN 'bg-cyan-100'
    
    -- Business & Commerce
    WHEN 'Entrepreneur' THEN 'bg-amber-100'
    WHEN 'Impex' THEN 'bg-orange-100'
    
    -- Technology
    WHEN 'Engineering' THEN 'bg-violet-100'
    WHEN 'WebDesign' THEN 'bg-fuchsia-100'
    
    -- Personal Services
    WHEN 'Beauty' THEN 'bg-pink-100'
    WHEN 'HealthCare' THEN 'bg-rose-100'
    WHEN 'FuneralServices' THEN 'bg-slate-100'
    
    -- Food & Hospitality
    WHEN 'Restaurants' THEN 'bg-teal-100'
    WHEN 'EventManagement' THEN 'bg-sky-100'
    
    -- Education & Training
    WHEN 'Education' THEN 'bg-purple-100'
    
    -- Default color for new categories
    ELSE 'bg-gray-100'
  END
WHERE color LIKE 'bg-%';

-- Add comment
COMMENT ON TABLE categories IS 'Business categories with professional color scheme';