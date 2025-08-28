import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class SearchAndFriendRequestApi {
  static const String baseUrl = 'http://localhost:2000';
  static const String tokenPath = '~/.config/chat_app/token.json';

  // Get token from file
  static Future<String?> _getToken() async {
    try {
      // For Android/iOS, we'll need to adjust this path or use shared preferences
      // For now, assuming the token is stored in app's document directory
      final String home = Platform.environment['HOME'] ?? '';
      final String tokenFilePath = '$home/.config/chat_app/token.json';
      
      final file = File(tokenFilePath);
      if (await file.exists()) {
        final String contents = await file.readAsString();
        final Map<String, dynamic> tokenData = json.decode(contents);
        return tokenData['token'];
      }
      return null;
    } catch (e) {
      print('Error reading token: $e');
      return null;
    }
  }

  // Search user by username
  static Future<SearchUserResponse?> searchUser(String username) async {
    try {
      final String? token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/search_user'),
        headers: {
          'authorization': 'Bearer $token',
          'username': username,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return SearchUserResponse.fromJson(data);
      } else {
        print('Search user failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error searching user: $e');
      return null;
    }
  }

  // Send friend request
  static Future<FriendRequestResponse?> sendFriendRequest(String username) async {
    try {
      final String? token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/send_friend_request'),
        headers: {
          'authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'username': username,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return FriendRequestResponse.fromJson(data);
      } else {
        print('Send friend request failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error sending friend request: $e');
      return null;
    }
  }
}

// Data models for API responses
class SearchUserResponse {
  final String message;
  final UserData searchedBy;
  final String timestamp;
  final UserData userData;

  SearchUserResponse({
    required this.message,
    required this.searchedBy,
    required this.timestamp,
    required this.userData,
  });

  factory SearchUserResponse.fromJson(Map<String, dynamic> json) {
    return SearchUserResponse(
      message: json['message'] ?? '',
      searchedBy: UserData.fromJson(json['searched_by'] ?? {}),
      timestamp: json['timestamp'] ?? '',
      userData: UserData.fromJson(json['user_data'] ?? {}),
    );
  }
}

class FriendRequestResponse {
  final String message;
  final UserData recipient;
  final RequestData requestData;
  final int requestId;
  final UserData sender;
  final String status;
  final String timestamp;

  FriendRequestResponse({
    required this.message,
    required this.recipient,
    required this.requestData,
    required this.requestId,
    required this.sender,
    required this.status,
    required this.timestamp,
  });

  factory FriendRequestResponse.fromJson(Map<String, dynamic> json) {
    return FriendRequestResponse(
      message: json['message'] ?? '',
      recipient: UserData.fromJson(json['recipient'] ?? {}),
      requestData: RequestData.fromJson(json['request_data'] ?? {}),
      requestId: json['request_id'] ?? 0,
      sender: UserData.fromJson(json['sender'] ?? {}),
      status: json['status'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }
}

class UserData {
  final String userId;
  final String username;

  UserData({
    required this.userId,
    required this.username,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      userId: json['user_id'] ?? '',
      username: json['username'] ?? '',
    );
  }
}

class RequestData {
  final String actionRequired;
  final String createdAt;
  final String from;
  final String message;
  final String to;
  final String type;

  RequestData({
    required this.actionRequired,
    required this.createdAt,
    required this.from,
    required this.message,
    required this.to,
    required this.type,
  });

  factory RequestData.fromJson(Map<String, dynamic> json) {
    return RequestData(
      actionRequired: json['action_required'] ?? '',
      createdAt: json['created_at'] ?? '',
      from: json['from'] ?? '',
      message: json['message'] ?? '',
      to: json['to'] ?? '',
      type: json['type'] ?? '',
    );
  }
}
