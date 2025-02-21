import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  base: '/',
  publicDir: 'public',
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
  optimizeDeps: {
    exclude: ['lucide-react'],
  },
  server: {
    historyApiFallback: true,
    proxy: {
      '^/send-email': {
        target: 'http://localhost:3000',
        changeOrigin: true,
        secure: false
      },
    },
  },
  build: {
    copyPublicDir: true,
    assetsDir: 'assets',
  },
});