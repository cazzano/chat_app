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
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        );
      case MessageStatus.sent:
        return Icon(
          Icons.check,
          size: 14,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        );
      case MessageStatus.delivered:
        return Icon(
          Icons.done_all,
          size: 14,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        );
      case MessageStatus.read:
        return Icon(
          Icons.done_all,
          size: 14,
          color: Colors.blue,
        );
      case MessageStatus.failed:
        return Icon(
          Icons.error_outline,
          size: 14,
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
      child: Column(
        crossAxisAlignment:
            isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (showSenderName && isGroupChat && !isSentByMe)
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 2),
              child: Text(
                message.senderId ?? 'Unknown',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
            ),
          Row(
            mainAxisAlignment:
                isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isSentByMe && isGroupChat) const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSentByMe
                        ? const Color(0xFFDCF8C6) // WhatsApp green for sent messages
                        : theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isSentByMe ? 16 : 4),
                      bottomRight: Radius.circular(isSentByMe ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
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
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Time and status row
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getStatusText(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                              fontSize: 11,
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
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
