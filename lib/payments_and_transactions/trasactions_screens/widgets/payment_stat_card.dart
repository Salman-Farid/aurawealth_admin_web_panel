import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../shared/widgets/payment_glass_card.dart';

class PaymentStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final int index;

  const PaymentStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return PaymentGlassCard(
      animationIndex: index,
      padding: const EdgeInsets.all(14),
      borderColor: color.withValues(alpha: 0.18),
      child: Row(
        children: [
          PaymentGradientIcon(icon: icon, color: color, size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeSlideText(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                FadeSlideText(
                  label,
                  index: 1,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.grey600,
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
