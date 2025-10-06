'use client';

import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { Heart } from 'lucide-react';

interface UserSelectionProps {
  onUserSelected: (userId: string) => void;
}

export default function UserSelection({ onUserSelected }: UserSelectionProps) {
  const [selectedUser, setSelectedUser] = useState<string | null>(null);

  useEffect(() => {
    // Check if user was previously selected
    const savedUserId = localStorage.getItem('secretLoveUserId');
    if (savedUserId) {
      console.log('🔄 Auto-selecting previously chosen user:', savedUserId);
      // Auto-select after a brief moment
      setTimeout(() => {
        handleUserSelect(savedUserId);
      }, 300);
    }
  }, []);

  const handleUserSelect = (userId: string) => {
    setSelectedUser(userId);
    localStorage.setItem('secretLoveUserId', userId);
    
    // Smooth transition to password screen
    setTimeout(() => {
      onUserSelected(userId);
    }, 500);
  };

  return (
    <div className="min-h-screen flex items-center justify-center p-4">
      <motion.div
        initial={{ opacity: 0, scale: 0.9 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={{ duration: 0.5 }}
        className="w-full max-w-md"
      >
        <div className="text-center mb-8">
          <motion.div
            initial={{ scale: 0 }}
            animate={{ scale: 1 }}
            transition={{ delay: 0.2, type: 'spring', stiffness: 200 }}
            className="inline-block mb-4"
          >
            <Heart className="w-20 h-20 text-pink-300 fill-pink-300" />
          </motion.div>
          <h1 className="text-4xl font-serif text-white mb-2">
            Who are you?
          </h1>
          <p className="text-white/80">
            Select your identity
          </p>
        </div>

        <div className="grid grid-cols-2 gap-4">
          {/* NDG Button */}
          <motion.button
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
            onClick={() => handleUserSelect('ndg')}
            className={`
              relative overflow-hidden rounded-2xl p-8 
              bg-gradient-to-br from-blue-400/20 to-indigo-500/20 
              border-2 border-blue-400/50
              backdrop-blur-sm
              transition-all duration-300
              ${selectedUser === 'ndg' ? 'ring-4 ring-blue-400' : 'hover:border-blue-400'}
            `}
          >
            <div className="text-center">
              <div className="text-6xl mb-3">👨</div>
              <h3 className="text-2xl font-bold text-white">Him</h3>
              <p className="text-sm text-white/70 mt-1">NDG</p>
            </div>
            {selectedUser === 'ndg' && (
              <motion.div
                initial={{ scale: 0 }}
                animate={{ scale: 1 }}
                className="absolute top-2 right-2"
              >
                <div className="w-6 h-6 bg-blue-400 rounded-full flex items-center justify-center">
                  <span className="text-white text-xs">✓</span>
                </div>
              </motion.div>
            )}
          </motion.button>

          {/* AK Button */}
          <motion.button
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
            onClick={() => handleUserSelect('ak')}
            className={`
              relative overflow-hidden rounded-2xl p-8 
              bg-gradient-to-br from-pink-400/20 to-rose-500/20 
              border-2 border-pink-400/50
              backdrop-blur-sm
              transition-all duration-300
              ${selectedUser === 'ak' ? 'ring-4 ring-pink-400' : 'hover:border-pink-400'}
            `}
          >
            <div className="text-center">
              <div className="text-6xl mb-3">👩</div>
              <h3 className="text-2xl font-bold text-white">Her</h3>
              <p className="text-sm text-white/70 mt-1">AK</p>
            </div>
            {selectedUser === 'ak' && (
              <motion.div
                initial={{ scale: 0 }}
                animate={{ scale: 1 }}
                className="absolute top-2 right-2"
              >
                <div className="w-6 h-6 bg-pink-400 rounded-full flex items-center justify-center">
                  <span className="text-white text-xs">✓</span>
                </div>
              </motion.div>
            )}
          </motion.button>
        </div>

        <motion.p
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.5 }}
          className="text-center text-white/60 text-sm mt-6"
        >
          Your choice will be remembered 💕
        </motion.p>
      </motion.div>
    </div>
  );
}
