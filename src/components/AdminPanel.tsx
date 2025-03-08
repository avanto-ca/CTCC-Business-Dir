import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Plus, Edit, Trash2, Save, X, Search, FolderPlus } from 'lucide-react';
import { motion } from 'framer-motion';
import { supabase } from '../lib/supabase';
import type { Member, Category } from '../types';

export function AdminPanel() {
  const navigate = useNavigate();
  const [members, setMembers] = useState<Member[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [editingMember, setEditingMember] = useState<Member | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [isUploading, setIsUploading] = useState(false);
  const [uploadError, setUploadError] = useState<string | null>(null);
  const [logoFile, setLogoFile] = useState<File | null>(null);
  const [showCategoryModal, setShowCategoryModal] = useState(false);
  const [editingCategory, setEditingCategory] = useState<Partial<Category>>({});

  async function handleSaveCategory() {
    try {
      if (!editingCategory.name || !editingCategory.icon || !editingCategory.color) {
        setError('Please fill in all required fields');
        return;
      }

      // Generate URL-friendly name
      const url = editingCategory.name.toLowerCase().replace(/[^a-z0-9]+/g, '-');

      const { error: saveError } = await supabase
        .from('categories')
        .insert({
          name: editingCategory.name,
          icon: editingCategory.icon,
          url,
          color: editingCategory.color,
          seo_tags: editingCategory.seo_tags || [],
          description: editingCategory.description || ''
        });

      if (saveError) throw saveError;
      
      setShowCategoryModal(false);
      setEditingCategory({});
      fetchCategories();
    } catch (error) {
      setError('Failed to save category');
      console.error('Error:', error);
    }
  }

  // Function to generate unique logo filename
  function generateLogoFilename(file: File, businessName: string): string {
    const fileExt = file.name.split('.').pop()?.toLowerCase();
    const timestamp = Date.now();
    const cleanName = businessName.toLowerCase().replace(/[^a-z0-9]/g, '_');
    return `${cleanName}_${timestamp}.${fileExt}`;
  }

  useEffect(() => {
    fetchMembers();
    fetchCategories();
  }, []);

  async function handleLogoChange(file: File) {
    if (file) {
      const fileExt = file.name.split('.').pop()?.toLowerCase();
      const validExts = ['png', 'jpg', 'jpeg', 'gif', 'webp'];
      
      if (!fileExt || !validExts.includes(fileExt)) {
        setUploadError('Invalid file type. Please upload a PNG, JPG, GIF or WebP image.');
        return;
      }

      setLogoFile(file);
      setUploadError(null);
    }
  }

  async function fetchMembers() {
    try {
      const { data: members, error } = await supabase
        .from('members')
        .select('*')
        .order('Firstname', { ascending: true });

      if (error) throw error;
      setMembers(members || []);
    } catch (error) {
      setError('Failed to fetch members');
      console.error('Error:', error);
    } finally {
      setIsLoading(false);
    }
  }

  async function fetchCategories() {
    try {
      const { data: categories, error } = await supabase
        .from('categories')
        .select('*')
        .order('name', { ascending: true });

      if (error) throw error;
      setCategories(categories || []);
    } catch (error) {
      setError('Failed to fetch categories');
      console.error('Error:', error);
    }
  }

  async function handleSave(member: Member) {
    try {
      setIsUploading(true);
      
      let logoPath = member.logo;
  
      if (logoFile) {
        const businessName = (member.Name || `${member.Firstname}${member.Lastname}`).toLowerCase();
        const fileName = generateLogoFilename(logoFile, businessName || 'business');
  
        // Upload file to Supabase Storage (logos bucket)
        const { data, error: uploadError } = await supabase.storage
          .from('logos')
          .upload(`members/${fileName}`, logoFile, { upsert: true });
  
        if (uploadError) throw uploadError;
  
        // Get the public URL of the uploaded file
        const { data: publicUrlData } = supabase.storage.from('logos').getPublicUrl(`members/${fileName}`);
        logoPath = publicUrlData.publicUrl;
      }
  
      // Save member with updated logo path
      const { error } = await supabase
        .from('members')
        .upsert({
          ...member,
          logo: logoPath
        });
  
      if (error) throw error;
  
      setEditingMember(null);
      setLogoFile(null);
      fetchMembers();
    } catch (error) {
      setError('Failed to save member');
      console.error('Error:', error);
    } finally {
      setIsUploading(false);
    }
  }
  

  // async function handleSave(member: Member) {
  //   try {
  //     setIsUploading(true);
  //     let logoPath = member.logo;
  
  //     if (logoFile) {
  //       const formData = new FormData();
  //       formData.append("file", logoFile);
  
  //       const response = await fetch("/.netlify/functions/image-upload", {
  //         method: "POST",
  //         body: formData,
  //       });
  
  //       const result = await response.json();
  //       if (!response.ok) throw new Error(result.error);
  
  //       logoPath = result.filePath; // File path returned from Netlify Function
  //     }
  
  //     // Save member data in the database
  //     const { error } = await supabase
  //       .from("members")
  //       .upsert({
  //         ...member,
  //         logo: logoPath,
  //       });
  
  //     if (error) throw error;
  
  //     setEditingMember(null);
  //     setLogoFile(null);
  //     fetchMembers();
  //   } catch (error) {
  //     setError("Failed to save member");
  //     console.error("Error:", error);
  //   } finally {
  //     setIsUploading(false);
  //   }
  // }
  

  async function handleDelete(id: number) {
    if (!confirm('Are you sure you want to delete this member?')) return;

    try {
      const { error } = await supabase
        .from('members')
        .delete()
        .eq('id', id);

      if (error) throw error;
      
      fetchMembers();
    } catch (error) {
      setError('Failed to delete member');
      console.error('Error:', error);
    }
  }

  const filteredMembers = members.filter(member => {
    const searchString = searchTerm.toLowerCase();
    return (
      member.Firstname?.toLowerCase().includes(searchString) ||
      member.Lastname?.toLowerCase().includes(searchString) ||
      member.Name?.toLowerCase().includes(searchString) ||
      member.email?.toLowerCase().includes(searchString) ||
      member.phone?.toLowerCase().includes(searchString)
    );
  });

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-purple-600"></div>
      </div>
    );
  }

  return (
    <div className="max-w-7xl mx-auto px-4 py-8">
      <div className="flex justify-between items-center mb-8">
        <h1 className="text-3xl font-bold text-gray-900">Business Directory Admin</h1>
        <div className="flex space-x-4">
          <motion.button
            whileHover={{ scale: 1.02 }}
            whileTap={{ scale: 0.98 }}
            onClick={() => setShowCategoryModal(true)}
            className="inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
          >
            <FolderPlus className="h-5 w-5 mr-2" />
            Add New Category
          </motion.button>
          <motion.button
            whileHover={{ scale: 1.02 }}
            whileTap={{ scale: 0.98 }}
            onClick={() => setEditingMember({} as Member)}
            className="inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-purple-600 hover:bg-purple-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-purple-500"
          >
            <Plus className="h-5 w-5 mr-2" />
            Add New Business
          </motion.button>
        </div>
      </div>

      {error && (
        <div className="bg-red-50 border-l-4 border-red-400 p-4 mb-8">
          <div className="flex">
            <div className="flex-shrink-0">
              <X className="h-5 w-5 text-red-400" />
            </div>
            <div className="ml-3">
              <p className="text-sm text-red-700">{error}</p>
            </div>
          </div>
        </div>
      )}

      <div className="mb-8">
        <div className="relative">
          <input
            type="text"
            placeholder="Search businesses..."
            className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-600 focus:border-transparent"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
          <Search className="absolute right-3 top-2.5 h-5 w-5 text-gray-400" />
        </div>
      </div>

      <div className="bg-white shadow overflow-hidden sm:rounded-md">
        <ul className="divide-y divide-gray-200">
          {filteredMembers.map((member) => (
            <li key={member.id}>
              <div className="px-4 py-4 sm:px-6 hover:bg-gray-50">
                <div className="flex items-center justify-between">
                  <div className="flex-1 min-w-0">
                    <h3 className="text-lg font-medium text-gray-900 truncate">
                      {member.Name || `${member.Firstname} ${member.Lastname}`}
                    </h3>
                    <div className="mt-2 flex flex-col sm:flex-row sm:flex-wrap sm:space-x-6">
                      <div className="mt-2 flex items-center text-sm text-gray-500">
                        {categories.find(c => c.id === member.category_id)?.name}
                      </div>
                      {member.email && (
                        <div className="mt-2 flex items-center text-sm text-gray-500">
                          {member.email}
                        </div>
                      )}
                      {member.phone && (
                        <div className="mt-2 flex items-center text-sm text-gray-500">
                          {member.phone}
                        </div>
                      )}
                    </div>
                  </div>
                  <div className="flex items-center space-x-4">
                    <motion.button
                      whileHover={{ scale: 1.1 }}
                      whileTap={{ scale: 0.9 }}
                      onClick={() => setEditingMember(member)}
                      className="p-2 text-purple-600 hover:text-purple-900"
                    >
                      <Edit className="h-5 w-5" />
                    </motion.button>
                    <motion.button
                      whileHover={{ scale: 1.1 }}
                      whileTap={{ scale: 0.9 }}
                      onClick={() => handleDelete(member.id)}
                      className="p-2 text-red-600 hover:text-red-900"
                    >
                      <Trash2 className="h-5 w-5" />
                    </motion.button>
                  </div>
                </div>
              </div>
            </li>
          ))}
        </ul>
      </div>

      {editingMember && (
        <div className="fixed inset-0 bg-gray-500 bg-opacity-75 flex items-center justify-center p-4">
          <motion.div
            initial={{ opacity: 0, scale: 0.95 }}
            animate={{ opacity: 1, scale: 1 }}
            className="bg-white rounded-lg shadow-xl max-w-3xl w-full max-h-[90vh] overflow-y-auto"
          >
            <div className="px-6 py-4 border-b border-gray-200">
              <div className="flex items-center justify-between">
                <h3 className="text-lg font-medium text-gray-900">
                  {editingMember.id ? 'Edit Business Profile' : 'New Business Profile'}
                </h3>
                <button
                  onClick={() => setEditingMember(null)}
                  className="text-gray-400 hover:text-gray-500"
                >
                  <X className="h-6 w-6" />
                </button>
              </div>
            </div>
            <div className="px-6 py-4">
              <form onSubmit={(e) => {
                e.preventDefault();
                handleSave(editingMember);
              }}>
                <div className="grid grid-cols-1 gap-6">
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div>
                      <label className="block text-sm font-medium text-gray-700">First Name</label>
                      <input
                        type="text"
                        value={editingMember.Firstname || ''}
                        onChange={(e) => setEditingMember({
                          ...editingMember,
                          Firstname: e.target.value
                        })}
                        className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-purple-500 focus:ring-purple-500"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700">Last Name</label>
                      <input
                        type="text"
                        value={editingMember.Lastname || ''}
                        onChange={(e) => setEditingMember({
                          ...editingMember,
                          Lastname: e.target.value
                        })}
                        className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-purple-500 focus:ring-purple-500"
                      />
                    </div>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Business Name</label>
                    <input
                      type="text"
                      value={editingMember.Name || ''}
                      onChange={(e) => setEditingMember({
                        ...editingMember,
                        Name: e.target.value
                      })}
                      className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-purple-500 focus:ring-purple-500"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Category</label>
                    <select
                      value={editingMember.category_id || ''}
                      onChange={(e) => setEditingMember({
                        ...editingMember,
                        category_id: e.target.value
                      })}
                      className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-purple-500 focus:ring-purple-500"
                    >
                      <option value="">Select a category</option>
                      {categories.map((category) => (
                        <option key={category.id} value={category.id}>
                          {category.name}
                        </option>
                      ))}
                    </select>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Email</label>
                    <input
                      type="email"
                      value={editingMember.email || ''}
                      onChange={(e) => setEditingMember({
                        ...editingMember,
                        email: e.target.value
                      })}
                      className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-purple-500 focus:ring-purple-500"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Phone</label>
                    <input
                      type="tel"
                      value={editingMember.phone || ''}
                      onChange={(e) => setEditingMember({
                        ...editingMember,
                        phone: e.target.value
                      })}
                      className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-purple-500 focus:ring-purple-500"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Website</label>
                    <input
                      type="url"
                      value={editingMember.website || ''}
                      onChange={(e) => setEditingMember({
                        ...editingMember,
                        website: e.target.value
                      })}
                      className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-purple-500 focus:ring-purple-500"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Address</label>
                    <input
                      type="text"
                      value={editingMember.address || ''}
                      onChange={(e) => setEditingMember({
                        ...editingMember,
                        address: e.target.value
                      })}
                      className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-purple-500 focus:ring-purple-500"
                    />
                  </div>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div>
                      <label className="block text-sm font-medium text-gray-700">Facebook Profile URL</label>
                      <input
                        type="url"
                        value={editingMember.facebook || ''}
                        onChange={(e) => setEditingMember({
                          ...editingMember,
                          facebook: e.target.value
                        })}
                        className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-purple-500 focus:ring-purple-500"
                        placeholder="https://facebook.com/..."
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700">LinkedIn Profile URL</label>
                      <input
                        type="url"
                        value={editingMember.linkedin || ''}
                        onChange={(e) => setEditingMember({
                          ...editingMember,
                          linkedin: e.target.value
                        })}
                        className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-purple-500 focus:ring-purple-500"
                        placeholder="https://linkedin.com/in/..."
                      />
                    </div>
                  </div>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div>
                      <label className="block text-sm font-medium text-gray-700">Twitter Profile URL</label>
                      <input
                        type="url"
                        value={editingMember.twitter || ''}
                        onChange={(e) => setEditingMember({
                          ...editingMember,
                          twitter: e.target.value
                        })}
                        className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-purple-500 focus:ring-purple-500"
                        placeholder="https://twitter.com/..."
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700">Instagram Profile URL</label>
                      <input
                        type="url"
                        value={editingMember.instagram || ''}
                        onChange={(e) => setEditingMember({
                          ...editingMember,
                          instagram: e.target.value
                        })}
                        className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-purple-500 focus:ring-purple-500"
                        placeholder="https://instagram.com/..."
                      />
                    </div>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700">WhatsApp Number</label>
                    <input
                      type="tel"
                      value={editingMember.whatsapp || ''}
                      onChange={(e) => setEditingMember({
                        ...editingMember,
                        whatsapp: e.target.value
                      })}
                      className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-purple-500 focus:ring-purple-500"
                      placeholder="+1234567890"
                    />
                    <p className="mt-1 text-sm text-gray-500">
                      Enter the full phone number with country code (e.g., +1234567890)
                    </p>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700">About</label>
                    <textarea
                      rows={4}
                      value={editingMember.aboutus || ''}
                      onChange={(e) => setEditingMember({
                        ...editingMember,
                        aboutus: e.target.value
                      })}
                      className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-purple-500 focus:ring-purple-500"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Logo</label>
                    <div className="mt-1 flex items-center space-x-4">
                      {editingMember.logo && (
                        <img
                          src={editingMember.logo.startsWith('http') ? editingMember.logo : `/Logos/${editingMember.logo}`}
                          alt="Business Logo"
                          className="h-20 w-20 object-contain bg-gray-100 rounded-lg"
                        />
                      )}
                      <div>
                        <input
                          type="file"
                          accept="image/*"
                          disabled={isUploading}
                          onChange={(e) => {
                            if (e.target.files?.[0]) {
                              handleLogoChange(e.target.files[0]);
                            }
                          }}
                          className="block w-full text-sm text-gray-500
                            file:mr-4 file:py-2 file:px-4
                            file:rounded-md file:border-0
                            file:text-sm file:font-medium
                            file:bg-purple-50 file:text-purple-700
                            hover:file:bg-purple-100"
                        />
                        <p className="mt-1 text-sm text-gray-500 flex items-center">
                          PNG, JPG, GIF or WebP images only
                          {isUploading && (
                            <span className="ml-2 inline-block h-4 w-4 border-2 border-purple-600 border-t-transparent rounded-full animate-spin"></span>
                          )}
                          {uploadError && (
                            <span className="ml-2 text-red-600">
                              {uploadError}
                            </span>
                          )}
                        </p>
                      </div>
                    </div>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Google Maps Embed URL</label>
                    <input
                      type="text"
                      value={editingMember.iframe || ''}
                      onChange={(e) => setEditingMember({
                        ...editingMember,
                        iframe: e.target.value
                      })}
                      className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-purple-500 focus:ring-purple-500"
                    />
                  </div>
                </div>
                <div className="mt-6 flex justify-end space-x-3">
                  <button
                    type="button"
                    onClick={() => setEditingMember(null)}
                    className="px-4 py-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-purple-500"
                  >
                    Cancel
                  </button>
                  <button
                    type="submit"
                    className="inline-flex justify-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-purple-600 hover:bg-purple-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-purple-500"
                  >
                    <Save className="h-5 w-5 mr-2" />
                    Save
                  </button>
                </div>
              </form>
            </div>
          </motion.div>
        </div>
      )}

      {/* Category Modal */}
      {showCategoryModal && (
        <div className="fixed inset-0 bg-gray-500 bg-opacity-75 flex items-center justify-center p-4">
          <motion.div
            initial={{ opacity: 0, scale: 0.95 }}
            animate={{ opacity: 1, scale: 1 }}
            className="bg-white rounded-lg shadow-xl max-w-lg w-full"
          >
            <div className="px-6 py-4 border-b border-gray-200">
              <div className="flex items-center justify-between">
                <h3 className="text-lg font-medium text-gray-900">
                  New Business Category
                </h3>
                <button
                  onClick={() => {
                    setShowCategoryModal(false);
                    setEditingCategory({});
                  }}
                  className="text-gray-400 hover:text-gray-500"
                >
                  <X className="h-6 w-6" />
                </button>
              </div>
            </div>
            <div className="px-6 py-4">
              <form onSubmit={(e) => {
                e.preventDefault();
                handleSaveCategory();
              }}>
                <div className="space-y-6">
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Category Name</label>
                    <input
                      type="text"
                      value={editingCategory.name || ''}
                      onChange={(e) => setEditingCategory({
                        ...editingCategory,
                        name: e.target.value
                      })}
                      className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-purple-500 focus:ring-purple-500"
                      placeholder="e.g., RealEstate"
                    />
                    <p className="mt-1 text-sm text-gray-500">
                      Use PascalCase without spaces (e.g., RealEstate, WebDesign)
                    </p>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Icon Name</label>
                    <input
                      type="text"
                      value={editingCategory.icon || ''}
                      onChange={(e) => setEditingCategory({
                        ...editingCategory,
                        icon: e.target.value
                      })}
                      className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-purple-500 focus:ring-purple-500"
                      placeholder="e.g., Home"
                    />
                    <p className="mt-1 text-sm text-gray-500">
                      Use Lucide icon names (e.g., Home, Building, Car)
                    </p>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Color</label>
                    <input
                      type="text"
                      value={editingCategory.color || ''}
                      onChange={(e) => setEditingCategory({
                        ...editingCategory,
                        color: e.target.value
                      })}
                      className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-purple-500 focus:ring-purple-500"
                      placeholder="e.g., bg-blue-500"
                    />
                    <p className="mt-1 text-sm text-gray-500">
                      Use Tailwind color classes (e.g., bg-blue-500, bg-red-500)
                    </p>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700">SEO Tags</label>
                    <input
                      type="text"
                      value={editingCategory.seo_tags?.join(', ') || ''}
                      onChange={(e) => setEditingCategory({
                        ...editingCategory,
                        seo_tags: e.target.value.split(',').map(tag => tag.trim())
                      })}
                      className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-purple-500 focus:ring-purple-500"
                      placeholder="e.g., real estate, property, homes"
                    />
                    <p className="mt-1 text-sm text-gray-500">
                      Comma-separated list of SEO keywords
                    </p>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Description</label>
                    <textarea
                      rows={3}
                      value={editingCategory.description || ''}
                      onChange={(e) => setEditingCategory({
                        ...editingCategory,
                        description: e.target.value
                      })}
                      className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-purple-500 focus:ring-purple-500"
                      placeholder="Category description for SEO"
                    />
                  </div>
                </div>
                <div className="mt-6 flex justify-end space-x-3">
                  <button
                    type="button"
                    onClick={() => {
                      setShowCategoryModal(false);
                      setEditingCategory({});
                    }}
                    className="px-4 py-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-purple-500"
                  >
                    Cancel
                  </button>
                  <button
                    type="submit"
                    className="inline-flex justify-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-purple-600 hover:bg-purple-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-purple-500"
                  >
                    <Save className="h-5 w-5 mr-2" />
                    Save Category
                  </button>
                </div>
              </form>
            </div>
          </motion.div>
        </div>
      )}
    </div>
  );
}