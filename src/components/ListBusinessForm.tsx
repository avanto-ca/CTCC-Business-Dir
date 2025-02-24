import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { X, Send, Loader2, CheckCircle } from 'lucide-react';
import { supabase } from '../lib/supabase';

interface ListBusinessFormProps {
  isOpen: boolean;
  onClose: () => void;
}

export function ListBusinessForm({ isOpen, onClose }: ListBusinessFormProps) {
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    phone: '',
    businessType: '',
    message: ''
  });
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [submitStatus, setSubmitStatus] = useState<'idle' | 'success' | 'error'>('idle');
  const [errorMessage, setErrorMessage] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);
    setSubmitStatus('idle');
    setErrorMessage('');

    try {
      if (!supabase) throw new Error('Supabase client not initialized');

      const { error } = await supabase
        .from('business_leads')
        .insert([{
          name: formData.name,
          email: formData.email,
          phone: formData.phone,
          business_type: formData.businessType,
          message: formData.message
        }]);

      if (error) throw error;

      setSubmitStatus('success');
    } catch (error) {
      console.error('Error submitting lead:', error);
      setErrorMessage('Failed to submit request. Please try again.');
      setSubmitStatus('error');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleClose = () => {
    onClose();
    setFormData({
      name: '',
      email: '',
      phone: '',
      businessType: '',
      message: ''
    });
    setSubmitStatus('idle');
  };

  return (
    <AnimatePresence>
      {isOpen && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          className="fixed inset-0 bg-black bg-opacity-50 z-50 flex items-center justify-center p-4"
        >
          <motion.div
            initial={{ scale: 0.95, opacity: 0 }}
            animate={{ scale: 1, opacity: 1 }}
            exit={{ scale: 0.95, opacity: 0 }}
            className="bg-white rounded-2xl shadow-xl max-w-lg w-full overflow-hidden"
          >
            {submitStatus === 'success' ? (
              <motion.div
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                className="p-8 text-center"
              >
                <motion.div
                  initial={{ scale: 0 }}
                  animate={{ scale: 1 }}
                  transition={{ type: "spring", duration: 0.5 }}
                  className="mb-6 inline-block"
                >
                  <CheckCircle className="w-16 h-16 text-green-500 mx-auto" />
                </motion.div>
                <h2 className="text-2xl font-bold text-gray-900 mb-4">
                  Thank You for Your Interest!
                </h2>
                <p className="text-gray-600 mb-8">
                  We've received your business listing request. Our team will review your information and get back to you soon.
                </p>
                <motion.button
                  whileHover={{ scale: 1.02 }}
                  whileTap={{ scale: 0.98 }}
                  onClick={handleClose}
                  className="inline-flex items-center px-6 py-3 border border-transparent text-base font-medium rounded-lg text-white bg-gradient-to-r from-purple-600 to-indigo-600 hover:from-purple-700 hover:to-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-purple-500"
                >
                  Close
                </motion.button>
              </motion.div>
            ) : (
              <>
                <div className="relative bg-gradient-to-r from-purple-600 to-indigo-600 p-8 overflow-hidden">
                  <div className="inset-0 bg-[radial-gradient(circle_at_center,_rgba(255,255,255,0.1)_0%,_transparent_2px)] bg-[length:16px_16px] opacity-25"></div>
                  <div className="flex justify-between items-start">
                    <div className="relative">
                      <h2 className="text-3xl font-bold text-white mb-3">List Your Business</h2>
                      <p className="text-purple-100 text-lg">Join the CTCC Business Directory</p>
                    </div>
                    <button
                      onClick={handleClose}
                      className="text-white/80 hover:text-white hover:bg-white/10 p-2 rounded-full transition-all duration-300"
                    >
                      <X className="w-6 h-6" />
                    </button>
                  </div>
                </div>

                <form onSubmit={handleSubmit} className="p-8 space-y-6">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Business/Owner Name
                    </label>
                    <input
                      type="text"
                      required
                      value={formData.name}
                      onChange={(e) => setFormData(prev => ({ ...prev, name: e.target.value }))}
                      className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent transition-shadow duration-200 hover:border-gray-400"
                      placeholder="Enter your business or full name"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Email Address
                    </label>
                    <input
                      type="email"
                      required
                      value={formData.email}
                      onChange={(e) => setFormData(prev => ({ ...prev, email: e.target.value }))}
                      className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent transition-shadow duration-200 hover:border-gray-400"
                      placeholder="Enter your email address"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Phone Number
                    </label>
                    <input
                      type="tel"
                      required
                      value={formData.phone}
                      onChange={(e) => setFormData(prev => ({ ...prev, phone: e.target.value }))}
                      className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent transition-shadow duration-200 hover:border-gray-400"
                      placeholder="Enter your phone number"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Type of Business
                    </label>
                    <input
                      type="text"
                      required
                      value={formData.businessType}
                      onChange={(e) => setFormData(prev => ({ ...prev, businessType: e.target.value }))}
                      className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent transition-shadow duration-200 hover:border-gray-400"
                      placeholder="e.g., Restaurant, Real Estate, Accounting"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Additional Details
                    </label>
                    <textarea
                      value={formData.message}
                      onChange={(e) => setFormData(prev => ({ ...prev, message: e.target.value }))}
                      rows={3}
                      className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent transition-shadow duration-200 hover:border-gray-400 resize-none"
                      placeholder="Tell us more about your business..."
                    />
                  </div>

                  {submitStatus === 'error' && (
                    <p className="text-red-600 text-sm">{errorMessage}</p>
                  )}

                  <div className="flex justify-end">
                    <motion.button
                      type="submit"
                      disabled={isSubmitting}
                      className={`
                        inline-flex items-center px-6 py-3 rounded-lg text-white font-medium
                        ${isSubmitting ? 'bg-purple-400' : 'bg-gradient-to-r from-purple-600 to-indigo-600 hover:from-purple-700 hover:to-indigo-700'}
                        focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-purple-500
                        transition-all duration-300 shadow-lg hover:shadow-xl
                      `}
                      whileHover={{ scale: 1.02 }}
                      whileTap={{ scale: 0.98 }}
                    >
                      {isSubmitting ? (
                        <Loader2 className="w-5 h-5 mr-2 animate-spin" />
                      ) : (
                        <Send className="w-5 h-5 mr-2" />
                      )}
                      {submitStatus === 'success' ? 'Submitted!' : 'Submit Request'}
                    </motion.button>
                  </div>
                </form>
              </>
            )}
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}