import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'credit_grams_panel.dart';
import 'redeem_code_panel.dart';

class DesktopLayout extends StatelessWidget {
  final CreditGramsPanel creditGramsPanel;
  final RedeemCodePanel redeemCodePanel;

  const DesktopLayout({
    super.key,
    required this.creditGramsPanel,
    required this.redeemCodePanel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Credit Grams Panel
          Expanded(
            child: SingleChildScrollView(
              child: creditGramsPanel
                  .animate()
                  .fadeIn(delay: 100.ms, duration: 600.ms)
                  .slideX(begin: -0.1, end: 0, duration: 600.ms),
            ),
          ),
          const SizedBox(width: 16),
          // Redeem Code Panel
          Expanded(
            child: SingleChildScrollView(
              child: redeemCodePanel
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 600.ms)
                  .slideX(begin: 0.1, end: 0, duration: 600.ms),
            ),
          ),
        ],
      ),
    );
  }
}
