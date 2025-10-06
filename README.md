# 💕 Secret Love - Real-Time Messaging App

A private couple's app with instant real-time messaging, built as a progressive web app and native Android mobile app.

## ✨ Features

- 🔒 **Password Protected** - Shared password authentication
- ⚡ **Real-Time Messaging** - Socket.IO for instant ping delivery (< 1 second)
- 📱 **Android Mobile App** - Native app via Capacitor
- 🔔 **Push Notifications** - OneSignal integration for offline notifications
- � **Background Notifications** - Local notifications work even when app is closed
- 📳 **Smart Vibrations** - Different vibration patterns for each ping type:
  - 💭 **Thinking of You**: Light single vibration
  - 💔 **Miss You**: Medium double vibration
  - 💕 **Love You**: Heavy triple vibration (strong)
  - 🆘 **Need You**: Heavy triple vibration (urgent)
- �💭 **Quick Pings** - Pre-defined messages with emojis
- 🎨 **Beautiful UI** - Ghibli-inspired design with animations
- 🔥 **Firebase Backend** - Firestore database + Authentication

## 🚀 Quick Start

### Prerequisites
- Node.js 18+ installed
- Android Studio (for mobile app)
- Git installed

### Local Development

**1. Install Dependencies**
```bash
# Install web app dependencies
npm install

# Install server dependencies
npm run server:install
```

**2. Configure Environment Variables**
```bash
# Copy .env.example to .env.local
cp .env.example .env.local

# Edit .env.local with your Firebase and OneSignal credentials
# Update NEXT_PUBLIC_SOCKET_URL with your local IP (e.g., http://192.168.1.x:3001)
```

**3. Start Development Servers**

Terminal 1 - Socket.IO Server:
```bash
npm run server:dev
```

Terminal 2 - Next.js Web App:
```bash
npm run dev
```

**4. Access the App**
- Web: http://localhost:3002
- Mobile: Build and install APK (see Mobile App section below)

### Mobile App (Android)
```bash
# Build web app
npm run build

# Sync to Android
npx cap sync android

# Install on connected phone
cd android
.\gradlew installDebug
```

## 📱 Current Setup

### Server
- **Socket.IO Server**: Port 3001
- **IP Address**: 10.195.33.185 (update if changed)
- **OneSignal**: Configured for push notifications

### Mobile App
- **Package**: com.secretlove.app
- **Users**: ak / ndg
- **Password**: speciallove2024

### Environment Variables
See `.env.local` for configuration:
- Firebase credentials
- OneSignal App ID
- Socket.IO server URL

## 🔧 Tech Stack

- **Frontend**: Next.js 14, React, TypeScript
- **Styling**: Tailwind CSS, Framer Motion
- **Real-Time**: Socket.IO
- **Push Notifications**: OneSignal
- **Database**: Firebase Firestore
- **Auth**: Firebase Authentication
- **Mobile**: Capacitor 7
- **Build**: Gradle (Android)

## 📖 Documentation

- **[QUICKSTART.md](QUICKSTART.md)** - Detailed setup instructions
- **[TESTING_GUIDE.md](TESTING_GUIDE.md)** - How to test the app
- **[REMOTE_DEBUGGING.md](REMOTE_DEBUGGING.md)** - Chrome DevTools debugging
- **[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)** - Deploy server to production
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Common issues and fixes
- **[FINAL_STATUS.md](FINAL_STATUS.md)** - Complete feature summary

## 🎯 How It Works

### Real-Time Messaging
1. **Both Online**: Socket.IO WebSocket connection (50-200ms delivery)
2. **One Offline**: OneSignal push notification (1-3 seconds)
3. **Background Mode**: Local notifications appear in notification drawer
4. **Auto-Reconnect**: Automatic reconnection on network issues

### Vibration Patterns
Different vibration patterns help you know the urgency without looking at your phone:

| Ping Type | Pattern | Duration | Feel |
|-----------|---------|----------|------|
| 💭 Thinking of You | Single | 100ms | Quick tap |
| 💔 Miss You | Double | 200ms-100ms-200ms | Two gentle pulses |
| 💕 Love You | Triple | 300ms-100ms-300ms-100ms-300ms | Three strong pulses |
| 🆘 Need You | Triple URGENT | 500ms-100ms-500ms-100ms-500ms | Three LONG strong pulses |

**Technical**: Uses Web Vibration API for custom patterns (Android native support)

### Architecture
```
Phone A (ak)  →  Socket.IO Server  →  Phone B (ndg)
     ↓                   ↓                    ↓
  Browser         OneSignal API         Browser
     ↓                                       ↓
Local Notifications (Background)    Local Notifications
```

## 🔐 Security

- Password-protected authentication
- Firebase security rules
- HTTPS in production (HTTP for local development)
- Environment variables for secrets

## 📊 Performance

- **Connection Time**: < 1 second
- **Message Delivery (online)**: 50-200ms
- **Push Notification**: 1-3 seconds
- **App Size**: ~10MB APK

## 🚧 Development

### Running Locally

1. **Start Socket.IO Server**:
   ```bash
   cd realtime-server
   npm start
   # Or from root: npm run server:dev
   ```

2. **Start Web App**:
   ```bash
   npm run dev
   ```

3. **Test on Phone**:
   - Connect phone and laptop to same WiFi
   - Get your IP: `ipconfig` (Windows) or `ifconfig` (Mac/Linux)
   - Update `.env.local`: `NEXT_PUBLIC_SOCKET_URL=http://YOUR_IP:3001`
   - Rebuild and install APK

### Building for Production

**Option 1: Deploy to Render.com (Recommended)**

1. **Push to GitHub**:
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
   git push -u origin main
   ```

2. **Deploy Server to Render**:
   - Go to [render.com](https://render.com)
   - Click "New +" → "Web Service"
   - Connect your GitHub repository
   - Settings:
     - **Name**: special-love-server
     - **Root Directory**: `realtime-server`
     - **Build Command**: `npm install`
     - **Start Command**: `npm start`
   - Add Environment Variables:
     - `ONESIGNAL_APP_ID`: Your OneSignal App ID
     - `ONESIGNAL_API_KEY`: Your OneSignal API Key
     - `PORT`: 3001 (auto-set by Render)
   - Click "Create Web Service"
   - Copy your Render URL (e.g., `https://special-love-server.onrender.com`)

3. **Update Web App Environment**:
   ```bash
   # Update .env.local
   NEXT_PUBLIC_SOCKET_URL=https://your-render-app.onrender.com
   ```

4. **Update Mobile App**:
   ```bash
   # Rebuild with production server URL
   npm run build
   npx cap sync android
   cd android
   .\gradlew assembleRelease  # For signed release
   ```

**Option 2: Self-Host Server**
- Deploy server on any VPS (AWS, DigitalOcean, etc.)
- Ensure port 3001 is open
- Use PM2 or systemd to keep server running
- Update `NEXT_PUBLIC_SOCKET_URL` to your server URL

## 🆘 Troubleshooting

### Common Issues

**Socket Connection Failed**:
- Check if server is running on port 3001
- Verify IP address hasn't changed
- Allow Node.js through Windows Firewall

**Push Notifications Not Working**:
- Check OneSignal dashboard
- Verify App ID in `.env.local`
- Ensure notifications enabled on phone

**APK Installation Failed**:
- Enable USB debugging
- Allow installation from unknown sources
- Check device connection: `adb devices`

See **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** for detailed solutions.

## 📝 License

Private project - Not for public distribution

## 💝 Built With Love

Created for a special couple to stay connected in real-time! ✨

---

**Last Updated**: October 6, 2025
**Status**: ✅ Fully Operational
**Version**: 1.0.0
