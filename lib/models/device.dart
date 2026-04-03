class Device {
  final String id;
  final String userId;
  final String? userName;
  final String? userEmail;
  final String token;
  final String deviceType;
  final String? deviceName;
  final bool isActive;
  final DateTime createdAt;

  Device({
    required this.id,
    required this.userId,
    this.userName,
    this.userEmail,
    required this.token,
    required this.deviceType,
    this.deviceName,
    required this.isActive,
    required this.createdAt,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    DateTime createdAt;
    try {
      createdAt = DateTime.parse(json['created_at']?.toString() ?? '');
    } catch (_) {
      createdAt = DateTime.now();
    }

    return Device(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      userName: json['user_name']?.toString(),
      userEmail: json['user_email']?.toString(),
      token: json['token']?.toString() ?? '',
      deviceType: json['device_type']?.toString() ?? 'unknown',
      deviceName: json['device_name']?.toString(),
      isActive: json['is_active'] == true || json['is_active'] == 1,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'user_name': userName,
        'user_email': userEmail,
        'token': token,
        'device_type': deviceType,
        'device_name': deviceName,
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
      };

  String get deviceIcon {
    switch (deviceType.toLowerCase()) {
      case 'android':
        return '📱';
      case 'ios':
        return '🍎';
      case 'web':
        return '🌐';
      default:
        return '📱';
    }
  }

  String get tokenPreview {
    if (token.length <= 20) return token;
    return '${token.substring(0, 20)}...';
  }
}

class DeviceStats {
  final int totalDevices;
  final int activeDevices;
  final int inactiveDevices;
  final int androidDevices;
  final int iosDevices;
  final int webDevices;

  DeviceStats({
    required this.totalDevices,
    required this.activeDevices,
    required this.inactiveDevices,
    required this.androidDevices,
    required this.iosDevices,
    this.webDevices = 0,
  });

  factory DeviceStats.fromJson(Map<String, dynamic> json) {
    return DeviceStats(
      totalDevices: json['total_devices'] ?? 0,
      activeDevices: json['active_devices'] ?? 0,
      inactiveDevices: json['inactive_devices'] ?? 0,
      androidDevices: json['android_devices'] ?? 0,
      iosDevices: json['ios_devices'] ?? 0,
      webDevices: json['web_devices'] ?? 0,
    );
  }
}

class NotificationResponse {
  final bool success;
  final String message;
  final int sentCount;
  final int failedCount;

  NotificationResponse({
    required this.success,
    required this.message,
    required this.sentCount,
    required this.failedCount,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      sentCount: json['sent_count'] ?? 0,
      failedCount: json['failed_count'] ?? 0,
    );
  }

  String get successRate {
    if (sentCount + failedCount == 0) return '0%';
    final rate = (sentCount / (sentCount + failedCount)) * 100;
    return '${rate.toStringAsFixed(1)}%';
  }
}
