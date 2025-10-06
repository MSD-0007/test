# Quick Test Guide - Streamlined Login Flow

## What Changed
The login process is now **much simpler**:
- **Before**: Email → Password → User Selection → Password → Name Entry
- **Now**: User Selection (NDG/AK) → Password → Main App

## Testing Steps

### 1. Open the App
- The app should open on RMX3853 device
- You'll see the splash screen (couple's silhouette)

### 2. User Selection Screen
After splash, you'll see:
- **Two big buttons**:
  - 👨 **Him (NDG)** - Blue gradient
  - 👩 **Her (AK)** - Pink gradient
- Select your user by tapping the button
- The app will **automatically log you in** (no email/password needed!)

### 3. Password Screen
After auto-login, you'll see:
- A beautiful password screen
- Shows which user you selected (👨 Him or 👩 Her)
- Enter the password: **`alwaysandforever`**
- Tap "Continue 💕"

### 4. Main App
You're in! Now you can:
- Send pings (Thinking of You, Miss You, Love You, Need You)
- Receive notifications with custom vibrations
- See dynamic moments
- Access all features

## Important Notes

### Password Changed
- **Old password**: `AnF`
- **New password**: `alwaysandforever`

### Auto-Login Credentials (Hidden from Users)
The app uses these credentials internally:
- **NDG**: `ndg@special.love` / `ndg123456`
- **AK**: `ak@special.love` / `ak123456`

Users **never see** these credentials - they just select NDG or AK!

## Testing Checklist

### Basic Flow
- [ ] Splash screen appears and completes
- [ ] User selection screen shows both buttons
- [ ] Selecting NDG shows "Authenticating..."
- [ ] Selecting AK shows "Authenticating..."
- [ ] Password screen appears with correct user indicator
- [ ] Password "alwaysandforever" works
- [ ] Wrong password shows error animation
- [ ] Successfully entering password loads main app

### Real-Time Features
- [ ] Socket.IO connects (check console logs)
- [ ] Can send pings
- [ ] Can receive pings
- [ ] Notifications appear
- [ ] Vibrations work (different patterns for each ping type)
- [ ] Background notifications work

### User Persistence
- [ ] After selecting user once, app remembers on next launch
- [ ] Can still manually select different user if needed

## Troubleshooting

### If Auto-Login Fails
Check console for errors. The app will:
1. Show "Authenticating..." message
2. Log "Auto-logging in with email: ..."
3. Either show "Auto-login successful" or "Auto-login failed"

### If Password Doesn't Work
- Make sure you're typing: `alwaysandforever` (all lowercase, no spaces)
- The password is case-sensitive

### If Socket Doesn't Connect
- Make sure realtime server is running: `npm start` in `realtime-server/`
- Check IP address matches: `10.195.33.185:3001`

## Expected Console Logs

### User Selection
```
👤 User selected: ndg
🔐 Auto-logging in with email: ndg@special.love
✅ Auto-login successful
```

### Password Entry
```
✅ Password verified, userId stored: ndg
🔐 Password verified for userId: ndg
```

### Socket Initialization
```
🌐 Initializing Socket.IO for user: ndg
🔌 Socket connected successfully
```

## Benefits of New Flow

1. **Faster**: 3 steps instead of 5
2. **Simpler**: Just pick user and enter one password
3. **Prettier**: New user selection screen with beautiful animations
4. **Safer**: Credentials locked in code, not exposed to users
5. **Smarter**: App remembers last selected user

---

**Ready to test!** 🚀

The APK has been installed on the device. Just open the app and follow the steps above.
