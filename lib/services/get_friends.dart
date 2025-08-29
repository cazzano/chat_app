import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class Friend {
  final String friendId;
  final String friendUsername;
  final String friendshipDate;
  final int friendshipId;
  final String status;

  Friend({
    required this.friendId,
    required this.friendUsername,
    required this.friendshipDate,
    required this.friendshipId,
    required this.status,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      friendId: json['friend_id'] ?? '',
      friendUsername: json['friend_username'] ?? '',
      friendshipDate: json['friendship_date'] ?? '',
      friendshipId: json['friendship_id'] ?? 0,
      status: json['status'] ?? '',
    );
  }
}

class GetFriendsResponse {
  final List<Friend> friends;
  final bool success;
  final String timestamp;
  final int totalFriends;
  final Map<String, dynamic> userInfo;

  GetFriendsResponse({
    required this.friends,
    required this.success,
    required this.timestamp,
    required this.totalFriends,
    required this.userInfo,
  });

  factory GetFriendsResponse.fromJson(Map<String, dynamic> json) {
    return GetFriendsResponse(
      friends: (json['friends'] as List?)
          ?.map((friend) => Friend.fromJson(friend))
          .toList() ?? [],
      success: json['success'] ?? false,
      timestamp: json['timestamp'] ?? '',
      totalFriends: json['total_friends'] ?? 0,
      userInfo: json['user_info'] ?? {},
    );
  }
}

class GetFriendsApi {
  static const String baseUrl = 'http://localhost:2000';
  static const String getFriendsEndpoint = '/auth/get_friends';

  static Future<String?> _getToken() async {
    try {
      // Get the home directory path
      final homeDir = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
      if (homeDir == null) {
        print('Could not determine home directory');
        return null;
      }

      // Construct the path to the token file
      final tokenPath = '$homeDir/.config/chat_app/token.json';
      final tokenFile = File(tokenPath);

      if (!await tokenFile.exists()) {
        print('Token file does not exist at: $tokenPath');
        return null;
      }

      // Read and parse the token file
      final tokenContent = await tokenFile.readAsString();
      final tokenData = jsonDecode(tokenContent);
      
      return tokenData['token'];
    } catch (e) {
      print('Error reading token: $e');
      return null;
    }
  }

  static Future<GetFriendsResponse?> getFriends() async {
    try {
      // Get the authentication token
      final token = await _getToken();
      if (token == null) {
        print('No authentication token found');
        return null;
      }

      // Make the API request
      final response = await http.get(
        Uri.parse('$baseUrl$getFriendsEndpoint'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return GetFriendsResponse.fromJson(jsonData);
      } else {
        print('Failed to get friends. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching friends: $e');
      return null;
    }
  }

  static Future<List<Friend>> getFriendsList() async {
    final response = await getFriends();
    return response?.friends ?? [];
  }
}
