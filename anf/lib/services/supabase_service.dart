import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  static const String supabaseUrl = 'https://jzrzcrjeoweznvgfgksw.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp6cnpjcmplb3dlem52Z2Zna3N3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI2MDI0MjUsImV4cCI6MjA3ODE3ODQyNX0.Ct9b45QytMFYjg0Fh2l3luvQnuILq6dMFg57uKZin_M';
  static const String fcmServerKey = 'QoWdZaZIqruIbws4afO-pqlxUoa8LYMf2OkBBLeLWL4';

  SupabaseClient get client => Supabase.instance.client;

  // Initialize Supabase
  Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      print('✅ Supabase initialized successfully');
      
      // Test connections
      await testConnection();
      await testStorageAccess();
    } catch (e) {
      print('❌ Error initializing Supabase: $e');
      rethrow;
    }
  }

  // Upload image to Supabase Storage
  Future<String> uploadImage(String imagePath, String uploadedBy) async {
    try {
      print('📁 Checking file existence: $imagePath');
      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('Image file does not exist at path: $imagePath');
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(imagePath);
      final fileName = '${uploadedBy}_${timestamp}$extension';
      print('📝 Generated filename: $fileName');

      // Read file as bytes
      print('📖 Reading file as bytes...');
      final bytes = await file.readAsBytes();
      print('📊 File size: ${bytes.length} bytes');

      // Upload to Supabase Storage
      print('☁️ Uploading to Supabase Storage bucket: moments');
      final response = await client.storage
          .from('moments')
          .uploadBinary(fileName, bytes);
      print('📤 Upload response: $response');

      // Get public URL
      print('🔗 Getting public URL...');
      final publicUrl = client.storage
          .from('moments')
          .getPublicUrl(fileName);
      print('🌐 Public URL: $publicUrl');

      print('✅ Image uploaded successfully: $fileName');
      return publicUrl;
    } catch (e) {
      print('❌ Error uploading image: $e');
      print('❌ Error type: ${e.runtimeType}');
      rethrow;
    }
  }

  // Add moment to database
  Future<Map<String, dynamic>> addMoment(String imagePath, String uploadedBy) async {
    try {
      print('📸 Starting photo upload process...');
      print('📋 Image path: $imagePath');
      print('📋 Uploaded by: $uploadedBy');
      
      // Upload image first
      print('📤 Uploading image to Supabase Storage...');
      final imageUrl = await uploadImage(imagePath, uploadedBy);
      print('✅ Image uploaded successfully: $imageUrl');

      // Add to database
      print('💾 Adding moment to database...');
      final response = await client
          .from('moments')
          .insert({
            'image_url': imageUrl,
            'uploaded_by': uploadedBy,
          })
          .select()
          .single();

      print('✅ Moment added to database: ${response['id']}');

      // Note: FCM notifications disabled for now - photos work without them
      print('📸 Photo uploaded successfully, real-time sync will handle updates');

      return response;
    } catch (e) {
      print('❌ Error adding moment: $e');
      print('❌ Error details: ${e.toString()}');
      rethrow;
    }
  }

  // Get all moments
  Future<List<Map<String, dynamic>>> getMoments() async {
    try {
      final response = await client
          .from('moments')
          .select()
          .order('created_at', ascending: false);

      print('✅ Retrieved ${response.length} moments');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error getting moments: $e');
      return [];
    }
  }

  // Listen to real-time changes
  Stream<List<Map<String, dynamic>>> listenToMoments() {
    return client
        .from('moments')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) {
          print('📡 Real-time update: ${data.length} moments');
          return List<Map<String, dynamic>>.from(data);
        });
  }

  // Delete moment
  Future<void> deleteMoment(String momentId, String imageUrl) async {
    try {
      // Extract filename from URL
      final uri = Uri.parse(imageUrl);
      final fileName = uri.pathSegments.last;

      // Delete from storage
      await client.storage
          .from('moments')
          .remove([fileName]);

      // Delete from database
      await client
          .from('moments')
          .delete()
          .eq('id', momentId);

      print('✅ Moment deleted: $momentId');
    } catch (e) {
      print('❌ Error deleting moment: $e');
      rethrow;
    }
  }

  // Clear all moments (admin function)
  Future<void> clearAllMoments() async {
    try {
      // Get all moments first
      final moments = await getMoments();

      // Delete all files from storage
      final fileNames = moments.map((moment) {
        final uri = Uri.parse(moment['image_url']);
        return uri.pathSegments.last;
      }).toList();

      if (fileNames.isNotEmpty) {
        await client.storage
            .from('moments')
            .remove(fileNames);
      }

      // Delete all from database
      await client
          .from('moments')
          .delete()
          .neq('id', '00000000-0000-0000-0000-000000000000'); // Delete all

      print('✅ All moments cleared');
    } catch (e) {
      print('❌ Error clearing moments: $e');
      rethrow;
    }
  }

  // Test connection
  Future<bool> testConnection() async {
    try {
      print('🧪 Testing Supabase connection...');
      final result = await client.from('moments').select().limit(1);
      print('✅ Supabase connection test successful: $result');
      return true;
    } catch (e) {
      print('❌ Supabase connection test failed: $e');
      print('❌ Error type: ${e.runtimeType}');
      return false;
    }
  }

  // Test storage access
  Future<bool> testStorageAccess() async {
    try {
      print('🧪 Testing Supabase storage access...');
      final buckets = await client.storage.listBuckets();
      print('✅ Storage buckets: $buckets');
      
      // Test moments bucket specifically
      final files = await client.storage.from('moments').list();
      print('✅ Moments bucket files: $files');
      return true;
    } catch (e) {
      print('❌ Supabase storage test failed: $e');
      print('❌ Error type: ${e.runtimeType}');
      return false;
    }
  }

  // Send photo upload notification via FCM
  Future<void> _sendPhotoNotification(String from, String to) async {
    try {
      final fromName = from.toUpperCase();
      final toName = to.toUpperCase();
      
      // FCM endpoint (legacy API)
      const fcmUrl = 'https://fcm.googleapis.com/fcm/send';
      
      // Notification payload
      final notification = {
        'to': '/topics/$to', // Send to topic for the recipient
        'notification': {
          'title': '📸 New Photo from $fromName!',
          'body': '$fromName just shared a new moment with you 💕',
          'icon': 'ic_notification',
          'sound': 'default',
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        },
        'data': {
          'type': 'photo_upload',
          'from': from,
          'to': to,
          'timestamp': DateTime.now().toIso8601String(),
        },
        'priority': 'high',
        'content_available': true,
      };

      // Send FCM request
      final response = await http.post(
        Uri.parse(fcmUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$fcmServerKey',
        },
        body: jsonEncode(notification),
      );
      
      print('📤 FCM Response Status: ${response.statusCode}');
      print('📤 FCM Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Photo notification sent to $toName');
      } else {
        print('❌ FCM notification failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error sending photo notification: $e');
    }
  }
}