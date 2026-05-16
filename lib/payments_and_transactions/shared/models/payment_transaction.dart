import 'payment_gateway.dart';

enum PaymentStatus {
  draft,
  pending,
  processing,
  succeeded,
  failed,
  cancelled,
  refunded,
}

extension PaymentStatusX on PaymentStatus {
  String get label {
    switch (this) {
      case PaymentStatus.draft:
        return 'Draft';
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.processing:
        return 'Processing';
      case PaymentStatus.succeeded:
        return 'Succeeded';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.cancelled:
        return 'Cancelled';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }

  bool get isSuccess => this == PaymentStatus.succeeded;
  bool get isFailure =>
      this == PaymentStatus.failed || this == PaymentStatus.cancelled;
  bool get isBusy =>
      this == PaymentStatus.pending || this == PaymentStatus.processing;
}

class PaymentTransaction {
  final String id;
  final PaymentGateway gateway;
  final PaymentStatus status;
  final double amount;
  final String currency;
  final String customerName;
  final String customerEmail;
  final String? paymentIntentId;
  final String? checkoutUrl;
  final String? merchantInvoiceNumber;
  final String? note;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic> raw;

  const PaymentTransaction({
    required this.id,
    required this.gateway,
    required this.status,
    required this.amount,
    required this.currency,
    required this.customerName,
    required this.customerEmail,
    required this.createdAt,
    this.paymentIntentId,
    this.checkoutUrl,
    this.merchantInvoiceNumber,
    this.note,
    this.updatedAt,
    this.raw = const <String, dynamic>{},
  });

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) {
    final gatewayValue = '${json['gateway'] ?? json['provider'] ?? 'stripe'}'
        .toLowerCase();
    final statusValue = '${json['status'] ?? 'pending'}'.toLowerCase();

    return PaymentTransaction(
      id: '${json['id'] ?? json['transaction_id'] ?? json['payment_id'] ?? ''}',
      gateway: gatewayValue == 'bkash'
          ? PaymentGateway.bkash
          : PaymentGateway.stripe,
      status: _statusFromString(statusValue),
      amount: _doubleFromJson(
        json['amount'] ?? json['amount_bdt'] ?? json['total'],
      ),
      currency: '${json['currency'] ?? 'BDT'}'.toUpperCase(),
      customerName: '${json['customer_name'] ?? json['name'] ?? 'Customer'}',
      customerEmail: '${json['customer_email'] ?? json['email'] ?? ''}',
      paymentIntentId: json['payment_intent_id']?.toString(),
      checkoutUrl: (json['checkout_url'] ?? json['url'] ?? json['bkash_url'])
          ?.toString(),
      merchantInvoiceNumber:
          (json['merchant_invoice_number'] ??
                  json['invoice'] ??
                  json['invoice_id'])
              ?.toString(),
      note: json['note']?.toString(),
      createdAt: _dateFromJson(json['created_at']) ?? DateTime.now(),
      updatedAt: _dateFromJson(json['updated_at']),
      raw: json,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'gateway': gateway.id,
    'status': status.label.toLowerCase(),
    'amount': amount,
    'currency': currency,
    'customer_name': customerName,
    'customer_email': customerEmail,
    'payment_intent_id': paymentIntentId,
    'checkout_url': checkoutUrl,
    'merchant_invoice_number': merchantInvoiceNumber,
    'note': note,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };

  PaymentTransaction copyWith({
    String? id,
    PaymentGateway? gateway,
    PaymentStatus? status,
    double? amount,
    String? currency,
    String? customerName,
    String? customerEmail,
    String? paymentIntentId,
    String? checkoutUrl,
    String? merchantInvoiceNumber,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? raw,
  }) {
    return PaymentTransaction(
      id: id ?? this.id,
      gateway: gateway ?? this.gateway,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      paymentIntentId: paymentIntentId ?? this.paymentIntentId,
      checkoutUrl: checkoutUrl ?? this.checkoutUrl,
      merchantInvoiceNumber:
          merchantInvoiceNumber ?? this.merchantInvoiceNumber,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      raw: raw ?? this.raw,
    );
  }

  static PaymentStatus _statusFromString(String value) {
    switch (value) {
      case 'draft':
        return PaymentStatus.draft;
      case 'processing':
        return PaymentStatus.processing;
      case 'succeeded':
      case 'success':
      case 'completed':
      case 'paid':
        return PaymentStatus.succeeded;
      case 'failed':
      case 'error':
        return PaymentStatus.failed;
      case 'cancelled':
      case 'canceled':
        return PaymentStatus.cancelled;
      case 'refunded':
        return PaymentStatus.refunded;
      case 'pending':
      default:
        return PaymentStatus.pending;
    }
  }

  static double _doubleFromJson(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse('${value ?? 0}') ?? 0;
  }

  static DateTime? _dateFromJson(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
