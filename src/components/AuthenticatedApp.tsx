'use client';

import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { useAuth } from '@/components/auth/AuthProvider';
import SplashScreen from '@/components/shared/SplashScreen';
import LoginForm from '@/components/auth/LoginForm';
import PasswordProtection from '@/components/password/PasswordProtection';
import HomePage from '@/components/home/HomePage';
import FloatingParticles from '@/components/shared/FloatingParticles';
import { initializeSocket } from '@/lib/socket';
import { initializeOneSignal } from '@/lib/onesignal';

type AppState = 'splash' | 'login' | 'user-selection' | 'main';

export default function AuthenticatedApp() {
  const { user, loading, isAuthenticated } = useAuth();
  const [appState, setAppState] = useState<AppState>('splash');
  const [socketInitialized, setSocketInitialized] = useState(false);

  console.log('🚀 AuthenticatedApp state:', { appState, isAuthenticated, userEmail: user?.email });

  // Initialize Socket.IO and OneSignal when user is authenticated
  useEffect(() => {
    const initRealtime = async () => {
      if (isAuthenticated && appState === 'main' && !socketInitialized) {
        const userId = localStorage.getItem('secretLoveUserId');
        if (userId) {
          console.log('� Initializing Socket.IO for user:', userId);
          
          // Initialize OneSignal first to get player ID
          const playerId = await initializeOneSignal(userId);
          
          // Initialize Socket.IO with user ID and optional OneSignal player ID
          initializeSocket(userId, playerId || undefined);
          
          setSocketInitialized(true);
        }
      }
    };

    initRealtime();
  }, [isAuthenticated, appState, socketInitialized]);

  // Show loading while auth is initializing
  if (loading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-[#5865F2] via-[#4752C4] to-[#3C45A5] flex items-center justify-center">
        <FloatingParticles />
        <div className="text-white text-lg">Loading...</div>
      </div>
    );
  }

  // If authenticated and past splash, go straight to user selection or main
  if (isAuthenticated && appState === 'splash') {
    setAppState('user-selection');
  }

  // If not authenticated and past splash, show login
  if (!isAuthenticated && appState === 'splash') {
    setAppState('login');
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-[#5865F2] via-[#4752C4] to-[#3C45A5] relative overflow-hidden">
      <FloatingParticles />
      
      <AnimatePresence mode="wait">
        {appState === 'splash' && (
          <motion.div
            key="splash"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ duration: 0.5 }}
          >
            <SplashScreen 
              onComplete={() => {
                if (isAuthenticated) {
                  setAppState('user-selection');
                } else {
                  setAppState('login');
                }
              }} 
            />
          </motion.div>
        )}

        {appState === 'login' && !isAuthenticated && (
          <motion.div
            key="login"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            transition={{ duration: 0.5 }}
            className="min-h-screen flex items-center justify-center p-4"
          >
            <LoginForm 
              onLoginSuccess={() => setAppState('user-selection')} 
            />
          </motion.div>
        )}

        {appState === 'user-selection' && isAuthenticated && (
          <motion.div
            key="user-selection"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            transition={{ duration: 0.5 }}
            className="min-h-screen flex items-center justify-center"
          >
            <PasswordProtection 
              correctPassword="AnF"
              onAuthenticated={(userId) => {
                console.log('🔐 User selection completed, userId:', userId);
                setAppState('main');
              }} 
            />
          </motion.div>
        )}

        {appState === 'main' && isAuthenticated && (
          <motion.div
            key="main"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ duration: 0.5 }}
          >
            <HomePage />
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}