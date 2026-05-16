class BkashConfig {
  final String createPaymentPath;
  final String executePaymentPath;
  final String queryPaymentPath;
  final String transactionsPath;
  final bool sandbox;

  const BkashConfig({
    this.createPaymentPath = '/payments/bkash/create',
    this.executePaymentPath = '/payments/bkash/execute',
    this.queryPaymentPath = '/payments/bkash/query',
    this.transactionsPath = '/payments/bkash/transactions',
    this.sandbox = true,
  });
}
