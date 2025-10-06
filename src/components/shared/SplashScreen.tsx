'use client';

import { motion } from 'framer-motion';
import { Heart, Sparkles } from 'lucide-react';
import { useEffect, useState } from 'react';

export default function SplashScreen({ onComplete }: { onComplete: () => void }) {
  const [showText, setShowText] = useState(false);
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
    
    // Show text after 500ms
    const textTimer = setTimeout(() => setShowText(true), 500);
    
    // Complete splash after 2.5 seconds
    const completeTimer = setTimeout(() => {
      onComplete();
    }, 2500);

    return () => {
      clearTimeout(textTimer);
      clearTimeout(completeTimer);
    };
  }, [onComplete]);

  // Get safe dimensions
  const getRandomPosition = () => {
    if (typeof window === 'undefined') return { x: 0, y: 0 };
    return {
      x: Math.random() * window.innerWidth,
      y: Math.random() * window.innerHeight
    };
  };

  return (
    <motion.div
      initial={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      transition={{ duration: 0.5 }}
      className="fixed inset-0 z-50 flex items-center justify-center bg-gradient-to-br from-[#5865F2] via-[#4752C4] to-[#3C45A5]"
    >
      {/* Animated background particles */}
      {mounted && (
        <div className="absolute inset-0 overflow-hidden">
          {[...Array(20)].map((_, i) => {
            const startPos = getRandomPosition();
            const endPos1 = getRandomPosition();
            const endPos2 = getRandomPosition();
            
            return (
              <motion.div
                key={i}
                className="absolute w-2 h-2 bg-white/30 rounded-full"
                initial={{ 
                  x: startPos.x, 
                  y: startPos.y,
                  scale: Math.random() * 0.5 + 0.5
                }}
                animate={{
                  y: [null, endPos1.y, endPos2.y],
                  x: [null, endPos1.x, endPos2.x],
                  opacity: [0, 1, 0],
                }}
                transition={{
                  duration: Math.random() * 3 + 2,
                  repeat: Infinity,
                  ease: "linear"
                }}
              />
            );
          })}
        </div>
      )}

      {/* Main content */}
      <div className="relative z-10 flex flex-col items-center space-y-6">
        {/* Heart with sparkles animation */}
        <motion.div
          initial={{ scale: 0, rotate: -180 }}
          animate={{ scale: 1, rotate: 0 }}
          transition={{ 
            type: "spring", 
            stiffness: 200, 
            damping: 15,
            duration: 0.8
          }}
          className="relative"
        >
          <motion.div
            animate={{ 
              scale: [1, 1.1, 1],
            }}
            transition={{ 
              duration: 1.5,
              repeat: Infinity,
              ease: "easeInOut"
            }}
          >
            <Heart 
              className="w-24 h-24 text-white fill-white drop-shadow-2xl" 
            />
          </motion.div>

          {/* Sparkles around heart */}
          {[0, 1, 2, 3].map((i) => (
            <motion.div
              key={i}
              className="absolute"
              style={{
                top: '50%',
                left: '50%',
                transform: `rotate(${i * 90}deg) translateY(-60px)`
              }}
              initial={{ opacity: 0, scale: 0 }}
              animate={{ 
                opacity: [0, 1, 0],
                scale: [0, 1, 0]
              }}
              transition={{
                duration: 2,
                repeat: Infinity,
                delay: i * 0.2
              }}
            >
              <Sparkles className="w-6 h-6 text-white" />
            </motion.div>
          ))}
        </motion.div>

        {/* Text */}
        {showText && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5 }}
            className="text-center space-y-2"
          >
            <h1 className="text-4xl font-serif font-bold text-white drop-shadow-lg">
              Secret Love
            </h1>
            <p className="text-white/90 text-lg font-light tracking-wide">
              Our Little Universe
            </p>
          </motion.div>
        )}

        {/* Loading indicator */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 1 }}
          className="flex space-x-2"
        >
          {[0, 1, 2].map((i) => (
            <motion.div
              key={i}
              className="w-2 h-2 bg-white rounded-full"
              animate={{
                scale: [1, 1.5, 1],
                opacity: [0.5, 1, 0.5]
              }}
              transition={{
                duration: 1,
                repeat: Infinity,
                delay: i * 0.2
              }}
            />
          ))}
        </motion.div>
      </div>
    </motion.div>
  );
}
