import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:io';

class MomentsProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _moments = [];
  bool _isLoading = false;
  String? _currentUserId;

  List<Map<String, dynamic>> get moments => List.unmodifiable(_moments);
  bool get isLoading => _isLoading;

  void setCurrentUser(String userId) {
    _currentUserId = userId;
  }

  // Initialize and load moments from Firebase
  Future<void> initialize() async {
    _setLoading(true);
    
    try {
      await _loadMomentsFromFirebase();
      _listenToMomentsUpdates();
      print('✅ Moments provider initialized with ${_moments.length} moments');
    } catch (e) {
      print('❌ Error initializing moments provider: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Add a new moment (photo) to Firebase
  Future<void> addMoment(String imagePath) async {
    print('🔄 Starting to add moment...');
    print('📋 Current user ID: $_currentUserId');
    print('📋 Image path: $imagePath');
    
    if (_currentUserId == null) {
      print('❌ User not logged in - cannot upload photo');
      throw Exception('User not logged in');
    }

    try {
      // Read and encode the image
      final file = File(imagePath);
      print('📋 Checking if file exists...');
      
      if (!await file.exists()) {
        print('❌ Image file does not exist at path: $imagePath');
        throw Exception('Image file does not exist');
      }

      print('📋 Reading image bytes...');
      final imageBytes = await file.readAsBytes();
      print('📋 Image size: ${imageBytes.length} bytes');
      
      final imageBase64 = base64Encode(imageBytes);
      print('📋 Base64 encoded, length: ${imageBase64.length}');

      // Create moment document
      final momentData = {
        'imageData': imageBase64,
        'uploadedBy': _currentUserId,
        'timestamp': FieldValue.serverTimestamp(),
        'id': '', // Will be set after creation
      };

      print('📋 Adding document to Firestore...');
      // Add to Firestore
      final docRef = await FirebaseFirestore.instance
          .collection('moments')
          .add(momentData);

      print('📋 Document added with ID: ${docRef.id}');
      
      // Update with the document ID
      await docRef.update({'id': docRef.id});
      print('📋 Document updated with ID field');

      print('✅ Added new moment to Firebase: ${docRef.id}');
    } catch (e) {
      print('❌ Error adding moment: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // Delete a moment from Firebase
  Future<void> deleteMoment(String momentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('moments')
          .doc(momentId)
          .delete();

      print('✅ Deleted moment from Firebase: $momentId');
    } catch (e) {
      print('❌ Error deleting moment: $e');
      rethrow;
    }
  }

  // Load moments from Firebase
  Future<void> _loadMomentsFromFirebase() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('moments')
          .orderBy('timestamp', descending: true)
          .get();

      _moments = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      notifyListeners();
    } catch (e) {
      print('❌ Error loading moments from Firebase: $e');
      _moments = [];
    }
  }

  // Listen to real-time updates from Firebase
  void _listenToMomentsUpdates() {
    FirebaseFirestore.instance
        .collection('moments')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      _moments = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      notifyListeners();
      print('📸 Moments updated: ${_moments.length} total');
    }, onError: (error) {
      print('❌ Error listening to moments updates: $error');
    });
  }

  // Clear all moments (admin function)
  Future<void> clearAllMoments() async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      final snapshot = await FirebaseFirestore.instance
          .collection('moments')
          .get();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('✅ Cleared all moments from Firebase');
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
}