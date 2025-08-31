import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ApiService {
  static const String baseUrl = 'https://chatapp-production-4eb5.up.railway.app';
  static String? _cachedToken;

  static Future<String?> getToken() async {
    if (_cachedToken != null) return _cachedToken;

    try {
      // Get home directory path cross-platform
      final home = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
      if (home != null) {
        // Use path.join for cross-platform path construction
        final configDir = path.join(home, '.config', 'chat_app');
        final tokenPath = path.join(configDir, 'token.json');
        final tokenFile = File(tokenPath);
        
        if (await tokenFile.exists()) {
          final tokenContent = await tokenFile.readAsString();
          final tokenJson = json.decode(tokenContent);
          _cachedToken = tokenJson['token'];
          return _cachedToken;
        }
      }

      // Fallback to app documents directory
      final directory = await getApplicationDocumentsDirectory();
      final configDir = path.join(directory.parent.path, '.config', 'chat_app');
      final tokenPath = path.join(configDir, 'token.json');
      final tokenFile = File(tokenPath);
      
      if (await tokenFile.exists()) {
        final tokenContent = await tokenFile.readAsString();
        final tokenJson = json.decode(tokenContent);
        _cachedToken = tokenJson['token'];
        return _cachedToken;
      }

      // Development fallback token
      _cachedToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiVTAzIiwidXNlcm5hbWUiOiJyaWNvIiwiZXhwIjoxNzU2NDYxMTE1LCJpYXQiOjE3NTYzNzQ3MTUsImlzcyI6InlvdXItYXBwLW5hbWUifQ.bk-qaJjk36Tq_ntgGecqLFHL3aVC3CbPzp_h8wWgJEo";
      return _cachedToken;
    } catch (e) {
      print('Error loading token: $e');
      // Return development fallback token
      _cachedToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiVTAzIiwidXNlcm5hbWUiOiJyaWNvIiwiZXhwIjoxNzU2NDYxMTE1LCJpYXQiOjE3NTYzNzQ3MTUsImlzcyI6InlvdXItYXBwLW5hbWUifQ.bk-qaJjk36Tq_ntgGecqLFHL3aVC3CbPzp_h8wWgJEo";
      return _cachedToken;
    }
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

  static void clearCachedToken() {
    _cachedToken = null;
  }
}