class BkashPaymentSession {
  final String paymentId;
  final String bkashUrl;
  final String status;
  final String merchantInvoiceNumber;
  final double amount;
  final String currency;
  final Map<String, dynamic> raw;

  const BkashPaymentSession({
    required this.paymentId,
    required this.bkashUrl,
    required this.status,
    required this.merchantInvoiceNumber,
    required this.amount,
    required this.currency,
    this.raw = const <String, dynamic>{},
  });

  factory BkashPaymentSession.fromJson(Map<String, dynamic> json) {
    return BkashPaymentSession(
      paymentId:
          '${json['payment_id'] ?? json['paymentID'] ?? json['id'] ?? ''}',
      bkashUrl: '${json['bkash_url'] ?? json['bkashURL'] ?? json['url'] ?? ''}',
      status: '${json['status'] ?? 'pending'}',
      merchantInvoiceNumber:
          '${json['merchant_invoice_number'] ?? json['merchantInvoiceNumber'] ?? json['invoice'] ?? ''}',
      amount: _doubleFromJson(
        json['amount'] ?? json['amount_bdt'] ?? json['total'],
      ),
      currency: '${json['currency'] ?? 'BDT'}'.toUpperCase(),
      raw: json,
    );
  }

  static double _doubleFromJson(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse('${value ?? 0}') ?? 0;
  }
}
