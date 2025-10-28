/**
 * Firebase Cloud Function: Send Push Notification on New Ping
 * 
 * READY TO PASTE INTO FIREBASE CONSOLE!
 * 
 * Instructions:
 * 1. Go to Firebase Console → Functions
 * 2. Click "Create Function"
 * 3. Name: sendPingNotification
 * 4. Trigger: Cloud Firestore
 * 5. Event: Document Create
 * 6. Document path: pings/{pingId}
 * 7. Runtime: Node.js 20
 * 8. Paste this entire code
 * 9. Click Deploy
 */

const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.sendPingNotification = functions.firestore
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
          priority: 'high',
          notification: {
            sound: 'default',
            channelId: 'ping_notifications',
            priority: 'high',
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
