import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'notification_service.dart';
import '../models/ping_message.dart';

// Top-level function for background message handling
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('🔥 Background message received: ${message.messageId}');
  print('📋 Data: ${message.data}');
  
  // Handle the background message
  await FCMService().handleBackgroundMessage(message);
}

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final NotificationService _notificationService = NotificationService();
  String? _fcmToken;

  // Initialize FCM
  Future<void> initialize() async {
    print('🔥 Initializing Firebase Cloud Messaging...');

    try {
      // Request permission for notifications
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      print('📋 FCM Permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ FCM permissions granted');
        
        // Get FCM token
        _fcmToken = await _messaging.getToken();
        print('🔑 FCM Token: $_fcmToken');

        // Set up message handlers
        await _setupMessageHandlers();
        
        // Subscribe to topics
        await _subscribeToTopics();
        
        print('✅ FCM initialized successfully');
      } else {
        print('❌ FCM permissions denied');
      }
    } catch (e) {
      print('❌ Error initializing FCM: $e');
    }
  }

  // Set up message handlers
  Future<void> _setupMessageHandlers() async {
    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📱 Foreground message received: ${message.messageId}');
      _handleForegroundMessage(message);
    });

    // Handle message taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('👆 Message tapped (app in background): ${message.messageId}');
      _handleMessageTap(message);
    });

    // Handle message tap when app is terminated
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      print('🚀 App opened from terminated state via message: ${initialMessage.messageId}');
      _handleMessageTap(initialMessage);
    }
  }

  // Subscribe to topics for receiving messages
  Future<void> _subscribeToTopics() async {
    try {
      await _messaging.subscribeToTopic('love_pings');
      await _messaging.subscribeToTopic('ndg_pings');
      await _messaging.subscribeToTopic('ak_pings');
      print('✅ Subscribed to FCM topics');
    } catch (e) {
      print('❌ Error subscribing to topics: $e');
    }
  }

  // Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    print('📱 Processing foreground message...');
    
    if (message.data.isNotEmpty) {
      _processMessageData(message.data);
    }
    
    // Show local notification for foreground messages
    _showLocalNotification(message);
  }

  // Handle background messages
  Future<void> handleBackgroundMessage(RemoteMessage message) async {
    print('🔥 Processing background message...');
    
    if (message.data.isNotEmpty) {
      _processMessageData(message.data);
    }
    
    // Show local notification for background messages
    _showLocalNotification(message);
  }

  // Handle message tap
  void _handleMessageTap(RemoteMessage message) {
    print('👆 Processing message tap...');
    
    if (message.data.isNotEmpty) {
      _processMessageData(message.data);
    }
    
    // TODO: Navigate to specific screen based on message data
  }

  // Process message data
  void _processMessageData(Map<String, dynamic> data) {
    print('📋 Processing message data: $data');
    
    try {
      if (data.containsKey('ping_data')) {
        final pingJson = jsonDecode(data['ping_data']);
        final ping = PingMessage.fromJson(pingJson);
        print('📨 Processed ping: ${ping.type} from ${ping.from}');
        
        // Show notification using the notification service
        _notificationService.showPingNotification(ping);
      }
    } catch (e) {
      print('❌ Error processing message data: $e');
    }
  }

  // Show local notification
  void _showLocalNotification(RemoteMessage message) {
    print('🔔 Showing local notification for FCM message');
    
    try {
      final notification = message.notification;
      if (notification != null) {
        // Use the notification service to show the notification
        final androidDetails = AndroidNotificationDetails(
          'love_pings_fcm',
          'Love Pings FCM',
          channelDescription: 'Firebase Cloud Messaging notifications',
          importance: Importance.max,
          priority: Priority.max,
          enableVibration: true,
          icon: '@mipmap/ic_launcher',
          largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
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

        _notificationService.notifications.show(
          DateTime.now().millisecondsSinceEpoch ~/ 1000,
          notification.title ?? 'Love Ping',
          notification.body ?? 'You received a love message!',
          notificationDetails,
        );
      }
    } catch (e) {
      print('❌ Error showing local notification: $e');
    }
  }

  // Send FCM message (for server-side implementation)
  Future<void> sendFCMMessage({
    required String to,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    print('📤 Sending FCM message to: $to');
    
    // This would typically be done from a server
    // For now, we'll use the existing Firebase listener approach
    // but with FCM for background delivery
    
    print('📋 FCM message data prepared: $data');
  }

  // Get FCM token
  String? get fcmToken => _fcmToken;

  // Refresh FCM token
  Future<String?> refreshToken() async {
    try {
      _fcmToken = await _messaging.getToken();
      print('🔄 FCM token refreshed: $_fcmToken');
      return _fcmToken;
    } catch (e) {
      print('❌ Error refreshing FCM token: $e');
      return null;
    }
  }

  // Delete FCM token
  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      _fcmToken = null;
      print('🗑️ FCM token deleted');
    } catch (e) {
      print('❌ Error deleting FCM token: $e');
    }
  }
}