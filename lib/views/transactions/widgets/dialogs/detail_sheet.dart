import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../controllers/transaction_controller.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../models/transaction.dart';
import '../transaction_constants.dart';
import '../atoms/type_icon.dart';
import '../atoms/status_badge.dart';
import 'approve_dialog.dart';
import 'reject_dialog.dart';

void showDetailSheet(BuildContext context, Transaction tx,
    TransactionController ctrl) {
  Get.bottomSheet(
    Container(
      decoration: const BoxDecoration(
        color: sheetBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 36, height: 4,
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            decoration: BoxDecoration(
                color: cardBorder, borderRadius: BorderRadius.circular(2)),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(children: [
                _sheetCard(
                  child: Row(children: [
                    TypeIcon(type: tx.type, size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(typeLabel(tx.type),
                            style: TextStyle(fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: typeColor(tx.type))),
                        const SizedBox(height: 2),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: tx.id));
                            Get.snackbar('Copied', 'ID copied',
                                duration: const Duration(seconds: 1));
                          },
                          child: Text(tx.id,
                              style: const TextStyle(fontSize: 10, color: textMuted,
                                  fontFamily: 'monospace'),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ]),
                    ),
                    StatusBadge(status: tx.status),
                  ]),
                ),
                const SizedBox(height: 10),
                _sheetCard(
                  child: Column(children: [
                    _dRow('User',       tx.userName ?? tx.userEmail ?? '—'),
                    _dRow('User ID',    tx.userId ?? '—'),
                    _dRow('Grams',      Formatters.formatGrams(tx.grams)),
                    _dRow('Amount',     Formatters.formatCurrency(tx.amountBdt),
                        bold: true),
                    _dRow('Fee %',      '${tx.feePercent}%'),
                    _dRow('Fee Amount', Formatters.formatCurrency(tx.feeAmount)),
                    if (tx.code != null) _dRow('Code', tx.code!),
                    _dRow('Created',    Formatters.formatDateTime(tx.createdAt)),
                    if (tx.approvedAt != null)
                      _dRow('Approved', Formatters.formatDateTime(tx.approvedAt!)),
                    if (tx.rejectedAt != null)
                      _dRow('Rejected', Formatters.formatDateTime(tx.rejectedAt!)),
                    if (tx.adminNote != null && tx.adminNote!.isNotEmpty)
                      _dRow('Note', tx.adminNote!),
                  ]),
                ),
                if (tx.status.toLowerCase() == 'pending') ...[
                  const SizedBox(height: 10),
                  _sheetCard(
                    child: Row(children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Get.back();
                            showApproveDialog(context, tx, ctrl);
                          },
                          icon: const Icon(Icons.check_rounded, size: 15),
                          label: const Text('Approve'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colApproved,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Get.back();
                            showRejectDialog(context, tx, ctrl);
                          },
                          icon: const Icon(Icons.close_rounded, size: 15),
                          label: const Text('Reject'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colRejected,
                            side: const BorderSide(color: colRejected),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ],
              ]),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 6),
        ]),
      ),
    ),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

Widget _sheetCard({required Widget child}) => Container(
  width: double.infinity,
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  decoration: BoxDecoration(
    color: cardBg,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: cardBorder),
  ),
  child: child,
);

Widget _dRow(String label, String value, {bool bold = false}) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 6),
  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    SizedBox(
      width: 110,
      child: Text(label,
          style: const TextStyle(fontSize: 10.5, color: textSec,
              fontWeight: FontWeight.w600)),
    ),
    const SizedBox(width: 8),
    Expanded(
      child: Text(value,
          style: TextStyle(fontSize: 12, color: textPri,
              fontWeight: bold ? FontWeight.w800 : FontWeight.normal)),
    ),
  ]),
);
