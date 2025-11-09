import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../models/ping_message.dart';
import '../models/ping_type.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  FirebaseFirestore? _firestore;
  StreamSubscription<QuerySnapshot>? _messageSubscription;
  DateTime? _listenerStartTime;

  // Initialize Firebase
  Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _firestore = FirebaseFirestore.instance;
      print('✅ Firebase initialized successfully');
    } catch (e) {
      print('❌ Error initializing Firebase: $e');
      rethrow;
    }
  }

  // Send a ping message
  Future<bool> sendPing({
    required String to,
    required String from,
    required PingType type,
  }) async {
    try {
      if (_firestore == null) {
        throw Exception('Firebase not initialized');
      }

      final pingMessage = PingMessage(
        from: from,
        to: to,
        message: type.message,
        type: type.value,
        timestamp: DateTime.now(),
        delivered: false,
      );

      if (!pingMessage.isValid()) {
        throw Exception('Invalid ping message data');
      }

      // Add to Firestore (for real-time listeners)
      final docRef = await _firestore!
          .collection('pings')
          .add(pingMessage.toFirestore());

      // Also add to FCM collection for background notifications
      await _firestore!
          .collection('fcm_notifications')
          .add({
        'to': to,
        'from': from,
        'title': '💕 ${from.toUpperCase()} sent you a ping!',
        'body': '${type.emoji} ${type.label}: ${type.message}',
        'data': {
          'ping_id': docRef.id,
          'ping_type': type.value,
          'ping_from': from,
          'ping_to': to,
        },
        'timestamp': FieldValue.serverTimestamp(),
        'processed': false,
      });

      print('✅ Ping sent successfully: ${type.label} from $from to $to');
      print('📤 FCM notification queued for background delivery');
      return true;
    } catch (e) {
      print('❌ Error sending ping: $e');
      return false;
    }
  }

  // Listen for incoming messages with background support
  Stream<PingMessage> listenForMessages(String userId) {
    if (_firestore == null) {
      throw Exception('Firebase not initialized');
    }

    // Track when we start listening to filter old messages
    _listenerStartTime = DateTime.now();
    print('🎯 Starting to listen for messages for user: $userId at ${_listenerStartTime}');
    
    // Listen for ALL messages to this user with enhanced background support
    return _firestore!
        .collection('pings')
        .where('to', isEqualTo: userId)
        .snapshots(includeMetadataChanges: true) // Include metadata changes for better background sync
        .asyncMap((snapshot) async {
      final List<PingMessage> newMessages = [];
      
      print('📡 Received ${snapshot.docChanges.length} document changes (from cache: ${snapshot.metadata.isFromCache})');
      
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final ping = PingMessage.fromFirestore(change.doc);
          
          print('📋 Processing ping: ${ping.type} from ${ping.from} to ${ping.to}');
          print('📋 Ping timestamp: ${ping.timestamp}');
          print('📋 Ping delivered: ${ping.delivered}');
          print('📋 Listener start time: $_listenerStartTime');
          print('📋 From cache: ${snapshot.metadata.isFromCache}');
          
          // Only process undelivered messages that are recent
          if (!ping.delivered) {
            // Accept messages from the last 5 minutes to catch background messages
            final cutoffTime = _listenerStartTime!.subtract(const Duration(minutes: 5));
            final isRecent = ping.timestamp.isAfter(cutoffTime);
            
            print('📋 Is recent (after $cutoffTime): $isRecent');
            
            if (isRecent) {
              // Process the message
              newMessages.add(ping);
              print('📨 ✅ NEW ping received and processed: ${ping.type} from ${ping.from}');
              
              // Try to mark as delivered (optional, don't fail if it doesn't work)
              try {
                await _firestore!
                    .collection('pings')
                    .doc(ping.id)
                    .update({'delivered': true});
                print('✅ Marked ping as delivered');
              } catch (e) {
                print('⚠️ Could not mark as delivered (permissions): $e');
              }
            } else {
              print('🔇 Ignoring old ping from ${ping.from} sent at ${ping.timestamp}');
            }
          } else {
            print('📬 Ping already delivered from ${ping.from} sent at ${ping.timestamp}');
          }
        } else if (change.type == DocumentChangeType.modified) {
          print('📝 Ping modified (probably marked as delivered)');
        } else if (change.type == DocumentChangeType.removed) {
          print('🗑️ Ping removed');
        }
      }
      
      return newMessages;
    }).expand((messages) => messages);
  }

  // Get message history (for debugging)
  Future<List<PingMessage>> getMessageHistory(String userId, {int limit = 10}) async {
    try {
      if (_firestore == null) {
        throw Exception('Firebase not initialized');
      }

      final snapshot = await _firestore!
          .collection('pings')
          .where('to', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => PingMessage.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('❌ Error getting message history: $e');
      return [];
    }
  }

  // Clean up old messages (optional maintenance)
  Future<void> cleanupOldMessages({int daysOld = 7}) async {
    try {
      if (_firestore == null) return;

      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
      final snapshot = await _firestore!
          .collection('pings')
          .where('timestamp', isLessThan: Timestamp.fromDate(cutoffDate))
          .get();

      final batch = _firestore!.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('✅ Cleaned up ${snapshot.docs.length} old messages');
    } catch (e) {
      print('❌ Error cleaning up old messages: $e');
    }
  }

  // Test connection
  Future<bool> testConnection() async {
    try {
      if (_firestore == null) return false;
      
      // Try to read from Firestore
      await _firestore!.collection('pings').limit(1).get();
      return true;
    } catch (e) {
      print('❌ Firebase connection test failed: $e');
      return false;
    }
  }

  // Dispose resources
  void dispose() {
    _messageSubscription?.cancel();
    _messageSubscription = null;
    _listenerStartTime = null;
  }
}