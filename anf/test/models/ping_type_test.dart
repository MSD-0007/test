import 'package:flutter_test/flutter_test.dart';
import 'package:anf/models/ping_type.dart';

void main() {
  group('PingType', () {
    test('should convert from string correctly', () {
      expect(PingType.fromString('thinking-of-you'), PingType.thinkingOfYou);
      expect(PingType.fromString('miss-you'), PingType.missYou);
      expect(PingType.fromString('love-you'), PingType.loveYou);
      expect(PingType.fromString('need-you'), PingType.needYou);
      expect(PingType.fromString('free-talk'), PingType.freeTalk);
      expect(PingType.fromString('busy'), PingType.busy);
      expect(PingType.fromString('good-morning'), PingType.goodMorning);
      expect(PingType.fromString('sweet-dreams'), PingType.sweetDreams);
      expect(PingType.fromString('invalid'), PingType.thinkingOfYou); // Default
    });

    test('should convert to string correctly', () {
      expect(PingType.thinkingOfYou.value, 'thinking-of-you');
      expect(PingType.missYou.value, 'miss-you');
      expect(PingType.loveYou.value, 'love-you');
      expect(PingType.needYou.value, 'need-you');
      expect(PingType.freeTalk.value, 'free-talk');
      expect(PingType.busy.value, 'busy');
      expect(PingType.goodMorning.value, 'good-morning');
      expect(PingType.sweetDreams.value, 'sweet-dreams');
    });

    test('should have correct labels', () {
      expect(PingType.thinkingOfYou.label, 'Thinking of You');
      expect(PingType.missYou.label, 'Missing You');
      expect(PingType.loveYou.label, 'I Love You');
      expect(PingType.needYou.label, 'Need You NOW');
    });

    test('should have messages', () {
      expect(PingType.thinkingOfYou.message, isNotEmpty);
      expect(PingType.missYou.message, isNotEmpty);
      expect(PingType.loveYou.message, isNotEmpty);
      expect(PingType.needYou.message, isNotEmpty);
    });

    test('should have emojis', () {
      expect(PingType.thinkingOfYou.emoji, '✨');
      expect(PingType.missYou.emoji, '💕');
      expect(PingType.loveYou.emoji, '💕');
      expect(PingType.needYou.emoji, '🆘');
    });

    test('should have gradient colors', () {
      expect(PingType.thinkingOfYou.gradientColors, hasLength(2));
      expect(PingType.missYou.gradientColors, hasLength(2));
      expect(PingType.loveYou.gradientColors, hasLength(2));
      expect(PingType.needYou.gradientColors, hasLength(2));
    });

    test('should have vibration patterns', () {
      expect(PingType.thinkingOfYou.vibrationPattern, VibrationPattern.light);
      expect(PingType.missYou.vibrationPattern, VibrationPattern.medium);
      expect(PingType.loveYou.vibrationPattern, VibrationPattern.heavy);
      expect(PingType.needYou.vibrationPattern, VibrationPattern.heavy);
    });
  });

  group('VibrationPattern', () {
    test('should have correct patterns', () {
      expect(VibrationPattern.light.pattern, [0, 100]);
      expect(VibrationPattern.medium.pattern, [0, 200, 100, 200]);
      expect(VibrationPattern.heavy.pattern, [0, 300, 100, 300, 100, 300]);
    });
  });
}