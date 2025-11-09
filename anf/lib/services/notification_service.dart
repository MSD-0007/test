import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/ping_message.dart';
import '../models/ping_type.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  
  // Getter for external access (needed by FCM service)
  FlutterLocalNotificationsPlugin get notifications => _notifications;
  bool _isInitialized = false;

  // Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) {
      print('⚠️ Notification service already initialized');
      return;
    }

    print('🔔 Starting notification service initialization...');

    try {
      // Android initialization settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      print('📱 Android settings configured');
      
      // iOS initialization settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      print('🍎 iOS settings configured');

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      print('🔧 Initializing notification plugin...');
      final initialized = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
      print('🔧 Notification plugin initialized: $initialized');

      // Create notification channel for Android
      print('📢 Creating notification channel...');
      await _createNotificationChannel();
      
      _isInitialized = true;
      print('✅ Notification service initialized successfully');
    } catch (e) {
      print('❌ Error initializing notifications: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // Request notification permissions
  Future<bool> requestPermissions() async {
    print('🔐 Requesting notification permissions...');
    
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        print('📱 Platform: Android');
        final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        
        if (androidPlugin != null) {
          print('🔌 Android plugin found, requesting permissions...');
          final granted = await androidPlugin.requestNotificationsPermission();
          print('📱 Android notification permission granted: $granted');
          
          // Also check if notifications are enabled
          final enabled = await androidPlugin.areNotificationsEnabled();
          print('📱 Android notifications enabled: $enabled');
          
          return granted ?? false;
        } else {
          print('❌ Android plugin not found');
          return false;
        }
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        print('🍎 Platform: iOS');
        final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
        
        if (iosPlugin != null) {
          final granted = await iosPlugin.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
          print('🍎 iOS notification permission granted: $granted');
          return granted ?? false;
        } else {
          print('❌ iOS plugin not found');
          return false;
        }
      }
      
      print('⚠️ Unknown platform, defaulting to true');
      return true; // Default to true for other platforms
    } catch (e) {
      print('❌ Error requesting notification permissions: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      return false;
    }
  }

  // Create notification channel for Android
  Future<void> _createNotificationChannel() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;

    const channel = AndroidNotificationChannel(
      'love_pings',
      'Love Pings',
      description: 'Notifications for love messages between partners',
      importance: Importance.max,
      enableVibration: true,
      playSound: true,
      showBadge: true,
    );

    // High priority channel for urgent notifications
    const urgentChannel = AndroidNotificationChannel(
      'love_pings_urgent',
      'Urgent Love Pings',
      description: 'High priority notifications that bypass Do Not Disturb',
      importance: Importance.max,
      enableVibration: true,
      playSound: true,
      showBadge: true,
    );

    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(channel);
      await androidPlugin.createNotificationChannel(urgentChannel);
      print('✅ Notification channels created');
    }
  }

  // Show notification for received ping
  Future<void> showPingNotification(PingMessage ping) async {
    print('🔔 Attempting to show notification for ping from ${ping.from}');
    
    if (!_isInitialized) {
      print('❌ Notification service not initialized, cannot show notification');
      return;
    }

    try {
      final pingType = PingType.fromString(ping.type);
      final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      
      print('📋 Notification ID: $notificationId');
      print('📋 Ping type: ${pingType.label}');

      // Android notification details with enhanced background support
      final androidDetails = AndroidNotificationDetails(
        'love_pings_urgent',
        'Urgent Love Pings',
        channelDescription: 'High priority notifications for love messages',
        importance: Importance.max,
        priority: Priority.max,
        enableVibration: true,
        vibrationPattern: Int64List.fromList(pingType.vibrationPattern.pattern),
        icon: '@mipmap/ic_launcher',
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        styleInformation: BigTextStyleInformation(
          ping.message,
          contentTitle: '💕 ${ping.from.toUpperCase()} sent you a ping!',
          summaryText: pingType.label,
        ),
        // Enhanced background notification settings
        fullScreenIntent: true,
        category: AndroidNotificationCategory.message,
        visibility: NotificationVisibility.public,
        showWhen: true,
        when: DateTime.now().millisecondsSinceEpoch,
        usesChronometer: false,
        autoCancel: true,
        ongoing: false,
        silent: false,
        enableLights: true,
        ledColor: Colors.red,
        ledOnMs: 1000,
        ledOffMs: 500,
      );

      // iOS notification details
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      print('📤 Showing notification...');
      await _notifications.show(
        notificationId,
        '💕 ${ping.from.toUpperCase()} sent you a ping!',
        '${pingType.emoji} ${pingType.label}: ${ping.message}',
        notificationDetails,
        payload: ping.id,
      );

      print('✅ Notification shown successfully for ping from ${ping.from}');
    } catch (e) {
      print('❌ Error showing notification: $e');
      print('❌ Stack trace: ${StackTrace.current}');
    }
  }

  // Show test notification
  Future<void> showTestNotification() async {
    if (!_isInitialized) {
      print('⚠️ Notification service not initialized');
      return;
    }

    try {
      final androidDetails = AndroidNotificationDetails(
        'love_pings',
        'Love Pings',
        channelDescription: 'Test notification',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 300, 100, 300]),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        999999,
        '🧪 Test Notification',
        'All notification systems are working perfectly! 💕',
        notificationDetails,
      );

      print('✅ Test notification shown');
    } catch (e) {
      print('❌ Error showing test notification: $e');
    }
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    print('👆 Notification tapped: ${response.payload}');
    // TODO: Navigate to specific ping or main screen
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    print('🔕 All notifications cancelled');
  }

  // Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        return await androidPlugin.areNotificationsEnabled() ?? false;
      }
    }
    
    return true; // Assume enabled for other platforms
  }
}