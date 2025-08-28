import 'package:flutter/material.dart';
import '../models/friend_request.dart';

class FriendRequestTile extends StatefulWidget {
  final FriendRequest friendRequest;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const FriendRequestTile({
    Key? key,
    required this.friendRequest,
    this.onAccept,
    this.onReject,
  }) : super(key: key);

  @override
  _FriendRequestTileState createState() => _FriendRequestTileState();
}

class _FriendRequestTileState extends State<FriendRequestTile>
    with SingleTickerProviderStateMixin {
  bool _isProcessing = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _handleAction(VoidCallback? action) async {
    if (action == null || _isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    try {
      action();
      // Wait a bit for the API call to complete
      await Future.delayed(const Duration(milliseconds: 500));
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Color _getStatusColor(BuildContext context) {
    switch (widget.friendRequest.status) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Theme.of(context).hintColor;
    }
  }

  IconData _getStatusIcon() {
    switch (widget.friendRequest.status) {
      case 'accepted':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'pending':
        return Icons.schedule;
      default:
        return Icons.help_outline;
    }
  }

  Widget _buildActionButtons() {
    // For accepted requests, show status only
    if (widget.friendRequest.status == 'accepted') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _getStatusColor(context).withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getStatusColor(context).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getStatusIcon(),
              size: 16,
              color: _getStatusColor(context),
            ),
            const SizedBox(width: 4),
            Text(
              widget.friendRequest.statusDisplayText,
              style: TextStyle(
                color: _getStatusColor(context),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    // For pending requests, show accept/reject buttons
    if (widget.friendRequest.status == 'pending') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Reject button
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.red.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: _isProcessing ? null : () => _handleAction(widget.onReject),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: _isProcessing
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.red.withOpacity(0.6),
                          ),
                        )
                      : Icon(
                          Icons.close,
                          color: Colors.red.withOpacity(0.8),
                          size: 20,
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Accept button
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: _isProcessing ? null : () => _handleAction(widget.onAccept),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 20,
                        ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // For rejected requests, show re-accept button
    if (widget.friendRequest.status == 'rejected') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(context).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getStatusColor(context).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getStatusIcon(),
                  size: 12,
                  color: _getStatusColor(context),
                ),
                const SizedBox(width: 4),
                Text(
                  'Rejected',
                  style: TextStyle(
                    color: _getStatusColor(context),
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Re-accept button
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.green.withOpacity(0.1),
              border: Border.all(
                color: Colors.green.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _isProcessing ? null : () => _handleAction(widget.onAccept),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _isProcessing
                          ? SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.green.withOpacity(0.8),
                              ),
                            )
                          : Icon(
                              Icons.refresh,
                              color: Colors.green.withOpacity(0.8),
                              size: 14,
                            ),
                      const SizedBox(width: 4),
                      Text(
                        'Re-accept',
                        style: TextStyle(
                          color: Colors.green.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Default fallback
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary.withOpacity(0.8),
                          theme.colorScheme.secondary.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        widget.friendRequest.senderUsername[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // User info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.friendRequest.senderUsername,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'User ID: ${widget.friendRequest.senderUserId}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Action buttons
                  _buildActionButtons(),
                ],
              ),
              const SizedBox(height: 12),
              // Message
              if (widget.friendRequest.requestData.message.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.hintColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.hintColor.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 16,
                        color: theme.hintColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.friendRequest.requestData.message,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.normal,
                            color: theme.colorScheme.onSurface.withOpacity(0.8),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              // Footer with timestamp
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: theme.hintColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.friendRequest.formattedTimestamp,
                    style: theme.textTheme.labelSmall,
                  ),
                  const Spacer(),
                  if (widget.friendRequest.status != 'pending') ...[
                    Text(
                      'Request ID: ${widget.friendRequest.requestId}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
