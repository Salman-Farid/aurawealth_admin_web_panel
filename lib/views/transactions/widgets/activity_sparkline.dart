import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../models/transaction.dart';
import './transaction_constants.dart';
import 'atoms/transaction_card.dart';

class ActivitySparkline extends StatelessWidget {
  final List<Transaction> transactions;
  const ActivitySparkline({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final spots = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final cnt = transactions.where((tx) {
        final d = tx.createdAt;
        return d.year == day.year &&
            d.month == day.month &&
            d.day == day.day;
      }).length;
      return FlSpot(i.toDouble(), cnt.toDouble());
    });

    final maxY = spots.map((s) => s.y).fold(0.0, (a, b) => a > b ? a : b);

    return TransactionCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const CardLabel('7-day Activity'),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: colApproved.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 6, height: 6,
                  decoration: const BoxDecoration(
                      color: colApproved, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              const Text('Live', style: TextStyle(fontSize: 9,
                  color: colApproved, fontWeight: FontWeight.w600)),
            ]),
          ),
        ]),
        const SizedBox(height: 10),
        SizedBox(
          height: 80,
          child: LineChart(
            LineChartData(
              lineTouchData: LineTouchData(enabled: false),
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(show: false),
              minX: 0,
              maxX: 6,
              minY: 0,
              maxY: maxY == 0 ? 5 : maxY + 1,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: colBuyApp,
                  barWidth: 2.5,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (s, _, __, ___) => FlDotCirclePainter(
                      radius: 3,
                      color: Colors.white,
                      strokeWidth: 2,
                      strokeColor: colBuyApp,
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        colBuyApp.withOpacity(0.18),
                        colBuyApp.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
