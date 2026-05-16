import 'package:flutter/material.dart';

import '../../shared/models/payment_gateway.dart';
import '../../shared/widgets/payment_glass_card.dart';

class BkashGatewayCard extends StatelessWidget {
  final VoidCallback? onTap;
  final bool selected;

  const BkashGatewayCard({super.key, this.onTap, this.selected = false});

  @override
  Widget build(BuildContext context) {
    const gateway = PaymentGateway.bkash;
    return PaymentGlassCard(
      onTap: onTap,
      borderColor: selected ? gateway.color.withValues(alpha: 0.55) : null,
      backgroundColor: selected ? gateway.softColor : Colors.white,
      animationIndex: 1,
      child: Row(
        children: [
          PaymentGradientIcon(icon: gateway.icon, color: gateway.color),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeSlideText(
                  gateway.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                FadeSlideText(
                  gateway.subtitle,
                  index: 1,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          Icon(
            selected
                ? Icons.radio_button_checked_rounded
                : Icons.radio_button_off_rounded,
            color: gateway.color,
          ),
        ],
      ),
    );
  }
}
