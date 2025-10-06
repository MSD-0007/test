'use client';

import { useEffect, useState } from 'react';
import { onPingReceived, removePingListener } from '@/lib/socket';
import { onNotificationClick } from '@/lib/onesignal';
import { Haptics, ImpactStyle } from '@capacitor/haptics';
import { LocalNotifications } from '@capacitor/local-notifications';
import { Capacitor } from '@capacitor/core';
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

// Vibration patterns for different ping types
const VIBRATION_PATTERNS = {
  'thinking-of-you': ImpactStyle.Light,
  'miss-you': ImpactStyle.Medium,
  'love-you': ImpactStyle.Heavy,
  'need-you': ImpactStyle.Heavy,
  default: ImpactStyle.Medium,
};

// Get vibration intensity based on ping type
function getVibrationPattern(type: string): ImpactStyle {
  return VIBRATION_PATTERNS[type as keyof typeof VIBRATION_PATTERNS] || VIBRATION_PATTERNS.default;
}

// Trigger haptic feedback with pattern
async function triggerVibration(type: string) {
  if (!Capacitor.isNativePlatform()) return;

  const pattern = getVibrationPattern(type);
  
  try {
    // For serious pings (need-you, love-you), vibrate multiple times
    if (type === 'need-you' || type === 'love-you') {
      await Haptics.impact({ style: ImpactStyle.Heavy });
      await new Promise(resolve => setTimeout(resolve, 100));
      await Haptics.impact({ style: ImpactStyle.Heavy });
      await new Promise(resolve => setTimeout(resolve, 100));
      await Haptics.impact({ style: ImpactStyle.Heavy });
    } else if (type === 'miss-you') {
      await Haptics.impact({ style: ImpactStyle.Medium });
      await new Promise(resolve => setTimeout(resolve, 150));
      await Haptics.impact({ style: ImpactStyle.Medium });
    } else {
      await Haptics.impact({ style: pattern });
    }
  } catch (error) {
    console.log('⚠️ Haptic not available:', error);
  }
}

// Show local notification (works even in background)
async function showLocalNotification(ping: IncomingPing) {
  if (!Capacitor.isNativePlatform()) return;

  try {
    // Request permissions
    const permission = await LocalNotifications.requestPermissions();
    if (permission.display !== 'granted') {
      console.log('⚠️ Notification permission not granted');
      return;
    }

    // Schedule notification
    await LocalNotifications.schedule({
      notifications: [
        {
          title: `💕 ${ping.from === 'ndg' ? 'Him' : 'Her'} sent you a ping!`,
          body: ping.message,
          id: ping.timestamp,
          schedule: { at: new Date(Date.now() + 100) }, // Show immediately
          sound: 'beep.wav',
          attachments: undefined,
          actionTypeId: '',
          extra: ping,
        },
      ],
    });
  } catch (error) {
    console.error('❌ Error showing local notification:', error);
  }
}

export default function PingListener({ userId }: PingListenerProps) {
  const [notifications, setNotifications] = useState<IncomingPing[]>([]);

  useEffect(() => {
    console.log('� PingListener started for userId:', userId);

    // Request notification permissions on mount
    if (Capacitor.isNativePlatform()) {
      LocalNotifications.requestPermissions().then((permission) => {
        console.log('📱 Notification permission:', permission.display);
      });
    }

    onPingReceived((pingData: IncomingPing) => {
      console.log('📨 Ping received via Socket.IO:', pingData);
      
      // Trigger vibration based on ping type
      triggerVibration(pingData.type);

      // Show local notification (works in background)
      showLocalNotification(pingData);

      // Add to notification list
      setNotifications((prev) => [pingData, ...prev].slice(0, 3)); // Keep only last 3

      // Auto-dismiss after 5 seconds
      setTimeout(() => {
        setNotifications((prev) => prev.filter((n) => n.timestamp !== pingData.timestamp));
      }, 5000);
    });

    onNotificationClick((notification) => {
      console.log('🔔 OneSignal notification clicked:', notification);
    });

    return () => {
      removePingListener();
    };
  }, [userId]);

  const dismissNotification = (timestamp: number) => {
    setNotifications((prev) => prev.filter((n) => n.timestamp !== timestamp));
  };

  return (
    <div className="fixed top-4 left-0 right-0 z-50 flex flex-col items-center gap-2 px-4 pointer-events-none">
      <AnimatePresence>
        {notifications.map((ping) => (
          <motion.div
            key={ping.timestamp}
            initial={{ opacity: 0, y: -100, scale: 0.9 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, y: -100, scale: 0.9 }}
            className="w-full max-w-md pointer-events-auto"
          >
            <div className="bg-gradient-to-br from-pink-500 via-purple-500 to-indigo-500 p-[2px] rounded-2xl shadow-2xl">
              <div className="bg-white/95 backdrop-blur-xl rounded-2xl p-4 relative">
                <button
                  onClick={() => dismissNotification(ping.timestamp)}
                  className="absolute top-2 right-2 p-1.5 rounded-full bg-gray-100 hover:bg-gray-200 transition-colors"
                  aria-label="Dismiss"
                >
                  <X className="w-4 h-4 text-gray-600" />
                </button>

                <div className="pr-10">
                  <div className="flex items-center gap-2 mb-1">
                    <span className="text-2xl">💕</span>
                    <h3 className="font-bold text-base text-gray-800">
                      {ping.from === 'ndg' ? 'Him' : 'Her'} sent you a ping!
                    </h3>
                  </div>
                  <p className="text-gray-700 text-sm leading-snug mt-2">
                    {ping.message}
                  </p>
                  <p className="text-xs text-gray-400 mt-2">
                    Just now ⚡
                  </p>
                </div>

                {/* Animated hearts */}
                <div className="absolute -top-1 -right-1 pointer-events-none">
                  {[...Array(3)].map((_, i) => (
                    <motion.div
                      key={i}
                      initial={{ opacity: 0, scale: 0 }}
                      animate={{ 
                        opacity: [0, 1, 0],
                        scale: [0, 1.5, 0],
                        x: [0, 20 * i, 30 * i],
                        y: [0, -20 * i, -30 * i],
                      }}
                      transition={{
                        duration: 2,
                        delay: i * 0.2,
                        repeat: Infinity,
                        repeatDelay: 1,
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
        ))}
      </AnimatePresence>
    </div>
  );
}