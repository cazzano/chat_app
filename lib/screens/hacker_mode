// get_request

import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/friend_request.dart';
import '../widgets/friend_request_tile.dart';

class GetRequestsScreen extends StatefulWidget {
  const GetRequestsScreen({Key? key}) : super(key: key);

  @override
  _GetRequestsScreenState createState() => _GetRequestsScreenState();
}

class _GetRequestsScreenState extends State<GetRequestsScreen> with TickerProviderStateMixin {
  List<FriendRequest> _friendRequests = [];
  bool _isLoading = true;
  String? _error;
  String _selectedFilter = 'pending';
  late TabController _tabController;
  String? _authToken;

  final List<String> _filters = ['all', 'pending', 'accepted', 'rejected'];
  final Map<String, String> _filterLabels = {
    'all': 'All',
    'pending': 'Pending',
    'accepted': 'Accepted',
    'rejected': 'Rejected',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _filters.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadAuthToken();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _selectedFilter = _filters[_tabController.index];
      });
      _loadFriendRequests(); // Load from server when filter changes
    }
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
      print('Error loading authentication token: $e');
      return null;
    }
  }

  Future<void> _loadAuthToken() async {
    try {
      _authToken = await _getToken();
      if (_authToken != null) {
        await _loadFriendRequests();
      } else {
        setState(() {
          _error = 'Authentication token not found. Please login first.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading authentication token: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadFriendRequests() async {
    if (_authToken == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('https://chatapp-production-4eb5.up.railway.app/get_requests'),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true || data.containsKey('requests')) {
          final List<dynamic> requestsJson = data['requests'] ?? [];
          List<FriendRequest> allRequests = requestsJson
              .map((json) => FriendRequest.fromJson(json))
              .toList();

          // Filter requests based on selected filter
          List<FriendRequest> filteredRequests = allRequests;
          if (_selectedFilter != 'all') {
            filteredRequests = allRequests
                .where((request) => request.status == _selectedFilter)
                .toList();
          }

          // Sort by timestamp (newest first)
          filteredRequests.sort((a, b) => b.timestamp.compareTo(a.timestamp));

          setState(() {
            _friendRequests = filteredRequests;
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = data['message'] ?? 'Failed to load friend requests';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = 'Failed to load friend requests. Status: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Network error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _respondToFriendRequest(String username, String action) async {
    if (_authToken == null) return;

    try {
      final response = await http.post(
        Uri.parse('https://chatapp-production-4eb5.up.railway.app/auth/respond_friend_request'),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'action': action,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Show success message
        String actionText = action == 'accept' ? 'accepted' : 'rejected';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Request $actionText successfully'),
            backgroundColor: action == 'accept' ? Colors.green : Colors.orange,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );

        // Don't reload automatically - only update local state if needed
        // The requests will be refreshed when user manually refreshes or changes filter
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Failed to $action request'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildEmptyState() {
    String message;
    IconData icon;
    
    switch (_selectedFilter) {
      case 'pending':
        message = 'No pending friend requests';
        icon = Icons.inbox_outlined;
        break;
      case 'accepted':
        message = 'No accepted requests';
        icon = Icons.check_circle_outline;
        break;
      case 'rejected':
        message = 'No rejected requests';
        icon = Icons.cancel_outlined;
        break;
      default:
        message = 'No friend requests found';
        icon = Icons.people_outline;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Theme.of(context).hintColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).hintColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilter == 'pending' 
                ? 'You\'ll see new friend requests here'
                : 'Switch to other tabs to see more requests',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).hintColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Theme.of(context).colorScheme.error.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadFriendRequests,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friend Requests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadFriendRequests,
            tooltip: 'Refresh from server',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          tabs: _filters.map((filter) {
            final count = _friendRequests.length;
            return Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_filterLabels[filter]!),
                  if (filter == _selectedFilter && count > 0) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        count.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        ),
      ),
      body: _error != null
          ? _buildErrorState()
          : _isLoading
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading friend requests...'),
                    ],
                  ),
                )
              : _friendRequests.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadFriendRequests,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _friendRequests.length,
                        itemBuilder: (context, index) {
                          final request = _friendRequests[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: FriendRequestTile(
                              friendRequest: request,
                              onAccept: (request.status == 'pending' || request.status == 'rejected')
                                  ? () => _respondToFriendRequest(request.senderUsername, 'accept')
                                  : null,
                              onReject: request.status == 'pending'
                                  ? () => _respondToFriendRequest(request.senderUsername, 'reject')
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
