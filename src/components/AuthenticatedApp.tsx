'use client';

import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { signInWithEmailAndPassword } from 'firebase/auth';
import { auth } from '@/lib/firebase';
import SplashScreen from '@/components/shared/SplashScreen';
import UserSelection from '@/components/auth/UserSelection';
import PasswordProtection from '@/components/password/PasswordProtection';
import HomePage from '@/components/home/HomePage';
import FloatingParticles from '@/components/shared/FloatingParticles';
import { initializeSocket } from '@/lib/socket';
import { initializeOneSignal } from '@/lib/onesignal';

type AppState = 'splash' | 'user-selection' | 'password' | 'main';

const USER_CREDENTIALS = {
  ndg: {
    email: 'ndg@special.love',
    password: 'ndg123456'
  },
  ak: {
    email: 'ak@special.love',
    password: 'ak123456'
  }
};

export default function AuthenticatedApp() {
  const [appState, setAppState] = useState<AppState>('splash');
  const [selectedUserId, setSelectedUserId] = useState<string>('');
  const [isAuthenticating, setIsAuthenticating] = useState(false);
  const [socketInitialized, setSocketInitialized] = useState(false);

  console.log('AuthenticatedApp state:', { appState, selectedUserId });

  const handleUserSelection = async (userId: string) => {
    console.log('User selected:', userId);
    setSelectedUserId(userId);
    setIsAuthenticating(true);

    try {
      const credentials = USER_CREDENTIALS[userId as keyof typeof USER_CREDENTIALS];
      console.log('Auto-logging in with email:', credentials.email);
      
      await signInWithEmailAndPassword(auth, credentials.email, credentials.password);
      
      console.log('Auto-login successful');
      setAppState('password');
    } catch (error) {
      console.error('Auto-login failed:', error);
      setSelectedUserId('');
    } finally {
      setIsAuthenticating(false);
    }
  };

  useEffect(() => {
    const initRealtime = async () => {
      if (appState === 'main' && selectedUserId && !socketInitialized) {
        console.log('Initializing Socket.IO for user:', selectedUserId);
        
        const playerId = await initializeOneSignal(selectedUserId);
        initializeSocket(selectedUserId, playerId || undefined);
        
        setSocketInitialized(true);
      }
    };

    initRealtime();
  }, [appState, selectedUserId, socketInitialized]);

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
              onComplete={() => setAppState('user-selection')} 
            />
          </motion.div>
        )}

        {appState === 'user-selection' && (
          <motion.div
            key="user-selection"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            transition={{ duration: 0.5 }}
            className="min-h-screen flex items-center justify-center"
          >
            {isAuthenticating ? (
              <div className="text-white text-lg">Authenticating...</div>
            ) : (
              <UserSelection onUserSelected={handleUserSelection} />
            )}
          </motion.div>
        )}

        {appState === 'password' && selectedUserId && (
          <motion.div
            key="password"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            transition={{ duration: 0.5 }}
            className="min-h-screen flex items-center justify-center"
          >
            <PasswordProtection 
              correctPassword="alwaysandforever"
              userId={selectedUserId}
              onAuthenticated={() => {
                console.log('Password verified for userId:', selectedUserId);
                setAppState('main');
              }} 
            />
          </motion.div>
        )}

        {appState === 'main' && selectedUserId && (
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
