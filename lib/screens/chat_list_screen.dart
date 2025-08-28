import 'package:flutter/material.dart';
import '../models/conversation.dart';
import '../data/mock_data.dart';
import '../widgets/conversation_tile.dart';
import '../widgets/user_search_dialog.dart';
import '../widgets/friend_requests_badge.dart';
import '../services/login_api.dart'; // Add this import
import 'chat_screen.dart';
import 'auth_screen.dart';
import 'get_requests.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late List<Conversation> _conversations;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _isLoggingOut = false; // Add loading state for logout
  final GlobalKey<FriendRequestsBadgeState> _badgeKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  void _loadConversations() {
    _conversations = MockData.getMockConversations();
  }

  void _onSearchChanged(String query) {
    // In a real app, we would filter the conversations based on the search query
    // For now, we'll just rebuild the UI
    setState(() {});
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      // Clear search results
    });
  }

  void _navigateToChat(Conversation conversation) {
    // Mark as read when opening the chat
    setState(() {
      final index = _conversations.indexWhere((c) => c.id == conversation.id);
      if (index != -1) {
        _conversations[index] = conversation.markAsRead();
      }
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(conversation: conversation),
      ),
    ).then((_) {
      // Refresh the conversation list when returning from chat
      setState(() {
        _conversations = MockData.getMockConversations();
      });
    });
  }

  void _startNewChat() {
    // In a real app, this would open a new chat screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Start new chat')),
    );
  }

  void _showUserSearchDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const UserSearchDialog();
      },
    );
  }

  void _navigateToFriendRequests() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GetRequestsScreen(),
      ),
    ).then((_) {
      // Refresh badge when returning from friend requests screen
      _badgeKey.currentState?.refreshBadge();
    });
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: _isLoggingOut ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: _isLoggingOut ? null : _performLogout,
              child: _isLoggingOut
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout() async {
    setState(() {
      _isLoggingOut = true;
    });

    try {
      // Clear the stored token
      await LoginApi.clearToken();
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logged out successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Close the dialog
      if (mounted) {
        Navigator.pop(context);
      }

      // Navigate to login screen and clear all previous routes
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AuthScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() {
        _isLoggingOut = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search conversations...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                style: const TextStyle(fontSize: 16),
                onChanged: _onSearchChanged,
              )
            : const Text('Messages'),
        actions: [
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _stopSearch,
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: _startSearch,
            ),
            // Friend Requests Badge Button
            FriendRequestsBadge(
              key: _badgeKey,
              onTap: _navigateToFriendRequests,
              child: IconButton(
                icon: const Icon(Icons.person_add_outlined),
                onPressed: _navigateToFriendRequests,
                tooltip: 'Friend Requests',
              ),
            ),
            IconButton(
              icon: const Icon(Icons.person_search),
              onPressed: _showUserSearchDialog,
              tooltip: 'Search Users',
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _isLoggingOut ? null : _handleLogout,
              tooltip: 'Logout',
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'friend_requests':
                    _navigateToFriendRequests();
                    break;
                  case 'new_group':
                    // Handle new group
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('New group feature coming soon!')),
                    );
                    break;
                  case 'settings':
                    // Handle settings
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Settings feature coming soon!')),
                    );
                    break;
                  case 'logout':
                    _handleLogout();
                    break;
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(
                  value: 'friend_requests',
                  child: Row(
                    children: [
                      Icon(Icons.person_add_outlined),
                      SizedBox(width: 8),
                      Text('Friend Requests'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'new_group',
                  child: Row(
                    children: [
                      Icon(Icons.group_add),
                      SizedBox(width: 8),
                      Text('New group'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings),
                      SizedBox(width: 8),
                      Text('Settings'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout),
                      SizedBox(width: 8),
                      Text('Logout'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      body: _conversations.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 80,
                    color: theme.hintColor.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No conversations yet',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start a new conversation',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _showUserSearchDialog,
                        icon: const Icon(Icons.person_search),
                        label: const Text('Search Users'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FriendRequestsBadge(
                        onTap: _navigateToFriendRequests,
                        child: OutlinedButton.icon(
                          onPressed: _navigateToFriendRequests,
                          icon: const Icon(Icons.person_add_outlined),
                          label: const Text('Requests'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Quick action buttons for search users and friend requests
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _showUserSearchDialog,
                          icon: const Icon(Icons.person_search, size: 18),
                          label: const Text('Search Users'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FriendRequestsBadge(
                        onTap: _navigateToFriendRequests,
                        child: OutlinedButton.icon(
                          onPressed: _navigateToFriendRequests,
                          icon: const Icon(Icons.person_add_outlined, size: 18),
                          label: const Text('Requests'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Conversations list
                Expanded(
                  child: ListView.builder(
                    itemCount: _conversations.length,
                    itemBuilder: (context, index) {
                      final conversation = _conversations[index];
                      return ConversationTile(
                        conversation: conversation,
                        onTap: () => _navigateToChat(conversation),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startNewChat,
        child: const Icon(Icons.chat),
        tooltip: 'Start new chat',
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
