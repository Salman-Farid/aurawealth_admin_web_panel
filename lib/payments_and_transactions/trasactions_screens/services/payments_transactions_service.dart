import '../../bkash/services/bkash_payment_service.dart';
import '../../shared/models/payment_gateway.dart';
import '../../shared/models/payment_transaction.dart';
import '../../stripe/services/stripe_payment_service.dart';

class PaymentsTransactionsService {
  final StripePaymentService stripeService;
  final BkashPaymentService bkashService;

  PaymentsTransactionsService({
    required this.stripeService,
    required this.bkashService,
  });

  Future<List<PaymentTransaction>> fetchAll({PaymentGateway? gateway}) async {
    if (gateway == PaymentGateway.stripe) {
      return stripeService.fetchTransactions();
    }
    if (gateway == PaymentGateway.bkash) {
      return bkashService.fetchTransactions();
    }

    final results = await Future.wait<List<PaymentTransaction>>([
      stripeService.fetchTransactions(),
      bkashService.fetchTransactions(),
    ]);

    return <PaymentTransaction>[...results[0], ...results[1]]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}
