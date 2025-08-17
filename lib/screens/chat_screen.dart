import 'package:flutter/material.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';
import '../data/mock_data.dart';

class ChatScreen extends StatefulWidget {
  final Conversation conversation;

  const ChatScreen({
    Key? key,
    required this.conversation,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late List<Message> _messages;
  late String _contactName;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  bool _showEmojiPicker = false;

  @override
  void initState() {
    super.initState();
    _messages = List.from(widget.conversation.messages);
    _contactName = widget.conversation.contactName;
    
    // Scroll to bottom when the widget is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;

    final newMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isSentByMe: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(newMessage);
    });

    // Scroll to bottom after adding a new message
    _scrollToBottom();

    // In a real app, you would send the message to a server here
    // and update the UI when you get a response
  }

  void _onAttachmentPressed() {
    // Show attachment options
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  Navigator.pop(context);
                  // Handle photo library selection
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  // Handle camera
                },
              ),
              ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: const Text('Document'),
                onTap: () {
                  Navigator.pop(context);
                  // Handle document selection
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _onEmojiPressed() {
    setState(() {
      _showEmojiPicker = !_showEmojiPicker;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isGroupChat = _contactName == 'Team Flutter'; // Simple check for demo

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.primaryColor.withOpacity(0.2),
              backgroundImage: widget.conversation.avatarUrl != null
                  ? NetworkImage(widget.conversation.avatarUrl!)
                  : null,
              child: widget.conversation.avatarUrl == null
                  ? Text(
                      _contactName[0].toUpperCase(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _contactName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isGroupChat)
                    Text(
                      '${_messages.length} participants',
                      style: theme.textTheme.labelSmall,
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: () {
              // Handle call
            },
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {
              // Handle video call
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              // Handle menu item selection
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'view_contact',
                child: Text('View contact'),
              ),
              const PopupMenuItem(
                value: 'media',
                child: Text('Media, links, and docs'),
              ),
              const PopupMenuItem(
                value: 'search',
                child: Text('Search'),
              ),
              const PopupMenuItem(
                value: 'mute',
                child: Text('Mute notifications'),
              ),
              const PopupMenuItem(
                value: 'wallpaper',
                child: Text('Wallpaper'),
              ),
              const PopupMenuItem(
                value: 'more',
                child: Text('More'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: GestureDetector(
              onTap: () {
                // Dismiss keyboard when tapping on messages
                FocusScope.of(context).unfocus();
                if (_showEmojiPicker) {
                  setState(() => _showEmojiPicker = false);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: const AssetImage('assets/chat_bg.png'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      theme.colorScheme.surface.withOpacity(0.9),
                      BlendMode.dstOver,
                    ),
                  ),
                ),
                child: _messages.isEmpty
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
                              'No messages yet',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.hintColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Send your first message',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.hintColor,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isGroupMessage = isGroupChat && !message.isSentByMe;
                          final showSenderName = isGroupMessage &&
                              (index == 0 ||
                                  _messages[index - 1].isSentByMe !=
                                      message.isSentByMe);

                          return MessageBubble(
                            message: message,
                            showSenderName: showSenderName,
                            isGroupChat: isGroupChat,
                          );
                        },
                      ),
              ),
            ),
          ),
          // Message input
          MessageInput(
            onSubmitted: _handleSubmitted,
            onAttachmentPressed: _onAttachmentPressed,
            onEmojiPressed: _onEmojiPressed,
          ),
          // Emoji picker (conditionally shown)
          if (_showEmojiPicker)
            SizedBox(
              height: 250,
              child: Placeholder(
                fallbackHeight: 250,
                color: theme.colorScheme.surfaceVariant,
                child: Center(
                  child: Text(
                    'Emoji Picker',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
