import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class FriendRequestsBadge extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const FriendRequestsBadge({
    Key? key,
    required this.child,
    required this.onTap,
  }) : super(key: key);

  @override
  FriendRequestsBadgeState createState() => FriendRequestsBadgeState();
}

class FriendRequestsBadgeState extends State<FriendRequestsBadge> {
  int _pendingRequestsCount = 0;
  bool _isLoading = false;
  String? _authToken;

  @override
  void initState() {
    super.initState();
    _loadAuthTokenAndRefresh();
  }

  Future<void> _loadAuthTokenAndRefresh() async {
    await _loadAuthToken();
    await refreshBadge();
  }

  Future<String?> _getToken() async {
    try {
      if (Platform.isAndroid) {
        // Android: Use app's internal files directory
        final directory = await getApplicationDocumentsDirectory();
        final tokenFile = File(path.join(directory.path, 'token.json'));
        
        if (!await tokenFile.exists()) {
          return null;
        }

        final content = await tokenFile.readAsString();
        final tokenData = jsonDecode(content);
        return tokenData['token'];
      } else {
        // Other platforms: Use existing logic (Linux, Windows, macOS)
        final homeDir = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
        if (homeDir == null) {
          print('Could not determine home directory');
          return null;
        }

        final configDir = path.join(homeDir, '.config', 'chat_app');
        final tokenPath = path.join(configDir, 'token.json');
        final file = File(tokenPath);
        
        if (await file.exists()) {
          final content = await file.readAsString();
          final tokenData = jsonDecode(content);
          return tokenData['token'];
        }
        return null;
      }
    } catch (e) {
      print('Error loading token for badge: $e');
      return null;
    }
  }

  Future<void> _loadAuthToken() async {
    try {
      _authToken = await _getToken();
    } catch (e) {
      // Handle error silently for badge
      print('Error loading token for badge: $e');
    }
  }

  Future<void> refreshBadge() async {
    if (_authToken == null || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://influential-etta-cazzano-afbfc85e.koyeb.app/get_requests'),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data.containsKey('requests')) {
          final List<dynamic> requests = data['requests'] ?? [];
          final pendingCount = requests
              .where((request) => request['status'] == 'pending')
              .length;

          if (mounted) {
            setState(() {
              _pendingRequestsCount = pendingCount;
            });
          }
        }
      }
    } catch (e) {
      // Handle error silently for badge
      print('Error fetching friend requests count: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            widget.onTap();
            // Refresh badge when tapped
            Future.delayed(const Duration(seconds: 1), () {
              refreshBadge();
            });
          },
          child: widget.child,
        ),
        if (_pendingRequestsCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              constraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              child: Center(
                child: Text(
                  _pendingRequestsCount > 99 ? '99+' : _pendingRequestsCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        if (_isLoading)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
