import { useState, useEffect } from 'react';
import { Helmet } from 'react-helmet-async';
import type { Member, Category, SEOMetadata } from '../types';
import { supabase } from '../lib/supabase';

interface SEOHeadProps {
  member?: Member;
  category?: Category;
  isHomePage?: boolean;
}

export function SEOHead({ member, category, isHomePage = false }: SEOHeadProps) {
  const [seoMetadata, setSeoMetadata] = useState<SEOMetadata | null>(null);

  useEffect(() => {
    async function fetchSEOMetadata() {
      if (member?.id) {
        const { data, error } = await supabase
          .from('seo_metadata')
          .select('*')
          .eq('member_id', member.id)
          .single();

        if (error) {
          if (error.code !== 'PGRST116') { // Ignore "no rows returned" error
            console.error('Error fetching SEO metadata:', error);
          }
        } else if (data) {
          setSeoMetadata(data);
        }
      }
    }

    fetchSEOMetadata();
  }, [member?.id]);

  if (isHomePage) {
    return (
      <Helmet>
        {/* <title>CTCC Business Directory - Tamil Chamber of Commerce</title> */}
        <title>Tamil Business Listings | Explore Tamil Businesses in Canada | CTCC Business Directory</title>
        <meta name="description" content="Find trusted Tamil professionals and businesses in your community. The Canadian Tamil Chamber of Commerce (CTCC) Business Directory connects you with qualified service providers." />
        <meta name="keywords" content="CTCC,Tamil business,Canadian Tamil Chamber of Commerce,Tamil professionals,business directory,Toronto Tamil business" />
        
        {/* Canonical URL */}
        <link rel="canonical" href={window.location.href} />
        
        {/* Open Graph / Facebook */}
        <meta property="og:type" content="website" />
        <meta property="og:title" content="CTCC Business Directory - Tamil Chamber of Commerce" />
        <meta property="og:description" content="Find trusted Tamil professionals and businesses in your community. Connect with qualified service providers through CTCC." />
        <meta property="og:image" content="/Logos/CTCCLogo.webp" />
        
        {/* Twitter */}
        <meta name="twitter:card" content="summary_large_image" />
        <meta name="twitter:title" content="CTCC Business Directory - Tamil Chamber of Commerce" />
        <meta name="twitter:description" content="Find trusted Tamil professionals and businesses in your community. Connect with qualified service providers through CTCC." />
        <meta name="twitter:image" content="/Logos/CTCCLogo.webp" />
      </Helmet>
    );
  }

  if (category && !member) {
    return (
      <Helmet>
        <title>{`${category.name.replace(/([A-Z])/g, ' $1').trim()} - CTCC Business Directory`}</title>
        <meta name="description" content={category.description} />
        <meta name="keywords" content={category.seo_tags.join(',')} />

        {/* Canonical URL */}
        <link rel="canonical" href={window.location.href} />
        
        {/* Open Graph / Facebook */}
        <meta property="og:type" content="website" />
        <meta property="og:title" content={`${category.name.replace(/([A-Z])/g, ' $1').trim()} - CTCC Business Directory`} />
        <meta property="og:description" content={category.description} />
        
        {/* Twitter */}
        <meta name="twitter:card" content="summary" />
        <meta name="twitter:title" content={`${category.name.replace(/([A-Z])/g, ' $1').trim()} - CTCC Business Directory`} />
        <meta name="twitter:description" content={category.description} />
      </Helmet>
    );
  }

  if (member && category) {
    const fullName = member.Name || `${member.Firstname} ${member.Lastname}`;
    const businessName = member.Name || fullName;
    const title = seoMetadata?.title || `${fullName} - ${category.name.replace(/([A-Z])/g, ' $1').trim()} | CTCC Directory`;
    
    // Generate rich keywords based on business type
    const defaultKeywords = [
      fullName,
      businessName,
      member.address?.split(',')[1]?.trim() || 'Toronto', // City
      category.name,
      ...category.seo_tags,
      'Tamil business',
      'CTCC member',
      'Canadian Tamil Chamber of Commerce'
    ].filter(Boolean) as string[];

    // Generate a rich description
    const description = `${fullName} provides professional ${category.name.replace(/([A-Z])/g, ' $1').trim().toLowerCase()} services${member.address ? ` in ${member.address.split(',')[1]?.trim() || 'Toronto'}` : ''}. ${member.aboutus || category.description}`;

    return (
      <Helmet>
        <title>{title}</title>
        <meta name="description" content={seoMetadata?.description || description.substring(0, 160)} />
        <meta name="keywords" content={seoMetadata?.keywords?.join(', ') || defaultKeywords.join(', ')} />

        {/* Canonical URL */}
        <link rel="canonical" href={window.location.href} />
        
        {/* Schema.org markup for business */}
        <script type="application/ld+json">
          {JSON.stringify({
            "@context": "https://schema.org",
            "@type": "LocalBusiness",
            "name": businessName,
            "image": member.logo,
            "description": seoMetadata?.schema_description || member.aboutus || category.description,
            "address": {
              "@type": "PostalAddress",
              "name": member.address,
              "streetAddress": member.address?.split(',')[0]?.trim(),
              "addressLocality": member.address?.split(',')[1]?.trim(),
              "addressRegion": "ON",
              "addressCountry": "CA"
            },
            "geo": {
              "@type": "GeoCoordinates",
              "latitude": "43.7417",
              "longitude": "-79.3733"
            },
            "url": member.website || window.location.href,
            "telephone": member.phone,
            "email": member.email,
            "priceRange": "$$",
            "openingHours": "Mo-Fr 09:00-17:00",
            "areaServed": {
              "@type": "GeoCircle",
              "geoMidpoint": { "@type": "GeoCoordinates", "latitude": 43.7417, "longitude": -79.3733 }
            },
            "category": category.name.replace(/([A-Z])/g, ' $1').trim()
          })}
        </script>
        
        {/* Open Graph / Facebook */}
        <meta property="og:type" content="business.business" />
        <meta property="og:title" content={seoMetadata?.og_title || title} />
        <meta property="og:description" content={seoMetadata?.og_description || description.substring(0, 160)} />
        <meta property="og:image" content={member.logo} />
        <meta property="og:url" content={window.location.href} />
        <meta property="business:contact_data:street_address" content={member.address?.split(',')[0]?.trim()} />
        <meta property="business:contact_data:locality" content={member.address?.split(',')[1]?.trim()} />
        <meta property="business:contact_data:region" content="ON" />
        <meta property="business:contact_data:postal_code" content={member.address?.split(',')[2]?.trim()} />
        <meta property="business:contact_data:country_name" content="Canada" />
        
        {/* Twitter */}
        <meta name="twitter:card" content="summary_large_image" />
        <meta name="twitter:title" content={seoMetadata?.twitter_title || title} />
        <meta name="twitter:description" content={seoMetadata?.twitter_description || description.substring(0, 160)} />
        <meta name="twitter:image" content={member.logo} />
      </Helmet>
    );
  }

  return null;
}