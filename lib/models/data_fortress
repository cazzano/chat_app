// friend_request.dart

class FriendRequest {
  final int requestId;
  final String senderUserId;
  final String senderUsername;
  final String status;
  final DateTime timestamp;
  final FriendRequestData requestData;

  FriendRequest({
    required this.requestId,
    required this.senderUserId,
    required this.senderUsername,
    required this.status,
    required this.timestamp,
    required this.requestData,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      requestId: json['request_id'] ?? 0,
      senderUserId: json['sender']['user_id'] ?? '',
      senderUsername: json['sender']['username'] ?? '',
      status: json['status'] ?? 'pending',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      requestData: FriendRequestData.fromJson(json['request_data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'request_id': requestId,
      'sender': {
        'user_id': senderUserId,
        'username': senderUsername,
      },
      'status': status,
      'timestamp': timestamp.toIso8601String(),
      'request_data': requestData.toJson(),
    };
  }

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';

  String get statusDisplayText {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }

  String get formattedTimestamp {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}

class FriendRequestData {
  final String actionRequired;
  final DateTime createdAt;
  final String from;
  final String message;
  final String to;
  final String type;

  FriendRequestData({
    required this.actionRequired,
    required this.createdAt,
    required this.from,
    required this.message,
    required this.to,
    required this.type,
  });

  factory FriendRequestData.fromJson(Map<String, dynamic> json) {
    return FriendRequestData(
      actionRequired: json['action_required'] ?? 'accept_or_reject',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      from: json['from'] ?? '',
      message: json['message'] ?? 'Friend request',
      to: json['to'] ?? '',
      type: json['type'] ?? 'friend_request',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'action_required': actionRequired,
      'created_at': createdAt.toIso8601String(),
      'from': from,
      'message': message,
      'to': to,
      'type': type,
    };
  }
}
