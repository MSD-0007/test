import express from 'express';
import http from 'http';
import { Server } from 'socket.io';
import cors from 'cors';
import OneSignal from 'onesignal-node';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST']
  }
});

app.use(cors());
app.use(express.json());

// OneSignal Configuration (set these via environment variables)
const ONESIGNAL_APP_ID = process.env.ONESIGNAL_APP_ID || '';
const ONESIGNAL_API_KEY = process.env.ONESIGNAL_API_KEY || '';

let oneSignalClient = null;
if (ONESIGNAL_APP_ID && ONESIGNAL_API_KEY) {
  oneSignalClient = new OneSignal.Client(ONESIGNAL_APP_ID, ONESIGNAL_API_KEY);
  console.log('✅ OneSignal initialized');
} else {
  console.warn('⚠️ OneSignal not configured. Set ONESIGNAL_APP_ID and ONESIGNAL_API_KEY');
}

// In-memory user socket map and OneSignal player IDs
const users = {};
const playerIds = {}; // Maps userId to OneSignal player ID

// Helper: Send push notification via OneSignal
async function sendPushNotification(to, from, message) {
  if (!oneSignalClient) {
    console.log('⚠️ OneSignal not configured, skipping push notification');
    return;
  }

  const playerId = playerIds[to];
  if (!playerId) {
    console.log(`⚠️ No OneSignal player ID for user ${to}`);
    return;
  }

  try {
    const notification = {
      contents: { en: message },
      headings: { en: `💕 ${from} sent you a ping!` },
      include_player_ids: [playerId],
      data: { from, message, timestamp: Date.now() }
    };

    await oneSignalClient.createNotification(notification);
    console.log(`✅ Push notification sent to ${to}`);
  } catch (error) {
    console.error('❌ Error sending push notification:', error.message);
  }
}

// --- Socket.IO Events ---
io.on('connection', (socket) => {
  console.log('✅ User connected:', socket.id);

  // User login with optional OneSignal player ID
  socket.on('login', ({ userId, playerId }) => {
    users[userId] = socket.id;
    if (playerId) {
      playerIds[userId] = playerId;
      console.log(`✅ ${userId} logged in with socket ${socket.id} and OneSignal player ${playerId}`);
    } else {
      console.log(`✅ ${userId} logged in with socket ${socket.id}`);
    }
  });

  // Real-time ping with push fallback
  socket.on('ping', async (data) => {
    const { to, from, message, type } = data;
    const recipientSocket = users[to];
    
    if (recipientSocket) {
      // User is online, deliver instantly via Socket.IO
      io.to(recipientSocket).emit('ping', { 
        from, 
        to, 
        message, 
        type: type || 'ping',
        timestamp: Date.now() 
      });
      console.log(`⚡ Ping delivered instantly to ${to} (online)`);
    } else {
      // User is offline, send push notification
      console.log(`📱 User ${to} offline, sending push notification`);
      await sendPushNotification(to, from, message);
    }
  });

  socket.on('disconnect', () => {
    // Remove user from online list
    for (const [userId, sockId] of Object.entries(users)) {
      if (sockId === socket.id) {
        delete users[userId];
        console.log(`👋 ${userId} disconnected`);
        break;
      }
    }
  });
});

app.get('/', (req, res) => {
  res.send('Special Love Realtime Server is running!');
});

const PORT = process.env.PORT || 3001;
server.listen(PORT, () => {
  console.log(`Realtime server listening on port ${PORT}`);
});
