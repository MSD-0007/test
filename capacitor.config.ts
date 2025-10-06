import type { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'com.secretlove.app',
  appName: 'Secret Love',
  webDir: 'out',
  server: {
    androidScheme: 'http',  // Use HTTP to allow insecure WebSocket connections for testing
    cleartext: true,         // Allow cleartext (HTTP) traffic
    allowNavigation: [
      'http://10.195.33.185:3001',
      'ws://10.195.33.185:3001',
      'localhost:3001',
      '127.0.0.1:3001'
    ]
  },
  android: {
    allowMixedContent: true,
    captureInput: true,
    webContentsDebuggingEnabled: true,
    // Keep WebView alive in background
    backgroundColor: '#ffffff',
  },
  plugins: {
    SplashScreen: {
      launchShowDuration: 2000,
      backgroundColor: "#5865F2",
      androidSplashResourceName: "splash",
      androidScaleType: "CENTER_CROP",
      showSpinner: false,
      androidSpinnerStyle: "large",
      iosSpinnerStyle: "small",
      spinnerColor: "#ffffff",
      splashFullScreen: true,
      splashImmersive: true,
    },
    PushNotifications: {
      presentationOptions: ["badge", "sound", "alert"]
    },
    LocalNotifications: {
      smallIcon: "ic_stat_icon_config_sample",
      iconColor: "#FF69B4",
      sound: "default"
    }
  }
};

export default config;
