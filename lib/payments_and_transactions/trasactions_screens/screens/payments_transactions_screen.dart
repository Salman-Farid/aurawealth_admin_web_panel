import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../bkash/services/bkash_payment_service.dart';
import '../../shared/models/payment_gateway.dart';
import '../../shared/models/payment_transaction.dart';
import '../../shared/utils/payment_formatters.dart';
import '../../shared/widgets/payment_glass_card.dart';
import '../../stripe/models/stripe_config.dart';
import '../../stripe/services/stripe_payment_service.dart';
import '../controllers/payments_transactions_controller.dart';
import '../services/payments_transactions_service.dart';
import '../widgets/payment_stat_card.dart';
import '../widgets/payment_transaction_tile.dart';

class PaymentsTransactionsScreen extends StatefulWidget {
  const PaymentsTransactionsScreen({super.key});

  @override
  State<PaymentsTransactionsScreen> createState() =>
      _PaymentsTransactionsScreenState();
}

class _PaymentsTransactionsScreenState
    extends State<PaymentsTransactionsScreen> {
  late final PaymentsTransactionsController _controller;
  final _searchController = TextEditingController();
  final _statusOptions = const <String>[
    '',
    'Pending',
    'Processing',
    'Succeeded',
    'Failed',
    'Cancelled',
    'Refunded',
  ];

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<PaymentsTransactionsController>()
        ? Get.find<PaymentsTransactionsController>()
        : Get.put(
            PaymentsTransactionsController(
              service: PaymentsTransactionsService(
                stripeService: StripePaymentService(
                  config: const StripeConfig(publishableKey: ''),
                ),
                bkashService: BkashPaymentService(),
              ),
            ),
          );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: RefreshIndicator(
        onRefresh: _controller.loadTransactions,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 22),
              _buildStatsGrid(),
              const SizedBox(height: 18),
              _buildFilters(),
              const SizedBox(height: 18),
              _buildTransactionList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 760;
        final title = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeSlideText(
              'Payments & Transactions',
              style: TextStyle(
                fontSize: MediaQuery.sizeOf(context).width < 600 ? 26 : 34,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                letterSpacing: -0.9,
              ),
            ),
            const SizedBox(height: 8),
            FadeSlideText(
              'Monitor Stripe and bKash payment activity with animated, responsive admin controls.',
              index: 1,
              style: TextStyle(fontSize: 14, color: AppColors.grey600),
            ),
          ],
        );

        final actions = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _GatewayAction(
              gateway: PaymentGateway.stripe,
              onTap: () => _controller.setGateway(PaymentGateway.stripe),
            ),
            const SizedBox(width: 10),
            _GatewayAction(
              gateway: PaymentGateway.bkash,
              onTap: () => _controller.setGateway(PaymentGateway.bkash),
            ),
          ],
        );

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [title, const SizedBox(height: 14), actions],
          );
        }
        return Row(
          children: [
            Expanded(child: title),
            actions,
          ],
        );
      },
    );
  }

  Widget _buildStatsGrid() {
    return Obx(
      () => LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final columns = width >= 1100
              ? 4
              : width >= 760
              ? 2
              : 1;
          final spacing = columns == 1 ? 12.0 : 16.0;
          final cardWidth = (width - (spacing * (columns - 1))) / columns;
          final cards = <Widget>[
            PaymentStatCard(
              label: 'Total Volume',
              value: PaymentFormatters.money(_controller.totalVolume),
              icon: Icons.account_balance_wallet_outlined,
              color: AppColors.primary,
              index: 0,
            ),
            PaymentStatCard(
              label: 'Succeeded',
              value: '${_controller.succeededCount}',
              icon: Icons.verified_rounded,
              color: AppColors.success,
              index: 1,
            ),
            PaymentStatCard(
              label: 'Pending / Processing',
              value: '${_controller.pendingCount}',
              icon: Icons.hourglass_top_rounded,
              color: AppColors.warning,
              index: 2,
            ),
            PaymentStatCard(
              label: 'Failed / Cancelled',
              value: '${_controller.failedCount}',
              icon: Icons.error_outline_rounded,
              color: AppColors.error,
              index: 3,
            ),
          ];

          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: cards
                .map((card) => SizedBox(width: cardWidth, child: card))
                .toList(),
          );
        },
      ),
    );
  }

  Widget _buildFilters() {
    return PaymentGlassCard(
      animationIndex: 2,
      padding: const EdgeInsets.all(16),
      child: Obx(
        () => LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 760;
            final search = TextField(
              controller: _searchController,
              onChanged: _controller.setSearch,
              decoration: InputDecoration(
                hintText: 'Search by name, email, ID, gateway...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: AppColors.grey100.withValues(alpha: 0.7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.grey200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.grey200),
                ),
              ),
            );

            final filters = Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _GatewayFilterChip(
                  label: 'All',
                  selected: _controller.filter.value.gateway == null,
                  onTap: () => _controller.setGateway(null),
                ),
                for (final gateway in PaymentGateway.values)
                  _GatewayFilterChip(
                    label: gateway.title,
                    color: gateway.color,
                    selected: _controller.filter.value.gateway == gateway,
                    onTap: () => _controller.setGateway(gateway),
                  ),
                const SizedBox(width: 4),
                DropdownButtonHideUnderline(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.grey200),
                    ),
                    child: DropdownButton<String>(
                      value: _controller.filter.value.status,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      items: _statusOptions
                          .map(
                            (status) => DropdownMenuItem(
                              value: status,
                              child: Text(
                                status.isEmpty ? 'All Statuses' : status,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => _controller.setStatus(value ?? ''),
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    _searchController.clear();
                    _controller.clearFilters();
                  },
                  icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
                  label: const Text('Clear'),
                ),
              ],
            );

            if (isNarrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [search, const SizedBox(height: 12), filters],
              );
            }
            return Row(
              children: [
                Expanded(child: search),
                const SizedBox(width: 14),
                Flexible(flex: 2, child: filters),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    return PaymentGlassCard(
      animationIndex: 3,
      padding: const EdgeInsets.all(18),
      child: Obx(() {
        final items = _controller.filteredTransactions;
        if (_controller.isLoading.value && _controller.transactions.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 80),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (_controller.errorMessage.value.isNotEmpty &&
            _controller.transactions.isEmpty) {
          return _StateMessage(
            icon: Icons.cloud_off_rounded,
            color: AppColors.error,
            title: 'Unable to load transactions',
            message: _controller.errorMessage.value,
            actionLabel: 'Retry',
            onAction: _controller.loadTransactions,
          );
        }

        if (items.isEmpty) {
          return _StateMessage(
            icon: Icons.receipt_long_outlined,
            color: AppColors.primary,
            title: 'No matching transactions',
            message:
                'Try clearing filters or refresh when your payment endpoints return data.',
            actionLabel: 'Clear filters',
            onAction: () {
              _searchController.clear();
              _controller.clearFilters();
            },
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: FadeSlideText(
                    '${items.length} Transactions',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _controller.loadTransactions,
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Refresh',
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...List.generate(
              items.length,
              (index) => Padding(
                padding: EdgeInsets.only(top: index == 0 ? 0 : 10),
                child: PaymentTransactionTile(
                  transaction: items[index],
                  index: index,
                  onTap: () => _showTransactionDetails(items[index]),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  void _showTransactionDetails(PaymentTransaction transaction) {
    Get.dialog<void>(
      Dialog(
        insetPadding: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    PaymentGradientIcon(
                      icon: transaction.gateway.icon,
                      color: transaction.gateway.color,
                      size: 48,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        transaction.customerName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back<void>(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _DetailLine(label: 'Transaction ID', value: transaction.id),
                _DetailLine(label: 'Gateway', value: transaction.gateway.title),
                _DetailLine(label: 'Status', value: transaction.status.label),
                _DetailLine(
                  label: 'Amount',
                  value: PaymentFormatters.money(
                    transaction.amount,
                    currency: transaction.currency,
                  ),
                ),
                _DetailLine(
                  label: 'Email',
                  value: transaction.customerEmail.isEmpty
                      ? 'N/A'
                      : transaction.customerEmail,
                ),
                _DetailLine(
                  label: 'Created',
                  value: PaymentFormatters.date(transaction.createdAt),
                ),
                if (transaction.checkoutUrl != null &&
                    transaction.checkoutUrl!.isNotEmpty)
                  _DetailLine(
                    label: 'Checkout URL',
                    value: transaction.checkoutUrl!,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GatewayAction extends StatelessWidget {
  final PaymentGateway gateway;
  final VoidCallback onTap;

  const _GatewayAction({required this.gateway, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: gateway.color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: gateway.color.withValues(alpha: 0.16)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(gateway.icon, color: gateway.color, size: 20),
            const SizedBox(width: 8),
            Text(
              gateway.title,
              style: TextStyle(
                color: gateway.color,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 450.ms).slideX(begin: 0.08, end: 0);
  }
}

class _GatewayFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;

  const _GatewayFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primary;
    return ChoiceChip(
      selected: selected,
      label: Text(label),
      onSelected: (_) => onTap(),
      selectedColor: effectiveColor.withValues(alpha: 0.12),
      labelStyle: TextStyle(
        color: selected ? effectiveColor : AppColors.grey700,
        fontWeight: FontWeight.w800,
      ),
      side: BorderSide(
        color: selected
            ? effectiveColor.withValues(alpha: 0.35)
            : AppColors.grey200,
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    );
  }
}

class _StateMessage extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _StateMessage({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 54),
      child: Center(
        child: Column(
          children: [
            PaymentGradientIcon(icon: icon, color: color, size: 58),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.grey600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  final String label;
  final String value;

  const _DetailLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.grey600,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          SelectableText(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
