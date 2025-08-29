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
  bool _isSubmitting = false;
  bool _shouldMaintainFocus = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    
    // Debug: Monitor focus changes
    _focusNode.addListener(() {
      print('DEBUG MessageInput: Focus changed - hasFocus: ${_focusNode.hasFocus}');
    });
  }

  @override
  void dispose() {
    print('DEBUG MessageInput: Disposing MessageInput');
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
    print('DEBUG MessageInput: _handleSubmitted called - text: "$trimmedText", isSendingMessage: ${widget.isSendingMessage}, isSubmitting: $_isSubmitting');
    
    if (trimmedText.isNotEmpty && !widget.isSendingMessage && !_isSubmitting) {
      setState(() {
        _isSubmitting = true;
        _shouldMaintainFocus = true; // Flag to maintain focus after submission
      });
      
      print('DEBUG MessageInput: About to call onSubmitted callback');
      
      // Clear the text first
      _controller.clear();
      setState(() {
        _hasText = false;
      });
      
      // Call the parent's submit handler
      widget.onSubmitted(trimmedText);
      
      print('DEBUG MessageInput: Called onSubmitted, scheduling focus restoration');
      
      // More efficient focus restoration - wait for parent to finish processing
      _scheduleEfficientFocusRestoration();
      
      setState(() {
        _isSubmitting = false;
      });
    } else {
      print('DEBUG MessageInput: Submit rejected - trimmedText.isEmpty: ${trimmedText.isEmpty}, isSendingMessage: ${widget.isSendingMessage}, isSubmitting: $_isSubmitting');
    }
  }

  void _scheduleEfficientFocusRestoration() {
    print('DEBUG MessageInput: _scheduleEfficientFocusRestoration called');
    
    // Single, well-timed focus restoration instead of multiple attempts
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted && _shouldMaintainFocus && !_focusNode.hasFocus) {
        print('DEBUG MessageInput: Executing scheduled focus restoration');
        _focusNode.requestFocus();
        _shouldMaintainFocus = false;
        
        // Fallback focus attempt if the first one fails
        Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted && !_focusNode.hasFocus) {
            print('DEBUG MessageInput: Fallback focus restoration');
            _focusNode.requestFocus();
          }
        });
      }
    });
  }

  @override
  void didUpdateWidget(MessageInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // When parent finishes sending message, restore focus if needed
    if (oldWidget.isSendingMessage && !widget.isSendingMessage && _shouldMaintainFocus) {
      print('DEBUG MessageInput: Parent finished sending, restoring focus');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_focusNode.hasFocus) {
          _focusNode.requestFocus();
        }
        _shouldMaintainFocus = false;
      });
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
              onPressed: widget.isSendingMessage ? null : widget.onAttachmentPressed,
              color: theme.colorScheme.primary,
            ),
            // Emoji button
            IconButton(
              icon: const Icon(Icons.emoji_emotions_outlined),
              onPressed: widget.isSendingMessage ? null : widget.onEmojiPressed,
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
                        onSubmitted: _handleSubmitted,
                        enabled: !widget.isSendingMessage,
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
            // Send button
            IconButton(
              icon: widget.isSendingMessage
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.primary,
                      ),
                    )
                  : Icon(
                      _hasText ? Icons.send_rounded : Icons.mic_rounded,
                      color: _hasText && !widget.isSendingMessage
                          ? theme.colorScheme.primary
                          : theme.colorScheme.primary.withOpacity(0.5),
                    ),
              onPressed: _hasText && !widget.isSendingMessage
                  ? () => _handleSubmitted(_controller.text)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
