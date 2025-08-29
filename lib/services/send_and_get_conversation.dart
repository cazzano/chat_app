import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/message.dart';

// Model for conversation message
class ConversationMessage {
  final String direction; // 'sent' or 'received'
  final bool isRead;
  final String message;
  final int messageId;
  final String recipient;
  final String sender;
  final String timestamp;

  ConversationMessage({
    required this.direction,
    required this.isRead,
    required this.message,
    required this.messageId,
    required this.recipient,
    required this.sender,
    required this.timestamp,
  });

  factory ConversationMessage.fromJson(Map<String, dynamic> json) {
    return ConversationMessage(
      direction: json['direction'] ?? '',
      isRead: json['is_read'] ?? false,
      message: json['message'] ?? '',
      messageId: json['message_id'] ?? 0,
      recipient: json['recipient'] ?? '',
      sender: json['sender'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }

  // Convert to your existing Message model format
  bool get isSentByMe => direction == 'sent';
  
  DateTime get parsedTimestamp {
    try {
      // Handle both formats: "2025-08-27 09:21:52" and ISO format
      if (timestamp.contains('T')) {
        return DateTime.parse(timestamp);
      } else {
        return DateTime.parse(timestamp.replaceAll(' ', 'T'));
      }
    } catch (e) {
      return DateTime.now();
    }
  }
}

// Model for conversation response
class ConversationResponse {
  final List<ConversationMessage> conversation;
  final String currentUser;
  final String otherUser;
  final List<String> participants;
  final int totalMessages;

  ConversationResponse({
    required this.conversation,
    required this.currentUser,
    required this.otherUser,
    required this.participants,
    required this.totalMessages,
  });

  factory ConversationResponse.fromJson(Map<String, dynamic> json) {
    return ConversationResponse(
      conversation: (json['conversation'] as List?)
          ?.map((msg) => ConversationMessage.fromJson(msg))
          .toList() ?? [],
      currentUser: json['current_user'] ?? '',
      otherUser: json['other_user'] ?? '',
      participants: List<String>.from(json['participants'] ?? []),
      totalMessages: json['total_messages'] ?? 0,
    );
  }
}

// Model for send message response
class SendMessageResponse {
  final String message;
  final int messageId;
  final String recipient;
  final String sender;
  final String timestamp;

  SendMessageResponse({
    required this.message,
    required this.messageId,
    required this.recipient,
    required this.sender,
    required this.timestamp,
  });

  factory SendMessageResponse.fromJson(Map<String, dynamic> json) {
    return SendMessageResponse(
      message: json['message'] ?? '',
      messageId: json['message_id'] ?? 0,
      recipient: json['recipient'] ?? '',
      sender: json['sender'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }
}

class ConversationApi {
  static const String baseUrl = 'http://localhost:2000';
  static const String sendMessageEndpoint = '/auth/send_message';
  static const String conversationEndpoint = '/auth/conversation';

  // Get authentication token from file
  static Future<String?> _getToken() async {
    try {
      final homeDir = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
      if (homeDir == null) {
        print('Could not determine home directory');
        return null;
      }

      final tokenPath = '$homeDir/.config/chat_app/token.json';
      final tokenFile = File(tokenPath);

      if (!await tokenFile.exists()) {
        print('Token file does not exist at: $tokenPath');
        return null;
      }

      final tokenContent = await tokenFile.readAsString();
      final tokenData = jsonDecode(tokenContent);
      
      return tokenData['token'];
    } catch (e) {
      print('Error reading token: $e');
      return null;
    }
  }

  // Send a message to a specific user
  static Future<SendMessageResponse?> sendMessage({
    required String message,
    required String recipientUserId,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        print('No authentication token found');
        return null;
      }

      final response = await http.post(
        Uri.parse('$baseUrl$sendMessageEndpoint'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': message,
          'recipient_user_id': recipientUserId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        return SendMessageResponse.fromJson(jsonData);
      } else {
        print('Failed to send message. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error sending message: $e');
      return null;
    }
  }

  // Get conversation with a specific user
  static Future<ConversationResponse?> getConversation(String userId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        print('No authentication token found');
        return null;
      }

      final response = await http.get(
        Uri.parse('$baseUrl$conversationEndpoint/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return ConversationResponse.fromJson(jsonData);
      } else {
        print('Failed to get conversation. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching conversation: $e');
      return null;
    }
  }

  // Get conversation messages as your existing Message model format
  static Future<List<Message>> getConversationMessages(String userId) async {
    final conversationResponse = await getConversation(userId);
    if (conversationResponse == null) return [];

    // Convert ConversationMessage to your Message model
    return conversationResponse.conversation.map((msg) {
      return Message(
        id: msg.messageId.toString(),
        text: msg.message,
        isSentByMe: msg.isSentByMe,
        timestamp: msg.parsedTimestamp,
        senderId: msg.sender,
      );
    }).toList();
  }

  // Send message and return it as your Message model
  static Future<Message?> sendMessageAndReturnMessage({
    required String message,
    required String recipientUserId,
  }) async {
    final response = await sendMessage(
      message: message,
      recipientUserId: recipientUserId,
    );

    if (response == null) return null;

    return Message(
      id: response.messageId.toString(),
      text: message,
      isSentByMe: true,
      timestamp: DateTime.parse(response.timestamp),
      senderId: response.sender,
    );
  }

  // Helper method to extract user ID from friend data
  static String extractUserId(String friendId) {
    // Based on your get_friends API format, the friend_id is already the user ID
    return friendId;
  }
}
