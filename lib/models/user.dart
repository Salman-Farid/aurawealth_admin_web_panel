class User {
  final String id;
  final String? firebaseUid;
  final String? email;
  final String? phoneNumber;
  final DateTime createdAt;
  final bool phoneVerified;
  final String kycStatus;
  final double? totalGrams;
  final double? lockedGrams;
  final double? availableGrams;

  User({
    required this.id,
    this.firebaseUid,
    this.email,
    this.phoneNumber,
    required this.createdAt,
    required this.phoneVerified,
    required this.kycStatus,
    this.totalGrams,
    this.lockedGrams,
    this.availableGrams,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['user_id'] ?? '',
      firebaseUid: json['firebase_uid'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      createdAt: DateTime.parse(json['created_at']),
      phoneVerified: json['phone_verified'] ?? false,
      kycStatus: json['kyc_status'] ?? 'pending',
      totalGrams: json['total_grams']?.toDouble(),
      lockedGrams: json['locked_grams']?.toDouble(),
      availableGrams: json['available_grams']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firebase_uid': firebaseUid,
      'email': email,
      'phone_number': phoneNumber,
      'created_at': createdAt.toIso8601String(),
      'phone_verified': phoneVerified,
      'kyc_status': kycStatus,
      'total_grams': totalGrams,
      'locked_grams': lockedGrams,
      'available_grams': availableGrams,
    };
  }
}
