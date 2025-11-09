# Special Love - Flutter App

A beautiful Flutter app for NDG and AK to send love messages across any distance 💕

## Features

### ✨ **Core Functionality**
- **8 Ping Types**: Thinking of You, Missing You, I Love You, Need You NOW, Free to Talk, Busy, Good Morning, Sweet Dreams
- **Real-time Messaging**: Instant delivery using Firebase Firestore
- **Cross-Platform**: Works seamlessly with the existing Next.js web app
- **Native Notifications**: Reliable Android notifications with custom sounds and vibrations
- **Haptic Feedback**: Different vibration patterns for each ping type

### 🎨 **Beautiful UI**
- **Exact Design Match**: Pixel-perfect recreation of the original web app
- **Gradient Background**: Same purple-to-blue gradient (#5865F2 to #3C45A5)
- **Floating Particles**: 50+ animated hearts, stars, and sparkles
- **Smooth Animations**: Elegant transitions and micro-interactions
- **Romantic Theme**: Love-focused design with hearts and romantic colors

### 🔧 **Technical Features**
- **Firebase Integration**: Same database as Next.js app for seamless communication
- **State Management**: Provider pattern for reactive UI updates
- **Local Storage**: Remembers user selection and preferences
- **Error Handling**: Graceful fallbacks and user-friendly error messages
- **Performance Optimized**: Efficient animations and memory management

## Architecture

### **Data Models**
- `PingMessage`: Core message model with Firestore serialization
- `PingType`: Enum with 8 ping types, colors, vibrations, and messages

### **Services**
- `FirebaseService`: Real-time messaging with Firestore
- `NotificationService`: Native Android notifications
- `HapticService`: Vibration patterns and haptic feedback

### **UI Components**
- `PingButton`: Animated ping buttons with gradients and effects
- `PingGrid`: Grid layout for all ping types
- `FloatingParticles`: Custom particle animation system
- `MessageHistory`: Recent message display

### **Screens**
- `SplashScreen`: Animated loading with heart icon
- `AuthScreen`: Password and user selection
- `HomeScreen`: Main ping interface with message history

## Setup & Installation

### **Prerequisites**
- Flutter SDK (3.7.2+)
- Android SDK with NDK 27.0.12077973
- Firebase project (already configured)

### **Installation**
1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Build and install: `flutter build apk --debug && adb install build/app/outputs/flutter-apk/app-debug.apk`

### **Firebase Configuration**
The app uses the same Firebase project as the Next.js web app:
- Project ID: `special-love-fa3eb`
- Collection: `pings`
- Real-time listeners for instant message delivery

## Usage

### **Authentication**
1. Enter password: `AnF`
2. Select user identity: `NDG` or `AK`
3. App remembers selection for future launches

### **Sending Pings**
1. Tap any ping button on the main screen
2. Feel haptic feedback based on ping type
3. See success confirmation
4. Message delivered instantly to recipient

### **Receiving Pings**
1. Automatic real-time listening when app is open
2. Native Android notifications when app is closed
3. Custom vibration patterns per ping type
4. Message history shows recent pings

### **Cross-Platform**
- Send from Flutter app → Receive on Next.js web app ✅
- Send from Next.js web app → Receive on Flutter app ✅
- Same user identifiers and message format
- Shared Firebase database

## Testing

### **Unit Tests**
```bash
flutter test test/models/  # Test data models
```

### **Manual Testing**
1. **Notifications**: Use "Test Notifications" button
2. **Cross-Platform**: Send pings between Flutter and web apps
3. **Haptics**: Feel different vibrations for each ping type
4. **Real-time**: Instant message delivery when both apps are open

## Troubleshooting

### **Common Issues**
1. **Notifications not working**: Check Android notification permissions
2. **Cross-platform issues**: Verify Firebase configuration matches
3. **Build errors**: Ensure NDK version 27.0.12077973 is installed

### **Debug Commands**
```bash
flutter clean && flutter pub get  # Clean rebuild
flutter analyze                   # Check for issues
flutter test                      # Run tests
adb logcat | grep flutter        # View Android logs
```

## Comparison with Original

### **Advantages over Capacitor Version**
- ✅ **Native Android Integration**: No web-to-native bridge issues
- ✅ **Reliable Notifications**: Uses Android's native notification system
- ✅ **Better Performance**: Compiled to native code
- ✅ **Consistent Haptics**: Native vibration API
- ✅ **Faster Startup**: No web view initialization

### **Maintained Features**
- ✅ **Identical UI**: Exact same design and animations
- ✅ **Same Firebase Database**: Full compatibility with web app
- ✅ **All Ping Types**: Same 8 message types with identical content
- ✅ **User System**: Same NDG/AK authentication
- ✅ **Real-time Messaging**: Instant delivery via Firestore

## Future Enhancements

### **Potential Additions**
- [ ] iOS version using same codebase
- [ ] Push notifications for background delivery
- [ ] Message scheduling and reminders
- [ ] Custom ping types and messages
- [ ] Photo and voice message support
- [ ] Relationship milestones and memories

---

**Made with infinite love for NDG and AK 💕**

*"Distance means so little when someone means so much"*