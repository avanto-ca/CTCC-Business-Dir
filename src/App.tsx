import { useState, useEffect } from 'react';
import * as Icons from 'lucide-react';
import { Search, ChevronRight, MapPin, Mail, Phone, Globe, ArrowLeft, Share2, Facebook, Linkedin, Twitter, Instagram, Copy, Building2, User, PlusCircle, ListPlus, X } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import { useNavigate, useParams, useLocation } from 'react-router-dom';
import DOMPurify from 'dompurify';
import { ContactForm } from './components/ContactForm';
import { ListBusinessForm } from './components/ListBusinessForm';
import { SEOHead } from './components/SEOHead';
import { Footer } from './components/Footer';
import type { Member, Category, CommunityMember } from './types';
import { supabase } from './lib/supabase';

function App() {

  const navigate = useNavigate();
  const { category, memberId } = useParams();
  const location = useLocation();
  const [isLoading, setIsLoading] = useState(true);
  const [members, setMembers] = useState<Member[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedMemberData, setSelectedMemberData] = useState<Member | null>(null);
  const [showShareTooltip, setShowShareTooltip] = useState(false);
  const selectedCategory = category || null;
  const [shuffledMembers, setShuffledMembers] = useState<Member[]>([]);
  const [showListBusinessForm, setShowListBusinessForm] = useState(false);
  const [communityMembers, setCommunityMembers] = useState<CommunityMember[]>([]);

  useEffect(() => {
    async function fetchCategories() {
      try {
        if (!supabase) return;

        const { data, error } = await supabase
          .from('categories')
          .select('*')
          .order('name', { ascending: true });
        
        if (error) {
          throw error;
        }

        if (data) {
          setCategories(data);
        }
      } catch (error) {
        console.error('Error fetching categories:', error);
        setCategories([]);
      }
    }

    fetchCategories();
  }, []);

  useEffect(() => {
    async function fetchMembers() {
      try {
        if (!supabase) return;

        const { data, error } = await supabase
          .from('members')
          .select('*')
          .order('Firstname', { ascending: true });
        
        if (error) {
          throw error;
        }

        if (data) {
          const transformedData = data.map(member => ({
            ...member,
            Name: member.Name || '',
            Firstname: member.Firstname || '',
            Lastname: member.Lastname || '',
            aboutus: member.aboutus_html || member.aboutus || ''
          }));
          setMembers(transformedData);
        }
      } catch (error) {
        console.error('Error fetching members:', error);
        setMembers([]);
      } finally {
        setIsLoading(false);
      }
    }

    fetchMembers();
  }, []);

  useEffect(() => {
    async function fetchCommunityMembers() {
      try {
        if (!supabase) return;

        const { data, error } = await supabase
          .from('community_members')
          .select('*')
          .order('name', { ascending: true });
        
        if (error) {
          throw error;
        }

        if (data) {
          setCommunityMembers(data);
        }
      } catch (error) {
        console.error('Error fetching community members:', error);
        setCommunityMembers([]);
      }
    }

    fetchCommunityMembers();
  }, []);

  useEffect(() => {
    async function fetchMemberDetails() {
      if (memberId && category) {      
        const names = memberId.split('-');
        if (names.length !== 2) {
          navigate(`/${category}`);
          return;
        }

        const [firstName, lastName] = names;
        const categoryData = categories.find(c => c.url === category);
        if (!categoryData) {     
          // navigate('/');
          return;
        }

        try {
          if (!supabase) return;

          const { data, error } = await supabase
            .from('members')
            .select('*')
            .eq('category_id', categoryData.id)
            .ilike('Firstname', firstName || '')
            .ilike('Lastname', lastName || '')
            .single();

          if (error) {
            if (error.code === 'PGRST116') {
              // No results found
              navigate(`/${category}`);
            } else {
              console.error('Error fetching member details:', error);
              navigate(`/${category}`);
            }
            return;
          }

          if (data) {
            setSelectedMemberData(data);
          } else {
            navigate(`/${category}`);
          }
        } catch (error) {
          console.error('Error fetching member details:', error);
          navigate(`/${category}`);
        }
      }
    }

    fetchMemberDetails();
  }, [memberId, category, navigate, categories]);

  // Shuffle members when category changes
  useEffect(() => {
    if (selectedCategory) {
      const categoryId = categories.find(c => c.url === selectedCategory)?.id;
      const categoryMembers = categoryId ? members.filter(m => m.category_id === categoryId) : [];
      const shuffled = [...categoryMembers].sort(() => Math.random() - 0.5);
      setShuffledMembers(shuffled);
    }
  }, [selectedCategory, members, categories]);

  useEffect(() => {
    if (category && !categories.some(c => c.url === category)) {
      // navigate('/');
    }
  }, [category, categories, navigate]);

  const handleCategoryClick = (categoryName: string) => {
    navigate(`/${categoryName}`);
  };

  const handleMemberClick = (member: Member) => {
    // Validate required fields
    if (!member.Firstname || !member.Lastname) {
      console.warn('Member missing required name fields:', member);
      return;
    }

    const category = categories.find(c => c.id === member.category_id);
    if (!category) {
      console.warn('Member has invalid category:', member);
      return;
    }

    const memberSlug = `${member.Firstname}-${member.Lastname}`;
    navigate(`/${category.url}/${memberSlug.toLowerCase()}`);
  };

  const handleBackToCategories = () => {
    setSearchTerm("");
    navigate('/');
  };

  const handleBackToCategory = () => {
    setSearchTerm("");
    if (selectedCategory) {
      setSelectedMemberData(null);
      navigate(`/${selectedCategory}`);
    } else {
      // navigate('/');
    }
  };

  const handleShare = async (platform: string) => {
    if (!selectedMemberData) return;
    
    const memberName = selectedMemberData.Name || `${selectedMemberData.Firstname} ${selectedMemberData.Lastname}`;
    const shareUrl = window.location.href;
    const shareText = `Check out ${memberName}'s business profile on CTCC Directory!`;
    
    switch (platform) {
      case 'whatsapp':
        window.open(`https://api.whatsapp.com/send?text=${encodeURIComponent(shareText + ' ' + shareUrl)}`, '_blank');
        break;
      case 'facebook':
        window.open(`https://www.facebook.com/sharer/sharer.php?u=${encodeURIComponent(shareUrl)}`, '_blank');
        break;
      case 'linkedin':
        window.open(`https://www.linkedin.com/sharing/share-offsite/?url=${encodeURIComponent(shareUrl)}`, '_blank');
        break;
      case 'twitter':
        window.open(`https://twitter.com/intent/tweet?text=${encodeURIComponent(shareText)}&url=${encodeURIComponent(shareUrl)}`, '_blank');
        break;
      case 'copy':
        try {
          await navigator.clipboard.writeText(shareUrl);
          setShowShareTooltip(true);
          setTimeout(() => setShowShareTooltip(false), 2000);
        } catch (err) {
          console.error('Failed to copy URL:', err);
        }
        break;
    }
  };

  const filteredMembers = selectedCategory
  ? shuffledMembers
  : searchTerm.trim() === ''
  ? []
  : members.filter(member => {
      const searchLower = searchTerm.toLowerCase().trim();
      const category = categories.find(c => c.id === member.category_id);
      if (!category) return false;

      const categoryName = category.name.replace(/([A-Z])/g, ' $1').trim();      

      const priorityFields = [
        `${member.Firstname || ''} ${member.Lastname || ''}`.trim(),
        member.Name || '',
        categoryName,
        member.phone || '',
        member.email || '',
        member.sectionItem1||'',
        member.sectionItem2||'',
        member.sectionItem3||'',
        member.sectionItem4||'',
        member.sectionItem5||'',
        // member.aboutus || '',
        // category.description,
        // ...category.seo_tags
      ];

      return priorityFields.some(field =>
        field?.toLowerCase()?.includes(searchLower)
      );
    });


  // const filteredMembers = selectedCategory
  //   ? shuffledMembers
  //   : searchTerm.trim() === '' ? [] : members.filter(member => {
  //       const searchLower = searchTerm.toLowerCase().trim();
  //       const category = categories.find(c => c.id === member.category_id);
  //       if (!category) return false;
        
  //       const categoryName = category.name.replace(/([A-Z])/g, ' $1').trim();

  //       // Fields to search in
  //       const searchFields = [
  //         member.Name || '',
  //         member.Firstname || '',
  //         member.Lastname || '',
  //         member.phone || '',
  //         member.address || '',
  //         member.aboutus || '',
  //         categoryName,
  //         category.description,
  //         ...category.seo_tags
  //       ];

  //       // Check if any field contains the search term
  //       return searchFields.some(field =>
  //         field?.toLowerCase()?.includes(searchLower)
  //       );
  //     });

  const renderHome = () => (
    <div>
      {/* Search Section */}
      <div className="relative bg-gradient-to-br from-[#7A2B8F] via-purple-700 to-indigo-600 pt-8 pb-16 px-4 overflow-hidden">
        <div className="relative max-w-7xl mx-auto mb-8 flex justify-end z-10">
          <motion.button
            onClick={() => setShowListBusinessForm(true)}
            className="flex items-center space-x-2 bg-white/10 backdrop-blur-sm text-white px-5 py-2.5 rounded-lg border border-white/20 hover:bg-white/20 transition-all duration-300 cursor-pointer"
            whileHover={{ scale: 1.02 }}
            whileTap={{ scale: 0.98 }}
            initial={{ opacity: 0, y: -10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.3 }}
          >
            <ListPlus className="w-5 h-5" />
            <span className="font-medium">List Your Business</span>
          </motion.button>
        </div>
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_center,_rgba(255,255,255,0.1)_0%,_transparent_2px)] bg-[length:24px_24px] opacity-25 z-0"></div>
        <div className="relative max-w-3xl mx-auto">
          <motion.div 
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.6 }}
            className="bg-white rounded-2xl p-6 mb-8 shadow-xl backdrop-blur-sm transform hover:scale-102 transition-transform duration-300"
          >
            <motion.img
              initial={{ y: 20 }}
              animate={{ y: 0 }}
              transition={{ duration: 0.5, delay: 0.2 }}
              src="/Logos/ctcc-logo.png"
              alt="CTCC Logo"
              className="w-72 mx-auto drop-shadow-sm"
            />
          </motion.div>
          <motion.h1 
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6 }}
            className="text-5xl font-bold text-white mb-6 text-center tracking-tight"
          >
            Business Directory
          </motion.h1>
          <motion.p
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 0.2 }}
            className="text-xl text-white/90 mb-12 text-center font-light"
          >
            Connect with trusted Tamil professionals and businesses in your community
          </motion.p>
          <motion.div 
            initial={{ opacity: 0, scale: 0.95 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.5, delay: 0.3 }}
            style={{display:"flex"}}
            className="relative z-20" // add "z-20" by Blazingcoders 21-02-2025
          >
            <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
              <Search className="h-5 w-5 text-gray-400" />
            </div>
            <input
              type="text"
              className="block w-full pl-10 pr-3 py-5 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-purple-500 bg-white text-gray-900 placeholder-gray-500 shadow-xl transition-all duration-300"
              placeholder="Search by name, business type, or phone number..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              aria-label="Search businesses"
            />
            {searchTerm&&
            <div className="absolute inset-y-0 right-0 pl-3 flex items-center">
            <button
              onClick={()=>setSearchTerm("")}
              className="p-2 rounded-full transition-all duration-300"
            >
              <X className="w-6 h-6" />
            </button>
            </div>
            }
          </motion.div>
        </div>
        <div className="absolute bottom-0 left-0 right-0 h-32 bg-gradient-to-t from-white to-transparent"></div>
      </div>

      {/* Search Results */}
      {searchTerm.trim() !== '' && (
        <div className="max-w-7xl mx-auto px-4 py-8">
          <h2 className="text-2xl font-bold text-gray-900 mb-6">
            Search Results {filteredMembers.length > 0 && `(${filteredMembers.length})`}
          </h2>
          {filteredMembers.length > 0 ? (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {filteredMembers.map((member) => (
                <div
                  key={member.id}
                  onClick={() => {
                    if (member.Firstname && member.Lastname) {
                      handleMemberClick(member);
                    }
                  }}
                  style={{cursor:"pointer"}}
                  className="bg-white rounded-lg shadow-md p-6 hover:shadow-lg transition-shadow"
                >
                  <h3 className="text-xl font-semibold mb-2">
                    {member.Name || `${member.Firstname} ${member.Lastname}`}
                  </h3>
                  <p className="text-purple-600 mb-4">{member.type}</p>
                  <div className="space-y-2 text-gray-600">
                    {member.address && (
                      <p className="flex items-start">
                        <Building2 className="w-4 h-4 mt-1 mr-2 flex-shrink-0" />
                        {member.address}
                      </p>
                    )}
                    {member.phone && (
                      <p>
                        <a href={`tel:${member.phone}`} className="text-purple-600 hover:text-purple-800">
                          {member.phone}
                        </a>
                      </p>
                    )}
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <p className="text-gray-500 text-center py-8">No results found for "{searchTerm}"</p>
          )}
        </div>
      )}

      {/* Categories Grid (shown when not searching) */}
      {searchTerm.trim() === '' && <div className="max-w-7xl mx-auto grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6 p-8 -mt-16">
        {categories.map((category, index) => {
          const Icon = Icons[category.icon as keyof typeof Icons] || Icons.HelpCircle;
          const count = members.filter(m => m.category_id === category.id).length;
          return (
            <motion.button
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5, delay: index * 0.1 }}
              whileHover={{ scale: 1.02, y: -4, boxShadow: '0 20px 25px -5px rgb(0 0 0 / 0.1), 0 8px 10px -6px rgb(0 0 0 / 0.1)' }}
              whileTap={{ scale: 0.98 }}
              key={category.name}
              onClick={() => handleCategoryClick(category.url)}
              // style={{backgroundColor:"red"}}
              className={`group relative ${category.color} rounded-2xl shadow-lg overflow-hidden transition-all duration-300 hover:border-[#7A2B8F] border-2 border-transparent backdrop-blur-sm ${category.color.replace('bg-', 'hover:border-')}`}
            >
              <div className={`absolute inset-0 ${category.color} opacity-5 group-hover:opacity-10 transition-opacity`}></div>
              <div className="p-6">
                <div className="flex items-center space-x-4">
                  <motion.div 
                    whileHover={{ rotate: [0, -10, 10, -10, 0] }}
                    transition={{ duration: 0.5 }}
                    // style={{backgroundColor:category.color}}
                    className={`p-3 rounded-xl ${category.color} bg-opacity-15 transform group-hover:scale-110 transition-transform duration-300`}
                  >
                    <Icon className={`w-6 h-6 `} />
                  </motion.div>
                  <div className="flex-1">
                    <h3 className="text-lg font-semibold text-gray-900">
                      {category.name.replace(/([A-Z])/g, ' $1').trim()}
                    </h3>
                    <p className="text-sm text-[#7A2B8F] mt-1 font-medium">{count} {count === 1 ? 'member' : 'members'}</p>
                  </div>
                  <motion.div
                    whileHover={{ x: [0, 4, 0] }}
                    transition={{ duration: 0.5, repeat: Infinity }}
                  >
                    <ChevronRight className="w-5 h-5 text-gray-400 group-hover:text-gray-600" />
                  </motion.div>
                </div>
              </div>
            </motion.button>
          );
        })}
      </div>}
    </div>
  );

  const renderCategory = () => (    
    
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      <div className="relative max-w-3xl mx-auto">
          <motion.div 
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.6 }}
            className="bg-white rounded-2xl p-6 mb-8 backdrop-blur-sm transform hover:scale-102 transition-transform duration-300"
            
          >
            <motion.img
              initial={{ y: 20 }}
              animate={{ y: 0 }}
              transition={{ duration: 0.5, delay: 0.2 }}
              src="/Logos/ctcc-logo.png"
              alt="CTCC Logo"
              className="w-72 mx-auto drop-shadow-sm"
              style={{cursor:"pointer"}}
              onClick={() =>{ setSearchTerm(""); navigate('/')}}
            />
          </motion.div>
      </div>
      <button 
        onClick={handleBackToCategories}
        className="group mb-8 text-purple-600 hover:text-purple-800 flex items-center font-medium transition-colors"
      >
        <ChevronRight className="w-5 h-5 mr-1 transform rotate-180" />
        Back to Categories
      </button>
      <h2 className="text-3xl font-bold text-gray-900 mb-8">
        {categories.find(c => c.url === selectedCategory)?.name.replace(/([A-Z])/g, ' $1').trim()}
        {/* {selectedCategory?.replace(/([A-Z])/g, ' $1').trim()} */}
      </h2>
      <p className="text-sm text-gray-500 mb-8 italic">
        Note: Profiles are displayed in random order and refresh each time you visit
      </p>
      {isLoading ? (
        <div>Loading...</div>
      ) : (
        <>
          {/* Premium Members */}
          <div className="mb-16 relative">
            <div className="mb-8 relative">
              <div className="inline-flex flex-col">
                <h3 className="text-3xl font-bold bg-gradient-to-r from-purple-600 to-indigo-600 bg-clip-text text-transparent">
                  CTCC Corporate Members
                </h3>
                <p className="text-sm text-purple-600 font-medium mt-2">(Exclusive Members)</p>
              </div>
            </div>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
              {filteredMembers.map((member) => (
                <div 
                  key={member.id}
                  onClick={() => {
                    if (member.Firstname && member.Lastname) {
                      handleMemberClick(member);
                    }
                  }}
                  className={`bg-white rounded-xl shadow-md overflow-hidden ${
                    member.Firstname && member.Lastname ? 'cursor-pointer hover:shadow-lg hover:-translate-y-1' : 'cursor-not-allowed opacity-70'
                  } transition-all duration-300 transform flex flex-col`}
                >
                  <div className="h-48 w-full relative bg-gray-100">
                    <img 
                      src={member.logo ? (member.logo.startsWith('http') ? member.logo : `/Logos/${member.logo}`) : '/Logos/ctcc-logo.png'} 
                      alt={member.Name || `${member.Firstname} ${member.Lastname}`}
                      className="w-full h-full object-contain p-4"
                    />
                  </div>
                  <div className="p-6">
                    <h3 className="text-xl font-semibold mb-2">
                      {member.Name || `${member.Firstname} ${member.Lastname}`}
                    </h3>
                    <p className="text-purple-600 mb-4">{member.type}</p>
                    <div className="space-y-2 text-gray-600">
                      {member.address && (
                        <p className="flex items-start">
                          <Building2 className="w-4 h-4 mt-1 mr-2 flex-shrink-0" />
                          {member.address}
                        </p>
                      )}
                      {member.phone && (
                        <p>
                          <a href={`tel:${member.phone}`} className="text-purple-600 hover:text-purple-800">
                            {member.phone}
                          </a>
                        </p>
                      )}
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Non-Paid Members */}
          {communityMembers
            .filter(member => member.category_id === categories.find(c => c.url === selectedCategory)?.id)
            .length > 0 && (
          <div> 
            <div className="mb-8 pb-2 border-b border-gray-200">
              <div className="inline-flex flex-col">
                <h3 className="text-2xl font-semibold text-gray-600">
                  Other {selectedCategory?.replace(/([A-Z])/g, ' $1').trim()}
                </h3>
                <p className="text-sm text-gray-500 mt-1">(Community Members)</p>
              </div>
            </div>
            <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
              {communityMembers
                .filter(member => member.category_id === categories.find(c => c.url === selectedCategory)?.id)
                .map((member) => (
                <div 
                  key={member.id}
                  className="bg-white rounded-lg shadow-sm p-4 hover:shadow-md transition-all duration-300 hover:bg-gray-50"
                >
                  <div className="flex items-center space-x-3 mb-3">
                    <div className="w-12 h-12 rounded-full flex items-center justify-center overflow-hidden">
                      <div className={`w-full h-full bg-gradient-to-br from-purple-100 to-indigo-100 flex items-center justify-center`}>
                        <span className="text-lg font-medium text-purple-600">
                          {member.name.split(' ').map(n => n[0]).join('').slice(0, 2).toUpperCase()}
                        </span>
                      </div>
                    </div>
                    <div>
                      <h4 className="font-medium text-gray-900 line-clamp-1">
                        {member.name}
                      </h4>
                      <p className="text-sm text-gray-500">
                        {categories.find(c => c.id === member.category_id)?.name.replace(/([A-Z])/g, ' $1').trim()}
                      </p>
                    </div>
                  </div>
                  <div className="space-y-1 text-sm">
                    {member.email && (
                      <p className="flex items-center text-gray-600">
                        <Mail className="w-4 h-4 mr-2 flex-shrink-0" />
                        <a 
                          href={`mailto:${member.email}`} 
                          className="hover:text-purple-600 truncate"
                          title={member.email}
                        >
                          {member.email}
                        </a>
                      </p>
                    )}
                    {member.phone && (
                      <p className="flex items-center text-gray-600">
                        <Phone className="w-4 h-4 mr-2 flex-shrink-0" />
                        <a 
                          href={`tel:${member.phone}`} 
                          className="hover:text-purple-600"
                        >
                          {member.phone}
                        </a>
                      </p>
                    )}
                  </div>
                </div>
              ))}
            </div>
          </div>)}
        </>
      )}
    </div>
  );

  const renderMemberProfile = () => (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 sm:py-12">
            <div className="relative max-w-3xl mx-auto">
          <motion.div 
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.6 }}
            className="bg-white rounded-2xl p-6 mb-8 backdrop-blur-sm transform hover:scale-102 transition-transform duration-300"
            
          >
            <motion.img
              initial={{ y: 20 }}
              animate={{ y: 0 }}
              transition={{ duration: 0.5, delay: 0.2 }}
              src="/Logos/ctcc-logo.png"
              alt="CTCC Logo"
              className="w-72 mx-auto drop-shadow-sm"
              style={{cursor:"pointer"}}
              onClick={() =>{ setSearchTerm(""); navigate('/')}}
            />
          </motion.div>
      </div>
      <button 
        onClick={handleBackToCategory}
        className="group mb-6 sm:mb-8 text-purple-600 hover:text-purple-800 flex items-center font-medium transition-colors"
      >
        <ArrowLeft className="w-5 h-5 mr-2" />
        Back to Category
      </button>
      {selectedMemberData ? (
        <div>
          <motion.div 
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 0.4 }}
            className="bg-white rounded-2xl shadow-lg p-6 sm:p-8"
          >
            <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-8">
              <h2 className="text-2xl sm:text-3xl font-bold text-gray-900">
                {selectedMemberData.Name || `${selectedMemberData.Firstname} ${selectedMemberData.Lastname}`}
              </h2>
              <div className="flex flex-col items-end gap-2">
                <span className="text-sm text-gray-600">Share this profile with others:</span>
              <div className="flex items-center space-x-4">
                <button 
                  onClick={() => handleShare('whatsapp')}
                  className="text-gray-500 hover:text-green-600 transition-colors p-2 hover:bg-green-50 rounded-full"
                >
                  <svg 
                    viewBox="0 0 24 24" 
                    className="w-5 h-5"
                    fill="currentColor"
                  >
                    <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413Z"/>
                  </svg>
                </button>
                <button 
                  onClick={() => handleShare('facebook')}
                  className="text-gray-500 hover:text-blue-600 transition-colors p-2 hover:bg-blue-50 rounded-full"
                >
                  <Facebook className="w-5 h-5" />
                </button>
                <button 
                  onClick={() => handleShare('linkedin')}
                  className="text-gray-500 hover:text-blue-800 transition-colors p-2 hover:bg-blue-50 rounded-full"
                >
                  <Linkedin className="w-5 h-5" />
                </button>
                <button 
                  onClick={() => handleShare('twitter')}
                  className="text-gray-500 hover:text-blue-400 transition-colors p-2 hover:bg-blue-50 rounded-full"
                >
                  <Twitter className="w-5 h-5" />
                </button>
                <button 
                  onClick={() => handleShare('copy')}
                  className="text-gray-500 hover:text-purple-600 transition-colors p-2 hover:bg-purple-50 rounded-full relative"
                >
                  <Copy className="w-5 h-5" />
                  {showShareTooltip && (
                    <div className="absolute -top-10 left-1/2 transform -translate-x-1/2 bg-gray-800 text-white text-xs px-3 py-1.5 rounded-md shadow-lg">
                      Copied!
                    </div>
                  )}
                </button>
              </div></div>
            </div>
            <div className="grid grid-cols-1 lg:grid-cols-3 gap-8 lg:gap-12">
              <div className="md:col-span-1">
                <img 
                  src={selectedMemberData.logo ? (selectedMemberData.logo.startsWith('http') ? selectedMemberData.logo : `/Logos/${selectedMemberData.logo}`) : '/Logos/ctcc-logo.png'}
                  alt={selectedMemberData.Name || `${selectedMemberData.Firstname} ${selectedMemberData.Lastname}`}
                  className="w-full h-48 sm:h-64 rounded-xl shadow-md object-contain bg-gray-100 p-4"
                />
                <div className="mt-8 space-y-4 text-gray-700">
                  {selectedMemberData.address && (
                    <div className="flex items-start group">
                      <MapPin className="w-5 h-5 mr-3 flex-shrink-0 text-purple-600" />
                      <p className="flex-1">{selectedMemberData.address}</p>
                    </div>
                  )}
                  {selectedMemberData.phone && (
                    <div className="flex items-center group">
                      <Phone className="w-5 h-5 mr-3 flex-shrink-0 text-purple-600" />
                      <a href={`tel:${selectedMemberData.phone}`} className="hover:text-purple-800 transition-colors">
                        {selectedMemberData.phone}
                      </a>
                    </div>
                  )}
                  {selectedMemberData.email && (
                    <div className="flex items-center group">
                      <Mail className="w-5 h-5 mr-3 flex-shrink-0 text-purple-600" />
                      <a href={`mailto:${selectedMemberData.email}`} className="hover:text-purple-800 transition-colors break-all">
                        {selectedMemberData.email}
                      </a>
                    </div>
                  )}
                  {selectedMemberData.website && (
                    <div className="flex items-center group">
                      <Globe className="w-5 h-5 mr-3 flex-shrink-0 text-purple-600" />
                      <a href={selectedMemberData.website} target="_blank" rel="noopener noreferrer" className="hover:text-purple-800 transition-colors break-all">
                        {selectedMemberData.website.replace(/(^\w+:|^)\/\//, '')}
                      </a>
                    </div>
                  )}
                  {/* Social Media Links Section - Only shown if at least one social link exists */}
                  {(selectedMemberData.facebook || selectedMemberData.linkedin || selectedMemberData.twitter || selectedMemberData.instagram || selectedMemberData.whatsapp) && (
                    <div className="mt-8 border-t border-gray-100 pt-6">
                      <h3 className="text-sm font-medium text-gray-500 mb-4">Connect With Us</h3>
                      <div className="flex items-center space-x-3">
                        {selectedMemberData.whatsapp && (
                          <a
                            href={`https://wa.me/${selectedMemberData.whatsapp.replace(/\D/g, '')}`}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="p-2 text-gray-400 hover:text-[#25D366] hover:bg-green-50 rounded-lg transition-all duration-300"
                            title="Chat on WhatsApp"
                          >
                            <svg 
                              viewBox="0 0 24 24" 
                              className="w-5 h-5"
                              fill="currentColor"
                            >
                              <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413Z"/>
                            </svg>
                          </a>
                        )}
                        {selectedMemberData.facebook && (
                          <a
                            href={selectedMemberData.facebook}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="p-2 text-gray-400 hover:text-[#1877F2] hover:bg-blue-50 rounded-lg transition-all duration-300"
                            title="Follow us on Facebook"
                          >
                            <Facebook className="w-5 h-5" />
                          </a>
                        )}
                        {selectedMemberData.linkedin && (
                          <a
                            href={selectedMemberData.linkedin}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="p-2 text-gray-400 hover:text-[#0A66C2] hover:bg-blue-50 rounded-lg transition-all duration-300"
                            title="Connect on LinkedIn"
                          >
                            <Linkedin className="w-5 h-5" />
                          </a>
                        )}
                        {selectedMemberData.twitter && (
                          <a
                            href={selectedMemberData.twitter}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="p-2 text-gray-400 hover:text-[#1DA1F2] hover:bg-blue-50 rounded-lg transition-all duration-300"
                            title="Follow us on Twitter"
                          >
                            <Twitter className="w-5 h-5" />
                          </a>
                        )}
                        {selectedMemberData.instagram && (
                          <a
                            href={selectedMemberData.instagram}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="p-2 text-gray-400 hover:text-[#E4405F] hover:bg-pink-50 rounded-lg transition-all duration-300"
                            title="Follow us on Instagram"
                          >
                            <Instagram className="w-5 h-5" />
                          </a>
                        )}
                      </div>
                    </div>
                  )}
                </div>
              </div>
              <div className="lg:col-span-2">
                <motion.div
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ duration: 0.5 }}
                  className="bg-gradient-to-br from-purple-50 to-white p-6 rounded-xl border border-purple-100 mb-8"
                >
                  <h3 className="text-xl font-semibold mb-6 text-gray-900 flex items-center">
                    <motion.span 
                      initial={{ scale: 0.8, rotate: -10 }}
                      animate={{ scale: 1, rotate: 0 }}
                      transition={{ duration: 0.5, delay: 0.2 }}
                      className="bg-purple-100 p-2 rounded-lg mr-3"
                    >
                      <Icons.Info className="w-5 h-5 text-purple-600" />
                    </motion.span>
                    About
                  </h3>
                <div 
                  className="prose max-w-none text-gray-700 [&>p]:text-base [&>ul]:mt-4 [&>ul]:space-y-2 [&>p:not(:last-child)]:mb-4"
                  dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(selectedMemberData.aboutus) }}
                />
                </motion.div>

                {/* Services List */}
                {(selectedMemberData.sectionItem1 || selectedMemberData.sectionItem2 || selectedMemberData.sectionItem3 || selectedMemberData.sectionItem4 || selectedMemberData.sectionItem5) && (
                  <div className="mt-8">
                    <motion.div
                      initial={{ opacity: 0, y: 20 }}
                      animate={{ opacity: 1, y: 0 }}
                      transition={{ duration: 0.5 }}
                      className="bg-gradient-to-br from-purple-50 to-white p-6 rounded-xl border border-purple-100"
                    >
                      <h3 className="text-xl font-semibold mb-6 text-gray-900 flex items-center">
                        <motion.span 
                          initial={{ scale: 0.8, rotate: -10 }}
                          animate={{ scale: 1, rotate: 0 }}
                          transition={{ duration: 0.5, delay: 0.2 }}
                          className="bg-purple-100 p-2 rounded-lg mr-3"
                        >
                          <Icons.Briefcase className="w-5 h-5 text-purple-600" />
                        </motion.span>
                        Services Offered:
                      </h3>
                      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 max-w-4xl mx-auto">
                      {selectedMemberData.sectionItem1 && (
                        <motion.div 
                          initial={{ opacity: 0, x: -20 }}
                          animate={{ opacity: 1, x: 0 }}
                          transition={{ duration: 0.5, delay: 0.3 }}
                          whileHover={{ scale: 1.02, y: -4 }}
                          className="group bg-white p-5 rounded-lg shadow-sm border border-purple-100/50 hover:shadow-md hover:border-purple-200 transition-all duration-300 h-full"
                        >
                          <div className="flex items-start space-x-3">
                            <motion.div 
                              initial={{ scale: 0 }}
                              animate={{ scale: 1 }}
                              transition={{ duration: 0.3, delay: 0.4 }}
                              className="w-2 h-2 rounded-full bg-purple-500 flex-shrink-0 mt-2 group-hover:scale-110 transition-transform duration-300" 
                            />
                            <p className="text-gray-700 leading-relaxed font-medium">{selectedMemberData.sectionItem1}</p>
                          </div>
                        </motion.div>
                      )}
                      {selectedMemberData.sectionItem2 && (
                        <motion.div 
                          initial={{ opacity: 0, x: -20 }}
                          animate={{ opacity: 1, x: 0 }}
                          transition={{ duration: 0.5, delay: 0.4 }}
                          whileHover={{ scale: 1.02, y: -4 }}
                          className="group bg-white p-5 rounded-lg shadow-sm border border-purple-100/50 hover:shadow-md hover:border-purple-200 transition-all duration-300 h-full"
                        >
                          <div className="flex items-start space-x-3">
                            <motion.div 
                              initial={{ scale: 0 }}
                              animate={{ scale: 1 }}
                              transition={{ duration: 0.3, delay: 0.5 }}
                              className="w-2 h-2 rounded-full bg-purple-500 flex-shrink-0 mt-2 group-hover:scale-110 transition-transform duration-300" 
                            />
                            <p className="text-gray-700 leading-relaxed font-medium">{selectedMemberData.sectionItem2}</p>
                          </div>
                        </motion.div>
                      )}
                      {selectedMemberData.sectionItem3 && (
                        <motion.div 
                          initial={{ opacity: 0, x: -20 }}
                          animate={{ opacity: 1, x: 0 }}
                          transition={{ duration: 0.5, delay: 0.5 }}
                          whileHover={{ scale: 1.02, y: -4 }}
                          className="group bg-white p-5 rounded-lg shadow-sm border border-purple-100/50 hover:shadow-md hover:border-purple-200 transition-all duration-300 h-full"
                        >
                          <div className="flex items-start space-x-3">
                            <motion.div 
                              initial={{ scale: 0 }}
                              animate={{ scale: 1 }}
                              transition={{ duration: 0.3, delay: 0.6 }}
                              className="w-2 h-2 rounded-full bg-purple-500 flex-shrink-0 mt-2 group-hover:scale-110 transition-transform duration-300" 
                            />
                            <p className="text-gray-700 leading-relaxed font-medium">{selectedMemberData.sectionItem3}</p>
                          </div>
                        </motion.div>
                      )}
                      {selectedMemberData.sectionItem4 && (
                        <motion.div 
                          initial={{ opacity: 0, x: -20 }}
                          animate={{ opacity: 1, x: 0 }}
                          transition={{ duration: 0.5, delay: 0.6 }}
                          whileHover={{ scale: 1.02, y: -4 }}
                          className="group bg-white p-5 rounded-lg shadow-sm border border-purple-100/50 hover:shadow-md hover:border-purple-200 transition-all duration-300 h-full"
                        >
                          <div className="flex items-start space-x-3">
                            <motion.div 
                              initial={{ scale: 0 }}
                              animate={{ scale: 1 }}
                              transition={{ duration: 0.3, delay: 0.7 }}
                              className="w-2 h-2 rounded-full bg-purple-500 flex-shrink-0 mt-2 group-hover:scale-110 transition-transform duration-300" 
                            />
                            <p className="text-gray-700 leading-relaxed font-medium">{selectedMemberData.sectionItem4}</p>
                          </div>
                        </motion.div>
                      )}
                      {selectedMemberData.sectionItem5 && (
                        <motion.div 
                          initial={{ opacity: 0, x: -20 }}
                          animate={{ opacity: 1, x: 0 }}
                          transition={{ duration: 0.5, delay: 0.7 }}
                          whileHover={{ scale: 1.02, y: -4 }}
                          className="group bg-white p-5 rounded-lg shadow-sm border border-purple-100/50 hover:shadow-md hover:border-purple-200 transition-all duration-300 h-full"
                        >
                          <div className="flex items-start space-x-3">
                            <motion.div 
                              initial={{ scale: 0 }}
                              animate={{ scale: 1 }}
                              transition={{ duration: 0.3, delay: 0.8 }}
                              className="w-2 h-2 rounded-full bg-purple-500 flex-shrink-0 mt-2 group-hover:scale-110 transition-transform duration-300" 
                            />
                            <p className="text-gray-700 leading-relaxed font-medium">{selectedMemberData.sectionItem5}</p>
                          </div>
                        </motion.div>
                      )}
                      </div>
                    </motion.div>
                  </div>
                )}
              </div>
            </div>
          </motion.div>
         
          {!isLoading && (selectedMemberData?.email || selectedMemberData?.iframe) && (
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 mt-8">
              {selectedMemberData.email && (
                <ContactForm
                  recipientName={selectedMemberData.Name || `${selectedMemberData.Firstname} ${selectedMemberData.Lastname}`}
                  recipientEmail={selectedMemberData.email}
                />
              )}
              
              {selectedMemberData.iframe && (
                <motion.div 
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ duration: 0.6, delay: 0.8 }}
                  className="bg-white rounded-2xl shadow-lg p-6 sm:p-8 h-full"
                >
                  <h2 className="text-2xl font-semibold mb-6 text-gray-900">Location</h2>
                  <div className="map-container bg-gray-50 rounded-xl overflow-hidden">
                    <iframe
                      src={selectedMemberData.iframe}
                      allowFullScreen
                      loading="lazy"
                      referrerPolicy="no-referrer"
                      title={`Location map for ${selectedMemberData.Name || `${selectedMemberData.Firstname} ${selectedMemberData.Lastname}`}`}
                      className="w-full h-full border-0"
                    />
                  </div>
                </motion.div>
              )}
            </div>
          )}
        </div>
      ) : (
        <div className="flex items-center justify-center py-12">
          <div className="animate-pulse text-gray-500">Loading...</div>
        </div>
      )}
    </div>
  );

  return (
    <div>
      <SEOHead 
        member={selectedMemberData || undefined}
        category={categories.find(c => c.url === category) || undefined}
        isHomePage={!category && !memberId}
      />
      <ListBusinessForm 
        isOpen={showListBusinessForm}
        onClose={() => setShowListBusinessForm(false)}
      />
      <AnimatePresence mode="wait">
        <div className="min-h-screen flex flex-col">
          <div className="flex-grow">
            {!category && !memberId && renderHome()}
            {category && !memberId && renderCategory()}
            {category && memberId && renderMemberProfile()}
          </div>
          <Footer />
        </div>
      </AnimatePresence>
    </div>
  );
}

export default App;