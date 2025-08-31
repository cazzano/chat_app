import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class LoginApi {
  static const String baseUrl = 'https://chatapp-production-4eb5.up.railway.app';
  
  static Future<LoginResponse> login({
    required String username,
    required String password,
    required String code,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'username': username,
          'password': password,
          'code': code,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return LoginResponse.fromJson(data);
      } else {
        final errorData = json.decode(response.body);
        throw LoginException(
          errorData['message'] ?? 'Login failed',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is LoginException) rethrow;
      throw LoginException('Network error: ${e.toString()}', 0);
    }
  }

  static Future<File> _getTokenFile() async {
    if (Platform.isAndroid) {
      // Android: Use app's internal files directory
      final directory = await getApplicationDocumentsDirectory();
      final tokenFile = File(path.join(directory.path, 'token.json'));
      return tokenFile;
    } else {
      // Other platforms: Use existing logic (Linux, Windows, macOS)
      final homeDir = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
      if (homeDir == null) throw Exception('Could not find home directory');
      
      final configDir = Directory(path.join(homeDir, '.config', 'chat_app'));
      if (!await configDir.exists()) {
        await configDir.create(recursive: true);
      }
      return File(path.join(configDir.path, 'token.json'));
    }
  }

  static Future<void> saveToken(String token) async {
    try {
      final tokenFile = await _getTokenFile();
      
      // Ensure parent directory exists for Android
      if (Platform.isAndroid) {
        final parentDir = tokenFile.parent;
        if (!await parentDir.exists()) {
          await parentDir.create(recursive: true);
        }
      }

      final tokenData = {
        'token': token,
        'saved_at': DateTime.now().toIso8601String(),
      };

      await tokenFile.writeAsString(json.encode(tokenData));
      print('Token saved to: ${tokenFile.path}');
    } catch (e) {
      print('Error saving token: $e');
      throw Exception('Failed to save token: ${e.toString()}');
    }
  }

  static Future<String?> getStoredToken() async {
    try {
      final tokenFile = await _getTokenFile();

      if (!await tokenFile.exists()) return null;

      final tokenContent = await tokenFile.readAsString();
      final tokenData = json.decode(tokenContent);
      return tokenData['token'];
    } catch (e) {
      print('Error getting stored token: $e');
      return null;
    }
  }

  static Future<void> clearToken() async {
    try {
      final tokenFile = await _getTokenFile();

      if (await tokenFile.exists()) {
        await tokenFile.delete();
        print('Token cleared from: ${tokenFile.path}');
      }
    } catch (e) {
      print('Error clearing token: $e');
      // Ignore errors when clearing token
    }
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
