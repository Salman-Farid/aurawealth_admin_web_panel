import 'package:flutter/material.dart';

class DateChip extends StatelessWidget {
  final DateTime date;

  const DateChip({
    super.key,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    String label;
    if (date.day == now.day &&
        date.month == now.month &&
        date.year == now.year) {
      label = 'Today';
    } else if (date.day == now.day - 1 &&
        date.month == now.month &&
        date.year == now.year) {
      label = 'Yesterday';
    } else {
      label = '${date.day} ${_monthName(date.month)} ${date.year}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey.shade300)),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey.shade300)),
        ],
      ),
    );
  }

  String _monthName(int m) => const [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ][m];
}
