import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:get/get.dart';
import '../../../../controllers/transaction_controller.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../models/transaction.dart';
import '../transaction_constants.dart';

void showRejectDialog(BuildContext context, Transaction tx,
    TransactionController ctrl) {
  final noteCtrl = TextEditingController();
  Get.dialog(Dialog(
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Lottie.network(lottieRejected, width: 80, height: 80,
              repeat: false,
              errorBuilder: (_, __, ___) => const Icon(
                  Icons.cancel_rounded, size: 56, color: colRejected)),
          const SizedBox(height: 10),
          const Text('Reject Transaction',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                  color: textPri)),
          const SizedBox(height: 4),
          Text(Formatters.formatCurrency(tx.amountBdt),
              style: const TextStyle(fontSize: 20,
                  fontWeight: FontWeight.w800, color: colRejected)),
          const SizedBox(height: 2),
          Text(typeLabel(tx.type),
              style: const TextStyle(fontSize: 12, color: textSec)),
          const SizedBox(height: 16),
          const Divider(color: border),
          const SizedBox(height: 12),
          TextField(
            controller: noteCtrl, maxLines: 3,
            style: const TextStyle(fontSize: 12),
            decoration: InputDecoration(
              labelText: 'Reason (optional)',
              labelStyle: const TextStyle(fontSize: 12),
              filled: true, fillColor: bg,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: border),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Cancel',
                    style: TextStyle(fontSize: 13, color: textSec)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  ctrl.rejectTransaction(tx.id,
                      note: noteCtrl.text.trim().isEmpty
                          ? null
                          : noteCtrl.text.trim());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colRejected,
                  foregroundColor: Colors.white, elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Confirm Reject',
                    style: TextStyle(fontSize: 13,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          ]),
        ]),
      ),
    ),
  ));
}
