/*
  # Update about us content with HTML formatting

  1. Changes
    - Updates the aboutus_html column for all members with HTML-formatted content
    - Preserves existing information while adding proper HTML structure
    - Improves readability with proper HTML formatting

  2. Security
    - No changes to RLS policies needed
    - Content is sanitized on display in the frontend
*/

UPDATE members SET aboutus_html = CASE
  -- Easility Group
  WHEN id = '2' THEN 
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

  -- Ari Ariaran
  WHEN id = '3' THEN
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

  -- Chapel Ridge
  WHEN id = '4' THEN
    '<div class="space-y-4">
      <p>At Chapel Ridge Funeral Home & Cremation Centre in Markham, Ontario, we strive to offer personalized services to all of our clients.</p>
      <h3 class="text-lg font-semibold mt-4">Our Commitment:</h3>
      <ul class="list-disc pl-6">
        <li>Compassionate Care</li>
        <li>Personalized Services</li>
        <li>Cultural Sensitivity</li>
        <li>Professional Support</li>
      </ul>
      <p class="mt-4">We understand the importance of honoring your loved ones with dignity and respect.</p>
    </div>'

  -- Darshan Sritharan
  WHEN id = '5' THEN
    '<div class="space-y-4">
      <p>Dominion Lending Centres is Canada''s national mortgage and leasing company. We provide expert guidance for:</p>
      <ul class="list-disc pl-6">
        <li>First-Time Home Buyers</li>
        <li>Mortgage Refinancing</li>
        <li>Investment Properties</li>
        <li>Commercial Mortgages</li>
      </ul>
      <p class="mt-4">Our team of professionals is dedicated to finding the best mortgage solutions for your needs.</p>
    </div>'

  -- Default case for other profiles
  ELSE 
    CASE 
      WHEN aboutus IS NOT NULL AND aboutus != '' THEN 
        '<div class="space-y-4"><p>' || aboutus || '</p></div>'
      ELSE aboutus
    END
END
WHERE aboutus IS NOT NULL;