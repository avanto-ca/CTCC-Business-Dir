import { Mail, Heart } from 'lucide-react';
import { motion } from 'framer-motion';

export function Footer() {
  return (
    <footer className="bg-gradient-to-b from-transparent to-gray-50 pt-12 pb-6">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.5 }}
            className="inline-flex items-center space-x-2 text-gray-600 hover:text-purple-600 transition-colors duration-300"
          >
            <Mail className="w-5 h-5" />
            <a 
              href="mailto:admin@ctcc.ca"
              className="text-sm font-medium hover:underline"
            >
              Questions or need support? Contact us at admin@ctcc.ca
            </a>
          </motion.div>
          
          <motion.p
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.5, delay: 0.2 }}
            className="mt-4 text-sm text-gray-500 flex items-center justify-center"
          >Made with <Heart className="w-4 h-4 mx-1 text-red-500" /> by{' '}
            <a 
              href="https://avanto.ca/" 
              target="_blank" 
              rel="noopener noreferrer" 
              className="text-purple-600 hover:text-purple-800 hover:underline transition-colors ml-1"
            >
              Avanto
            </a>
          </motion.p>
        </div>
      </div>
    </footer>
  );
}