import { motion } from 'framer-motion';
import { useLocation, useNavigate } from 'react-router-dom';
import { CheckCircle, ArrowLeft } from 'lucide-react';

export function ThankYou() {
  const location = useLocation();
  const navigate = useNavigate();
  const state = location.state as { recipientName: string; firstName: string } | null;

  if (!state) {
    navigate('/');
    return null;
  }

  return (
    <div className="min-h-screen bg-gray-50 flex items-center justify-center px-4">
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6 }}
        className="max-w-md w-full bg-white rounded-2xl shadow-lg p-8 text-center"
      >
        <div className="mb-6">
          <CheckCircle className="w-16 h-16 text-green-500 mx-auto" />
        </div>
        <h1 className="text-2xl font-bold text-gray-900 mb-4">
          Thank You, {state.firstName}!
        </h1>
        <p className="text-gray-600 mb-8">
          Your message has been sent to {state.recipientName}. They will get back to you soon.
        </p>
        <button
          onClick={() => navigate(-1)}
          className="inline-flex items-center px-6 py-3 border border-transparent text-base font-medium rounded-md text-white bg-purple-600 hover:bg-purple-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-purple-500 mx-auto"
        >
          <ArrowLeft className="w-5 h-5 mr-2" />
          Back to Profile
        </button>
      </motion.div>
    </div>
  );
}