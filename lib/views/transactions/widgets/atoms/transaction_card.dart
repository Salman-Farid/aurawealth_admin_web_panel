import 'package:flutter/material.dart';
import '../transaction_constants.dart';

class TransactionCard extends StatelessWidget {
  final Widget child;
  const TransactionCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: border),
    ),
    child: child,
  );
}

class CardLabel extends StatelessWidget {
  final String text;
  const CardLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: textSec,
          letterSpacing: 0.4));
}
