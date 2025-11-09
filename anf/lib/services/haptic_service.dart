import 'package:vibration/vibration.dart';
import 'package:flutter/services.dart';
import '../models/ping_type.dart';

class HapticService {
  static final HapticService _instance = HapticService._internal();
  factory HapticService() => _instance;
  HapticService._internal();

  bool _isSupported = false;
  bool _isInitialized = false;

  // Initialize haptic service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _isSupported = await Vibration.hasVibrator() ?? false;
      _isInitialized = true;
      print('✅ Haptic service initialized (supported: $_isSupported)');
    } catch (e) {
      print('❌ Error initializing haptic service: $e');
      _isSupported = false;
      _isInitialized = true;
    }
  }

  // Trigger haptic feedback for ping type
  Future<void> triggerPingHaptic(PingType pingType) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      if (_isSupported) {
        // Use custom vibration pattern
        await Vibration.vibrate(pattern: pingType.vibrationPattern.pattern);
        print('📳 Haptic feedback triggered for ${pingType.label}');
      } else {
        // Fallback to system haptic feedback
        await _triggerSystemHaptic(pingType.vibrationPattern);
        print('📳 System haptic feedback triggered for ${pingType.label}');
      }
    } catch (e) {
      print('❌ Error triggering haptic feedback: $e');
      // Silent fallback - don't crash the app
    }
  }

  // Trigger system haptic feedback as fallback
  Future<void> _triggerSystemHaptic(VibrationPattern pattern) async {
    try {
      switch (pattern) {
        case VibrationPattern.light:
          await HapticFeedback.lightImpact();
          break;
        case VibrationPattern.medium:
          await HapticFeedback.mediumImpact();
          break;
        case VibrationPattern.heavy:
          await HapticFeedback.heavyImpact();
          break;
      }
    } catch (e) {
      print('❌ Error with system haptic feedback: $e');
    }
  }

  // Trigger success haptic
  Future<void> triggerSuccess() async {
    try {
      if (_isSupported) {
        await Vibration.vibrate(pattern: [0, 100, 50, 100]);
      } else {
        await HapticFeedback.lightImpact();
      }
      print('✅ Success haptic triggered');
    } catch (e) {
      print('❌ Error triggering success haptic: $e');
    }
  }

  // Trigger error haptic
  Future<void> triggerError() async {
    try {
      if (_isSupported) {
        await Vibration.vibrate(pattern: [0, 200, 100, 200, 100, 200]);
      } else {
        await HapticFeedback.heavyImpact();
      }
      print('❌ Error haptic triggered');
    } catch (e) {
      print('❌ Error triggering error haptic: $e');
    }
  }

  // Trigger selection haptic (for button presses)
  Future<void> triggerSelection() async {
    try {
      if (_isSupported) {
        await Vibration.vibrate(duration: 50);
      } else {
        await HapticFeedback.selectionClick();
      }
    } catch (e) {
      print('❌ Error triggering selection haptic: $e');
    }
  }

  // Test all vibration patterns
  Future<void> testAllPatterns() async {
    print('🧪 Testing all haptic patterns...');
    
    for (final pingType in PingType.values) {
      print('Testing ${pingType.label}...');
      await triggerPingHaptic(pingType);
      await Future.delayed(const Duration(milliseconds: 1000));
    }
    
    print('✅ All haptic patterns tested');
  }

  // Check if vibration is supported
  bool get isSupported => _isSupported;

  // Check if service is initialized
  bool get isInitialized => _isInitialized;
}