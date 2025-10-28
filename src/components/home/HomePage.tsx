"use client";

import React, { useState, useEffect } from "react";
import { motion } from "framer-motion";
import { Button } from "@/components/shared/ui/button";
import { useToast } from "@/hooks/use-toast";
import { getRandomMessage } from "@/lib/utils";
import MusicToggle from "@/components/shared/MusicToggle";
import FloatingParticles from "@/components/shared/FloatingParticles";
import QuickPing from "@/components/sections/QuickPing";
import PingListener from "@/components/sections/PingListener";
import DynamicMoments from "@/components/sections/DynamicMoments";
import { listenForSimplePings, startPingPolling } from "@/lib/simple-messaging";
import { Capacitor } from '@capacitor/core';
import dynamic from "next/dynamic";

const LettersSection = dynamic(() => import("@/components/sections/LettersSection"), { ssr: false });
const HiddenHugs = dynamic(() => import("@/components/sections/HiddenHugs"), { ssr: false });

const loveMessages = [
  "I miss your smile so much right now.",
  "Every time I think of you, my heart skips a beat.",
  "You're the most beautiful part of my day, even when we're apart.",
  "I can't wait to hold you close again.",
  "Your laugh is my favorite sound in the world.",
  "Distance means so little when someone means so much.",
  "Missing you comes in waves, and right now I'm drowning.",
  "I've been smiling all day thinking about you.",
  "You're the first thing on my mind when I wake up.",
  "I love you more than yesterday, but less than tomorrow.",
];

export default function HomePage() {
  const { toast } = useToast();
  const [userId, setUserId] = useState<string>('ndg');
  
  // NUCLEAR OPTION: Simple notification handler + Firestore listener
  useEffect(() => {
    console.log('🚀 NUCLEAR: Setting up ping listeners');
    
    const handleNuclearPing = (event: any) => {
      console.log('🚀 NUCLEAR: Socket ping received:', event.detail);
      
      // Debug notification availability
      console.log('🔍 Socket ping - checking notification availability:', {
        showSimpleNotification: !!window.showSimpleNotification,
        Notification: typeof Notification !== 'undefined',
        permission: typeof Notification !== 'undefined' ? Notification.permission : 'unknown'
      });
      
      // Use the global simple notification function
      if (window.showSimpleNotification) {
        console.log('🔔 Socket ping - calling showSimpleNotification...');
        const title = `💕 ${event.detail.from || 'Someone'} sent you a ping!`;
        const body = event.detail.message || 'You received a new message!';
        window.showSimpleNotification(title, body);
      } else {
        console.error('❌ Socket ping - window.showSimpleNotification not available!');
        
        // Fallback to browser notification
        if (typeof Notification !== 'undefined' && Notification.permission === 'granted') {
          console.log('🔔 Socket ping - using fallback browser notification');
          new Notification(`💕 ${event.detail.from || 'Someone'} sent you a ping!`, {
            body: event.detail.message || 'You received a new message!',
            icon: '/images/heart-icon.png'
          });
        }
      }
    };

    const handleFirestorePing = async (ping: any) => {
      console.log('🔥 FIRESTORE: Ping received:', ping);
      
      // DIRECT ANDROID NOTIFICATION - bypass all other systems
      if (Capacitor.isNativePlatform()) {
        console.log('📱 DIRECT: Android detected, using direct LocalNotifications');
        try {
          const { LocalNotifications } = await import('@capacitor/local-notifications');
          
          // Request permission if needed
          const permissions = await LocalNotifications.requestPermissions();
          console.log('📱 DIRECT: Permissions:', permissions);
          
          if (permissions.display === 'granted') {
            await LocalNotifications.schedule({
              notifications: [{
                title: `💕 ${ping.from || 'Someone'} sent you a ping!`,
                body: ping.message || 'You received a new message!',
                id: Date.now(),
                sound: 'default',
                attachments: undefined,
                actionTypeId: '',
                extra: {}
              }]
            });
            console.log('📱 DIRECT: Android notification sent!');
          } else {
            console.error('📱 DIRECT: Permission denied');
          }
        } catch (error) {
          console.error('📱 DIRECT: Error:', error);
        }
      } else {
        // Web notification
        console.log('🌐 DIRECT: Web detected, using browser notification');
        if (typeof Notification !== 'undefined') {
          if (Notification.permission === 'granted') {
            new Notification(`💕 ${ping.from || 'Someone'} sent you a ping!`, {
              body: ping.message || 'You received a new message!',
              icon: '/images/heart-icon.png'
            });
            console.log('🌐 DIRECT: Web notification sent!');
          } else if (Notification.permission === 'default') {
            const permission = await Notification.requestPermission();
            if (permission === 'granted') {
              new Notification(`💕 ${ping.from || 'Someone'} sent you a ping!`, {
                body: ping.message || 'You received a new message!',
                icon: '/images/heart-icon.png'
              });
              console.log('🌐 DIRECT: Web notification sent after permission!');
            }
          }
        }
      }
      
      // Also trigger the custom event for other listeners
      window.dispatchEvent(new CustomEvent('new-ping', { detail: ping }));
    };

    // Add socket event listener
    window.addEventListener('new-ping', handleNuclearPing);
    
    // Add Firestore listener
    let unsubscribeFirestore: (() => void) | null = null;
    let stopPolling: (() => void) | null = null;
    
    if (userId) {
      // Always use real-time listener
      unsubscribeFirestore = listenForSimplePings(userId, handleFirestorePing);
      
      // On Android, also use polling as backup (since real-time can be unreliable)
      if (Capacitor.isNativePlatform()) {
        console.log('📱 Android detected, starting backup polling');
        stopPolling = startPingPolling(userId, handleFirestorePing, 5000); // Poll every 5 seconds
      }
    }
    
    console.log('🚀 NUCLEAR: All listeners added');
    
    return () => {
      window.removeEventListener('new-ping', handleNuclearPing);
      if (unsubscribeFirestore) {
        unsubscribeFirestore();
      }
      if (stopPolling) {
        stopPolling();
      }
    };
  }, [userId]);
  
  useEffect(() => {
    console.log('🏠 HomePage mounted!');
    
    // Get user ID from localStorage
    const storedUserId = localStorage.getItem('secretLoveUserId');
    console.log('📝 Stored userId from localStorage:', storedUserId);
    
    if (storedUserId) {
      setUserId(storedUserId);
      console.log('✅ Using userId:', storedUserId);
    } else {
      console.log('⚠️ No userId in localStorage, using default: ndg');
      // Set default
      localStorage.setItem('secretLoveUserId', 'ndg');
    }
  }, []);
  
  const showLoveMessage = () => {
    toast({
      title: "❤️ A Message for You",
      description: getRandomMessage(loveMessages),
    });
  };

  return (
    <div className="min-h-screen w-full overflow-x-hidden relative">
      {/* Floating Particles Background */}
      <FloatingParticles />

      {/* Ping Listener for incoming notifications */}
      <PingListener userId={userId} />

      {/* Music Toggle */}
      <div className="fixed top-4 right-4 z-30">
        <MusicToggle />
      </div>
      
      {/* User ID Display - for debugging */}
      <div className="fixed top-4 left-4 z-30 bg-black/50 text-white px-4 py-2 rounded-lg backdrop-blur-xl">
        <div className="text-xs">Logged in as:</div>
        <div className="text-lg font-bold">{userId.toUpperCase()}</div>
      </div>

      {/* Hero Section */}
      <section className="relative min-h-screen flex items-center justify-center px-4 z-10">
        <motion.div 
          className="text-center max-w-2xl"
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8 }}
        >
          <motion.h1 
            className="text-5xl md:text-7xl font-serif mb-6 text-white drop-shadow-2xl"
            animate={{
              scale: [1, 1.02, 1],
            }}
            transition={{
              repeat: Infinity,
              duration: 4,
              ease: "easeInOut",
            }}
          >
            Our Secret Love Space
          </motion.h1>
          <motion.p 
            className="mb-10 text-xl md:text-2xl text-white/90 font-light"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.3 }}
          >
            A place where our hearts connect, no matter the distance 💕
          </motion.p>
          <motion.div
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ delay: 0.5 }}
            className="flex flex-col sm:flex-row gap-4 justify-center items-center"
          >
            <Button 
              size="lg" 
              onClick={showLoveMessage}
              className="text-lg px-8 py-6 bg-white/20 hover:bg-white/30 text-white backdrop-blur-xl border border-white/30 shadow-2xl"
            >
              Send a Love Message 💖
            </Button>
            <Button 
              size="lg" 
              onClick={() => {
                console.log('🧪 Testing all notification systems...');
                // Test simple notifications
                if (window.showSimpleNotification) {
                  window.showSimpleNotification('🧪 Test Notification', 'All systems working!');
                }
                // Test final notification function
                if ((window as any).testFinalNotification) {
                  (window as any).testFinalNotification();
                }
              }}
              className="text-lg px-8 py-6 bg-green-500/20 hover:bg-green-500/30 text-white backdrop-blur-xl border border-green-400/30 shadow-2xl"
            >
              Test Notifications 🧪
            </Button>
          </motion.div>
        </motion.div>
      </section>

      {/* Quick Ping Section - Main Feature */}
      <section className="relative z-10 py-16">
        <QuickPing userId={userId} />
      </section>

      {/* Dynamic Moments Section */}
      <DynamicMoments userId={userId} />

      {/* Letters Section */}
      <LettersSection />
      
      {/* Hidden Hugs */}
      <HiddenHugs />

      {/* Footer */}
      <footer className="relative z-10 py-12 text-center">
        <motion.div
          initial={{ opacity: 0 }}
          whileInView={{ opacity: 1 }}
          viewport={{ once: true }}
          className="space-y-2"
        >
          <p className="text-white/90 text-lg font-light">
            Made with infinite love 💕
          </p>
          <p className="text-white/60 text-sm">
            For the two hearts that beat as one
          </p>
        </motion.div>
      </footer>
    </div>
  );
} 
 