// message

import 'package:flutter/foundation.dart';

enum MessageStatus {
  pending,    // Message is being sent
  sent,       // Message sent successfully (single tick)
  delivered,  // Message delivered (double tick)
  read,       // Message read (double blue tick)
  failed,     // Message failed to send
}

class Message {
  final String id;
  final String text;
  final bool isSentByMe;
  final DateTime timestamp;
  final String? senderId; // For group chats
  final MessageStatus status;

  Message({
    required this.id,
    required this.text,
    required this.isSentByMe,
    required this.timestamp,
    this.senderId,
    this.status = MessageStatus.sent,
  });

  // Helper method to create a copy of the message with updated fields
  Message copyWith({
    String? id,
    String? text,
    bool? isSentByMe,
    DateTime? timestamp,
    String? senderId,
    MessageStatus? status,
  }) {
    return Message(
      id: id ?? this.id,
      text: text ?? this.text,
      isSentByMe: isSentByMe ?? this.isSentByMe,
      timestamp: timestamp ?? this.timestamp,
      senderId: senderId ?? this.senderId,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Message &&
        other.id == id &&
        other.text == text &&
        other.isSentByMe == isSentByMe &&
        other.timestamp == timestamp &&
        other.senderId == senderId &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        text.hashCode ^
        isSentByMe.hashCode ^
        timestamp.hashCode ^
        (senderId?.hashCode ?? 0) ^
        status.hashCode;
  }

  @override
  String toString() {
    return 'Message(id: $id, text: $text, isSentByMe: $isSentByMe, timestamp: $timestamp, senderId: $senderId, status: $status)';
  }
}
