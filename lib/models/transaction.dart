class Transaction {
  final String id;
  final String type;
  final String status;
  final double grams;
  final double amountBdt;
  final double feePercent;
  final double feeAmount;
  final String? code;
  final DateTime? expiryTime;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final DateTime? paidAt;
  final DateTime? rejectedAt;
  final String? adminNote;
  final String? userId;
  final String? userName;
  final String? userEmail;

  Transaction({
    required this.id,
    required this.type,
    required this.status,
    required this.grams,
    required this.amountBdt,
    required this.feePercent,
    required this.feeAmount,
    this.code,
    this.expiryTime,
    required this.createdAt,
    this.approvedAt,
    this.paidAt,
    this.rejectedAt,
    this.adminNote,
    this.userId,
    this.userName,
    this.userEmail,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      status: json['status'] ?? '',
      grams: (json['grams'] ?? 0).toDouble(),
      amountBdt: (json['amount_bdt'] ?? 0).toDouble(),
      feePercent: (json['fee_percent'] ?? 0).toDouble(),
      feeAmount: (json['fee_amount'] ?? 0).toDouble(),
      code: json['code'],
      expiryTime: json['expiry_time'] != null 
          ? DateTime.parse(json['expiry_time']) 
          : null,
      createdAt: DateTime.parse(json['created_at']),
      approvedAt: json['approved_at'] != null 
          ? DateTime.parse(json['approved_at']) 
          : null,
      paidAt: json['paid_at'] != null 
          ? DateTime.parse(json['paid_at']) 
          : null,
      rejectedAt: json['rejected_at'] != null 
          ? DateTime.parse(json['rejected_at']) 
          : null,
      adminNote: json['admin_note'],
      userId: json['user_id'],
      userName: json['user_name'],
      userEmail: json['user_email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'status': status,
      'grams': grams,
      'amount_bdt': amountBdt,
      'fee_percent': feePercent,
      'fee_amount': feeAmount,
      'code': code,
      'expiry_time': expiryTime?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'approved_at': approvedAt?.toIso8601String(),
      'paid_at': paidAt?.toIso8601String(),
      'rejected_at': rejectedAt?.toIso8601String(),
      'admin_note': adminNote,
      'user_id': userId,
      'user_name': userName,
      'user_email': userEmail,
    };
  }
}
