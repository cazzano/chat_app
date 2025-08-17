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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSentByMe = message.isSentByMe;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSentByMe
                        ? theme.colorScheme.primary.withOpacity(0.1)
                        : theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isSentByMe ? 16 : 4),
                      bottomRight: Radius.circular(isSentByMe ? 4 : 16),
                    ),
                    border: Border.all(
                      color: isSentByMe
                          ? theme.colorScheme.primary.withOpacity(0.2)
                          : theme.colorScheme.outline.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        message.text,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: isSentByMe
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatTime(message.timestamp),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: (isSentByMe
                                      ? theme.colorScheme.onSurface
                                      : theme.colorScheme.onSurfaceVariant)
                                  .withOpacity(0.6),
                          fontSize: 10,
                        ),
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
