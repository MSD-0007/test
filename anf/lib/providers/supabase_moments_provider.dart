import 'package:flutter/foundation.dart';
import 'dart:async';
import '../services/supabase_service.dart';

class SupabaseMomentsProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _moments = [];
  bool _isLoading = false;
  String? _currentUserId;
  StreamSubscription? _momentsSubscription;

  List<Map<String, dynamic>> get moments => List.unmodifiable(_moments);
  bool get isLoading => _isLoading;

  void setCurrentUser(String userId) {
    _currentUserId = userId;
  }

  // Initialize and load moments from Supabase
  Future<void> initialize() async {
    _setLoading(true);
    
    try {
      await SupabaseService().initialize();
      await _loadMomentsFromSupabase();
      _listenToMomentsUpdates();
      print('✅ Supabase moments provider initialized with ${_moments.length} moments');
    } catch (e) {
      print('❌ Error initializing Supabase moments provider: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Add a new moment (photo) to Supabase
  Future<void> addMoment(String imagePath) async {
    if (_currentUserId == null) {
      throw Exception('User not logged in');
    }

    try {
      await SupabaseService().addMoment(imagePath, _currentUserId!);
      print('✅ Added new moment to Supabase');
    } catch (e) {
      print('❌ Error adding moment: $e');
      rethrow;
    }
  }

  // Delete a moment from Supabase
  Future<void> deleteMoment(String momentId) async {
    try {
      // Find the moment to get the image URL
      final moment = _moments.firstWhere((m) => m['id'] == momentId);
      await SupabaseService().deleteMoment(momentId, moment['image_url']);
      print('✅ Deleted moment from Supabase: $momentId');
    } catch (e) {
      print('❌ Error deleting moment: $e');
      rethrow;
    }
  }

  // Load moments from Supabase
  Future<void> _loadMomentsFromSupabase() async {
    try {
      _moments = await SupabaseService().getMoments();
      notifyListeners();
    } catch (e) {
      print('❌ Error loading moments from Supabase: $e');
      _moments = [];
    }
  }

  // Listen to real-time updates from Supabase
  void _listenToMomentsUpdates() {
    _momentsSubscription?.cancel();
    
    _momentsSubscription = SupabaseService()
        .listenToMoments()
        .listen((moments) {
      print('📡 Real-time update received: ${moments.length} moments');
      _moments = moments;
      notifyListeners();
      print('📸 Moments updated: ${_moments.length} total');
    }, onError: (error) {
      print('❌ Error listening to moments updates: $error');
      // Retry connection after error
      Future.delayed(const Duration(seconds: 5), () {
        print('🔄 Retrying real-time connection...');
        _listenToMomentsUpdates();
      });
    });
  }

  // Manual refresh method
  Future<void> refresh() async {
    print('🔄 Manual refresh requested');
    await _loadMomentsFromSupabase();
  }

  // Clear all moments (admin function)
  Future<void> clearAllMoments() async {
    try {
      await SupabaseService().clearAllMoments();
      print('✅ Cleared all moments from Supabase');
    } catch (e) {
      print('❌ Error clearing moments: $e');
      rethrow;
    }
  }

  // Helper method to set loading state
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _momentsSubscription?.cancel();
    super.dispose();
  }
}