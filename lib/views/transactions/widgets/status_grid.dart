import 'package:flutter/material.dart';
import './transaction_constants.dart';

class StatusGrid extends StatelessWidget {
  final int pending, approved, rejected, paid;
  const StatusGrid({
    super.key,
    required this.pending,
    required this.approved,
    required this.rejected,
    required this.paid,
  });

  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(
      child: Column(children: [
        _StatTile('Pending',  pending,  colPending,  Icons.schedule_rounded),
        const SizedBox(height: 7),
        _StatTile('Rejected', rejected, colRejected, Icons.cancel_rounded),
      ]),
    ),
    const SizedBox(width: 7),
    Expanded(
      child: Column(children: [
        _StatTile('Approved', approved, colApproved, Icons.check_circle_rounded),
        const SizedBox(height: 7),
        _StatTile('Paid',     paid,     colPaid,     Icons.payments_rounded),
      ]),
    ),
  ]);
}

class _StatTile extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;
  const _StatTile(this.label, this.count, this.color, this.icon);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
    decoration: BoxDecoration(
      color: color.withOpacity(0.06),
      borderRadius: BorderRadius.circular(radiusSm),
      border: Border.all(color: color.withOpacity(0.18)),
    ),
    child: Row(children: [
      Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 13, color: color),
      ),
      const SizedBox(width: 7),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('$count',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
                color: color, height: 1.1)),
        Text(label,
            style: const TextStyle(fontSize: 9, color: textSec,
                fontWeight: FontWeight.w500, letterSpacing: 0.3)),
      ]),
    ]),
  );
}
