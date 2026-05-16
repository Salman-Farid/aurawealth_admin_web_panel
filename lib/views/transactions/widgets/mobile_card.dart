import 'package:flutter/material.dart';
import '../../../../controllers/transaction_controller.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../models/transaction.dart';
import './transaction_constants.dart';
import 'atoms/type_icon.dart';
import 'atoms/status_badge.dart';
import 'atoms/action_buttons.dart';
import 'dialogs/detail_sheet.dart';

class MobileCard extends StatelessWidget {
  final Transaction tx;
  final TransactionController ctrl;
  const MobileCard({super.key, required this.tx, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final tc = typeColor(tx.type);
    return GestureDetector(
      onTap: () => showDetailSheet(context, tx, ctrl),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: border),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            TypeIcon(type: tx.type, size: 34),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(typeLabel(tx.type),
                        style: TextStyle(fontSize: 12,
                            fontWeight: FontWeight.w700, color: tc)),
                    const SizedBox(height: 1),
                    Text(tx.userName ?? tx.userEmail ?? '—',
                        style: const TextStyle(fontSize: 11, color: textSec),
                        overflow: TextOverflow.ellipsis),
                  ]),
            ),
            StatusBadge(status: tx.status),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            _MetricCell(label: 'Grams',
                value: Formatters.formatGrams(tx.grams)),
            _vDivider(),
            _MetricCell(label: 'Amount',
                value: Formatters.formatCurrency(tx.amountBdt), bold: true),
            _vDivider(),
            _MetricCell(label: 'Fee',
                value: Formatters.formatCurrency(tx.feeAmount)),
            _vDivider(),
            _MetricCell(label: 'Date',
                value: Formatters.formatDate(tx.createdAt)),
          ]),
          if (tx.status.toLowerCase() == 'pending') ...[
            const SizedBox(height: 10),
            const Divider(height: 1, color: border),
            const SizedBox(height: 8),
            ActionButtons(tx: tx, ctrl: ctrl),
          ],
        ]),
      ),
    );
  }

  static Widget _vDivider() => Container(
      width: 1, height: 28, color: border,
      margin: const EdgeInsets.symmetric(horizontal: 8));
}

class _MetricCell extends StatelessWidget {
  final String label, value;
  final bool bold;
  const _MetricCell(
      {required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(
              fontSize: 9, color: textMuted,
              fontWeight: FontWeight.w600, letterSpacing: 0.3)),
      const SizedBox(height: 3),
      Text(value,
          style: TextStyle(
              fontSize: 11,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
              color: textPri),
          overflow: TextOverflow.ellipsis),
    ]),
  );
}
