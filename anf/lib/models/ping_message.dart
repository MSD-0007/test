import 'package:cloud_firestore/cloud_firestore.dart';

class PingMessage {
  final String? id;
  final String from;
  final String to;
  final String message;
  final String type;
  final DateTime timestamp;
  final bool delivered;

  const PingMessage({
    this.id,
    required this.from,
    required this.to,
    required this.message,
    required this.type,
    required this.timestamp,
    this.delivered = false,
  });

  // Create from Firestore document
  factory PingMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PingMessage(
      id: doc.id,
      from: data['from'] ?? '',
      to: data['to'] ?? '',
      message: data['message'] ?? '',
      type: data['type'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      delivered: data['delivered'] ?? false,
    );
  }

  // Create from JSON (for FCM messages)
  factory PingMessage.fromJson(Map<String, dynamic> json) {
    return PingMessage(
      id: json['id'],
      from: json['from'] ?? '',
      to: json['to'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? '',
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      delivered: json['delivered'] ?? false,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'from': from,
      'to': to,
      'message': message,
      'type': type,
      'timestamp': Timestamp.fromDate(timestamp),
      'delivered': delivered,
    };
  }

  // Convert to JSON (for FCM messages)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from': from,
      'to': to,
      'message': message,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'delivered': delivered,
    };
  }

  // Create a copy with updated fields
  PingMessage copyWith({
    String? id,
    String? from,
    String? to,
    String? message,
    String? type,
    DateTime? timestamp,
    bool? delivered,
  }) {
    return PingMessage(
      id: id ?? this.id,
      from: from ?? this.from,
      to: to ?? this.to,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      delivered: delivered ?? this.delivered,
    );
  }

  // Validation
  bool isValid() {
    return from.isNotEmpty &&
        to.isNotEmpty &&
        message.isNotEmpty &&
        type.isNotEmpty;
  }

  @override
  String toString() {
    return 'PingMessage(id: $id, from: $from, to: $to, type: $type, delivered: $delivered)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PingMessage &&
        other.id == id &&
        other.from == from &&
        other.to == to &&
        other.message == message &&
        other.type == type &&
        other.delivered == delivered;
  }

  @override
  int get hashCode {
    return Object.hash(id, from, to, message, type, delivered);
  }
}