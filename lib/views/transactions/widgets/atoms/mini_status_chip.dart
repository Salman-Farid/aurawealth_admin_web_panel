import 'package:flutter/material.dart';

Widget miniStatusChip(String label, int count, Color color) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  decoration: BoxDecoration(
    color: color.withOpacity(0.08),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: color.withOpacity(0.3)),
  ),
  child: Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 6, height: 6,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 5),
    Text('$count $label',
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
  ]),
);
