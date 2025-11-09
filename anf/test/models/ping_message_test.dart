import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:anf/models/ping_message.dart';

void main() {
  group('PingMessage', () {
    test('should create a valid PingMessage', () {
      final message = PingMessage(
        from: 'ndg',
        to: 'ak',
        message: 'Test message',
        type: 'thinking-of-you',
        timestamp: DateTime.now(),
      );

      expect(message.from, 'ndg');
      expect(message.to, 'ak');
      expect(message.message, 'Test message');
      expect(message.type, 'thinking-of-you');
      expect(message.delivered, false);
      expect(message.isValid(), true);
    });

    test('should validate message correctly', () {
      final validMessage = PingMessage(
        from: 'ndg',
        to: 'ak',
        message: 'Test message',
        type: 'thinking-of-you',
        timestamp: DateTime.now(),
      );

      final invalidMessage = PingMessage(
        from: '',
        to: 'ak',
        message: 'Test message',
        type: 'thinking-of-you',
        timestamp: DateTime.now(),
      );

      expect(validMessage.isValid(), true);
      expect(invalidMessage.isValid(), false);
    });

    test('should convert to Firestore format correctly', () {
      final message = PingMessage(
        from: 'ndg',
        to: 'ak',
        message: 'Test message',
        type: 'thinking-of-you',
        timestamp: DateTime.now(),
      );

      final firestoreData = message.toFirestore();

      expect(firestoreData['from'], 'ndg');
      expect(firestoreData['to'], 'ak');
      expect(firestoreData['message'], 'Test message');
      expect(firestoreData['type'], 'thinking-of-you');
      expect(firestoreData['delivered'], false);
      expect(firestoreData['timestamp'], isA<Timestamp>());
    });

    test('should create copy with updated fields', () {
      final original = PingMessage(
        from: 'ndg',
        to: 'ak',
        message: 'Test message',
        type: 'thinking-of-you',
        timestamp: DateTime.now(),
      );

      final copy = original.copyWith(delivered: true);

      expect(copy.from, original.from);
      expect(copy.to, original.to);
      expect(copy.message, original.message);
      expect(copy.type, original.type);
      expect(copy.delivered, true);
    });
  });
}