import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ping_message.dart';
import '../models/ping_type.dart';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';
import '../services/haptic_service.dart';
import 'moments_provider.dart';

class AppStateProvider extends ChangeNotifier {
  // User state
  String? _currentUserId;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  // Message state
  final List<PingMessage> _recentMessages = [];
  bool _isListening = false;

  // Services
  final FirebaseService _firebaseService = FirebaseService();
  final NotificationService _notificationService = NotificationService();
  final HapticService _hapticService = HapticService();
  MomentsProvider? _momentsProvider;

  // Getters
  String? get currentUserId => _currentUserId;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  List<PingMessage> get recentMessages => List.unmodifiable(_recentMessages);
  bool get isListening => _isListening;

  // Get display name for user
  String get displayName {
    if (_currentUserId == null) return 'Unknown';
    return _currentUserId!.toUpperCase();
  }

  // Get recipient ID
  String get recipientId {
    if (_currentUserId == 'ndg') return 'ak';
    if (_currentUserId == 'ak') return 'ndg';
    return 'unknown';
  }

  // Set moments provider reference
  void setMomentsProvider(MomentsProvider momentsProvider) {
    _momentsProvider = momentsProvider;
  }

  // Initialize app state
  Future<void> initialize() async {
    _setLoading(true);
    
    try {
      // Load saved user ID
      final prefs = await SharedPreferences.getInstance();
      final savedUserId = prefs.getString('user_id');
      
      if (savedUserId != null && (savedUserId == 'ndg' || savedUserId == 'ak')) {
        _currentUserId = savedUserId;
        _isAuthenticated = true;
        
        // Set current user in moments provider
        _momentsProvider?.setCurrentUser(savedUserId);
        
        // Start listening for messages
        await _startMessageListener();
        
        print('✅ App state initialized for user: $savedUserId');
      }
    } catch (e) {
      print('❌ Error initializing app state: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Authenticate user with password
  Future<bool> authenticateWithPassword(String password) async {
    _setLoading(true);
    
    try {
      // Check password (same as original app)
      if (password != 'AnF') {
        return false;
      }
      
      return true;
    } finally {
      _setLoading(false);
    }
  }

  // Select user (NDG or AK)
  Future<void> selectUser(String userId) async {
    _setLoading(true);
    
    try {
      if (userId != 'ndg' && userId != 'ak') {
        throw Exception('Invalid user ID');
      }
      
      _currentUserId = userId;
      _isAuthenticated = true;
      
      // Set current user in moments provider
      _momentsProvider?.setCurrentUser(userId);
      
      // Save to preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', userId);
      
      // Start listening for messages
      await _startMessageListener();
      
      print('✅ User selected: $userId');
    } catch (e) {
      print('❌ Error selecting user: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Start listening for messages
  Future<void> _startMessageListener() async {
    if (_currentUserId == null || _isListening) return;
    
    try {
      _isListening = true;
      
      _firebaseService.listenForMessages(_currentUserId!).listen(
        (message) async {
          _recentMessages.insert(0, message);
          
          // Keep only recent messages
          if (_recentMessages.length > 50) {
            _recentMessages.removeRange(50, _recentMessages.length);
          }
          
          // Show notification
          await _notificationService.showPingNotification(message);
          
          // Trigger haptic feedback
          final pingType = PingType.fromString(message.type);
          await _hapticService.triggerPingHaptic(pingType);
          
          notifyListeners();
          
          print('📨 Message received and processed: ${message.type} from ${message.from}');
        },
        onError: (error) {
          print('❌ Error in message listener: $error');
        },
      );
      
      print('👂 Started listening for messages for user: $_currentUserId');
    } catch (e) {
      print('❌ Error starting message listener: $e');
      _isListening = false;
    }
  }

  // Send ping message
  Future<bool> sendPing(String pingTypeValue, String message) async {
    if (_currentUserId == null) return false;
    
    _setLoading(true);
    
    try {
      // Convert string to PingType enum
      final type = _stringToPingType(pingTypeValue);
      if (type == null) return false;
      
      // Trigger haptic feedback
      await _hapticService.triggerPingHaptic(type);
      
      // Send message
      final success = await _firebaseService.sendPing(
        to: recipientId,
        from: _currentUserId!,
        type: type,
      );
      
      if (success) {
        await _hapticService.triggerSuccess();
        print('✅ Ping sent successfully: $pingTypeValue');
      } else {
        await _hapticService.triggerError();
        print('❌ Failed to send ping: $pingTypeValue');
      }
      
      return success;
    } catch (e) {
      print('❌ Error sending ping: $e');
      await _hapticService.triggerError();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Test notifications
  Future<void> testNotifications() async {
    try {
      await _notificationService.showTestNotification();
      await _hapticService.triggerSuccess();
      print('🧪 Test notification sent');
    } catch (e) {
      print('❌ Error sending test notification: $e');
      await _hapticService.triggerError();
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      _currentUserId = null;
      _isAuthenticated = false;
      _isListening = false;
      _recentMessages.clear();
      
      // Clear saved preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_id');
      
      // Dispose Firebase listener
      _firebaseService.dispose();
      
      notifyListeners();
      print('✅ User logged out');
    } catch (e) {
      print('❌ Error during logout: $e');
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  // Convert string to PingType enum
  PingType? _stringToPingType(String value) {
    try {
      return PingType.fromString(value);
    } catch (e) {
      print('❌ Error converting string to PingType: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _firebaseService.dispose();
    super.dispose();
  }
}