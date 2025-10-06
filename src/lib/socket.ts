import { io, Socket } from 'socket.io-client';
import { Capacitor } from '@capacitor/core';

// Socket.IO client instance
let socket: Socket | null = null;

// Smart Server URL detection:
// - In browser (localhost/127.0.0.1): use localhost
// - On mobile app (Capacitor): use computer's IP address
const getSocketServerUrl = () => {
  const configuredUrl = process.env.NEXT_PUBLIC_SOCKET_URL;
  
  // Check if running on native mobile platform (Capacitor)
  if (Capacitor.isNativePlatform()) {
    console.log('📱 Running on native platform, using configured URL:', configuredUrl);
    return configuredUrl || 'http://localhost:3001';
  }
  
  // Running in web browser - use localhost
  console.log('🌐 Running in browser, using localhost');
  return 'http://localhost:3001';
};

/**
 * Initialize Socket.IO connection
 */
export const initializeSocket = (userId: string, oneSignalPlayerId?: string) => {
  if (socket?.connected) {
    console.log('Socket already connected');
    return socket;
  }

  const serverUrl = getSocketServerUrl();
  console.log('🔌 Connecting to Socket.IO server:', serverUrl);
  
  socket = io(serverUrl, {
    transports: ['websocket', 'polling'],
    reconnection: true,
    reconnectionAttempts: Infinity, // Keep trying to reconnect
    reconnectionDelay: 1000,
    reconnectionDelayMax: 5000,
    timeout: 20000,
    forceNew: false,
    autoConnect: true,
  });

  socket.on('connect', () => {
    console.log('✅ Connected to Socket.IO server:', socket?.id);
    
    // Login with userId and optional OneSignal player ID
    socket?.emit('login', { userId, playerId: oneSignalPlayerId });
  });

  socket.on('disconnect', (reason) => {
    console.log('❌ Disconnected from Socket.IO server. Reason:', reason);
    
    // Auto-reconnect if not intentional disconnect
    if (reason === 'io server disconnect') {
      // Server disconnected, manually reconnect
      socket?.connect();
    }
  });

  socket.on('reconnect', (attemptNumber) => {
    console.log('🔄 Reconnected to server after', attemptNumber, 'attempts');
    // Re-login after reconnection
    socket?.emit('login', { userId, playerId: oneSignalPlayerId });
  });

  socket.on('connect_error', (error: Error) => {
    console.error('❌ Socket connection error:', error.message);
  });

  return socket;
};

/**
 * Send a ping to another user
 */
export const sendPing = (to: string, from: string, message: string, type?: string) => {
  if (!socket?.connected) {
    console.error('❌ Socket not connected. Cannot send ping.');
    return false;
  }

  socket.emit('ping', { to, from, message, type: type || 'ping' });
  console.log(`⚡ Ping sent to ${to}`);
  return true;
};

/**
 * Listen for incoming pings
 */
export const onPingReceived = (callback: (data: any) => void) => {
  if (!socket) {
    console.error('❌ Socket not initialized');
    return;
  }

  socket.on('ping', callback);
};

/**
 * Remove ping listener
 */
export const removePingListener = () => {
  if (!socket) return;
  socket.off('ping');
};

/**
 * Disconnect socket
 */
export const disconnectSocket = () => {
  if (socket) {
    socket.disconnect();
    socket = null;
    console.log('🔌 Socket disconnected');
  }
};

/**
 * Get current socket instance
 */
export const getSocket = () => socket;
