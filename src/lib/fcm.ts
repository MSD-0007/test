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
    console.log('📱 Platform:', Capacitor.getPlatform());
    console.log('📱 Is Native Platform:', Capacitor.isNativePlatform());

    // Check if PushNotifications is available
    if (!PushNotifications) {
      console.error('❌ PushNotifications plugin not available');
      return;
    }

    // Request permission
    console.log('🔔 Requesting push notification permissions...');
    const permStatus = await PushNotifications.requestPermissions();
    console.log('🔔 Push permission status:', JSON.stringify(permStatus, null, 2));

    if (permStatus.receive === 'granted') {
      console.log('✅ Permission granted, registering for push notifications...');

      // Register for push notifications
      await PushNotifications.register();
      console.log('✅ Registered for push notifications');

      // Get FCM token
      PushNotifications.addListener('registration', async (token) => {
        console.log('✅ FCM Token obtained:', token.value);
        console.log('💾 Saving FCM token to Firestore...');
        await saveFCMToken(userId, token.value);
      });

      // Handle errors
      PushNotifications.addListener('registrationError', (error) => {
        console.error('❌ Error registering for push:', JSON.stringify(error, null, 2));
      });

      // Handle notification received (foreground)
      PushNotifications.addListener('pushNotificationReceived', (notification) => {
        console.log('📨 Push notification received (foreground):', JSON.stringify(notification, null, 2));
        handleNativeForegroundNotification(notification);
      });

      // Handle notification tap (when user taps notification)
      PushNotifications.addListener('pushNotificationActionPerformed', (notification) => {
        console.log('👆 Push notification tapped:', JSON.stringify(notification, null, 2));
        // You can navigate to specific ping or open app
      });
    } else {
      console.warn('⚠️ Push notification permission not granted:', permStatus);
      console.warn('⚠️ Permission receive status:', permStatus.receive);
    }
  } catch (error) {
    console.error('❌ Error initializing Native FCM:', error);
    console.error('❌ Error details:', JSON.stringify(error, null, 2));
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
const handleNativeForegroundNotification = async (notification: any) => {
  console.log('📨 Handling native foreground notification:', notification);

  // Show a local notification for testing
  if (Capacitor.isNativePlatform()) {
    try {
      const { LocalNotifications } = await import('@capacitor/local-notifications');
      await LocalNotifications.schedule({
        notifications: [
          {
            title: notification.title || 'New Ping!',
            body: notification.body || 'You received a new message',
            id: Math.floor(Math.random() * 100000), // Use proper integer ID
            sound: 'default',
            attachments: undefined,
            actionTypeId: '',
            extra: notification.data
          }
        ]
      });
      console.log('✅ Local notification scheduled');
    } catch (error) {
      console.error('❌ Error scheduling local notification:', error);
    }
  }

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
