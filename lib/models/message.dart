class Message {
  final String id;
  final String direction; // user_to_admin | admin_to_user
  final String body;
  final bool isRead;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.direction,
    required this.body,
    required this.isRead,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? '',
      direction: json['direction'] ?? '',
      body: json['body'] ?? '',
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'direction': direction,
      'body': body,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }
  
  bool get isFromUser => direction == 'user_to_admin';
  bool get isFromAdmin => direction == 'admin_to_user';
}
