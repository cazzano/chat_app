import 'package:flutter/material.dart';
import '../models/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool showSenderName;
  final bool isGroupChat;

  const MessageBubble({
    Key? key,
    required this.message,
    this.showSenderName = false,
    this.isGroupChat = false,
  }) : super(key: key);

  Widget _buildStatusIcon(ThemeData theme) {
    if (!message.isSentByMe) return const SizedBox.shrink();

    switch (message.status) {
      case MessageStatus.pending:
        return SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: Colors.black54,
          ),
        );
      case MessageStatus.sent:
        return Icon(
          Icons.check,
          size: 16,
          color: Colors.black54,
        );
      case MessageStatus.delivered:
        return Icon(
          Icons.done_all,
          size: 16,
          color: Colors.black54,
        );
      case MessageStatus.read:
        return Icon(
          Icons.done_all,
          size: 16,
          color: const Color(0xFF4FC3F7), // WhatsApp blue
        );
      case MessageStatus.failed:
        return Icon(
          Icons.error_outline,
          size: 16,
          color: Colors.red,
        );
    }
  }

  String _getStatusText() {
    switch (message.status) {
      case MessageStatus.pending:
        return 'Sending...';
      case MessageStatus.sent:
        return _formatTime(message.timestamp);
      case MessageStatus.delivered:
        return _formatTime(message.timestamp);
      case MessageStatus.read:
        return _formatTime(message.timestamp);
      case MessageStatus.failed:
        return 'Failed to send';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSentByMe = message.isSentByMe;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Row(
        mainAxisAlignment: isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Add spacing from left edge for sent messages
          if (isSentByMe) const Flexible(flex: 1, child: SizedBox()),
          
          // Message bubble
          Flexible(
            flex: 3,
            child: Column(
              crossAxisAlignment: isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (showSenderName && isGroupChat && !isSentByMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 2),
                    child: Text(
                      message.senderId ?? 'Unknown',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  margin: EdgeInsets.only(
                    left: isSentByMe ? 0 : 0,
                    right: isSentByMe ? 0 : 0,
                  ),
                  decoration: BoxDecoration(
                    color: isSentByMe
                        ? const Color(0xFFDCF8C6) // WhatsApp green for sent messages
                        : Colors.white, // White for received messages
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isSentByMe ? 18 : 5),
                      bottomRight: Radius.circular(isSentByMe ? 5 : 18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 1,
                        offset: const Offset(0, 1),
                      ),
                    ],
                    border: isSentByMe 
                        ? null 
                        : Border.all(
                            color: Colors.grey.withOpacity(0.2),
                            width: 0.5,
                          ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Message text
                      Container(
                        width: double.infinity,
                        child: Text(
                          message.text,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Time and status row
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getStatusText(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                          if (isSentByMe) ...[
                            const SizedBox(width: 4),
                            _buildStatusIcon(theme),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Add spacing from right edge for received messages
          if (!isSentByMe) const Flexible(flex: 1, child: SizedBox()),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
