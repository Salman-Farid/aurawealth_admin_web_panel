import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controllers/transaction_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/common/error_widget.dart' as custom_error;
import '../../models/transaction.dart';

// ── Lottie URLs ───────────────────────────────────────────────────────────────
const _lottieApproved = 'https://assets9.lottiefiles.com/packages/lf20_jbrw3hcz.json';
const _lottieRejected = 'https://assets7.lottiefiles.com/packages/lf20_qmfs6c3i.json';
const _lottieEmpty    = 'https://assets5.lottiefiles.com/packages/lf20_szlepvdh.json';
const _lottieLoading  = 'https://assets2.lottiefiles.com/packages/lf20_usmfx6bp.json';

// ── Distinct PNG per transaction type ─────────────────────────────────────────
const _pngBuyApp    = 'https://cdn-icons-png.flaticon.com/128/1170/1170678.png';
const _pngBuyStore  = 'https://cdn-icons-png.flaticon.com/128/869/869636.png';
const _pngSellBank  = 'https://cdn-icons-png.flaticon.com/128/2830/2830284.png';
const _pngSellStore = 'https://cdn-icons-png.flaticon.com/128/1198/1198385.png';
const _pngExchange  = 'https://cdn-icons-png.flaticon.com/128/1023/1023539.png';

// ── Pure helpers ──────────────────────────────────────────────────────────────

Color _statusColor(String s) {
  switch (s.toUpperCase()) {
    case 'PENDING':  return AppColors.statusPending;
    case 'APPROVED': return AppColors.statusApproved;
    case 'PAID':     return AppColors.statusPaid;
    case 'REJECTED': return AppColors.statusRejected;
    default:         return AppColors.grey600;
  }
}

IconData _statusIcon(String s) {
  switch (s.toUpperCase()) {
    case 'PENDING':  return Icons.schedule_rounded;
    case 'APPROVED': return Icons.check_circle_rounded;
    case 'PAID':     return Icons.payments_rounded;
    case 'REJECTED': return Icons.cancel_rounded;
    default:         return Icons.help_rounded;
  }
}

Color _typeColor(String t) {
  switch (t.toUpperCase()) {
    case 'BUY_IN_APP':            return const Color(0xFF0288D1);
    case 'BUY_IN_STORE':          return const Color(0xFF00897B);
    case 'SELL_TO_BANK':          return const Color(0xFF6D4C41);
    case 'SELL_TO_STORE':         return const Color(0xFFE53935);
    case 'EXCHANGE_TO_JEWELLERY': return const Color(0xFF7B1FA2);
    default:                      return AppColors.grey600;
  }
}

String _typeLabel(String t) {
  switch (t.toUpperCase()) {
    case 'BUY_IN_APP':            return 'Buy In App';
    case 'BUY_IN_STORE':          return 'Buy In Store';
    case 'SELL_TO_BANK':          return 'Sell to Bank';
    case 'SELL_TO_STORE':         return 'Sell to Store';
    case 'EXCHANGE_TO_JEWELLERY': return 'Exchange';
    default:
      return t.replaceAll('_', ' ').split(' ').map((w) =>
          w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}'
      ).join(' ');
  }
}

String _pngForType(String t) {
  switch (t.toUpperCase()) {
    case 'BUY_IN_APP':            return _pngBuyApp;
    case 'BUY_IN_STORE':          return _pngBuyStore;
    case 'SELL_TO_BANK':          return _pngSellBank;
    case 'SELL_TO_STORE':         return _pngSellStore;
    case 'EXCHANGE_TO_JEWELLERY': return _pngExchange;
    default:                      return _pngExchange;
  }
}

IconData _iconForType(String t) {
  switch (t.toUpperCase()) {
    case 'BUY_IN_APP':            return Icons.phone_android_rounded;
    case 'BUY_IN_STORE':          return Icons.shopping_bag_rounded;
    case 'SELL_TO_BANK':          return Icons.account_balance_rounded;
    case 'SELL_TO_STORE':         return Icons.storefront_rounded;
    case 'EXCHANGE_TO_JEWELLERY': return Icons.swap_horiz_rounded;
    default:                      return Icons.receipt_long_rounded;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  ROOT SCREEN
//  Key rule: Expanded is NEVER placed inside an Obx return value.
//  The outer Obx returns the whole Column; Expanded lives directly in Column.
// ─────────────────────────────────────────────────────────────────────────────

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TransactionController>();

    return Obx(() {
      // ── loading state
      if (ctrl.isLoading.value && ctrl.transactions.isEmpty) {
        return const _LoadingView();
      }
      // ── error state
      if (ctrl.errorMessage.value.isNotEmpty && ctrl.transactions.isEmpty) {
        return custom_error.CustomErrorWidget(
          message: ctrl.errorMessage.value,
          onRetry: ctrl.refresh,
        );
      }

      // ── normal state
      // Snapshot reactive data here — pass plain values to children so
      // no child needs its own Obx just to read these.
      final all      = ctrl.transactions;
      final filtered = ctrl.filteredTransactions;
      final pending  = all.where((t) => t.status.toLowerCase() == 'pending').length;
      final approved = all.where((t) => t.status.toLowerCase() == 'approved').length;
      final rejected = all.where((t) => t.status.toLowerCase() == 'rejected').length;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── summary bar (fixed height)
          _SummaryBar(
            total: all.length,
            shown: filtered.length,
            pending: pending,
            approved: approved,
            rejected: rejected,
            onRefresh: ctrl.refresh,
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

          // ── filter bar (fixed height)
          _FilterBar(ctrl: ctrl),
          const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

          // ── list area: Expanded fills remaining height
          Expanded(
            child: filtered.isEmpty
                ? const _EmptyView()
                : _ListArea(
                    transactions: filtered,
                    ctrl: ctrl,
                  ),
          ),
        ],
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Loading / Empty views
// ─────────────────────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();
  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Lottie.network(_lottieLoading, width: 140, height: 140,
              errorBuilder: (_, __, ___) => const CircularProgressIndicator()),
          const SizedBox(height: 12),
          const Text('Loading transactions…',
              style: TextStyle(color: AppColors.grey600, fontSize: 14)),
        ]),
      );
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();
  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Lottie.network(_lottieEmpty, width: 180, height: 180,
              errorBuilder: (_, __, ___) => const Icon(
                  Icons.receipt_long_outlined, size: 80, color: AppColors.grey400)),
          const SizedBox(height: 16),
          const Text('No transactions found',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          const Text('Adjust your filters or refresh',
              style: TextStyle(fontSize: 13, color: AppColors.grey600)),
        ]),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
//  Summary bar  (no reactive state — all values passed as plain ints)
// ─────────────────────────────────────────────────────────────────────────────

class _SummaryBar extends StatelessWidget {
  final int total, shown, pending, approved, rejected;
  final VoidCallback onRefresh;
  const _SummaryBar({
    required this.total,
    required this.shown,
    required this.pending,
    required this.approved,
    required this.rejected,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(children: [
          // Title
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Transactions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text('Showing $shown of $total',
                style: const TextStyle(fontSize: 12, color: AppColors.grey600)),
          ]),
          const Spacer(),
          _StatChip(label: 'Pending',  count: pending,  color: AppColors.statusPending),
          const SizedBox(width: 8),
          _StatChip(label: 'Approved', count: approved, color: AppColors.statusApproved),
          const SizedBox(width: 8),
          _StatChip(label: 'Rejected', count: rejected, color: AppColors.statusRejected),
          const SizedBox(width: 16),
          OutlinedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Refresh'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ]),
      );
}

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _StatChip({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 7, height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text('$count $label',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ]),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
//  Filter bar  (reads reactive values, but does NOT return Expanded)
// ─────────────────────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  final TransactionController ctrl;
  const _FilterBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    // Reading .value here inside a StatelessWidget that is rebuilt by
    // the parent Obx — no nested Obx needed.
    final statusVal = ctrl.selectedStatus.value.isEmpty ? null : ctrl.selectedStatus.value;
    final typeVal   = ctrl.selectedType.value.isEmpty   ? null : ctrl.selectedType.value;
    final hasFilter = ctrl.selectedStatus.value.isNotEmpty ||
        ctrl.selectedType.value.isNotEmpty ||
        ctrl.searchQuery.value.isNotEmpty;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(children: [
        // Search
        Expanded(
          child: SizedBox(
            height: 40,
            child: TextField(
              onChanged: ctrl.setSearchQuery,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search by ID, user, type…',
                hintStyle: const TextStyle(fontSize: 13, color: AppColors.grey400),
                prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.grey600),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        _DropdownFilter(
          label: 'Status',
          value: statusVal,
          items: const ['pending', 'approved', 'paid', 'rejected'],
          onChanged: (v) => ctrl.setStatusFilter(v),
        ),
        const SizedBox(width: 8),
        _DropdownFilter(
          label: 'Type',
          value: typeVal,
          items: const [
            'BUY_IN_APP', 'BUY_IN_STORE',
            'SELL_TO_BANK', 'SELL_TO_STORE',
            'EXCHANGE_TO_JEWELLERY',
          ],
          itemLabels: const [
            'Buy In App', 'Buy In Store',
            'Sell to Bank', 'Sell to Store',
            'Exchange',
          ],
          onChanged: (v) => ctrl.setTypeFilter(v),
        ),
        const SizedBox(width: 8),
        if (hasFilter)
          TextButton.icon(
            onPressed: ctrl.clearFilters,
            icon: const Icon(Icons.close_rounded, size: 14),
            label: const Text('Clear', style: TextStyle(fontSize: 12)),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
          ),
      ]),
    );
  }
}

class _DropdownFilter extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final List<String>? itemLabels;
  final void Function(String?) onChanged;

  const _DropdownFilter({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.itemLabels,
  });

  @override
  Widget build(BuildContext context) {
    final active = value != null;
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: active
            ? AppColors.primary.withValues(alpha: 0.06)
            : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: active ? AppColors.primary : Colors.transparent),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(label,
              style: const TextStyle(fontSize: 12, color: AppColors.grey600)),
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              size: 16, color: AppColors.grey600),
          style: TextStyle(
              fontSize: 12,
              color: active ? AppColors.primary : AppColors.textPrimary,
              fontWeight: active ? FontWeight.w600 : FontWeight.normal),
          isDense: true,
          onChanged: onChanged,
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text('All $label',
                  style: const TextStyle(fontSize: 12, color: AppColors.grey600)),
            ),
            ...items.asMap().entries.map((e) => DropdownMenuItem<String>(
                  value: e.value,
                  child: Text(itemLabels?[e.key] ?? e.value,
                      style: const TextStyle(fontSize: 12)),
                )),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  List area  — receives plain List<Transaction>, no reactive deps
//  Desktop: Column[ header | Expanded( ListView ) ] inside horizontal scroll
//  Mobile : ListView
// ─────────────────────────────────────────────────────────────────────────────

class _ListArea extends StatelessWidget {
  final List<Transaction> transactions;
  final TransactionController ctrl;
  const _ListArea({required this.transactions, required this.ctrl});

  // Total fixed width: left-pad(24) + col widths + right-pad(16)
  static const double _totalW = 40 + 200 + 16 + 150 + 16 + 110 + 16 + 80 + 16 + 120 + 16 + 100 + 16 + 100 + 16 + 160 + 16;

  @override
  Widget build(BuildContext context) {
    if (Responsive.isMobile(context)) {
      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: transactions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) =>
            _MobileCard(tx: transactions[i], ctrl: ctrl),
      );
    }

    // Desktop: horizontal scroll wraps a fixed-width column.
    // The column has the header + Expanded(ListView) — both get
    // correct constraints because the SizedBox gives fixed width.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: _totalW,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Pinned header
            _TableHeader(),
            const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
            // Scrollable rows — Expanded works here because
            // the Column has a bounded height from its parent (Expanded in root).
            Expanded(
              child: ListView.separated(
                itemCount: transactions.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                itemBuilder: (_, i) => _TableRow(
                  tx: transactions[i],
                  odd: i.isOdd,
                  ctrl: ctrl,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Desktop table header
// ─────────────────────────────────────────────────────────────────────────────

class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        color: const Color(0xFFF9F9F9),
        padding: const EdgeInsets.only(left: 20, right: 16, top: 11, bottom: 11),
        child: Row(children: const [
          SizedBox(width: 200, child: _TH(label: 'TRANSACTION')),
          SizedBox(width: 16),
          SizedBox(width: 150, child: _TH(label: 'USER')),
          SizedBox(width: 16),
          SizedBox(width: 110, child: _TH(label: 'STATUS')),
          SizedBox(width: 16),
          SizedBox(width: 80,  child: _TH(label: 'GRAMS')),
          SizedBox(width: 16),
          SizedBox(width: 120, child: _TH(label: 'AMOUNT')),
          SizedBox(width: 16),
          SizedBox(width: 100, child: _TH(label: 'FEE')),
          SizedBox(width: 16),
          SizedBox(width: 100, child: _TH(label: 'DATE')),
          SizedBox(width: 16),
          SizedBox(width: 160, child: _TH(label: 'ACTIONS')),
          SizedBox(width: 16),
        ]),
      );
}

class _TH extends StatelessWidget {
  final String label;
  const _TH({required this.label});

  @override
  Widget build(BuildContext context) => Text(label,
        style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.grey600,
            letterSpacing: 0.8));
}

// ─────────────────────────────────────────────────────────────────────────────
//  Desktop table row  (same fixed widths as header)
// ─────────────────────────────────────────────────────────────────────────────

class _TableRow extends StatelessWidget {
  final Transaction tx;
  final bool odd;
  final TransactionController ctrl;
  const _TableRow({required this.tx, required this.odd, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final tc = _typeColor(tx.type);
    return InkWell(
      onTap: () => _showDetailSheet(context, tx, ctrl),
      hoverColor: const Color(0xFFF0F4FF),
      child: Container(
        color: odd ? const Color(0xFFFAFAFA) : Colors.white,
        padding: const EdgeInsets.only(left: 20, right: 16, top: 12, bottom: 12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [

          // TRANSACTION 200px
          SizedBox(
            width: 200,
            child: Row(children: [
              _TypeIcon(type: tx.type, size: 34),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_typeLabel(tx.type),
                        style: TextStyle(fontSize: 12,
                            fontWeight: FontWeight.w600, color: tc),
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: tx.id));
                        Get.snackbar('Copied', 'ID copied',
                            duration: const Duration(seconds: 1));
                      },
                      child: Text(
                        tx.id.length > 8 ? '${tx.id.substring(0, 8)}…' : tx.id,
                        style: const TextStyle(fontSize: 10,
                            color: AppColors.grey400, fontFamily: 'monospace'),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
          const SizedBox(width: 16),

          // USER 150px
          SizedBox(
            width: 150,
            child: Text(tx.userName ?? tx.userEmail ?? '—',
                style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 16),

          // STATUS 110px
          SizedBox(width: 110, child: _StatusBadge(status: tx.status)),
          const SizedBox(width: 16),

          // GRAMS 80px
          SizedBox(
            width: 80,
            child: Text(Formatters.formatGrams(tx.grams),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 16),

          // AMOUNT 120px
          SizedBox(
            width: 120,
            child: Text(Formatters.formatCurrency(tx.amountBdt),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),

          // FEE 100px
          SizedBox(
            width: 100,
            child: Text(Formatters.formatCurrency(tx.feeAmount),
                style: const TextStyle(fontSize: 12, color: AppColors.grey600)),
          ),
          const SizedBox(width: 16),

          // DATE 100px
          SizedBox(
            width: 100,
            child: Text(Formatters.formatDate(tx.createdAt),
                style: const TextStyle(fontSize: 12, color: AppColors.grey600)),
          ),
          const SizedBox(width: 16),

          // ACTIONS 160px
          SizedBox(
            width: 160,
            child: tx.status.toLowerCase() == 'pending'
                ? _ActionButtons(tx: tx, ctrl: ctrl)
                : const SizedBox.shrink(),
          ),
          const SizedBox(width: 16),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Mobile card
// ─────────────────────────────────────────────────────────────────────────────

class _MobileCard extends StatelessWidget {
  final Transaction tx;
  final TransactionController ctrl;
  const _MobileCard({required this.tx, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final tc = _typeColor(tx.type);
    return GestureDetector(
      onTap: () => _showDetailSheet(context, tx, ctrl),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              _TypeIcon(type: tx.type, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_typeLabel(tx.type),
                      style: TextStyle(fontSize: 14,
                          fontWeight: FontWeight.w700, color: tc)),
                  const SizedBox(height: 3),
                  Text(tx.userName ?? tx.userEmail ?? '—',
                      style: const TextStyle(fontSize: 12, color: AppColors.grey600),
                      overflow: TextOverflow.ellipsis),
                ]),
              ),
              _StatusBadge(status: tx.status),
            ]),
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(children: [
              _MetricCell(label: 'Grams',
                  value: Formatters.formatGrams(tx.grams)),
              _vDiv(),
              _MetricCell(label: 'Amount',
                  value: Formatters.formatCurrency(tx.amountBdt), bold: true),
              _vDiv(),
              _MetricCell(label: 'Fee',
                  value: Formatters.formatCurrency(tx.feeAmount)),
              _vDiv(),
              _MetricCell(label: 'Date',
                  value: Formatters.formatDate(tx.createdAt)),
            ]),
          ),
          if (tx.status.toLowerCase() == 'pending') ...[
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: _ActionButtons(tx: tx, ctrl: ctrl),
            ),
          ],
        ]),
      ),
    );
  }

  Widget _vDiv() => Container(
      width: 1, height: 32, color: const Color(0xFFEEEEEE),
      margin: const EdgeInsets.symmetric(horizontal: 10));
}

class _MetricCell extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _MetricCell(
      {required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: const TextStyle(fontSize: 10, color: AppColors.grey400,
                  fontWeight: FontWeight.w500, letterSpacing: 0.3)),
          const SizedBox(height: 3),
          Text(value,
              style: TextStyle(fontSize: 13,
                  fontWeight: bold ? FontWeight.bold : FontWeight.w500,
                  color: AppColors.textPrimary),
              overflow: TextOverflow.ellipsis),
        ]),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
//  Shared atom widgets
// ─────────────────────────────────────────────────────────────────────────────

class _TypeIcon extends StatelessWidget {
  final String type;
  final double size;
  const _TypeIcon({required this.type, required this.size});

  @override
  Widget build(BuildContext context) {
    final clr = _typeColor(type);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        // Light tint background — distinct per type, not plain white
        color: clr.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(color: clr.withValues(alpha: 0.25), width: 1),
      ),
      padding: EdgeInsets.all(size * 0.18),
      child: CachedNetworkImage(
        imageUrl: _pngForType(type),
        // NO color tint — let the PNG show its own natural colours
        fit: BoxFit.contain,
        errorWidget: (_, __, ___) =>
            Icon(_iconForType(type), color: clr, size: size * 0.52),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final clr  = _statusColor(status);
    final icon = _statusIcon(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: clr),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: clr),
        const SizedBox(width: 4),
        Text(status.toUpperCase(),
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                color: clr, letterSpacing: 0.5)),
      ]),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final Transaction tx;
  final TransactionController ctrl;
  const _ActionButtons({required this.tx, required this.ctrl});

  @override
  Widget build(BuildContext context) => Wrap(spacing: 8, runSpacing: 6, children: [
        ElevatedButton.icon(
          onPressed: () => _showApproveDialog(context, tx, ctrl),
          icon: const Icon(Icons.check_rounded, size: 14),
          label: const Text('Approve', style: TextStyle(fontSize: 12)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.statusApproved,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        OutlinedButton.icon(
          onPressed: () => _showRejectDialog(context, tx, ctrl),
          icon: const Icon(Icons.close_rounded, size: 14),
          label: const Text('Reject', style: TextStyle(fontSize: 12)),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.statusRejected,
            side: const BorderSide(color: AppColors.statusRejected),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ]);
}

// ─────────────────────────────────────────────────────────────────────────────
//  Detail bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

void _showDetailSheet(BuildContext context, Transaction tx,
    TransactionController ctrl) {
  Get.bottomSheet(
    Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 40, height: 4,
          margin: const EdgeInsets.only(top: 12, bottom: 8),
          decoration: BoxDecoration(color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(children: [
            _TypeIcon(type: tx.type, size: 44),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_typeLabel(tx.type),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                        color: _typeColor(tx.type))),
                const SizedBox(height: 3),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: tx.id));
                    Get.snackbar('Copied', 'ID copied',
                        duration: const Duration(seconds: 1));
                  },
                  child: Text(tx.id,
                      style: const TextStyle(fontSize: 11, color: AppColors.grey400,
                          fontFamily: 'monospace'),
                      overflow: TextOverflow.ellipsis),
                ),
              ]),
            ),
            _StatusBadge(status: tx.status),
          ]),
        ),
        const Divider(height: 1, color: Color(0xFFEEEEEE)),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(children: [
              _dRow('User',       tx.userName ?? tx.userEmail ?? '—'),
              _dRow('User ID',    tx.userId ?? '—'),
              _dRow('Grams',      Formatters.formatGrams(tx.grams)),
              _dRow('Amount',     Formatters.formatCurrency(tx.amountBdt), bold: true),
              _dRow('Fee %',      '${tx.feePercent}%'),
              _dRow('Fee Amount', Formatters.formatCurrency(tx.feeAmount)),
              if (tx.code != null) _dRow('Code', tx.code!),
              _dRow('Created',    Formatters.formatDateTime(tx.createdAt)),
              if (tx.approvedAt != null)
                _dRow('Approved', Formatters.formatDateTime(tx.approvedAt!)),
              if (tx.rejectedAt != null)
                _dRow('Rejected', Formatters.formatDateTime(tx.rejectedAt!)),
              if (tx.adminNote != null && tx.adminNote!.isNotEmpty)
                _dRow('Note', tx.adminNote!),
            ]),
          ),
        ),
        if (tx.status.toLowerCase() == 'pending') ...[
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: Row(children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () { Get.back(); _showApproveDialog(context, tx, ctrl); },
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: const Text('Approve Transaction'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.statusApproved,
                    foregroundColor: Colors.white, elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () { Get.back(); _showRejectDialog(context, tx, ctrl); },
                  icon: const Icon(Icons.close_rounded, size: 16),
                  label: const Text('Reject'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.statusRejected,
                    side: const BorderSide(color: AppColors.statusRejected),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ]),
          ),
        ],
        SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
      ]),
    ),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

Widget _dRow(String label, String value, {bool bold = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 110,
          child: Text(label,
              style: const TextStyle(fontSize: 12, color: AppColors.grey600,
                  fontWeight: FontWeight.w500)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(value,
              style: TextStyle(fontSize: 13, color: AppColors.textPrimary,
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        ),
      ]),
    );

// ─────────────────────────────────────────────────────────────────────────────
//  Approve / Reject dialogs
// ─────────────────────────────────────────────────────────────────────────────

void _showApproveDialog(BuildContext context, Transaction tx,
    TransactionController ctrl) {
  final noteCtrl = TextEditingController();
  Get.dialog(Dialog(
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Lottie.network(_lottieApproved, width: 90, height: 90, repeat: false,
              errorBuilder: (_, __, ___) => const Icon(Icons.check_circle_rounded,
                  size: 64, color: AppColors.statusApproved)),
          const SizedBox(height: 12),
          const Text('Approve Transaction',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(Formatters.formatCurrency(tx.amountBdt),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
                  color: AppColors.statusApproved)),
          const SizedBox(height: 4),
          Text(_typeLabel(tx.type),
              style: const TextStyle(fontSize: 13, color: AppColors.grey600)),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 14),
          TextField(
            controller: noteCtrl, maxLines: 2,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              labelText: 'Note (optional)',
              filled: true, fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  ctrl.approveTransaction(tx.id,
                      note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.statusApproved,
                  foregroundColor: Colors.white, elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Confirm Approve'),
              ),
            ),
          ]),
        ]),
      ),
    ),
  ));
}

void _showRejectDialog(BuildContext context, Transaction tx,
    TransactionController ctrl) {
  final noteCtrl = TextEditingController();
  Get.dialog(Dialog(
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Lottie.network(_lottieRejected, width: 90, height: 90, repeat: false,
              errorBuilder: (_, __, ___) => const Icon(Icons.cancel_rounded,
                  size: 64, color: AppColors.statusRejected)),
          const SizedBox(height: 12),
          const Text('Reject Transaction',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(Formatters.formatCurrency(tx.amountBdt),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
                  color: AppColors.statusRejected)),
          const SizedBox(height: 4),
          Text(_typeLabel(tx.type),
              style: const TextStyle(fontSize: 13, color: AppColors.grey600)),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 14),
          TextField(
            controller: noteCtrl, maxLines: 3,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              labelText: 'Reason (optional)',
              filled: true, fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  ctrl.rejectTransaction(tx.id,
                      note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.statusRejected,
                  foregroundColor: Colors.white, elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Confirm Reject'),
              ),
            ),
          ]),
        ]),
      ),
    ),
  ));
}
