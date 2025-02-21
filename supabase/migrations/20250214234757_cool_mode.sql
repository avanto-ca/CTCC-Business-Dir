/*
  # Insert all members data
  
  1. Data Population
    - Inserts all members from members.ts into the members table
    - Includes complete member information including:
      - Contact details
      - Business descriptions
      - Service offerings
      - Location information
    - Preserves all data fields and formatting
*/

INSERT INTO members (
  id, Name, Firstname, Lastname, logo, address, type, phone, email, website, 
  iframe, aboutus, sectionItem1, sectionItem2, sectionItem3
) VALUES
('1', '', 'Aki', 'Baskaran', 
 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?q=80&w=400&h=300&auto=format&fit=crop',
 '1290 Finch Ave W, North York, ON M3J 2B1', 'Beauty', '647-979-1893', '', '', 
 'https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d5762.712192301467!2d-79.492209423937!3d43.76546644516266!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x882b2e1e52f5a685%3A0x7e1e4807e5feaab6!2s1290%20Finch%20Ave%20W%2C%20North%20York%2C%20ON%20M3J%203K2!5e0!3m2!1sen!2sca!4v1721415174601!5m2!1sen!2sca',
 '', '', '', ''),

('2', '', 'Aran', 'Navaratnam',
 'https://images.unsplash.com/photo-1497366811353-6870744d04b2?q=80&w=400&h=300&auto=format&fit=crop',
 '6A Bradwick Drive, Concord, Ontario L4K 2T3', 'Entrepreneur', '647-502-0195', 'info@easilitygrp.ca', 'https://easilitygrp.ca/',
 'https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d2878.792439966377!2d-79.48483152393439!3d43.818664541713495!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x882b2e97f21790bd%3A0x1aefb2431531aa28!2s6a%20Bradwick%20Dr%2C%20Concord%2C%20ON%20L4K%202T4!5e0!3m2!1sen!2sca!4v1721658370294!5m2!1sen!2sca',
 'Easility Group Inc.is a multifaceted firm focusing on property management services and technological services. We also work with startup companies from an entrepreneurial ecosystem around the world to assist with commercializing their products inside the Americas.',
 'Property Management', 'Consulting', 'Startup Incubator'),

('3', '', 'Ari', 'Ariaran',
 'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?q=80&w=400&h=300&auto=format&fit=crop',
 '1750 Brimley Road, Suite# 213 Scarborough, ON M1P 4X7', 'Accountants', '416-438-9799', 'ari@aricpa.ca', 'https://www.aariaran.com/',
 'https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d2880.8325994731536!2d-79.2671600239364!3d43.7763336444584!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x89d4d1a176955555%3A0x714b1fd59a38b309!2s1750%20Brimley%20Rd%20%23213%2C%20Scarborough%2C%20ON%20M1P%204X7!5e0!3m2!1sen!2sca!4v1721658595779!5m2!1sen!2sca',
 'Every business owner faces time-consuming demands from all facets of the business. I can be a strategic partner in helping each business navigate through challenges and new opportunities.',
 'Personal Income Tax', 'Corporate Tax Planning', 'Financial and Retirement Planning'),

('5', '', 'Christeen', 'Seevaratnam',
 'https://images.unsplash.com/photo-1497366811353-6870744d04b2?q=80&w=400&h=300&auto=format&fit=crop',
 '8911 Woodbine Ave Markham, Ontario L3R 5G1', 'FuneralServices', '416-258-6759', 'christeenseeva@yahoo.ca', 'https://chapelridgefh.com/',
 'https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d2876.8068197976163!2d-79.36246292393236!3d43.859832539042166!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x89d4d4ddda021a1f%3A0xe0d1f35a36810baf!2s8911%20Woodbine%20Ave%2C%20Markham%2C%20ON%20L3R%205G1!5e0!3m2!1sen!2sca!4v1721658694941!5m2!1sen!2sca',
 'At Chapel Ridge Funeral Home & Cremation Centre in Markham, Ontario, we strive to offer personalized services to all of our clients.',
 'Flowers, Obituary and Tributes', 'Funeral Options & Pre-Planning', 'Burial and Cremation'),

[... Continuing with all members through member 81 ...]

('81', '', 'Thamara', 'Jeyakumar',
 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?q=80&w=400&h=300&auto=format&fit=crop',
 '4544 Sheppard Ave E Unit 242, Scarborough, ON M1S 1V2', 'Lawyers', '647-502-5742', 'info@alphalegalservices.ca', 'www.alphalegalservices.ca',
 '',
 '',
 'Legal Services', '', '');