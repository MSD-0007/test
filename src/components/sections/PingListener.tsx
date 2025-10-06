'use client';

import { useEffect, useState } from 'react';
import { onPingReceived, removePingListener } from '@/lib/socket';
import { onNotificationClick } from '@/lib/onesignal';
import { Haptics, NotificationType } from '@capacitor/haptics';
import { Capacitor } from '@capacitor/core';
import { useToast } from '@/hooks/use-toast';
import { motion, AnimatePresence } from 'framer-motion';
import { X } from 'lucide-react';

interface PingListenerProps {
  userId: string;
}

interface IncomingPing {
  from: string;
  to: string;
  message: string;
  type: string;
  timestamp: number;
}

export default function PingListener({ userId }: PingListenerProps) {
  const [showNotification, setShowNotification] = useState(false);
  const [currentPing, setCurrentPing] = useState<IncomingPing | null>(null);
  const { toast } = useToast();

  useEffect(() => {
    console.log('🔔 PingListener started for userId:', userId);

    onPingReceived((pingData: IncomingPing) => {
      console.log('📨 Ping received via Socket.IO:', pingData);
      
      if (Capacitor.isNativePlatform()) {
        Haptics.notification({ type: NotificationType.Success }).catch(() => {
          console.log('⚠️ Haptic not available');
        });
      }

      setCurrentPing(pingData);
      setShowNotification(true);

      toast({
        title: `💕 ${pingData.from} sent you a ping!`,
        description: pingData.message,
      });
    });

    onNotificationClick((notification) => {
      console.log('🔔 OneSignal notification clicked:', notification);
    });

    return () => {
      removePingListener();
    };
  }, [userId, toast]);

  const dismissNotification = () => {
    setShowNotification(false);
    setTimeout(() => setCurrentPing(null), 300);
  };

  return (
    <AnimatePresence>
      {showNotification && currentPing && (
        <motion.div
          initial={{ opacity: 0, y: -100 }}
          animate={{ opacity: 1, y: 0 }}
          exit={{ opacity: 0, y: -100 }}
          className="fixed top-4 left-1/2 transform -translate-x-1/2 z-50 w-11/12 max-w-md"
        >
          <div className="bg-gradient-to-br from-pink-500 via-purple-500 to-indigo-500 p-1 rounded-2xl shadow-2xl">
            <div className="bg-white/95 backdrop-blur-xl rounded-xl p-4 relative overflow-hidden">
              <button
                onClick={dismissNotification}
                className="absolute top-2 right-2 p-1 rounded-full bg-white/50 hover:bg-white/80 transition-colors"
              >
                <X className="w-4 h-4 text-gray-700" />
              </button>

              <div className="pr-8">
                <div className="flex items-center gap-2 mb-2">
                  <span className="text-2xl">💕</span>
                  <h3 className="font-bold text-lg text-gray-800">
                    {currentPing.from === 'ndg' ? 'Him' : 'Her'} sent you a ping!
                  </h3>
                </div>
                <p className="text-gray-600 text-sm leading-relaxed">
                  {currentPing.message}
                </p>
                <p className="text-xs text-gray-400 mt-2">
                  Just now • Real-time delivery ⚡
                </p>
              </div>

              <div className="absolute -top-1 -right-1">
                {[...Array(3)].map((_, i) => (
                  <motion.div
                    key={i}
                    initial={{ opacity: 0, scale: 0 }}
                    animate={{ 
                      opacity: [0, 1, 0],
                      scale: [0, 1, 0],
                      y: [0, -30],
                      x: [0, (i - 1) * 10]
                    }}
                    transition={{ 
                      duration: 2,
                      delay: i * 0.3,
                      repeat: Infinity
                    }}
                    className="absolute text-2xl"
                  >
                    ❤️
                  </motion.div>
                ))}
              </div>
            </div>
          </div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}