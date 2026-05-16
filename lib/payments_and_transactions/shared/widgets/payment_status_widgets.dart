import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../models/payment_transaction.dart';
import '../utils/payment_formatters.dart';

class PaymentStatusPill extends StatelessWidget {
  final PaymentStatus status;

  const PaymentStatusPill({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = PaymentFormatters.statusColor(status.label);
    final icon = _iconForStatus(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            status.label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForStatus(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.draft:
        return Icons.edit_note_rounded;
      case PaymentStatus.pending:
        return Icons.schedule_rounded;
      case PaymentStatus.processing:
        return Icons.sync_rounded;
      case PaymentStatus.succeeded:
        return Icons.verified_rounded;
      case PaymentStatus.failed:
        return Icons.error_rounded;
      case PaymentStatus.cancelled:
        return Icons.cancel_rounded;
      case PaymentStatus.refunded:
        return Icons.keyboard_return_rounded;
    }
  }
}

class PaymentLoadingDots extends StatefulWidget {
  final Color color;
  const PaymentLoadingDots({super.key, this.color = AppColors.primary});

  @override
  State<PaymentLoadingDots> createState() => _PaymentLoadingDotsState();
}

class _PaymentLoadingDotsState extends State<PaymentLoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final value = (_controller.value + (index * 0.22)) % 1;
            final scale = 0.55 + (0.45 * Curves.elasticOut.transform(value));
            return Transform.scale(
              scale: scale,
              child: Container(
                width: 7,
                height: 7,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.35 + (0.55 * value)),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
