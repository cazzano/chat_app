// conversation

import 'package:flutter/foundation.dart';
import 'message.dart';

class Conversation {
  final String id;
  final String contactName;
  final String? lastMessage;
  final DateTime timestamp;
  final int unreadCount;
  final List<Message> messages;
  final String? avatarUrl; // URL for contact's avatar

  Conversation({
    required this.id,
    required this.contactName,
    this.lastMessage,
    required this.timestamp,
    this.unreadCount = 0,
    List<Message>? messages,
    this.avatarUrl,
  }) : messages = messages ?? [];
  
  Conversation copyWith({
    String? id,
    String? contactName,
    String? lastMessage,
    DateTime? timestamp,
    int? unreadCount,
    List<Message>? messages,
    String? avatarUrl,
  }) {
    return Conversation(
      id: id ?? this.id,
      contactName: contactName ?? this.contactName,
      lastMessage: lastMessage ?? this.lastMessage,
      timestamp: timestamp ?? this.timestamp,
      unreadCount: unreadCount ?? this.unreadCount,
      messages: messages ?? this.messages,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  // Add a message to the conversation
  Conversation addMessage(Message message) {
    final updatedMessages = List<Message>.from(messages)..add(message);
    return copyWith(
      lastMessage: message.text,
      timestamp: message.timestamp,
      messages: updatedMessages,
      unreadCount: message.isSentByMe ? unreadCount : unreadCount + 1,
    );
  }

  // Mark all messages as read
  Conversation markAsRead() {
    return copyWith(unreadCount: 0);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Conversation &&
        other.id == id &&
        other.contactName == contactName &&
        other.lastMessage == lastMessage &&
        other.timestamp == timestamp &&
        other.unreadCount == unreadCount &&
        listEquals(other.messages, messages) &&
        other.avatarUrl == avatarUrl;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        contactName.hashCode ^
        (lastMessage?.hashCode ?? 0) ^
        timestamp.hashCode ^
        unreadCount ^
        messages.hashCode ^
        (avatarUrl?.hashCode ?? 0);
  }

  @override
  String toString() {
    return 'Conversation(id: $id, contactName: $contactName, lastMessage: $lastMessage, '
        'timestamp: $timestamp, unreadCount: $unreadCount, messages: ${messages.length})';
  }
}
