import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import './transaction_constants.dart';
import 'atoms/transaction_card.dart';

class DonutCard extends StatelessWidget {
  final int pending, approved, rejected, paid, total;
  const DonutCard({
    super.key,
    required this.pending,
    required this.approved,
    required this.rejected,
    required this.paid,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    if (total == 0) return const SizedBox.shrink();
    return TransactionCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const CardLabel('Status Overview'),
        const SizedBox(height: 10),
        SizedBox(
          height: 140,
          child: Row(children: [
            Expanded(
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 38,
                  sections: [
                    if (pending > 0)
                      PieChartSectionData(
                        value: pending.toDouble(),
                        color: colPending,
                        radius: 22,
                        title: '',
                      ),
                    if (approved > 0)
                      PieChartSectionData(
                        value: approved.toDouble(),
                        color: colApproved,
                        radius: 22,
                        title: '',
                      ),
                    if (paid > 0)
                      PieChartSectionData(
                        value: paid.toDouble(),
                        color: colPaid,
                        radius: 22,
                        title: '',
                      ),
                    if (rejected > 0)
                      PieChartSectionData(
                        value: rejected.toDouble(),
                        color: colRejected,
                        radius: 22,
                        title: '',
                      ),
                  ],
                  pieTouchData: PieTouchData(enabled: false),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LegendDot('Pending',  pending,  colPending,  total),
                const SizedBox(height: 7),
                _LegendDot('Approved', approved, colApproved, total),
                const SizedBox(height: 7),
                _LegendDot('Paid',     paid,     colPaid,     total),
                const SizedBox(height: 7),
                _LegendDot('Rejected', rejected, colRejected, total),
              ],
            ),
          ]),
        ),
      ]),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final int total;
  const _LegendDot(this.label, this.count, this.color, this.total);

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (count / total * 100).toStringAsFixed(0) : '0';
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 8, height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(fontSize: 10, color: textSec,
                fontWeight: FontWeight.w500)),
        Text('$count  ($pct%)',
            style: TextStyle(fontSize: 10, color: color,
                fontWeight: FontWeight.w700)),
      ]),
    ]);
  }
}
