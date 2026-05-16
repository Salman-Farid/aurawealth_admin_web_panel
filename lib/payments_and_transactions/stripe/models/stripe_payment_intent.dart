import '../../shared/models/payment_transaction.dart';

class StripePaymentIntent {
  final String id;
  final String clientSecret;
  final PaymentStatus status;
  final double amount;
  final String currency;
  final String? checkoutUrl;
  final Map<String, dynamic> raw;

  const StripePaymentIntent({
    required this.id,
    required this.clientSecret,
    required this.status,
    required this.amount,
    required this.currency,
    this.checkoutUrl,
    this.raw = const <String, dynamic>{},
  });

  factory StripePaymentIntent.fromJson(Map<String, dynamic> json) {
    return StripePaymentIntent(
      id: '${json['id'] ?? json['payment_intent_id'] ?? ''}',
      clientSecret: '${json['client_secret'] ?? ''}',
      status: PaymentTransaction.fromJson({
        'status': json['status'] ?? 'pending',
      }).status,
      amount: _doubleFromJson(
        json['amount'] ?? json['amount_bdt'] ?? json['total'],
      ),
      currency: '${json['currency'] ?? 'BDT'}'.toUpperCase(),
      checkoutUrl: (json['checkout_url'] ?? json['url'])?.toString(),
      raw: json,
    );
  }

  static double _doubleFromJson(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse('${value ?? 0}') ?? 0;
  }
}
