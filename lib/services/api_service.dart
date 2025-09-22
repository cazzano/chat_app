import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class LoginApi {
  static const String baseUrl = 'https://influential-etta-cazzano-afbfc85e.koyeb.app';
  static String? _cachedToken;

  static Future<File> _getTokenFile() async {
    if (Platform.isAndroid) {
      // Android: Use app's internal files directory
      final directory = await getApplicationDocumentsDirectory();
      return File(path.join(directory.path, 'token.json'));
    } else {
      // Other platforms: Use existing logic (Linux, Windows, macOS)
      final home = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
      if (home == null) {
        throw Exception('Could not determine home directory');
      }
      
      final configDir = Directory(path.join(home, '.config', 'chat_app'));
      if (!await configDir.exists()) {
        await configDir.create(recursive: true);
      }
      return File(path.join(configDir.path, 'token.json'));
    }
  }

  static Future<String?> getToken() async {
    if (_cachedToken != null) return _cachedToken;

    try {
      final tokenFile = await _getTokenFile();
      
      if (await tokenFile.exists()) {
        final content = await tokenFile.readAsString();
        final tokenData = jsonDecode(content);
        _cachedToken = tokenData['token'];
        return _cachedToken;
      }

      return null;
    } catch (e) {
      print('Error loading token: $e');
      return null;
    }
  }

  static Future<void> saveToken(String token) async {
    try {
      final tokenFile = await _getTokenFile();
      
      // Ensure parent directory exists
      final parentDir = tokenFile.parent;
      if (!await parentDir.exists()) {
        await parentDir.create(recursive: true);
      }

      final tokenData = {
        'token': token,
        'saved_at': DateTime.now().toIso8601String(),
      };

      await tokenFile.writeAsString(json.encode(tokenData));
      _cachedToken = token; // Update cache
      print('Token saved to: ${tokenFile.path}');
    } catch (e) {
      print('Error saving token: $e');
      throw Exception('Failed to save token: ${e.toString()}');
    }
  }

  static Future<String?> getStoredToken() async {
    return await getToken();
  }

  static Future<void> clearToken() async {
    try {
      final tokenFile = await _getTokenFile();

      if (await tokenFile.exists()) {
        await tokenFile.delete();
        print('Token cleared from: ${tokenFile.path}');
      }
      
      _cachedToken = null; // Clear cache
    } catch (e) {
      print('Error clearing token: $e');
      // Ignore errors when clearing token
    }
  }

  static void clearCachedToken() {
    _cachedToken = null;
  }

  static Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'authorization': 'Bearer $token',
      'content-type': 'application/json',
    };
  }

  static Future<http.Response> getFriendRequests() async {
    final headers = await _getHeaders();
    return await http.get(
      Uri.parse('$baseUrl/get_requests'),
      headers: headers,
    );
  }

  static Future<http.Response> respondToFriendRequest({
    required String username,
    required String action, // 'accept' or 'reject'
  }) async {
    final headers = await _getHeaders();
    return await http.post(
      Uri.parse('$baseUrl/auth/respond_friend_request'),
      headers: headers,
      body: json.encode({
        'username': username,
        'action': action,
      }),
    );
  }
}

class LoginResponse {
  final String token;
  final String tokenType;
  final String userId;
  final String username;
  final String message;
  final String expiresIn;

  LoginResponse({
    required this.token,
    required this.tokenType,
    required this.userId,
    required this.username,
    required this.message,
    required this.expiresIn,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'],
      tokenType: json['token_type'],
      userId: json['user_id'],
      username: json['username'],
      message: json['message'],
      expiresIn: json['expires_in'],
    );
  }
}

class LoginException implements Exception {
  final String message;
  final int statusCode;

  LoginException(this.message, this.statusCode);

  @override
  String toString() => message;
}
