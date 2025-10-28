'use client';

import { useEffect } from 'react';

// FINAL NUCLEAR SOLUTION: Immediate notification setup
export default function NotificationManager() {
  useEffect(() => {
    console.log('💥 FINAL NUCLEAR: NotificationManager mounted');
    
    // Set up ping event listener
    const handlePing = (event: any) => {
      console.log('💥 FINAL NUCLEAR: Ping event received:', event.detail);
      if ((window as any).sendNotification) {
        (window as any).sendNotification(
          `💕 ${event.detail.from} sent a ping!`,
          event.detail.message || 'You received a message!'
        );
      }
    };
    
    // Set up notification function IMMEDIATELY
    const setupNotifications = () => {
      console.log('💥 FINAL NUCLEAR: Setting up notifications');
      
      // Create global notification function
      (window as any).sendNotification = (title: string, body: string) => {
        console.log('💥 FINAL NUCLEAR: sendNotification called:', { title, body });
        
        if ((window as any).Capacitor?.Plugins?.LocalNotifications) {
          console.log('💥 FINAL NUCLEAR: Using Capacitor LocalNotifications');
          
          (window as any).Capacitor.Plugins.LocalNotifications.schedule({
            notifications: [{
              title,
              body,
              id: Date.now() % 1000000 // Simple ID
            }]
          }).then(() => {
            console.log('💥 FINAL NUCLEAR: Notification sent!');
          }).catch((error: any) => {
            console.error('💥 FINAL NUCLEAR: Error:', error);
          });
        } else {
          console.error('💥 FINAL NUCLEAR: Capacitor LocalNotifications not found');
        }
      };
      
      window.addEventListener('new-ping', handlePing);
      console.log('💥 FINAL NUCLEAR: Event listener added');
      
      // Test function
      (window as any).testFinalNotification = () => {
        console.log('💥 FINAL NUCLEAR: Test function called');
        (window as any).sendNotification('💥 FINAL TEST', 'This is the final nuclear test!');
      };
      
      console.log('💥 FINAL NUCLEAR: Setup complete');
    };
    
    // Run setup immediately and also after a delay
    setupNotifications();
    setTimeout(setupNotifications, 1000);
    setTimeout(setupNotifications, 3000);
    
    return () => {
      window.removeEventListener('new-ping', handlePing);
    };
  }, []);
  
  return null; // This component renders nothing
}