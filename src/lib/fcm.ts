'use client';

import { getMessaging, getToken, onMessage, isSupported } from 'firebase/messaging';
import { app, db } from './firebase';
import { doc, setDoc, serverTimestamp } from 'firebase/firestore';
import { PushNotifications } from '@capacitor/push-notifications';
import { Capacitor } from '@capacitor/core';

let messaging: any = null;

// Initialize FCM
export const initializeFCM = async (userId: string) => {
  console.log('🔔 Initializing FCM for user:', userId);
  
  const platform = Capacitor.getPlatform();
  console.log('📱 Platform:', platform);

  if (platform === 'web') {
    // Web FCM using Firebase Messaging
    await initializeWebFCM(userId);
  } else {
    // Native FCM using Capacitor Push Notifications
    await initializeNativeFCM(userId);
  }
};

// Web FCM Implementation
const initializeWebFCM = async (userId: string) => {
  try {
    const supported = await isSupported();
    if (!supported) {
      console.warn('⚠️ Firebase Messaging not supported in this browser');
      return;
    }

    messaging = getMessaging(app);
    
    // Request permission
    const permission = await Notification.requestPermission();
    console.log('🔔 Notification permission:', permission);

    if (permission === 'granted') {
      // Get FCM token
      const token = await getToken(messaging, {
        vapidKey: process.env.NEXT_PUBLIC_FIREBASE_VAPID_KEY
      });
      
      console.log('✅ FCM Token obtained:', token);
      
      // Save token to Firestore
      await saveFCMToken(userId, token);
      
      // Listen for foreground messages
      onMessage(messaging, (payload) => {
        console.log('📨 Foreground message received:', payload);
        handleForegroundMessage(payload);
      });
    }
  } catch (error) {
    console.error('❌ Error initializing Web FCM:', error);
  }
};

// Native (Android/iOS) FCM Implementation
const initializeNativeFCM = async (userId: string) => {
  try {
    console.log('📱 Initializing Native FCM...');

    // Request permission
    const permStatus = await PushNotifications.requestPermissions();
    console.log('🔔 Push permission status:', permStatus);

    if (permStatus.receive === 'granted') {
      // Register for push notifications
      await PushNotifications.register();
      console.log('✅ Registered for push notifications');

      // Get FCM token
      PushNotifications.addListener('registration', async (token) => {
        console.log('✅ FCM Token obtained:', token.value);
        await saveFCMToken(userId, token.value);
      });

      // Handle errors
      PushNotifications.addListener('registrationError', (error) => {
        console.error('❌ Error registering for push:', error);
      });

      // Handle notification received (foreground)
      PushNotifications.addListener('pushNotificationReceived', (notification) => {
        console.log('📨 Push notification received (foreground):', notification);
        handleNativeForegroundNotification(notification);
      });

      // Handle notification tap (when user taps notification)
      PushNotifications.addListener('pushNotificationActionPerformed', (notification) => {
        console.log('👆 Push notification tapped:', notification);
        // You can navigate to specific ping or open app
      });
    } else {
      console.warn('⚠️ Push notification permission not granted');
    }
  } catch (error) {
    console.error('❌ Error initializing Native FCM:', error);
  }
};

// Save FCM token to Firestore
const saveFCMToken = async (userId: string, token: string) => {
  try {
    await setDoc(doc(db, 'users', userId), {
      fcmToken: token,
      platform: Capacitor.getPlatform(),
      lastUpdated: serverTimestamp()
    }, { merge: true });
    
    console.log('✅ FCM token saved to Firestore for user:', userId);
  } catch (error) {
    console.error('❌ Error saving FCM token:', error);
  }
};

// Handle foreground message (Web)
const handleForegroundMessage = (payload: any) => {
  console.log('📨 Handling foreground message:', payload);
  
  const { notification, data } = payload;
  
  // Show browser notification
  if (notification) {
    new Notification(notification.title || 'New Ping!', {
      body: notification.body || 'You received a new message',
      icon: '/images/heart-icon.png',
      badge: '/images/heart-icon.png',
      data: data
    });
  }
  
  // Trigger custom event to update UI
  window.dispatchEvent(new CustomEvent('new-ping', { detail: data }));
};

// Handle native foreground notification
const handleNativeForegroundNotification = (notification: any) => {
  console.log('📨 Handling native foreground notification:', notification);
  
  // Trigger custom event to update UI
  window.dispatchEvent(new CustomEvent('new-ping', { 
    detail: notification.data 
  }));
};

// Clean up FCM token on logout
export const cleanupFCM = async (userId: string) => {
  try {
    await setDoc(doc(db, 'users', userId), {
      fcmToken: null,
      lastUpdated: serverTimestamp()
    }, { merge: true });
    
    console.log('✅ FCM token cleaned up for user:', userId);
  } catch (error) {
    console.error('❌ Error cleaning up FCM token:', error);
  }
};
