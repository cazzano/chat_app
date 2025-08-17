import 'package:flutter/material.dart';
import '../models/conversation.dart';
import '../data/mock_data.dart';
import '../widgets/conversation_tile.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late List<Conversation> _conversations;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

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
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white, fontSize: 16),
                onChanged: _onSearchChanged,
              )
            : const Text('Messages'),
        actions: [
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _stopSearch,
            )
          else
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: _startSearch,
            ),
          if (!_isSearching)
            PopupMenuButton<String>(
              onSelected: (value) {
                // Handle menu item selection
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(
                  value: 'new_group',
                  child: Text('New group'),
                ),
                const PopupMenuItem(
                  value: 'settings',
                  child: Text('Settings'),
                ),
              ],
            ),
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
                ],
              ),
            )
          : ListView.builder(
              itemCount: _conversations.length,
              itemBuilder: (context, index) {
                final conversation = _conversations[index];
                return ConversationTile(
                  conversation: conversation,
                  onTap: () => _navigateToChat(conversation),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startNewChat,
        child: const Icon(Icons.chat),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
