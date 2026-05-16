import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../controllers/transaction_controller.dart';
import '../../../../models/transaction.dart';
import './transaction_constants.dart';
import 'empty_view.dart';
import 'filter_bar.dart';
import 'mobile_card.dart';
import 'atoms/mini_status_chip.dart';

class MobileLayout extends StatelessWidget {
  final List<Transaction> all, filtered;
  final int pending, approved, rejected, paid;
  final TransactionController ctrl;

  const MobileLayout({
    super.key,
    required this.all,
    required this.filtered,
    required this.pending,
    required this.approved,
    required this.rejected,
    required this.paid,
    required this.ctrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // compact header
        Container(
          color: surface,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Transactions',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
                        color: textPri)),
                Text('${filtered.length} of ${all.length}',
                    style: const TextStyle(fontSize: 11, color: textSec)),
              ]),
            ),
            IconButton(
              onPressed: ctrl.refresh,
              icon: const Icon(Icons.refresh_rounded, size: 20, color: textSec),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ]),
        ).animate()
          .fadeIn(duration: 900.ms, curve: Curves.easeInOutCubicEmphasized)
          .slideY(begin: 0.06, end: 0, duration: 900.ms, curve: Curves.easeInOutCubicEmphasized),
        // Horizontal status chips
        Container(
          color: surface,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              miniStatusChip('Pending',  pending,  colPending),
              const SizedBox(width: 6),
              miniStatusChip('Approved', approved, colApproved),
              const SizedBox(width: 6),
              miniStatusChip('Paid',     paid,     colPaid),
              const SizedBox(width: 6),
              miniStatusChip('Rejected', rejected, colRejected),
            ]),
          ),
        ).animate()
          .fadeIn(delay: 120.ms, duration: 900.ms, curve: Curves.easeInOutCubicEmphasized)
          .slideY(delay: 120.ms, begin: 0.06, end: 0, duration: 900.ms, curve: Curves.easeInOutCubicEmphasized)
          .scaleXY(delay: 120.ms, begin: 0.97, end: 1.0, duration: 900.ms, curve: Curves.easeInOutCubicEmphasized),
        const Divider(height: 1, color: border),
        FilterBar(ctrl: ctrl)
          .animate()
          .fadeIn(delay: 220.ms, duration: 900.ms, curve: Curves.easeInOutCubicEmphasized)
          .slideY(delay: 220.ms, begin: 0.06, end: 0, duration: 900.ms, curve: Curves.easeInOutCubicEmphasized)
          .scaleXY(delay: 220.ms, begin: 0.97, end: 1.0, duration: 900.ms, curve: Curves.easeInOutCubicEmphasized),
        const Divider(height: 1, color: border),
        Expanded(
          child: filtered.isEmpty
              ? const EmptyView()
              : ListView.builder(
                  itemCount: filtered.length,
                  padding: const EdgeInsets.all(12),
                  itemBuilder: (_, i) => MobileCard(tx: filtered[i], ctrl: ctrl)
                    .animate()
                    .fadeIn(delay: (300 + i * 80).ms, duration: 800.ms, curve: Curves.easeInOutCubicEmphasized)
                    .slideY(delay: (300 + i * 80).ms, begin: 0.06, end: 0, duration: 800.ms, curve: Curves.easeInOutCubicEmphasized)
                    .scaleXY(delay: (300 + i * 80).ms, begin: 0.97, end: 1.0, duration: 800.ms, curve: Curves.easeInOutCubicEmphasized),
                ),
        ),
      ],
    );
  }
}
