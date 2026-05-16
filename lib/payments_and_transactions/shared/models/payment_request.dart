class PaymentRequest {
  final double amount;
  final String currency;
  final String customerName;
  final String customerEmail;
  final String description;
  final String? userId;
  final String? merchantInvoiceNumber;
  final Map<String, String> metadata;

  const PaymentRequest({
    required this.amount,
    this.currency = 'BDT',
    required this.customerName,
    required this.customerEmail,
    required this.description,
    this.userId,
    this.merchantInvoiceNumber,
    this.metadata = const <String, String>{},
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
    'amount': amount,
    'currency': currency.toUpperCase(),
    'customer_name': customerName,
    'customer_email': customerEmail,
    'description': description,
    if (userId != null && userId!.isNotEmpty) 'user_id': userId,
    if (merchantInvoiceNumber != null && merchantInvoiceNumber!.isNotEmpty)
      'merchant_invoice_number': merchantInvoiceNumber,
    if (metadata.isNotEmpty) 'metadata': metadata,
  };

  PaymentRequest copyWith({
    double? amount,
    String? currency,
    String? customerName,
    String? customerEmail,
    String? description,
    String? userId,
    String? merchantInvoiceNumber,
    Map<String, String>? metadata,
  }) {
    return PaymentRequest(
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      merchantInvoiceNumber:
          merchantInvoiceNumber ?? this.merchantInvoiceNumber,
      metadata: metadata ?? this.metadata,
    );
  }
}
