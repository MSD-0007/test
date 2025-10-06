# 🔧 Troubleshooting Guide

## Common Issues and Solutions

### 🔥 Firebase Issues

#### "Firebase: Error (auth/invalid-api-key)"
**Solution:**
1. Check `.env.local` file exists in root directory
2. Verify all Firebase credentials are correct
3. Make sure variable names start with `NEXT_PUBLIC_`
4. Restart dev server after changing .env.local

#### "Missing or insufficient permissions"
**Solution:**
1. Go to Firebase Console → Firestore Database → Rules
2. Temporarily use test mode rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```
3. Click "Publish"

#### Images not uploading
**Solution:**
1. Go to Firebase Console → Storage → Rules
2. Use test mode rules:
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if true;
    }
  }
}
```

### 📱 Mobile Build Issues

#### "Could not find com.google.gms:google-services"
**Solution:**
1. Download `google-services.json` from Firebase Console
2. Place in `android/app/` folder
3. Open `android/build.gradle`, add:
```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.4.0'
}
```
4. Open `android/app/build.gradle`, add at bottom:
```gradle
apply plugin: 'com.google.gms.google-services'
```

#### Capacitor sync fails
**Solution:**
```bash
# Clean and rebuild
npm run export
npx cap sync
```

#### Android Studio won't open project
**Solution:**
1. File → Invalidate Caches / Restart
2. Try opening manually: File → Open → select `android` folder
3. Let Gradle sync complete

### 🎨 Styling Issues

#### Background not showing blurple
**Solution:**
- Hard refresh browser: Ctrl+Shift+R (Windows) or Cmd+Shift+R (Mac)
- Clear browser cache
- Check browser console for CSS errors

#### Animations not working
**Solution:**
1. Verify Framer Motion is installed: `npm install framer-motion`
2. Check for JavaScript errors in console
3. Ensure components are client components (`'use client'` at top)

### 🔐 Authentication Issues

#### Password not working
**Solution:**
1. Check `.env.local` for correct password
2. Default password is: `AnF`
3. Make sure no extra spaces in password

#### User ID not persisting
**Solution:**
- Check browser localStorage (F12 → Application → Local Storage)
- Should see `secretLoveUserId` and `secretLoveUserName`
- Clear and re-login if corrupted

### 📸 Photo Gallery Issues

#### Photos not appearing
**Solution:**
1. Check Firebase Console → Storage
2. Verify photos are uploading (check storage usage)
3. Check Firestore → moments collection for documents
4. Verify imageUrl field contains valid URL
5. Check browser console for CORS errors

#### Upload button not working
**Solution:**
1. Check file input is accessible
2. Verify file size isn't too large (Firebase free tier: 5GB total)
3. Check Storage rules allow write access
4. Look for errors in browser console

### 🔔 Notification Issues

#### Pings not showing up
**Solution:**
1. Open browser console on both tabs/devices
2. Check Firestore → pings collection
3. Verify documents are being created
4. Check for real-time listener errors
5. Ensure both users have different user IDs

#### No haptic feedback on phone
**Solution:**
- Haptics only work on real devices, not browsers
- Ensure vibration is enabled in phone settings
- Some phones have different vibration strengths

#### In-app notifications not dismissing
**Solution:**
- Click the X button to close manually
- They auto-dismiss after 8 seconds
- Check no JavaScript errors blocking animation

### 🌐 Network Issues

#### "Failed to fetch" errors
**Solution:**
1. Check internet connection
2. Verify Firebase project is active
3. Check Firebase status: status.firebase.google.com
4. Try disabling ad blockers

#### Real-time updates delayed
**Solution:**
- Firebase has ~1-2 second latency normally
- Check internet speed on both devices
- Verify devices aren't in airplane mode
- Try refreshing the page

### 🏗️ Build Issues

#### "next export" fails
**Solution:**
1. Remove any dynamic routes not supported by export
2. Check for server-side only code
3. Ensure all images use `unoptimized: true`
4. Run `npm run build` first to check for errors

#### Capacitor sync errors
**Solution:**
```bash
# Remove and re-add platforms
npx cap remove android
npx cap remove ios
npm run export
npx cap add android
npx cap add ios
npx cap sync
```

### 💻 Development Issues

#### Changes not showing in browser
**Solution:**
1. Hard refresh: Ctrl+Shift+R
2. Clear Next.js cache:
```bash
rm -rf .next
npm run dev
```
3. Check file is saved
4. Verify no TypeScript errors

#### "Module not found" errors
**Solution:**
```bash
# Reinstall dependencies
rm -rf node_modules
rm package-lock.json
npm install
```

#### Port 3000 already in use
**Solution:**
```bash
# Windows
netstat -ano | findstr :3000
taskkill /PID <PID> /F

# Mac/Linux
lsof -ti:3000 | xargs kill -9
```

### 📦 Package Issues

#### npm install fails
**Solution:**
1. Delete `node_modules` and `package-lock.json`
2. Clear npm cache: `npm cache clean --force`
3. Use Node 18 or higher
4. Try: `npm install --legacy-peer-deps`

#### Dependency conflicts
**Solution:**
```bash
npm install --force
# or
npm install --legacy-peer-deps
```

## 🆘 Getting Help

### Debug Steps:
1. ✅ Check browser console (F12)
2. ✅ Check Network tab for failed requests
3. ✅ Check Firebase Console for data
4. ✅ Verify .env.local exists and is correct
5. ✅ Check file paths are absolute
6. ✅ Look for TypeScript errors

### Check Firebase:
1. Go to Firebase Console
2. Firestore → Data → Check collections exist
3. Storage → Files → Check images uploaded
4. Usage → Check quotas not exceeded

### Browser Console Commands:
```javascript
// Check Firebase config
console.log(process.env);

// Check localStorage
console.log(localStorage.getItem('secretLoveUserId'));

// Test Firebase connection
import { db } from '@/lib/firebase';
import { collection, getDocs } from 'firebase/firestore';
getDocs(collection(db, 'pings')).then(console.log);
```

### Reset Everything:
```bash
# Clean install
rm -rf node_modules package-lock.json .next out
npm install
npm run dev

# Reset Firebase (in console)
# Delete all documents in pings and moments collections
# Delete all files in Storage

# Reset browser
# Clear cache, cookies, localStorage
# Hard refresh
```

## 📞 Still Stuck?

### Check These Files:
1. `.env.local` - Environment variables
2. `capacitor.config.ts` - Capacitor setup
3. `src/lib/firebase.ts` - Firebase initialization
4. Browser console - Error messages
5. Firebase Console - Data and rules

### Common Mistakes:
- ❌ Forgot to create .env.local
- ❌ .env.local in wrong location (must be in root)
- ❌ Firebase rules too restrictive
- ❌ Wrong Firebase credentials
- ❌ Not running npm run export before cap sync
- ❌ Old cached data causing issues

### Quick Fixes:
```bash
# Full reset and rebuild
rm -rf node_modules package-lock.json .next out
npm install
npm run export
npx cap sync

# Restart dev server
# Press Ctrl+C
npm run dev

# Force browser refresh
# Ctrl+Shift+R or Cmd+Shift+R
```

## ✅ Working Checklist

- [ ] `.env.local` file exists with all Firebase keys
- [ ] Firebase Console shows Firestore Database enabled
- [ ] Firebase Console shows Storage enabled
- [ ] `npm run dev` starts without errors
- [ ] Splash screen appears when opening app
- [ ] Password screen appears after splash
- [ ] Password "AnF" works correctly
- [ ] User identification step shows
- [ ] Main app loads with blurple background
- [ ] Quick Pings section visible
- [ ] Clicking a ping shows success toast
- [ ] Photo upload section visible
- [ ] Can select and upload a photo
- [ ] Photo appears in gallery
- [ ] No errors in browser console

If all checkboxes pass, your app is working correctly! 🎉

## 💡 Pro Tips

1. **Always check browser console first** - 90% of issues show errors there
2. **Test in web before mobile** - Easier to debug
3. **Use Firebase Console** - Verify data is actually being written
4. **Start with test mode rules** - Fix security later
5. **Clear cache often** - Prevents stale data issues
6. **Use incognito tabs** - Test as different users
7. **Check Network tab** - See if requests are failing
8. **Read error messages** - They usually tell you exactly what's wrong

Remember: Every bug is just an opportunity to learn! 💪
