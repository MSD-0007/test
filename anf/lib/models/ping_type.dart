import 'package:flutter/material.dart';

enum PingType {
  thinkingOfYou,
  missYou,
  loveYou,
  needYou,
  freeTalk,
  busy,
  goodMorning,
  sweetDreams,
  hug;

  // Convert from string (for Firestore)
  static PingType fromString(String value) {
    switch (value) {
      case 'thinking-of-you':
        return PingType.thinkingOfYou;
      case 'miss-you':
        return PingType.missYou;
      case 'love-you':
        return PingType.loveYou;
      case 'need-you':
        return PingType.needYou;
      case 'free-talk':
        return PingType.freeTalk;
      case 'busy':
        return PingType.busy;
      case 'good-morning':
        return PingType.goodMorning;
      case 'sweet-dreams':
        return PingType.sweetDreams;
      case 'hug':
        return PingType.hug;
      default:
        return PingType.thinkingOfYou;
    }
  }

  // Convert to string (for Firestore)
  String get value {
    switch (this) {
      case PingType.thinkingOfYou:
        return 'thinking-of-you';
      case PingType.missYou:
        return 'miss-you';
      case PingType.loveYou:
        return 'love-you';
      case PingType.needYou:
        return 'need-you';
      case PingType.freeTalk:
        return 'free-talk';
      case PingType.busy:
        return 'busy';
      case PingType.goodMorning:
        return 'good-morning';
      case PingType.sweetDreams:
        return 'sweet-dreams';
      case PingType.hug:
        return 'hug';
    }
  }

  // Display label
  String get label {
    switch (this) {
      case PingType.thinkingOfYou:
        return 'Thinking of You';
      case PingType.missYou:
        return 'Missing You';
      case PingType.loveYou:
        return 'I Love You';
      case PingType.needYou:
        return 'Need You NOW';
      case PingType.freeTalk:
        return 'Free to Talk?';
      case PingType.busy:
        return 'Busy Right Now';
      case PingType.goodMorning:
        return 'Good Morning';
      case PingType.sweetDreams:
        return 'Sweet Dreams';
      case PingType.hug:
        return 'Virtual Hug';
    }
  }

  // Message content
  String get message {
    switch (this) {
      case PingType.thinkingOfYou:
        return '✨ You just crossed my mind and made me smile... Thinking of you!';
      case PingType.missYou:
        return '💕 Your love is thinking about you right now... Missing you so much!';
      case PingType.loveYou:
        return '💕 Just wanted to tell you how much I love you! You mean everything to me!';
      case PingType.needYou:
        return '🆘 I really need to hear your voice right now. Please call me!';
      case PingType.freeTalk:
        return '💬 Hey beautiful! Are you free to talk for a bit?';
      case PingType.busy:
        return '⏰ I\'m a bit busy at the moment, but I\'ll message you soon! Love you!';
      case PingType.goodMorning:
        return '🌅 Good morning, sunshine! Hope you have the most amazing day! ☀️';
      case PingType.sweetDreams:
        return '🌙 Sweet dreams, my love. Can\'t wait to see you tomorrow! 💤';
      case PingType.hug:
        return '🤗 Sending you the biggest, warmest hug! You are so loved and cherished. 💕';
    }
  }

  // Emoji for display
  String get emoji {
    switch (this) {
      case PingType.thinkingOfYou:
        return '✨';
      case PingType.missYou:
        return '💕';
      case PingType.loveYou:
        return '💕';
      case PingType.needYou:
        return '🆘';
      case PingType.freeTalk:
        return '💬';
      case PingType.busy:
        return '⏰';
      case PingType.goodMorning:
        return '🌅';
      case PingType.sweetDreams:
        return '🌙';
      case PingType.hug:
        return '🤗';
    }
  }

  // Icon for UI
  IconData get icon {
    switch (this) {
      case PingType.thinkingOfYou:
        return Icons.auto_awesome;
      case PingType.missYou:
        return Icons.favorite;
      case PingType.loveYou:
        return Icons.favorite;
      case PingType.needYou:
        return Icons.phone;
      case PingType.freeTalk:
        return Icons.chat_bubble;
      case PingType.busy:
        return Icons.schedule;
      case PingType.goodMorning:
        return Icons.wb_sunny;
      case PingType.sweetDreams:
        return Icons.bedtime;
      case PingType.hug:
        return Icons.favorite;
    }
  }

  // Gradient colors for buttons
  List<Color> get gradientColors {
    switch (this) {
      case PingType.thinkingOfYou:
        return [const Color(0xFF9C27B0), const Color(0xFFE91E63)];
      case PingType.missYou:
        return [const Color(0xFFE91E63), const Color(0xFFF06292)];
      case PingType.loveYou:
        return [const Color(0xFFF44336), const Color(0xFFE91E63)];
      case PingType.needYou:
        return [const Color(0xFFF44336), const Color(0xFFFF9800)];
      case PingType.freeTalk:
        return [const Color(0xFF4CAF50), const Color(0xFF8BC34A)];
      case PingType.busy:
        return [const Color(0xFF9E9E9E), const Color(0xFF607D8B)];
      case PingType.goodMorning:
        return [const Color(0xFFFFC107), const Color(0xFFFFEB3B)];
      case PingType.sweetDreams:
        return [const Color(0xFF3F51B5), const Color(0xFF9C27B0)];
      case PingType.hug:
        return [const Color(0xFFFF6B9D), const Color(0xFFFF8E9B)];
    }
  }

  // Vibration pattern (light, medium, heavy)
  VibrationPattern get vibrationPattern {
    switch (this) {
      case PingType.thinkingOfYou:
        return VibrationPattern.light;
      case PingType.missYou:
        return VibrationPattern.medium;
      case PingType.loveYou:
        return VibrationPattern.heavy;
      case PingType.needYou:
        return VibrationPattern.heavy;
      case PingType.freeTalk:
        return VibrationPattern.light;
      case PingType.busy:
        return VibrationPattern.light;
      case PingType.goodMorning:
        return VibrationPattern.light;
      case PingType.sweetDreams:
        return VibrationPattern.light;
      case PingType.hug:
        return VibrationPattern.medium;
    }
  }
}

enum VibrationPattern {
  light,
  medium,
  heavy;

  // Duration in milliseconds
  List<int> get pattern {
    switch (this) {
      case VibrationPattern.light:
        return [0, 100];
      case VibrationPattern.medium:
        return [0, 200, 100, 200];
      case VibrationPattern.heavy:
        return [0, 300, 100, 300, 100, 300];
    }
  }
}