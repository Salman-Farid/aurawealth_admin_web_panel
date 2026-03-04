class MessageThread {
  final String userId;
  final String userName;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unreadCount;

  MessageThread({
    required this.userId,
    required this.userName,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.unreadCount,
  });

  factory MessageThread.fromJson(Map<String, dynamic> json) {
    return MessageThread(
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? 'Unknown User',
      lastMessage: json['last_message'] ?? '',
      lastMessageAt: DateTime.parse(json['last_message_at']),
      unreadCount: json['unread_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_name': userName,
      'last_message': lastMessage,
      'last_message_at': lastMessageAt.toIso8601String(),
      'unread_count': unreadCount,
    };
  }
}
