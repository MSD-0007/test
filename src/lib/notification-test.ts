'use client';

import { Capacitor } from '@capacitor/core';
import { PushNotifications } from '@capacitor/push-notifications';
import { LocalNotifications } from '@capacitor/local-notifications';

export const testNotifications = async () => {
  console.log('🧪 Testing notifications...');
  console.log('📱 Platform:', Capacitor.getPlatform());
  console.log('📱 Is Native Platform:', Capacitor.isNativePlatform());

  if (Capacitor.isNativePlatform()) {
    try {
      // Test local notifications first
      console.log('🔔 Testing local notifications...');
      
      const localPermissions = await LocalNotifications.requestPermissions();
      console.log('🔔 Local notification permissions:', localPermissions);
      
      if (localPermissions.display === 'granted') {
        try {
          await LocalNotifications.schedule({
            notifications: [
              {
                title: 'Test Local Notification',
                body: 'This is a test local notification',
                id: 12345, // Use a simple integer ID
                sound: 'default',
                attachments: undefined,
                actionTypeId: '',
                extra: { test: true }
              }
            ]
          });
          console.log('✅ Local notification scheduled');
        } catch (error) {
          console.error('❌ Error scheduling local notification:', error);
        }
      }

      // Test push notifications
      console.log('🔔 Testing push notifications...');
      
      const pushPermissions = await PushNotifications.requestPermissions();
      console.log('🔔 Push notification permissions:', pushPermissions);
      
      if (pushPermissions.receive === 'granted') {
        await PushNotifications.register();
        console.log('✅ Registered for push notifications');
      }
      
    } catch (error) {
      console.error('❌ Error testing notifications:', error);
    }
  } else {
    // Test web notifications
    console.log('🌐 Testing web notifications...');
    
    const permission = await Notification.requestPermission();
    console.log('🔔 Web notification permission:', permission);
    
    if (permission === 'granted') {
      new Notification('Test Web Notification', {
        body: 'This is a test web notification',
        icon: '/images/heart-icon.png'
      });
      console.log('✅ Web notification shown');
    }
  }
};

// Add to window for easy testing in console
if (typeof window !== 'undefined') {
  (window as any).testNotifications = testNotifications;
}