import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../../controllers/transaction_controller.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../models/transaction.dart';
import './transaction_constants.dart';
import 'atoms/type_icon.dart';
import 'atoms/status_badge.dart';
import 'atoms/action_buttons.dart';
import 'dialogs/detail_sheet.dart';

class DesktopTable extends StatelessWidget {
  final List<Transaction> transactions;
  final TransactionController ctrl;
  const DesktopTable({super.key, required this.transactions, required this.ctrl});

  static const double _w = 170+130+100+70+110+90+90+150 + 14*8.0 + 20+16;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: SizedBox(
      width: _w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const TableHeader(),
          const Divider(height: 1, color: border),
          Expanded(
            child: ListView.builder(
              itemCount: transactions.length,
              addAutomaticKeepAlives: false,
              addRepaintBoundaries: true,
              itemBuilder: (_, i) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (i > 0) const Divider(height: 1, color: border),
                  _TableRow(
                    tx: transactions[i],
                    odd: i.isOdd,
                    ctrl: ctrl,
                    index: i,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class TableHeader extends StatelessWidget {
  const TableHeader({super.key});

  @override
  Widget build(BuildContext context) => Container(
    color: bg,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: const [
        SizedBox(width: 170, child: _TH('TRANSACTION')),
        SizedBox(width: 14),
        SizedBox(width: 130, child: _TH('USER')),
        SizedBox(width: 14),
        SizedBox(width: 100, child: _TH('STATUS')),
        SizedBox(width: 14),
        SizedBox(width: 70,  child: _TH('GRAMS')),
        SizedBox(width: 14),
        SizedBox(width: 110, child: _TH('AMOUNT')),
        SizedBox(width: 14),
        SizedBox(width: 90,  child: _TH('FEE')),
        SizedBox(width: 14),
        SizedBox(width: 90,  child: _TH('DATE')),
        SizedBox(width: 14),
        SizedBox(width: 150, child: _TH('ACTIONS')),
        SizedBox(width: 16),
      ]),
    ),
  ).animate()
    .fadeIn(delay: 100.ms, duration: 200.ms, curve: Curves.easeOutCubic)
    .slideY(delay: 100.ms, begin: 0.04, end: 0, duration: 200.ms, curve: Curves.easeOutCubic);
}

class _TH extends StatelessWidget {
  final String label;
  const _TH(this.label);

  @override
  Widget build(BuildContext context) => Text(label,
      style: const TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: textSec,
          letterSpacing: 0.7));
}

class _TableRow extends StatelessWidget {
  final Transaction tx;
  final bool odd;
  final TransactionController ctrl;
  final int index;
  const _TableRow({required this.tx, required this.odd, required this.ctrl, required this.index});

  @override
  Widget build(BuildContext context) {
    final tc = typeColor(tx.type);
    final delay = Duration(milliseconds: 150 + index * 15);
    return InkWell(
      onTap: () => showDetailSheet(context, tx, ctrl),
      hoverColor: const Color(0xFFF0F4FF),
      child: Container(
        color: odd ? const Color(0xFFFAFBFD) : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [

          SizedBox(
            width: 160,
            child: Row(children: [
              TypeIcon(type: tx.type, size: 30),
              const SizedBox(width: 7),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(typeLabel(tx.type),
                          style: TextStyle(fontSize: 11,
                              fontWeight: FontWeight.w700, color: tc),
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 1),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: tx.id));
                          Get.snackbar('Copied', 'ID copied',
                              duration: const Duration(seconds: 1));
                        },
                        child: Text(
                          tx.id.length > 8
                              ? '${tx.id.substring(0, 8)}…'
                              : tx.id,
                          style: const TextStyle(fontSize: 9,
                              color: textMuted, fontFamily: 'monospace'),
                        ),
                      ),
                    ]),
              ),
            ]),
          ),
          const SizedBox(width: 14),

          SizedBox(
            width: 130,
            child: Text(tx.userName ?? tx.userEmail ?? '—',
                style: const TextStyle(fontSize: 11, color: textPri),
                overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 14),

          SizedBox(width: 100, child: StatusBadge(status: tx.status)),
          const SizedBox(width: 14),

          SizedBox(
            width: 70,
            child: Text(Formatters.formatGrams(tx.grams),
                style: const TextStyle(fontSize: 11,
                    fontWeight: FontWeight.w500, color: textPri)),
          ),
          const SizedBox(width: 14),

          SizedBox(
            width: 110,
            child: Text(Formatters.formatCurrency(tx.amountBdt),
                style: const TextStyle(fontSize: 11,
                    fontWeight: FontWeight.w800, color: textPri)),
          ),
          const SizedBox(width: 14),

          SizedBox(
            width: 90,
            child: Text(Formatters.formatCurrency(tx.feeAmount),
                style: const TextStyle(fontSize: 11, color: textSec)),
          ),
          const SizedBox(width: 14),

          SizedBox(
            width: 90,
            child: Text(Formatters.formatDate(tx.createdAt),
                style: const TextStyle(fontSize: 10, color: textSec)),
          ),
          const SizedBox(width: 14),

          SizedBox(
            width: 150,
            child: tx.status.toLowerCase() == 'pending'
                ? ActionButtons(tx: tx, ctrl: ctrl)
                : const SizedBox.shrink(),
           ),
          const SizedBox(width: 16),
        ]),
        ),
      ),
    ).animate()
      .fadeIn(delay: delay, duration: 200.ms, curve: Curves.easeOutCubic)
      .slideY(delay: delay, begin: 0.04, end: 0, duration: 200.ms, curve: Curves.easeOutCubic);
  }
}
