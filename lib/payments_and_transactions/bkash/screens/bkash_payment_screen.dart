import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../shared/models/payment_request.dart';
import '../../shared/models/payment_transaction.dart';
import '../../shared/utils/payment_formatters.dart';
import '../../shared/widgets/payment_glass_card.dart';
import '../../shared/widgets/payment_status_widgets.dart';
import '../controllers/bkash_payment_controller.dart';
import '../models/bkash_config.dart';
import '../services/bkash_payment_service.dart';
import '../widgets/bkash_gateway_card.dart';

class BkashPaymentScreen extends StatefulWidget {
  const BkashPaymentScreen({super.key});

  @override
  State<BkashPaymentScreen> createState() => _BkashPaymentScreenState();
}

class _BkashPaymentScreenState extends State<BkashPaymentScreen> {
  late final BkashPaymentController _controller;
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _invoiceController = TextEditingController();
  final _descriptionController = TextEditingController(
    text: 'AuraWealth bKash payment',
  );

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<BkashPaymentController>()
        ? Get.find<BkashPaymentController>()
        : Get.put(
            BkashPaymentController(
              service: BkashPaymentService(config: const BkashConfig()),
            ),
          );
    _controller.loadTransactions();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _invoiceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: RefreshIndicator(
        onRefresh: _controller.loadTransactions,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 900;
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  if (isNarrow)
                    Column(
                      children: [
                        _buildPaymentForm(),
                        const SizedBox(height: 18),
                        _buildTransactionsPanel(),
                      ],
                    )
                  else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 5, child: _buildPaymentForm()),
                        const SizedBox(width: 18),
                        Expanded(flex: 6, child: _buildTransactionsPanel()),
                      ],
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeSlideText(
          'bKash Payments',
          style: TextStyle(
            fontSize: MediaQuery.sizeOf(context).width < 600 ? 26 : 32,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 8),
        FadeSlideText(
          'Create, execute, query, and review Bangladesh mobile wallet checkout sessions.',
          index: 1,
          style: TextStyle(fontSize: 14, color: AppColors.grey600),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(child: BkashGatewayCard(selected: true, onTap: () {})),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(
                () => PaymentGlassCard(
                  animationIndex: 1,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const PaymentGradientIcon(
                        icon: Icons.receipt_long_rounded,
                        color: Color(0xFF43C6AC),
                        size: 44,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FadeSlideText(
                              '${_controller.transactions.length}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            FadeSlideText(
                              'Loaded transactions',
                              index: 1,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.grey600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentForm() {
    return PaymentGlassCard(
      animationIndex: 1,
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                PaymentGradientIcon(
                  icon: Icons.phone_iphone_rounded,
                  color: Color(0xFFE2136E),
                  size: 48,
                ),
                SizedBox(width: 14),
                Expanded(
                  child: FadeSlideText(
                    'Create bKash Checkout Session',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _PaymentField(
              controller: _amountController,
              label: 'Amount (BDT)',
              icon: Icons.payments_rounded,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: _amountValidator,
            ),
            const SizedBox(height: 12),
            _PaymentField(
              controller: _nameController,
              label: 'Customer Name',
              icon: Icons.person_outline_rounded,
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            _PaymentField(
              controller: _emailController,
              label: 'Customer Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: _emailValidator,
            ),
            const SizedBox(height: 12),
            _PaymentField(
              controller: _invoiceController,
              label: 'Merchant Invoice Number (optional)',
              icon: Icons.numbers_rounded,
            ),
            const SizedBox(height: 12),
            _PaymentField(
              controller: _descriptionController,
              label: 'Description',
              icon: Icons.description_outlined,
              maxLines: 2,
              validator: _requiredValidator,
            ),
            const SizedBox(height: 18),
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: _controller.isCreatingSession.value
                      ? null
                      : _createPayment,
                  icon: _controller.isCreatingSession.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.mobile_friendly_rounded),
                  label: Text(
                    _controller.isCreatingSession.value
                        ? 'Creating...'
                        : 'Create bKash Payment',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFE2136E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Obx(() {
              final session = _controller.currentSession.value;
              if (session == null) return const SizedBox.shrink();
              return _SessionPreview(controller: _controller);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsPanel() {
    return PaymentGlassCard(
      animationIndex: 2,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: FadeSlideText(
                  'Recent bKash Transactions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
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
          Obx(() {
            if (_controller.isLoading.value &&
                _controller.transactions.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (_controller.errorMessage.value.isNotEmpty &&
                _controller.transactions.isEmpty) {
              return _InlineMessage(
                icon: Icons.error_outline_rounded,
                color: AppColors.error,
                message: _controller.errorMessage.value,
              );
            }
            if (_controller.transactions.isEmpty) {
              return const _InlineMessage(
                icon: Icons.receipt_long_outlined,
                color: Color(0xFFE2136E),
                message: 'No bKash transactions found yet.',
              );
            }
            return Column(
              children: _controller.transactions.take(8).map((tx) {
                return _BkashTransactionRow(transaction: tx)
                    .animate()
                    .fadeIn(duration: 420.ms)
                    .slideY(begin: 0.08, end: 0, duration: 520.ms);
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _createPayment() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.parse(_amountController.text.trim());
    final session = await _controller.createPayment(
      PaymentRequest(
        amount: amount,
        currency: 'BDT',
        customerName: _nameController.text.trim(),
        customerEmail: _emailController.text.trim(),
        description: _descriptionController.text.trim(),
        merchantInvoiceNumber: _invoiceController.text.trim(),
      ),
    );
    if (session != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('bKash payment session created')),
      );
    }
  }

  String? _amountValidator(String? value) {
    final amount = double.tryParse(value?.trim() ?? '');
    if (amount == null || amount <= 0) return 'Enter a valid amount';
    return null;
  }

  String? _requiredValidator(String? value) =>
      value == null || value.trim().isEmpty ? 'Required' : null;

  String? _emailValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Required';
    if (!text.contains('@') || !text.contains('.')) return 'Invalid email';
    return null;
  }
}

class _SessionPreview extends StatelessWidget {
  final BkashPaymentController controller;

  const _SessionPreview({required this.controller});

  @override
  Widget build(BuildContext context) {
    final session = controller.currentSession.value!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE2136E).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2136E).withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  PaymentFormatters.shortId(session.paymentId),
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              Text(
                session.status.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFFE2136E),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            PaymentFormatters.money(session.amount, currency: session.currency),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFFE2136E),
            ),
          ),
          if (session.bkashUrl.isNotEmpty) ...[
            const SizedBox(height: 8),
            SelectableText(
              session.bkashUrl,
              style: TextStyle(fontSize: 12, color: AppColors.grey700),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: controller.queryCurrentPayment,
                  icon: const Icon(Icons.search_rounded),
                  label: const Text('Query'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: controller.isLoading.value
                      ? null
                      : () => controller.executeCurrentPayment(),
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: const Text('Execute'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFE2136E),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms).scaleXY(begin: 0.98, end: 1);
  }
}

class _BkashTransactionRow extends StatelessWidget {
  final PaymentTransaction transaction;

  const _BkashTransactionRow({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grey100.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const PaymentGradientIcon(
            icon: Icons.phone_iphone_rounded,
            color: Color(0xFFE2136E),
            size: 38,
            animate: false,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.customerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 3),
                Text(
                  '${PaymentFormatters.shortId(transaction.id)} • ${PaymentFormatters.date(transaction.createdAt)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: AppColors.grey600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                PaymentFormatters.money(
                  transaction.amount,
                  currency: transaction.currency,
                ),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              PaymentStatusPill(status: transaction.status),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  const _PaymentField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: AppColors.grey100.withValues(alpha: 0.65),
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
  }
}

class _InlineMessage extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String message;

  const _InlineMessage({
    required this.icon,
    required this.color,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.14)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.grey700,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
