import 'package:get/get.dart';

import '../../shared/models/payment_gateway.dart';
import '../../shared/models/payment_transaction.dart';
import '../models/payment_transaction_filter.dart';
import '../services/payments_transactions_service.dart';

class PaymentsTransactionsController extends GetxController {
  final PaymentsTransactionsService service;

  PaymentsTransactionsController({required this.service});

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final transactions = <PaymentTransaction>[].obs;
  final filter = const PaymentTransactionFilter().obs;

  List<PaymentTransaction> get filteredTransactions {
    final current = filter.value;
    final query = current.searchQuery.trim().toLowerCase();
    return transactions.where((tx) {
      final matchesGateway =
          current.gateway == null || tx.gateway == current.gateway;
      final matchesStatus =
          current.status.isEmpty ||
          tx.status.label.toLowerCase() == current.status.toLowerCase();
      final matchesQuery =
          query.isEmpty ||
          tx.id.toLowerCase().contains(query) ||
          tx.customerName.toLowerCase().contains(query) ||
          tx.customerEmail.toLowerCase().contains(query) ||
          tx.gateway.title.toLowerCase().contains(query);
      return matchesGateway && matchesStatus && matchesQuery;
    }).toList();
  }

  int get succeededCount =>
      transactions.where((tx) => tx.status == PaymentStatus.succeeded).length;
  int get pendingCount => transactions.where((tx) => tx.status.isBusy).length;
  int get failedCount => transactions.where((tx) => tx.status.isFailure).length;
  double get totalVolume => transactions.fold(0, (sum, tx) => sum + tx.amount);

  @override
  void onInit() {
    super.onInit();
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      transactions.assignAll(
        await service.fetchAll(gateway: filter.value.gateway),
      );
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void setGateway(PaymentGateway? gateway) {
    filter.value = filter.value.copyWith(
      gateway: gateway,
      clearGateway: gateway == null,
    );
    loadTransactions();
  }

  void setSearch(String value) {
    filter.value = filter.value.copyWith(searchQuery: value);
  }

  void setStatus(String value) {
    filter.value = filter.value.copyWith(status: value);
  }

  void clearFilters() {
    filter.value = const PaymentTransactionFilter();
    loadTransactions();
  }
}
