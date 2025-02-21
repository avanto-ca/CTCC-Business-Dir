import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { HelmetProvider } from 'react-helmet-async';
import App from './App.tsx';
import { LoginPage } from './components/LoginPage.tsx';
import { ProtectedRoute } from './components/ProtectedRoute.tsx';
import { AdminPanel } from './components/AdminPanel.tsx';
import { ThankYou } from './components/ThankYou.tsx';
import './index.css';

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <HelmetProvider>
      <BrowserRouter>
        <Routes>
          <Route path="/" element={<App />} />
          <Route path="/:category" element={<App />} />
          <Route path="/:category/:memberId" element={<App />} />
          <Route path="/login" element={<LoginPage />} />
          <Route path="/admin" element={<ProtectedRoute><AdminPanel /></ProtectedRoute>} />
          <Route path="/thank-you" element={<ThankYou />} />
        </Routes>
      </BrowserRouter>
    </HelmetProvider>
  </StrictMode>
);
