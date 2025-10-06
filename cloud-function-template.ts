import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();

// Trigger when a new ping is created
export const sendPingNotification = functions.firestore
  .document('pings/{pingId}')
  .onCreate(async (snap, context) => {
    const pingData = snap.data();
    
    console.log('📨 New ping detected:', pingData);
    
    const { to, from, message, emoji, type } = pingData;
    
    try {
      // Get recipient's FCM token from Firestore
      const userDoc = await admin.firestore()
        .collection('users')
        .doc(to)
        .get();
      
      if (!userDoc.exists) {
        console.log('❌ Recipient user document not found');
        return null;
      }
      
      const fcmToken = userDoc.data()?.fcmToken;
      
      if (!fcmToken) {
        console.log('❌ No FCM token found for recipient');
        return null;
      }
      
      console.log('✅ Found FCM token for recipient:', to);
      
      // Determine sender name
      const senderName = from === 'ndg' ? 'Him' : 'Her';
      
      // Send FCM notification
      const notification = {
        token: fcmToken,
        notification: {
          title: `${emoji} New Ping from ${senderName}!`,
          body: message,
        },
        data: {
          type: type,
          from: from,
          to: to,
          pingId: context.params.pingId,
          timestamp: Date.now().toString()
        },
        android: {
          priority: 'high' as const,
          notification: {
            sound: 'default',
            channelId: 'ping_notifications',
            priority: 'high' as const,
            vibrationPattern: [0, 250, 250, 250],
            lightSettings: {
              color: '#FF69B4',
              lightOnDuration: '200',
              lightOffDuration: '200'
            }
          }
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1
            }
          }
        }
      };
      
      const response = await admin.messaging().send(notification);
      console.log('✅ Notification sent successfully:', response);
      
      return response;
    } catch (error) {
      console.error('❌ Error sending notification:', error);
      return null;
    }
  });
