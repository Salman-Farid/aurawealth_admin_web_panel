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
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: creditGramsPanel
                  .animate()
                  .fadeIn(delay: 100.ms, duration: 500.ms)
                  .slideX(begin: -0.05, end: 0, duration: 500.ms),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: SingleChildScrollView(
              child: redeemCodePanel
                  .animate()
                  .fadeIn(delay: 150.ms, duration: 500.ms)
                  .slideX(begin: 0.05, end: 0, duration: 500.ms),
            ),
          ),
        ],
      ),
    );
  }
}
