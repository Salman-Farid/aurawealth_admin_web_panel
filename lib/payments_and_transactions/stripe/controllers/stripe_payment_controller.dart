import 'package:get/get.dart';

import '../../shared/models/payment_request.dart';
import '../../shared/models/payment_transaction.dart';
import '../models/stripe_payment_intent.dart';
import '../services/stripe_payment_service.dart';

class StripePaymentController extends GetxController {
  final StripePaymentService service;

  StripePaymentController({required this.service});

  final isLoading = false.obs;
  final isCreatingIntent = false.obs;
  final errorMessage = ''.obs;
  final transactions = <PaymentTransaction>[].obs;
  final currentIntent = Rxn<StripePaymentIntent>();
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

  Future<StripePaymentIntent?> createPaymentIntent(
    PaymentRequest request,
  ) async {
    isCreatingIntent.value = true;
    errorMessage.value = '';
    try {
      final intent = await service.createPaymentIntent(request);
      currentIntent.value = intent;
      return intent;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Stripe Error', errorMessage.value);
      return null;
    } finally {
      isCreatingIntent.value = false;
    }
  }

  Future<PaymentTransaction?> confirmCurrentIntent({String? note}) async {
    final intent = currentIntent.value;
    if (intent == null || intent.id.isEmpty) {
      errorMessage.value = 'No Stripe payment intent selected';
      return null;
    }

    isLoading.value = true;
    errorMessage.value = '';
    try {
      final tx = await service.confirmPayment(
        paymentIntentId: intent.id,
        note: note,
      );
      lastTransaction.value = tx;
      transactions.insert(0, tx);
      return tx;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Stripe Error', errorMessage.value);
      return null;
    } finally {
      isLoading.value = false;
    }
  }
}
