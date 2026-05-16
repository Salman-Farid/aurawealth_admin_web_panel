import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import './transaction_constants.dart';

class EmptyView extends StatelessWidget {
  const EmptyView({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Lottie.network(lottieEmpty, width: 140, height: 140,
          errorBuilder: (_, __, ___) => const Icon(
              Icons.receipt_long_outlined, size: 64, color: textMuted)),
      const SizedBox(height: 12),
      const Text('No transactions found',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
              color: textPri)),
      const SizedBox(height: 4),
      const Text('Adjust filters or refresh',
          style: TextStyle(fontSize: 12, color: textSec)),
    ]),
  );
}
