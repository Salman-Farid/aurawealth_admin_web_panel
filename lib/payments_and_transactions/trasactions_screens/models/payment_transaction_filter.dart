import '../../shared/models/payment_gateway.dart';

class PaymentTransactionFilter {
  final PaymentGateway? gateway;
  final String searchQuery;
  final String status;

  const PaymentTransactionFilter({
    this.gateway,
    this.searchQuery = '',
    this.status = '',
  });

  PaymentTransactionFilter copyWith({
    PaymentGateway? gateway,
    bool clearGateway = false,
    String? searchQuery,
    String? status,
  }) {
    return PaymentTransactionFilter(
      gateway: clearGateway ? null : gateway ?? this.gateway,
      searchQuery: searchQuery ?? this.searchQuery,
      status: status ?? this.status,
    );
  }
}
