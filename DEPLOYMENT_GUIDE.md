# 🚀 Complete Deployment & Setup Guide

## Overview

This guide will walk you through:
1. **Git Setup** - Prepare project for GitHub
2. **Render Deployment** - Deploy Socket.IO server (FREE)
3. **Environment Configuration** - Update URLs for production
4. **Mobile App Build** - Build production Android APK

---

## Part 1: Git Setup (5 minutes)

### Prerequisites
- Git installed on your computer
- GitHub account created

### Step 1: Initialize Git Repository

```bash
cd d:\Project\Special

# Initialize git (if not already done)
git init

# Check what will be committed
git status
```

### Step 2: Create GitHub Repository

1. Go to https://github.com
2. Click **"+" → New repository**
3. Repository name: `special-love-app`
4. Set to **Private**
5. **DO NOT** initialize with README (we already have one)
6. Click **Create repository**

### Step 3: Push to GitHub

```bash
# Add all files
git add .

# Commit
git commit -m "Initial commit - Secret Love app with real-time messaging"

# Add remote (replace YOUR_USERNAME)
git remote add origin https://github.com/YOUR_USERNAME/special-love-app.git

# Push to GitHub
git push -u origin main
```

**⚠️ Important**: Your `.env` and `.env.local` files are automatically excluded via `.gitignore` - your secrets are safe!

---

## Part 2: Deploy Server to Render.com (10 minutes)

### Step 1: Create Render Account

1. Go to https://render.com/
2. Click **Get Started**
3. Sign up with GitHub (recommended) - this will auto-connect your repos

### Step 2: Create New Web Service

1. From Render Dashboard, click **New +** → **Web Service**
2. Connect your GitHub repository (authorize if prompted)
3. Select your `special-love-app` repository

### Step 3: Configure the Service

Fill in these settings:

**Basic Settings:**
- **Name**: `special-love-server` (or any unique name)
- **Region**: Choose closest to your location
- **Branch**: `main`
- **Root Directory**: `realtime-server`
- **Runtime**: `Node`
- **Build Command**: `npm install`
- **Start Command**: `npm start`

**Plan:**
- Select **Free** plan (0 USD/month)
- Note: Free tier spins down after 15 mins of inactivity (takes ~30s to wake up)

### Step 4: Set Environment Variables

Click **Advanced** → **Add Environment Variable**

Add these:

| Key | Value | Where to get it |
|-----|-------|----------------|
| `ONESIGNAL_APP_ID` | Your App ID | OneSignal Dashboard → Settings |
| `ONESIGNAL_API_KEY` | Your API Key | OneSignal Dashboard → Settings → Keys & IDs |

**Current values** (already configured for you):
- ONESIGNAL_APP_ID: `8dafb65c-1299-447e-bfab-aa6125b5009e`
- ONESIGNAL_API_KEY: Check `realtime-server/.env` file

### Step 5: Deploy!

1. Click **Create Web Service**
2. Render will:
   - Clone your repository
   - Install dependencies (`npm install`)
   - Start the server (`npm start`)
3. Wait 2-3 minutes for deployment
4. You'll get a URL like: `https://special-love-server-xxxx.onrender.com`

### Step 6: Test the Server

1. Visit your Render URL in a browser
2. You should see: **"Special Love Realtime Server is running!"**
3. **Copy your server URL** - you'll need it next!

**🎉 Your server is now live and accessible from anywhere!**

---

## Part 3: Update App Configuration

## Part 3: Update App Configuration

### Step 1: Update Environment File

Open your `.env.local` file and update the Socket URL:

```env
# Socket.IO Server URL - UPDATE THIS!
NEXT_PUBLIC_SOCKET_URL=https://your-render-app.onrender.com
```

Replace `your-render-app.onrender.com` with your actual Render URL.

**Example:**
```env
NEXT_PUBLIC_SOCKET_URL=https://special-love-server-abc123.onrender.com
```

### Step 2: Rebuild the App

```bash
# From project root
npm run build
```

### Step 3: Sync to Android

```bash
npx cap sync android
```

### Step 4: Build Production APK

```bash
cd android
.\gradlew assembleRelease
```

The APK will be in: `android/app/build/outputs/apk/release/app-release-unsigned.apk`

### Step 5: Test Production App

1. Install the APK on your phone
2. Open the app
3. Send a ping from one user to another
4. Both users should receive the ping instantly!

---

## Part 4: Testing Both Environments

### Local Testing (Development)

**When to use**: Testing on same WiFi network

1. Make sure both devices on same WiFi
2. Get your computer's local IP:
   ```bash
   ipconfig  # Windows
   ifconfig  # Mac/Linux
   ```
3. Update `.env.local`:
   ```env
   NEXT_PUBLIC_SOCKET_URL=http://YOUR_LOCAL_IP:3001
   ```
4. Start local server:
   ```bash
   npm run server:dev
   ```
5. Rebuild and install APK

### Production Testing (Render)

**When to use**: Testing from different networks, or keeping server always available

1. Update `.env.local` with Render URL
2. No need to run local server
3. App connects to Render server automatically
4. Works from anywhere with internet!

---

## Troubleshooting

### Server Issues

**Problem**: Can't access Render URL  
**Solution**: 
- Check Render dashboard for deployment status
- Wait 30 seconds if server was sleeping (free tier)
- Check server logs in Render dashboard

**Problem**: Push notifications not working  
**Solution**:
- Verify OneSignal environment variables in Render
- Check OneSignal dashboard for delivery status

### App Issues

**Problem**: Socket connection failed  
**Solution**:
- Verify `NEXT_PUBLIC_SOCKET_URL` is correct
- Check if URL starts with `https://` for production
- Rebuild app after changing environment variables

**Problem**: Local testing not working  
**Solution**:
- Ensure server is running: `npm run server:dev`
- Check firewall allows port 3001
- Verify IP address hasn't changed
- Update `.env.local` with current IP

---

## Next Steps

1. ✅ Push your code to GitHub
2. ✅ Deploy server to Render
3. ✅ Update app with production URL
4. ✅ Build and test production APK
5. 🎉 Share the APK with your partner!

**Optional**:
- Set up custom domain for Render server
- Configure Render to prevent sleep (upgrade to paid plan)
- Build signed release APK for Play Store
- Add more features to your app!

---

## Quick Reference

**Render Server URL Format:**
```
https://YOUR-APP-NAME.onrender.com
```

**Local Server URL Format:**
```
http://YOUR-LOCAL-IP:3001
```

**Environment Variables:**
```env
# Production
NEXT_PUBLIC_SOCKET_URL=https://your-render-app.onrender.com

# Local Development  
NEXT_PUBLIC_SOCKET_URL=http://192.168.1.x:3001
```

**Build Commands:**
```bash
# Development
npm run dev
npm run server:dev

# Production
npm run build
npx cap sync android
cd android && .\gradlew assembleRelease
```
  appName: 'Special Love',
  webDir: 'out',
  server: {
    androidScheme: 'https'
  },
  plugins: {
    // Add this section
    PushNotifications: {
      presentationOptions: ["badge", "sound", "alert"]
    }
  }
};

export default config;
```

### Step 3: Install OneSignal Cordova Plugin

Run these commands in your project:

```bash
cd d:\Project\Special
npm install onesignal-cordova-plugin
npx cap sync android
```

---

## Part 4: Build & Test

### Step 1: Build the App

```bash
npm run build
npx cap sync android
npx cap open android
```

### Step 2: Build APK in Android Studio

1. Android Studio will open
2. Click **Build** → **Build Bundle(s) / APK(s)** → **Build APK(s)**
3. Wait for build to complete
4. Install on your phone

### Step 3: Test Real-Time Messaging

1. **Install on both phones** (yours and your partner's)
2. **Open the app on both devices**
3. **Send a ping from one device**
4. **The other device should receive it instantly** ⚡

**Speed test**:
- Both phones online: ~50-200ms delivery
- One phone offline: Push notification in ~1-2 seconds

---

## Part 5: Troubleshooting

### Server not responding?
- Check Render logs: Go to your service → **Logs**
- Free tier servers sleep after inactivity (takes 30s to wake up on first request)

### Pings not being received?
1. Check browser console (F12) for Socket.IO connection status
2. Make sure `.env.local` has the correct server URL
3. Verify OneSignal App ID is correct

### OneSignal notifications not working?
1. Make sure you granted notification permissions
2. Check OneSignal dashboard → **Audience** to see if devices are registered
3. Verify google-services.json is in the android/app folder

---

## ✅ Success Checklist

- [ ] OneSignal account created with App ID and API Key
- [ ] Server deployed to Render with environment variables
- [ ] Server URL responding with "Special Love Realtime Server is running!"
- [ ] `.env.local` file created with OneSignal App ID and server URL
- [ ] App built and installed on both devices
- [ ] Real-time pings working instantly when both online
- [ ] Push notifications working when app is closed

---

## 🎉 You're Done!

Your app now has:
- **Real-time messaging** (50-200ms when online)
- **Push notifications** (1-2s when offline)
- **100% FREE** hosting and notifications
- **No Firebase Cloud Functions needed!**

Enjoy your instant messaging app! 💕
