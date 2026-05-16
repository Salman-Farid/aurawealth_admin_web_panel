import 'package:flutter/material.dart';
import '../transaction_constants.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final clr  = statusColor(status);
    final icon = statusIcon(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: clr.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: clr.withOpacity(0.4)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 10, color: clr),
        const SizedBox(width: 3),
        Text(status.toUpperCase(),
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                color: clr, letterSpacing: 0.4)),
      ]),
    );
  }
}
