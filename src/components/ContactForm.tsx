import { useState, useRef } from 'react';
import { Send } from 'lucide-react';
import { motion } from 'framer-motion';
import { useNavigate } from 'react-router-dom';
import { supabase } from '../lib/supabase';

interface ContactFormProps {
  recipientName: string;
  recipientEmail: string;
}

export function ContactForm({ recipientName, recipientEmail }: ContactFormProps) {
  const [formData, setFormData] = useState({
    firstName: '',
    lastName: '',
    email: '',
    phone: '',
    message: ''
  });
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [submitStatus, setSubmitStatus] = useState<'idle' | 'success' | 'error'>('idle');
  const [errorMessage, setErrorMessage] = useState<string>('');
  const navigate = useNavigate(); 

  

  const handleSubmit = async (e: React.FormEvent) => {

    e.preventDefault();
    setIsSubmitting(true);
    setSubmitStatus('idle');
    setErrorMessage('');

    try {
      const pathParts = window.location.pathname.split('/');
      const category = pathParts[1];
      const businessName = pathParts[2];
      const currentPath = window.location.pathname;
      const businessUrl = window.location.href;

      const submissionData = {
        first_name: formData.firstName,
        last_name: formData.lastName,
        email: formData.email,
        phone: formData.phone,
        message: formData.message,
        recipient_name: recipientName,
        recipient_email: recipientEmail || null,  // Handle case where email is not provided
        category,
        business_url: businessUrl,
        business_name: businessName
      };

      // First, insert into Supabase
      const { error: dbError } = await supabase
        .from('contact_submissions')
        .insert([submissionData]);

      if (dbError) {
        throw new Error('Failed to save submission');
      }

      // Then send email
      const response = await fetch('/send-email', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          ...formData,
          recipientName,
          recipientEmail,
          category,
          businessUrl,
          currentPath,
          businessName
        }),
      });

      const data = await response.json();

      if (response.ok) {
        navigate('/thank-you', { 
          state: { 
            recipientName,
            firstName: formData.firstName
          }
        });
      } else {
        setErrorMessage(data.error || 'Failed to send message');
        setSubmitStatus('error');
      }
    } catch (error) {
      setErrorMessage(error instanceof Error ? error.message : 'Failed to send message');
      setSubmitStatus('error');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.6, delay: 0.2 }}
      className="bg-white rounded-2xl shadow-lg p-8 mb-12 relative overflow-hidden"
    >
      <div className="relative z-10">
        <h2 className="text-2xl font-semibold mb-6">
          <span className="text-purple-600">Contact</span>
          <span className="text-gray-900 ml-2">{recipientName}</span>
        </h2>
      </div>
      {/* <div className="absolute inset-0 bg-gradient-to-br from-purple-50/50 to-transparent"></div> */}
      <form onSubmit={handleSubmit} className="space-y-6">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <label htmlFor="firstName" className="block text-sm font-medium text-gray-700 mb-1">
              First Name
            </label>
            <input
              type="text"
              id="firstName"
              required
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-600 focus:border-transparent"
              value={formData.firstName}
              onChange={(e) => setFormData(prev => ({ ...prev, firstName: e.target.value }))}
            />
          </div>
          <div>
            <label htmlFor="lastName" className="block text-sm font-medium text-gray-700 mb-1">
              Last Name
            </label>
            <input
              type="text"
              id="lastName"
              required
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-600 focus:border-transparent"
              value={formData.lastName}
              onChange={(e) => setFormData(prev => ({ ...prev, lastName: e.target.value }))}
            />
          </div>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <label htmlFor="email" className="block text-sm font-medium text-gray-700 mb-1">
              Email
            </label>
            <input
              type="email"
              id="email"
              required
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-600 focus:border-transparent"
              value={formData.email}
              onChange={(e) => setFormData(prev => ({ ...prev, email: e.target.value }))}
            />
          </div>
          <div>
            <label htmlFor="phone" className="block text-sm font-medium text-gray-700 mb-1">
              Phone Number
            </label>
            <input
              type="tel"
              id="phone"
              required
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-600 focus:border-transparent"
              value={formData.phone}
              onChange={(e) => setFormData(prev => ({ ...prev, phone: e.target.value }))}
            />
          </div>
        </div>
        <div>
          <label htmlFor="message" className="block text-sm font-medium text-gray-700 mb-1">
            Message
          </label>
          <textarea
            id="message"
            required
            rows={4}
            className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-600 focus:border-transparent"
            value={formData.message}
            onChange={(e) => setFormData(prev => ({ ...prev, message: e.target.value }))}
          />
        </div>
        <div className="flex items-center justify-between">
          <motion.button
            type="submit"
            disabled={isSubmitting}
            whileHover={{ scale: 1.02, boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1)' }}
            whileTap={{ scale: 0.98 }}
            className="inline-flex items-center px-6 py-3 border border-transparent text-base font-medium rounded-md text-white bg-purple-600 hover:bg-purple-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-purple-500 disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-300"
          >
            {isSubmitting ? (
              <span>Sending...</span>
            ) : (
              <>
                <Send className="w-5 h-5 mr-2" />
                Send Message
              </>
            )}
          </motion.button>
          {submitStatus === 'success' && (
            <p className="text-green-600">Message sent successfully!</p>
          )}
          {submitStatus === 'error' && (
            <p className="text-red-600">
              {errorMessage || 'Failed to send message. Please try again.'}
            </p>
          )}
        </div>
      </form>
    </motion.div>
  );
}