'use client';

import { db } from './firebase';
import { collection, addDoc, query, where, orderBy, limit, onSnapshot, updateDoc, doc, serverTimestamp, getDocs, Timestamp } from 'firebase/firestore';

export interface SimplePing {
  id?: string;
  from: string;
  to: string;
  message: string;
  type: string;
  timestamp: any;
  delivered?: boolean;
}

/**
 * Send a ping message via Firestore
 */
export const sendSimplePing = async (to: string, from: string, message: string, type: string = 'ping'): Promise<boolean> => {
  try {
    console.log('📨 Sending simple ping via Firestore:', { to, from, type });
    
    const pingData: SimplePing = {
      from,
      to,
      message,
      type,
      timestamp: serverTimestamp(),
      delivered: false
    };

    await addDoc(collection(db, 'pings'), pingData);
    
    console.log('✅ Simple ping sent successfully via Firestore');
    return true;
  } catch (error) {
    console.error('❌ Error sending simple ping:', error);
    return false;
  }
};

/**
 * Listen for incoming pings via Firestore (only new pings)
 */
export const listenForSimplePings = (userId: string, callback: (ping: SimplePing) => void) => {
  console.log('👂 Listening for simple pings for user:', userId);
  
  // Track when we start listening to avoid processing old pings
  const startTime = Date.now();
  
  // Simplified query - only filter by 'to' field to avoid index requirement
  const q = query(
    collection(db, 'pings'),
    where('to', '==', userId),
    limit(10)
  );
  
  const unsubscribe = onSnapshot(q, (snapshot) => {
    snapshot.docChanges().forEach(async (change) => {
      if (change.type === 'added') {
        const ping = { id: change.doc.id, ...change.doc.data() } as SimplePing;
        
        // Only process pings that are:
        // 1. Not delivered yet
        // 2. Created after we started listening (to avoid old pings)
        const pingTime = ping.timestamp?.toMillis ? ping.timestamp.toMillis() : 0;
        const isNewPing = pingTime > startTime - 5000; // 5 second buffer for timing issues
        
        if (!ping.delivered && isNewPing) {
          console.log('📨 New simple ping received:', ping);
          
          // Mark as delivered
          try {
            await updateDoc(doc(db, 'pings', ping.id!), { delivered: true });
          } catch (error) {
            console.error('Error marking ping as delivered:', error);
          }
          
          // Call the callback
          callback(ping);
        } else if (!isNewPing) {
          console.log('🔇 Ignoring old ping from:', ping.from, 'sent at:', new Date(pingTime));
        }
      }
    });
  });
  
  return unsubscribe;
};

/**
 * Fallback: Poll for pings (simplified - no index needed)
 */
export const pollForPings = async (userId: string): Promise<SimplePing[]> => {
  try {
    const q = query(
      collection(db, 'pings'),
      where('to', '==', userId),
      limit(10)
    );
    
    const snapshot = await getDocs(q);
    const pings: SimplePing[] = [];
    
    snapshot.forEach(async (docSnap) => {
      const ping = { id: docSnap.id, ...docSnap.data() } as SimplePing;
      
      // Only return undelivered pings
      if (!ping.delivered) {
        pings.push(ping);
        
        // Mark as delivered
        try {
          await updateDoc(doc(db, 'pings', ping.id!), { delivered: true });
        } catch (error) {
          console.error('Error marking ping as delivered:', error);
        }
      }
    });
    
    return pings;
  } catch (error) {
    console.error('❌ Error polling for pings:', error);
    return [];
  }
};

/**
 * Start polling for pings (reliable fallback for Android)
 */
export const startPingPolling = (userId: string, callback: (ping: SimplePing) => void, intervalMs: number = 3000) => {
  console.log('🔄 Starting ping polling for user:', userId, 'every', intervalMs, 'ms');
  
  const poll = async () => {
    try {
      // Look for pings from the last 30 seconds
      const thirtySecondsAgo = Timestamp.fromMillis(Date.now() - 30000);
      
      const q = query(
        collection(db, 'pings'),
        where('to', '==', userId),
        where('delivered', '==', false),
        limit(5)
      );
      
      const snapshot = await getDocs(q);
      
      snapshot.forEach(async (docSnap) => {
        const ping = { id: docSnap.id, ...docSnap.data() } as SimplePing;
        
        // Check if ping is recent (within last 30 seconds)
        const pingTime = ping.timestamp?.toMillis ? ping.timestamp.toMillis() : 0;
        const isRecent = pingTime > (Date.now() - 30000);
        
        if (isRecent) {
          console.log('📨 Polling found new ping:', ping);
          
          // Mark as delivered
          try {
            await updateDoc(doc(db, 'pings', ping.id!), { delivered: true });
            callback(ping);
          } catch (error) {
            console.error('Error marking polled ping as delivered:', error);
          }
        }
      });
    } catch (error) {
      console.error('❌ Error in ping polling:', error);
    }
  };
  
  // Start polling
  const intervalId = setInterval(poll, intervalMs);
  
  // Return cleanup function
  return () => {
    console.log('🛑 Stopping ping polling');
    clearInterval(intervalId);
  };
};