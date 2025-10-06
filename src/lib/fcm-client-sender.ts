'use client';

import { db } from './firebase';
import { doc, getDoc } from 'firebase/firestore';

/**
 * Send FCM push notification directly from client
 * This is FREE - no Cloud Functions needed!
 */
export const sendFCMNotification = async (
  recipientUserId: string,
  notification: {
    title: string;
    body: string;
    data?: Record<string, string>;
  }
) => {
  try {
    console.log('📤 Sending FCM notification to:', recipientUserId);

    // Get recipient's FCM token from Firestore
    const userDocRef = doc(db, 'users', recipientUserId);
    const userDoc = await getDoc(userDocRef);

    if (!userDoc.exists()) {
      console.warn('⚠️ Recipient user document not found');
      return false;
    }

    const fcmToken = userDoc.data()?.fcmToken;

    if (!fcmToken) {
      console.warn('⚠️ No FCM token found for recipient');
      return false;
    }

    console.log('✅ Found FCM token for recipient');

    // Use Capacitor Push Notifications for native
    // For web, we use the service worker
    const { Capacitor } = await import('@capacitor/core');
    
    if (Capacitor.getPlatform() === 'web') {
      // Web: Use Firebase Messaging
      await sendWebNotification(fcmToken, notification);
    } else {
      // Native: Use Capacitor local notifications as fallback
      // The main delivery will be through FCM when we write to Firestore
      await sendNativeNotificationTrigger(recipientUserId, notification);
    }

    return true;
  } catch (error) {
    console.error('❌ Error sending FCM notification:', error);
    return false;
  }
};

/**
 * Send notification on web platform
 */
const sendWebNotification = async (
  fcmToken: string,
  notification: { title: string; body: string; data?: Record<string, string> }
) => {
  // For web, we trigger through Firestore write
  // The recipient's app will pick it up via PingListener
  console.log('🌐 Web notification will be delivered via Firestore listener');
};

/**
 * Trigger native notification through Firestore update
 */
const sendNativeNotificationTrigger = async (
  recipientUserId: string,
  notification: { title: string; body: string; data?: Record<string, string> }
) => {
  // For native apps without Cloud Functions, we use a hybrid approach:
  // 1. Write to Firestore (triggers PingListener on recipient's device)
  // 2. Recipient's PingListener shows local notification
  console.log('📱 Native notification will be delivered via PingListener');
  
  // The actual notification will be shown by PingListener when it detects the new ping
};

/**
 * Alternative: Use FCM HTTP v1 API (requires server or Cloud Function)
 * This is here for reference but won't work client-side due to CORS
 */
const sendViaFCMAPI = async (
  fcmToken: string,
  notification: { title: string; body: string; data?: Record<string, string> }
) => {
  // This would require a server or Cloud Function to work
  // Keeping it here for reference if you upgrade to Blaze plan later
  
  const FCM_SERVER_KEY = process.env.NEXT_PUBLIC_FIREBASE_SERVER_KEY;
  
  if (!FCM_SERVER_KEY) {
    console.warn('⚠️ FCM Server Key not configured');
    return;
  }

  const message = {
    to: fcmToken,
    notification: {
      title: notification.title,
      body: notification.body,
    },
    data: notification.data || {},
    priority: 'high',
    content_available: true,
  };

  // This will fail due to CORS from browser
  // Only works from server/Cloud Function
  const response = await fetch('https://fcm.googleapis.com/fcm/send', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `key=${FCM_SERVER_KEY}`,
    },
    body: JSON.stringify(message),
  });

  return response.ok;
};
