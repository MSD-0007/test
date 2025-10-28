import { Capacitor } from '@capacitor/core';

// OneSignal App ID - get this from OneSignal dashboard
const ONESIGNAL_APP_ID = process.env.NEXT_PUBLIC_ONESIGNAL_APP_ID || '';

// Declare OneSignal global (from Cordova plugin)
declare global {
  interface Window {
    plugins?: {
      OneSignal?: any;
    };
  }
}

/**
 * Initialize OneSignal for push notifications (Capacitor/Cordova)
 */
export const initializeOneSignal = async (userId: string): Promise<string | null> => {
  if (!ONESIGNAL_APP_ID) {
    console.warn('⚠️ OneSignal App ID not configured');
    return null;
  }

  // Only initialize on native platforms
  if (!Capacitor.isNativePlatform()) {
    console.log('⚠️ OneSignal only works on native platforms');
    return null;
  }

  return new Promise((resolve) => {
    try {
      console.log('🔔 Initializing OneSignal...');
      
      const OneSignal = window.plugins?.OneSignal;
      if (!OneSignal) {
        console.error('❌ OneSignal plugin not found');
        resolve(null);
        return;
      }

      // Initialize OneSignal with setAppId method
      if (typeof OneSignal.setAppId === 'function') {
        OneSignal.setAppId(ONESIGNAL_APP_ID);
      } else if (typeof OneSignal.startInit === 'function') {
        // Older API version
        OneSignal.startInit(ONESIGNAL_APP_ID);
        OneSignal.endInit();
      } else {
        console.error('❌ OneSignal API not recognized');
        resolve(null);
        return;
      }

      // Set external user ID for targeting
      if (typeof OneSignal.setExternalUserId === 'function') {
        OneSignal.setExternalUserId(userId);
      }

      // Get player ID
      if (typeof OneSignal.getDeviceState === 'function') {
        OneSignal.getDeviceState((state: any) => {
          const playerId = state?.userId;
          console.log('✅ OneSignal initialized. Player ID:', playerId);
          resolve(playerId || null);
        });
      } else {
        console.log('✅ OneSignal initialized (player ID not available)');
        resolve(null);
      }

      // Prompt for permission
      if (typeof OneSignal.promptForPushNotificationsWithUserResponse === 'function') {
        OneSignal.promptForPushNotificationsWithUserResponse((accepted: boolean) => {
          console.log(accepted ? '✅ Push permission granted' : '⚠️ Push permission denied');
        });
      }

    } catch (error) {
      console.error('❌ Error initializing OneSignal:', error);
      resolve(null);
    }
  });
};

/**
 * Handle notification received
 */
export const onNotificationReceived = (callback: (data: any) => void) => {
  if (!Capacitor.isNativePlatform()) return;

  const OneSignal = window.plugins?.OneSignal;
  if (!OneSignal) return;

  try {
    if (typeof OneSignal.setNotificationWillShowInForegroundHandler === 'function') {
      OneSignal.setNotificationWillShowInForegroundHandler((notification: any) => {
        console.log('🔔 Notification received:', notification);
        callback(notification);
      });
    } else {
      console.warn('⚠️ setNotificationWillShowInForegroundHandler not available');
    }
  } catch (error) {
    console.warn('⚠️ Could not set notification received handler:', error);
  }
};

/**
 * Handle notification click
 */
export const onNotificationClick = (callback: (data: any) => void) => {
  if (!Capacitor.isNativePlatform()) return;

  const OneSignal = window.plugins?.OneSignal;
  if (!OneSignal) return;

  try {
    // Use newer API first
    if (typeof OneSignal.setNotificationClickHandler === 'function') {
      OneSignal.setNotificationClickHandler((openedEvent: any) => {
        console.log('👆 Notification clicked (new API):', openedEvent);
        callback(openedEvent.notification);
      });
    } else if (typeof OneSignal.setNotificationOpenedHandler === 'function') {
      // Fallback to older API
      OneSignal.setNotificationOpenedHandler((openedEvent: any) => {
        console.log('👆 Notification clicked (legacy API):', openedEvent);
        callback(openedEvent.notification);
      });
    } else {
      console.warn('⚠️ No notification click handler available in this OneSignal version');
    }
  } catch (error) {
    console.warn('⚠️ Could not set notification click handler:', error);
  }
};
