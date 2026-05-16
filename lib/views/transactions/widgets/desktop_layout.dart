import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../controllers/transaction_controller.dart';
import '../../../../models/transaction.dart';
import './transaction_constants.dart';
import 'activity_sparkline.dart';
import 'donut_card.dart';
import 'empty_view.dart';
import 'filter_bar.dart';
import 'panel_header.dart';
import 'status_grid.dart';
import 'type_breakdown.dart';
import 'volume_chart.dart';
import 'desktop_table.dart';

class DesktopLayout extends StatelessWidget {
  final List<Transaction> all, filtered;
  final int pending, approved, rejected, paid;
  final TransactionController ctrl;

  const DesktopLayout({
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── LEFT SIDE PANEL (charts) ──────────────────────────────────────
        SizedBox(
          width: 300,
          child: Container(
            color: surface,
            child: Column(
              children: [
                // Header
                PanelHeader(
                  title: 'Transactions',
                  subtitle: '${all.length} total · ${filtered.length} shown',
                  onRefresh: ctrl.refresh,
                ).animate()
                  .fadeIn(duration: 900.ms, curve: Curves.easeInOutCubicEmphasized)
                  .slideY(begin: 0.06, end: 0, duration: 900.ms, curve: Curves.easeInOutCubicEmphasized),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                    child: Column(
                      children: [
                        // Status donut chart
                        DonutCard(
                          pending: pending,
                          approved: approved,
                          rejected: rejected,
                          paid: paid,
                          total: all.length,
                        ).animate()
                          .fadeIn(delay: 150.ms, duration: 900.ms, curve: Curves.easeInOutCubicEmphasized)
                          .slideY(delay: 150.ms, begin: 0.06, end: 0, duration: 900.ms, curve: Curves.easeInOutCubicEmphasized)
                          .scaleXY(delay: 150.ms, begin: 0.97, end: 1.0, duration: 900.ms, curve: Curves.easeInOutCubicEmphasized),
                        const SizedBox(height: 10),
                        // Status stat tiles (2x2 grid)
                        StatusGrid(
                          pending: pending,
                          approved: approved,
                          rejected: rejected,
                          paid: paid,
                        ).animate()
                          .fadeIn(delay: 250.ms, duration: 900.ms, curve: Curves.easeInOutCubicEmphasized)
                          .slideY(delay: 250.ms, begin: 0.06, end: 0, duration: 900.ms, curve: Curves.easeInOutCubicEmphasized)
                          .scaleXY(delay: 250.ms, begin: 0.97, end: 1.0, duration: 900.ms, curve: Curves.easeInOutCubicEmphasized),
                        const SizedBox(height: 10),
                        // Volume bar chart (by type)
                        VolumeByTypeChart(transactions: all)
                          .animate()
                          .fadeIn(delay: 350.ms, duration: 900.ms, curve: Curves.easeInOutCubicEmphasized)
                          .slideY(delay: 350.ms, begin: 0.06, end: 0, duration: 900.ms, curve: Curves.easeInOutCubicEmphasized)
                          .scaleXY(delay: 350.ms, begin: 0.97, end: 1.0, duration: 900.ms, curve: Curves.easeInOutCubicEmphasized),
                        const SizedBox(height: 10),
                        // Recent activity sparkline
                        ActivitySparkline(transactions: all)
                          .animate()
                          .fadeIn(delay: 450.ms, duration: 900.ms, curve: Curves.easeInOutCubicEmphasized)
                          .slideY(delay: 450.ms, begin: 0.06, end: 0, duration: 900.ms, curve: Curves.easeInOutCubicEmphasized)
                          .scaleXY(delay: 450.ms, begin: 0.97, end: 1.0, duration: 900.ms, curve: Curves.easeInOutCubicEmphasized),
                        const SizedBox(height: 10),
                        // Type breakdown list
                        TypeBreakdownList(transactions: all)
                          .animate()
                          .fadeIn(delay: 550.ms, duration: 900.ms, curve: Curves.easeInOutCubicEmphasized)
                          .slideY(delay: 550.ms, begin: 0.06, end: 0, duration: 900.ms, curve: Curves.easeInOutCubicEmphasized)
                          .scaleXY(delay: 550.ms, begin: 0.97, end: 1.0, duration: 900.ms, curve: Curves.easeInOutCubicEmphasized),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const VerticalDivider(width: 1, color: border),

        // ── RIGHT SIDE — Filter bar + Table ──────────────────────────────
        Expanded(
          child: Column(
            children: [
              FilterBar(ctrl: ctrl)
                .animate()
                .fadeIn(delay: 300.ms, duration: 900.ms, curve: Curves.easeInOutCubicEmphasized)
                .slideY(delay: 300.ms, begin: 0.06, end: 0, duration: 900.ms, curve: Curves.easeInOutCubicEmphasized)
                .scaleXY(delay: 300.ms, begin: 0.97, end: 1.0, duration: 900.ms, curve: Curves.easeInOutCubicEmphasized),
              const Divider(height: 1, color: border),
              Expanded(
                child: filtered.isEmpty
                    ? const EmptyView()
                    : DesktopTable(transactions: filtered, ctrl: ctrl),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
