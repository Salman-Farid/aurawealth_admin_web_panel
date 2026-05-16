import 'package:flutter/material.dart';
import './transaction_constants.dart';

class PanelHeader extends StatelessWidget {
  final String title, subtitle;
  final VoidCallback onRefresh;
  const PanelHeader(
      {super.key, required this.title, required this.subtitle, required this.onRefresh});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(14, 16, 10, 12),
    child: Row(children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: textPri)),
          const SizedBox(height: 2),
          Text(subtitle,
              style: const TextStyle(fontSize: 11, color: textSec)),
        ]),
      ),
      GestureDetector(
        onTap: onRefresh,
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: border),
          ),
          child: const Icon(Icons.refresh_rounded, size: 15, color: textSec),
        ),
      ),
    ]),
  );
}
