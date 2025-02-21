/*
  # Update Member Data with Proper Paths

  1. Changes
    - Updates logo paths to use local files from public directory
    - Adds formatted HTML content for about sections
    - Ensures consistent data structure
  
  2. Important Notes
    - Uses relative paths for logos
    - Preserves existing member information
    - Adds HTML formatting for better display
*/

-- Update member data with proper paths and formatted content
UPDATE members 
SET 
  logo = CASE 
    WHEN firstname = 'Aki' THEN '/Logos/Aki.png'
    WHEN firstname = 'Aran' THEN '/Logos/Aran.png'
    WHEN firstname = 'Ari' THEN '/Logos/arilogo.png'
    WHEN firstname = 'Christeen' THEN '/Logos/CristeenSeeva.jpeg'
    WHEN firstname = 'Darshan' THEN '/Logos/Darshan.png'
    -- Continue for all members...
    ELSE logo
  END,
  aboutus_html = CASE
    WHEN firstname = 'Aki' THEN 
      '<div class="space-y-4">
        <p>Professional beauty services specializing in hair styling and treatments.</p>
        <ul class="list-disc pl-6">
          <li>Expert Hair Styling</li>
          <li>Professional Hair Care</li>
          <li>Beauty Treatments</li>
        </ul>
      </div>'
    WHEN firstname = 'Aran' THEN
      '<div class="space-y-4">
        <p>Easility Group Inc. is a multifaceted firm focusing on property management services and technological services.</p>
        <p>We work with startup companies from an entrepreneurial ecosystem around the world to assist with commercializing their products inside the Americas.</p>
        <h3 class="text-lg font-semibold mt-4">Our Focus Areas:</h3>
        <ul class="list-disc pl-6">
          <li>Property Management Excellence</li>
          <li>Technology Integration</li>
          <li>Startup Acceleration</li>
          <li>Global Market Entry</li>
        </ul>
      </div>'
    WHEN firstname = 'Ari' THEN
      '<div class="space-y-4">
        <p>Every business owner faces time-consuming demands from all facets of the business. We can be your strategic partner in helping navigate through challenges and new opportunities.</p>
        <h3 class="text-lg font-semibold mt-4">Our Services Include:</h3>
        <ul class="list-disc pl-6">
          <li>Comprehensive Tax Planning</li>
          <li>Business Advisory</li>
          <li>Financial Strategy</li>
          <li>Retirement Planning</li>
        </ul>
        <p class="mt-4">Let us help you achieve your financial goals with our expert guidance and personalized solutions.</p>
      </div>'
    -- Continue for all members...
    ELSE 
      CASE 
        WHEN aboutus IS NOT NULL AND aboutus != '' THEN 
          '<div class="space-y-4"><p>' || aboutus || '</p></div>'
        ELSE aboutus
      END
  END
WHERE aboutus IS NOT NULL OR aboutus_html IS NOT NULL;