'use client';

import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { useAuth } from '@/components/auth/AuthProvider';
import SplashScreen from '@/components/shared/SplashScreen';
import LoginForm from '@/components/auth/LoginForm';
import PasswordProtection from '@/components/password/PasswordProtection';
import HomePage from '@/components/home/HomePage';
import FloatingParticles from '@/components/shared/FloatingParticles';
import NotificationManager from '@/components/NotificationManager';
import { initializeSocket } from '@/lib/socket';
import { initializeFCM } from '@/lib/fcm';
import { initSimpleNotifications } from '@/lib/simple-notifications';

type AppState = 'splash' | 'login' | 'user-selection' | 'main';

export default function AuthenticatedApp() {
  const { user, loading, isAuthenticated } = useAuth();
  const [appState, setAppState] = useState<AppState>('splash');
  const [socketInitialized, setSocketInitialized] = useState(false);

  console.log('🚀 AuthenticatedApp state:', { appState, isAuthenticated, userEmail: user?.email });

    // Initialize Socket.IO when authenticated and on main page
  useEffect(() => {
    console.log('🔍 Socket init check:', { isAuthenticated, appState, socketInitialized });
    
    const initializeSocketConnection = async () => {
      if (isAuthenticated && appState === 'main' && !socketInitialized) {
        console.log('🔌 Initializing socket connection...');
        
        const userId = localStorage.getItem('secretLoveUserId');
        console.log('👤 Retrieved userId from localStorage:', userId);
        
        if (!userId) {
          console.error('❌ No userId found for socket initialization');
          return;
        }

        try {
          // Initialize FCM for push notifications
          console.log('📱 Initializing FCM...');
          await initializeFCM(userId);
          console.log('✅ FCM initialization complete');
          
          // Initialize NUCLEAR simple notifications
          console.log('🚀 NUCLEAR: Initializing simple notifications');
          await initSimpleNotifications();
          
          // Initialize socket with userId
          console.log('🚀 Calling initializeSocket...');
          initializeSocket(userId, undefined);
          setSocketInitialized(true);
          console.log('✅ Socket initialization complete');
        } catch (error) {
          console.error('❌ Error initializing socket:', error);
        }
      }
    };

    initializeSocketConnection();
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
      <NotificationManager />
      
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