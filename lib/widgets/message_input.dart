import 'package:flutter/material.dart';

class MessageInput extends StatefulWidget {
  final ValueChanged<String> onSubmitted;
  final VoidCallback? onAttachmentPressed;
  final VoidCallback? onEmojiPressed;
  final bool isSendingMessage;
  final ScrollController? scrollController;

  const MessageInput({
    Key? key,
    required this.onSubmitted,
    this.onAttachmentPressed,
    this.onEmojiPressed,
    this.isSendingMessage = false,
    this.scrollController,
  }) : super(key: key);

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;
  bool _shouldMaintainFocus = true; // Flag to control persistent focus

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    
    // Auto-focus on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    
    _focusNode.addListener(() {
      print('DEBUG MessageInput: Focus changed - hasFocus: ${_focusNode.hasFocus}');
      
      // Always regain focus if lost and we should maintain focus
      if (!_focusNode.hasFocus && mounted && _shouldMaintainFocus) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted && !_focusNode.hasFocus && _shouldMaintainFocus) {
            print('DEBUG MessageInput: Restoring focus automatically');
            _focusNode.requestFocus();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    print('DEBUG MessageInput: Disposing MessageInput');
    _shouldMaintainFocus = false; // Stop focus restoration during disposal
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasText = _controller.text.trim().isNotEmpty;
    });
    print('DEBUG MessageInput: Text changed - hasText: $_hasText, text length: ${_controller.text.length}');
  }

  Future<void> _handleSubmitted(String text) async {
    final trimmedText = text.trim();
    print('DEBUG MessageInput: _handleSubmitted called - text: "$trimmedText"');
    
    if (trimmedText.isNotEmpty) {
      print('DEBUG MessageInput: About to call onSubmitted callback');
      
      // Clear the text immediately
      _controller.clear();
      setState(() {
        _hasText = false;
      });
      
      // Call the parent's submit handler
      widget.onSubmitted(trimmedText);
      
      // Ensure focus stays on input after submission
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) {
          _focusNode.requestFocus();
        }
      });
      
      print('DEBUG MessageInput: Called onSubmitted');
    } else {
      print('DEBUG MessageInput: Submit rejected - empty text');
    }
  }

  void _scrollToBottom() {
    if (widget.scrollController != null && widget.scrollController!.hasClients) {
      widget.scrollController!.animateTo(
        widget.scrollController!.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
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
                        focusNode: _focusNode,
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
                        // Use onSubmitted for Enter key on all platforms
                        onSubmitted: _handleSubmitted,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        onTap: () {
                          // Auto-scroll to bottom when focusing on input
                          Future.delayed(const Duration(milliseconds: 300), () {
                            _scrollToBottom();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Send button (show when text is present)
            if (_hasText)
              IconButton(
                icon: Icon(
                  Icons.send_rounded,
                  color: theme.colorScheme.primary,
                ),
                onPressed: () => _handleSubmitted(_controller.text),
              )
            // Mic button (when no text)
            else
              IconButton(
                icon: Icon(
                  Icons.mic_rounded,
                  color: theme.colorScheme.primary.withOpacity(0.5),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Voice message coming soon!')),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
