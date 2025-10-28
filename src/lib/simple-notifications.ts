'use client';

// NUCLEAR OPTION: Dead simple notification system
declare global {
  interface Window {
    showSimpleNotification: (title: string, body: string) => void;
    Capacitor: any;
  }
}

export const initSimpleNotifications = async () => {
  console.log('🚀 NUCLEAR: Initializing simple notifications');
  
  // Request permissions first on Capacitor
  if (typeof window !== 'undefined' && window.Capacitor && window.Capacitor.isNativePlatform()) {
    try {
      console.log('📱 NUCLEAR: Requesting LocalNotifications permissions...');
      const { LocalNotifications } = await import('@capacitor/local-notifications');
      
      const permissions = await LocalNotifications.requestPermissions();
      console.log('📱 NUCLEAR: LocalNotifications permissions:', permissions);
      
      if (permissions.display !== 'granted') {
        console.warn('⚠️ NUCLEAR: LocalNotifications permission denied');
      }
    } catch (error) {
      console.error('❌ NUCLEAR: Error requesting permissions:', error);
    }
  }
  
  // Create a global function that WILL work
  window.showSimpleNotification = async (title: string, body: string) => {
    console.log('🚀 NUCLEAR: showSimpleNotification called:', { title, body });
    
    if (typeof window !== 'undefined' && window.Capacitor && window.Capacitor.isNativePlatform()) {
      console.log('🚀 NUCLEAR: Capacitor native platform, using LocalNotifications');
      
      try {
        const { LocalNotifications } = await import('@capacitor/local-notifications');
        
        await LocalNotifications.schedule({
          notifications: [{
            title: title,
            body: body,
            id: Math.floor(Math.random() * 100000),
            sound: 'default',
            attachments: undefined,
            actionTypeId: '',
            extra: {}
          }]
        });
        
        console.log('🚀 NUCLEAR: Notification sent!');
      } catch (error) {
        console.error('🚀 NUCLEAR: Notification failed:', error);
      }
    } else {
      console.log('🚀 NUCLEAR: Not on native platform, using web notification');
      if ('Notification' in window) {
        if (Notification.permission === 'granted') {
          new Notification(title, { body });
          console.log('🚀 NUCLEAR: Web notification sent!');
        } else if (Notification.permission === 'default') {
          const permission = await Notification.requestPermission();
          if (permission === 'granted') {
            new Notification(title, { body });
            console.log('🚀 NUCLEAR: Web notification sent after permission!');
          }
        }
      }
    }
  };
  
  console.log('🚀 NUCLEAR: Global function created');
};

// Test function
export const testSimpleNotification = () => {
  if (window.showSimpleNotification) {
    window.showSimpleNotification('🚀 NUCLEAR TEST', 'This is a nuclear test notification!');
  } else {
    console.error('🚀 NUCLEAR: showSimpleNotification not found');
  }
};

// Final test function for console
export const testFinalNotification = () => {
  console.log('🚀 FINAL NUCLEAR TEST!');
  if (window.showSimpleNotification) {
    window.showSimpleNotification('🚀 FINAL NUCLEAR TEST!', 'This is the final nuclear test notification!');
  } else {
    console.error('🚀 NUCLEAR: showSimpleNotification not found');
  }
};

// Add to window for console access
if (typeof window !== 'undefined') {
  (window as any).testFinalNotification = testFinalNotification;
}