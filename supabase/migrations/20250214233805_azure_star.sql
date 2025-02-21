/*
  # Insert all member data
  
  1. Data Population
    - Inserts all member records from members.ts into the members table
    - Includes complete member information with contact details and business descriptions
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
 'Easility Group Inc. is a multifaceted firm focusing on property management services and technological services.',
 'Property Management', 'Consulting', 'Startup Incubator'),

('3', '', 'Ari', 'Ariaran',
 'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?q=80&w=400&h=300&auto=format&fit=crop',
 '1750 Brimley Road, Suite# 213 Scarborough, ON M1P 4X7', 'Accountants', '416-438-9799', 'ari@aricpa.ca', 'https://www.aariaran.com/',
 'https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d2880.8325994731536!2d-79.2671600239364!3d43.7763336444584!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x89d4d1a176955555%3A0x714b1fd59a38b309!2s1750%20Brimley%20Rd%20%23213%2C%20Scarborough%2C%20ON%20M1P%204X7!5e0!3m2!1sen!2sca!4v1721658595779!5m2!1sen!2sca',
 'Professional accounting services for businesses and individuals.',
 'Personal Income Tax', 'Corporate Tax Planning', 'Financial and Retirement Planning'),

('4', '', 'Arun', 'Thangavel',
 'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?q=80&w=400&h=300&auto=format&fit=crop',
 '1750 Brimley Road, Suite# 213 Scarborough, ON M1P 4X7', 'Accountants', '416-438-9799', 'arun@aricpa.ca', 'https://www.aariaran.com/',
 'https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d2880.8325994731536!2d-79.2671600239364!3d43.7763336444584!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x89d4d1a176955555%3A0x714b1fd59a38b309!2s1750%20Brimley%20Rd%20%23213%2C%20Scarborough%2C%20ON%20M1P%204X7!5e0!3m2!1sen!2sca!4v1721658595779!5m2!1sen!2sca',
 'Expert accounting and tax services for businesses and individuals.',
 'Corporate Accounting', 'Tax Planning', 'Business Advisory'),

('5', '', 'Bala', 'Balendran',
 'https://images.unsplash.com/photo-1560179707-f14e90ef3623?q=80&w=400&h=300&auto=format&fit=crop',
 '1750 Brimley Road, Suite# 213 Scarborough, ON M1P 4X7', 'Entrepreneur', '416-438-9799', 'bala@company.com', 'https://www.company.com/',
 'https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d2880.8325994731536!2d-79.2671600239364!3d43.7763336444584!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x89d4d1a176955555%3A0x714b1fd59a38b309!2s1750%20Brimley%20Rd%20%23213%2C%20Scarborough%2C%20ON%20M1P%204X7!5e0!3m2!1sen!2sca!4v1721658595779!5m2!1sen!2sca',
 'Innovative business solutions and entrepreneurial ventures.',
 'Business Development', 'Strategic Planning', 'Investment Advisory'),

('6', '', 'Bala', 'Thillainathan',
 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?q=80&w=400&h=300&auto=format&fit=crop',
 '1750 Brimley Road, Suite# 213 Scarborough, ON M1P 4X7', 'RealEstate', '416-438-9799', 'bala@realty.com', 'https://www.realty.com/',
 'https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d2880.8325994731536!2d-79.2671600239364!3d43.7763336444584!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x89d4d1a176955555%3A0x714b1fd59a38b309!2s1750%20Brimley%20Rd%20%23213%2C%20Scarborough%2C%20ON%20M1P%204X7!5e0!3m2!1sen!2sca!4v1721658595779!5m2!1sen!2sca',
 'Professional real estate services for residential and commercial properties.',
 'Property Sales', 'Property Management', 'Investment Properties'),

('7', '', 'Bala', 'Vigneswaran',
 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?q=80&w=400&h=300&auto=format&fit=crop',
 '1750 Brimley Road, Suite# 213 Scarborough, ON M1P 4X7', 'Finance', '416-438-9799', 'bala@finance.com', 'https://www.finance.com/',
 'https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d2880.8325994731536!2d-79.2671600239364!3d43.7763336444584!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x89d4d1a176955555%3A0x714b1fd59a38b309!2s1750%20Brimley%20Rd%20%23213%2C%20Scarborough%2C%20ON%20M1P%204X7!5e0!3m2!1sen!2sca!4v1721658595779!5m2!1sen!2sca',
 'Comprehensive financial planning and investment services.',
 'Financial Planning', 'Investment Management', 'Retirement Planning'),

('8', '', 'Baskaran', 'Sinnadurai',
 'https://images.unsplash.com/photo-1450101499163-c8848c66ca85?q=80&w=400&h=300&auto=format&fit=crop',
 '1750 Brimley Road, Suite# 213 Scarborough, ON M1P 4X7', 'Accountants', '416-438-9799', 'baskaran@accounting.com', 'https://www.accounting.com/',
 'https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d2880.8325994731536!2d-79.2671600239364!3d43.7763336444584!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x89d4d1a176955555%3A0x714b1fd59a38b309!2s1750%20Brimley%20Rd%20%23213%2C%20Scarborough%2C%20ON%20M1P%204X7!5e0!3m2!1sen!2sca!4v1721658595779!5m2!1sen!2sca',
 'Professional accounting and tax services for individuals and businesses.',
 'Tax Services', 'Bookkeeping', 'Business Advisory'),

('9', '', 'Chandran', 'Sornalingam',
 'https://images.unsplash.com/photo-1504615755583-2916b52192a3?q=80&w=400&h=300&auto=format&fit=crop',
 '1750 Brimley Road, Suite# 213 Scarborough, ON M1P 4X7', 'Engineering', '416-438-9799', 'chandran@engineering.com', 'https://www.engineering.com/',
 'https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d2880.8325994731536!2d-79.2671600239364!3d43.7763336444584!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x89d4d1a176955555%3A0x714b1fd59a38b309!2s1750%20Brimley%20Rd%20%23213%2C%20Scarborough%2C%20ON%20M1P%204X7!5e0!3m2!1sen!2sca!4v1721658595779!5m2!1sen!2sca',
 'Innovative engineering solutions for modern challenges.',
 'Structural Engineering', 'Project Management', 'Technical Consulting'),

('10', '', 'Gajan', 'Satkunarajah',
 'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?q=80&w=400&h=300&auto=format&fit=crop',
 '1750 Brimley Road, Suite# 213 Scarborough, ON M1P 4X7', 'Accountants', '416-438-9799', 'gajan@accounting.com', 'https://www.accounting.com/',
 'https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d2880.8325994731536!2d-79.2671600239364!3d43.7763336444584!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x89d4d1a176955555%3A0x714b1fd59a38b309!2s1750%20Brimley%20Rd%20%23213%2C%20Scarborough%2C%20ON%20M1P%204X7!5e0!3m2!1sen!2sca!4v1721658595779!5m2!1sen!2sca',
 'Comprehensive accounting and financial services.',
 'Tax Planning', 'Business Advisory', 'Financial Statements');