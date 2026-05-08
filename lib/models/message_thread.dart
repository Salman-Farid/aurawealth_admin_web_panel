import '../core/constants/app_constants.dart';

class MessageThread {
  final String userId;
  final String userName;
  final String? userEmail;
  final String? phoneNumber;
  final String? photoUrl;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unreadCount;

  MessageThread({
    required this.userId,
    required this.userName,
    this.userEmail,
    this.phoneNumber,
    this.photoUrl,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.unreadCount,
  });

  static String? _cleanString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return null;
    return text;
  }

  static String? _firstString(List<dynamic> values) {
    for (final value in values) {
      final cleaned = _cleanString(value);
      if (cleaned != null) return cleaned;
    }
    return null;
  }

  static Map<String, dynamic> _nestedMap(
    Map<String, dynamic> json,
    String key,
  ) {
    final value = json[key];
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  static DateTime _parseDate(dynamic value) {
    final text = _cleanString(value);
    if (text == null) return DateTime.now();
    return DateTime.tryParse(text) ?? DateTime.now();
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String? _normalizeImageUrl(dynamic value) {
    final raw = _cleanString(value);
    if (raw == null) return null;
    if (raw.startsWith('http://') ||
        raw.startsWith('https://') ||
        raw.startsWith('data:')) {
      return raw;
    }
    final path = raw.startsWith('/') ? raw : '/$raw';
    return '${AppConstants.baseUrl}$path';
  }

  factory MessageThread.fromJson(Map<String, dynamic> json) {
    final user = _nestedMap(json, 'user');
    final profile = _nestedMap(json, 'profile');
    final firestore = _nestedMap(json, 'firestore');

    final userId =
        _firstString([
          json['user_id'],
          json['userId'],
          json['firebase_uid'],
          json['firebaseUid'],
          json['uid'],
          user['firebase_uid'],
          user['firebaseUid'],
          user['uid'],
          user['id'],
          profile['firebase_uid'],
          profile['uid'],
          firestore['firebase_uid'],
          firestore['uid'],
        ]) ??
        '';

    final userName =
        _firstString([
          json['user_name'],
          json['userName'],
          json['name'],
          json['displayName'],
          user['name'],
          user['displayName'],
          profile['name'],
          profile['displayName'],
          firestore['name'],
          firestore['displayName'],
        ]) ??
        'User';

    final photoUrl =
        _normalizeImageUrl(json['profileImageUrl']) ??
        _normalizeImageUrl(json['profile_image_url']) ??
        _normalizeImageUrl(json['photo_url']) ??
        _normalizeImageUrl(json['profile_photo']) ??
        _normalizeImageUrl(json['avatar']) ??
        _normalizeImageUrl(json['image']) ??
        _normalizeImageUrl(user['profileImageUrl']) ??
        _normalizeImageUrl(user['profile_image_url']) ??
        _normalizeImageUrl(user['photo_url']) ??
        _normalizeImageUrl(user['avatar']) ??
        _normalizeImageUrl(profile['profileImageUrl']) ??
        _normalizeImageUrl(profile['profile_image_url']) ??
        _normalizeImageUrl(firestore['profileImageUrl']) ??
        _normalizeImageUrl(firestore['profile_image_url']);

    return MessageThread(
      userId: userId,
      userName: userName,
      userEmail: _firstString([
        json['email'],
        json['user_email'],
        json['userEmail'],
        user['email'],
        user['user_email'],
        profile['email'],
        firestore['email'],
      ]),
      phoneNumber: _firstString([
        json['phoneNumber'],
        json['phone_number'],
        json['phone'],
        user['phoneNumber'],
        user['phone_number'],
        user['phone'],
        profile['phoneNumber'],
        profile['phone_number'],
        firestore['phoneNumber'],
        firestore['phone_number'],
      ]),
      photoUrl: photoUrl,
      lastMessage:
          _firstString([
            json['last_message'],
            json['lastMessage'],
            json['message'],
            json['body'],
          ]) ??
          '',
      lastMessageAt: _parseDate(
        json['last_message_at'] ?? json['lastMessageAt'] ?? json['updated_at'],
      ),
      unreadCount: _parseInt(json['unread_count'] ?? json['unreadCount']),
    );
  }

  MessageThread copyWith({
    String? userId,
    String? userName,
    String? userEmail,
    String? phoneNumber,
    String? photoUrl,
    String? lastMessage,
    DateTime? lastMessageAt,
    int? unreadCount,
  }) {
    return MessageThread(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_name': userName,
      'user_email': userEmail,
      'phoneNumber': phoneNumber,
      'profileImageUrl': photoUrl,
      'last_message': lastMessage,
      'last_message_at': lastMessageAt.toIso8601String(),
      'unread_count': unreadCount,
    };
  }
}
