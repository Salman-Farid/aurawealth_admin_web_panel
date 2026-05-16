import 'package:flutter/material.dart';

import '../../shared/models/payment_gateway.dart';
import '../../shared/models/payment_transaction.dart';
import '../../shared/utils/payment_formatters.dart';
import '../../shared/widgets/payment_glass_card.dart';
import '../../shared/widgets/payment_status_widgets.dart';

class PaymentTransactionTile extends StatelessWidget {
  final PaymentTransaction transaction;
  final int index;
  final VoidCallback? onTap;

  const PaymentTransactionTile({
    super.key,
    required this.transaction,
    required this.index,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final gateway = transaction.gateway;
    return PaymentGlassCard(
      animationIndex: index,
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          PaymentGradientIcon(
            icon: gateway.icon,
            color: gateway.color,
            size: 46,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: FadeSlideText(
                        transaction.customerName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF111827),
                        ),
                        maxLines: 1,
                      ),
                    ),
                    PaymentStatusPill(status: transaction.status),
                  ],
                ),
                const SizedBox(height: 6),
                FadeSlideText(
                  '${gateway.title} • ${PaymentFormatters.shortId(transaction.id)}',
                  index: 1,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  maxLines: 1,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _MiniMetric(
                      icon: Icons.payments_rounded,
                      label: PaymentFormatters.money(
                        transaction.amount,
                        currency: transaction.currency,
                      ),
                      color: gateway.color,
                    ),
                    const SizedBox(width: 10),
                    _MiniMetric(
                      icon: Icons.calendar_month_rounded,
                      label: PaymentFormatters.date(transaction.createdAt),
                      color: const Color(0xFF43C6AC),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MiniMetric({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 13),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
