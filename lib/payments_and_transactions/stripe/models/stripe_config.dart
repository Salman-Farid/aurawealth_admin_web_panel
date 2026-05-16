class StripeConfig {
  final String publishableKey;
  final String createPaymentIntentPath;
  final String confirmPaymentPath;
  final String transactionsPath;
  final bool enableRedirectCheckout;

  const StripeConfig({
    required this.publishableKey,
    this.createPaymentIntentPath = '/payments/stripe/payment-intents',
    this.confirmPaymentPath = '/payments/stripe/confirm',
    this.transactionsPath = '/payments/stripe/transactions',
    this.enableRedirectCheckout = true,
  });

  bool get isConfigured => publishableKey.trim().isNotEmpty;
}
