import 'package:flutter/material.dart';

class MessageInput extends StatefulWidget {
  final ValueChanged<String> onSubmitted;
  final VoidCallback? onAttachmentPressed;
  final VoidCallback? onEmojiPressed;

  const MessageInput({
    Key? key,
    required this.onSubmitted,
    this.onAttachmentPressed,
    this.onEmojiPressed,
  }) : super(key: key);

  @override
  _MessageInputState createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasText = _controller.text.trim().isNotEmpty;
    });
  }

  void _handleSubmitted(String text) {
    final trimmedText = text.trim();
    if (trimmedText.isNotEmpty) {
      widget.onSubmitted(trimmedText);
      _controller.clear();
      setState(() => _hasText = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Attachment button
            IconButton(
              icon: const Icon(Icons.attach_file_rounded),
              onPressed: widget.onAttachmentPressed,
              color: theme.colorScheme.primary,
            ),
            // Emoji button
            IconButton(
              icon: const Icon(Icons.emoji_emotions_outlined),
              onPressed: widget.onEmojiPressed,
              color: theme.colorScheme.primary,
            ),
            // Text input field
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          hintStyle: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                          ),
                        ),
                        style: theme.textTheme.bodyLarge,
                        maxLines: 5,
                        minLines: 1,
                        textInputAction: TextInputAction.send,
                        onSubmitted: _handleSubmitted,
                        onTap: () {
                          // Auto-scroll to bottom when focusing on input
                          // This will be handled in the chat screen
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Send button
            IconButton(
              icon: Icon(
                _hasText ? Icons.send_rounded : Icons.mic_rounded,
                color: _hasText
                    ? theme.colorScheme.primary
                    : theme.colorScheme.primary.withOpacity(0.5),
              ),
              onPressed: _hasText
                  ? () => _handleSubmitted(_controller.text)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
