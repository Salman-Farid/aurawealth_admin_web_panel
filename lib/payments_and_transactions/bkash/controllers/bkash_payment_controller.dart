import 'package:get/get.dart';

import '../../shared/models/payment_request.dart';
import '../../shared/models/payment_transaction.dart';
import '../models/bkash_payment_session.dart';
import '../services/bkash_payment_service.dart';

class BkashPaymentController extends GetxController {
  final BkashPaymentService service;

  BkashPaymentController({required this.service});

  final isLoading = false.obs;
  final isCreatingSession = false.obs;
  final errorMessage = ''.obs;
  final transactions = <PaymentTransaction>[].obs;
  final currentSession = Rxn<BkashPaymentSession>();
  final lastTransaction = Rxn<PaymentTransaction>();

  Future<void> loadTransactions() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      transactions.assignAll(await service.fetchTransactions());
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<BkashPaymentSession?> createPayment(PaymentRequest request) async {
    isCreatingSession.value = true;
    errorMessage.value = '';
    try {
      final session = await service.createPayment(request);
      currentSession.value = session;
      return session;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('bKash Error', errorMessage.value);
      return null;
    } finally {
      isCreatingSession.value = false;
    }
  }

  Future<PaymentTransaction?> executeCurrentPayment() async {
    final session = currentSession.value;
    if (session == null || session.paymentId.isEmpty) {
      errorMessage.value = 'No bKash payment session selected';
      return null;
    }

    isLoading.value = true;
    errorMessage.value = '';
    try {
      final tx = await service.executePayment(paymentId: session.paymentId);
      lastTransaction.value = tx;
      transactions.insert(0, tx);
      return tx;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('bKash Error', errorMessage.value);
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<PaymentTransaction?> queryCurrentPayment() async {
    final session = currentSession.value;
    if (session == null || session.paymentId.isEmpty) return null;
    try {
      return await service.queryPayment(paymentId: session.paymentId);
    } catch (e) {
      errorMessage.value = e.toString();
      return null;
    }
  }
}
