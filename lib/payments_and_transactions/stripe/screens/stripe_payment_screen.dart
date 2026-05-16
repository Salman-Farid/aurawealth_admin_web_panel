import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../shared/models/payment_request.dart';
import '../../shared/models/payment_transaction.dart';
import '../../shared/utils/payment_formatters.dart';
import '../../shared/widgets/payment_glass_card.dart';
import '../../shared/widgets/payment_status_widgets.dart';
import '../controllers/stripe_payment_controller.dart';
import '../models/stripe_config.dart';
import '../services/stripe_payment_service.dart';
import '../widgets/stripe_gateway_card.dart';

class StripePaymentScreen extends StatefulWidget {
  const StripePaymentScreen({super.key});

  @override
  State<StripePaymentScreen> createState() => _StripePaymentScreenState();
}

class _StripePaymentScreenState extends State<StripePaymentScreen> {
  late final StripePaymentController _controller;
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _currencyController = TextEditingController(text: 'BDT');
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _descriptionController = TextEditingController(
    text: 'AuraWealth payment',
  );

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<StripePaymentController>()
        ? Get.find<StripePaymentController>()
        : Get.put(
            StripePaymentController(
              service: StripePaymentService(
                config: const StripeConfig(publishableKey: ''),
              ),
            ),
          );
    _controller.loadTransactions();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _currencyController.dispose();
    _nameController.dispose();
    _emailController.dispose();
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
                  _Header(controller: _controller),
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

  Widget _buildPaymentForm() {
    return PaymentGlassCard(
      animationIndex: 1,
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const PaymentGradientIcon(
                  icon: Icons.credit_card_rounded,
                  color: Color(0xFF635BFF),
                  size: 48,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FadeSlideText(
                        'Create Stripe Payment',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF111827),
                        ),
                      ),
                      FadeSlideText(
                        'Generate a payment intent from the admin panel.',
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
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _PaymentField(
                    controller: _amountController,
                    label: 'Amount',
                    icon: Icons.payments_rounded,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: _amountValidator,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PaymentField(
                    controller: _currencyController,
                    label: 'Currency',
                    icon: Icons.monetization_on_outlined,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Required'
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _PaymentField(
              controller: _nameController,
              label: 'Customer Name',
              icon: Icons.person_outline_rounded,
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Required' : null,
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
              controller: _descriptionController,
              label: 'Description',
              icon: Icons.description_outlined,
              maxLines: 2,
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 18),
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: _controller.isCreatingIntent.value
                      ? null
                      : _createPaymentIntent,
                  icon: _controller.isCreatingIntent.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.bolt_rounded),
                  label: Text(
                    _controller.isCreatingIntent.value
                        ? 'Creating...'
                        : 'Create Payment Intent',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF635BFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Obx(() {
              final intent = _controller.currentIntent.value;
              if (intent == null) return const SizedBox.shrink();
              return _IntentPreview(controller: _controller);
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
                  'Recent Stripe Transactions',
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
                color: Color(0xFF635BFF),
                message: 'No Stripe transactions found yet.',
              );
            }
            return Column(
              children: _controller.transactions.take(8).map((tx) {
                return _StripeTransactionRow(transaction: tx)
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

  Future<void> _createPaymentIntent() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.parse(_amountController.text.trim());
    final intent = await _controller.createPaymentIntent(
      PaymentRequest(
        amount: amount,
        currency: _currencyController.text.trim().toUpperCase(),
        customerName: _nameController.text.trim(),
        customerEmail: _emailController.text.trim(),
        description: _descriptionController.text.trim(),
      ),
    );
    if (intent != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stripe payment intent created')),
      );
    }
  }

  String? _amountValidator(String? value) {
    final amount = double.tryParse(value?.trim() ?? '');
    if (amount == null || amount <= 0) return 'Enter a valid amount';
    return null;
  }

  String? _emailValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Required';
    if (!text.contains('@') || !text.contains('.')) return 'Invalid email';
    return null;
  }
}

class _Header extends StatelessWidget {
  final StripePaymentController controller;

  const _Header({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeSlideText(
          'Stripe Payments',
          style: TextStyle(
            fontSize: MediaQuery.sizeOf(context).width < 600 ? 26 : 32,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 8),
        FadeSlideText(
          'Accept card, wallet, and Stripe-supported payments from a dedicated admin workflow.',
          index: 1,
          style: TextStyle(fontSize: 14, color: AppColors.grey600),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(child: StripeGatewayCard(selected: true, onTap: () {})),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(
                () => PaymentGlassCard(
                  animationIndex: 1,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const PaymentGradientIcon(
                        icon: Icons.analytics_outlined,
                        color: Color(0xFF43C6AC),
                        size: 44,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FadeSlideText(
                              '${controller.transactions.length}',
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
}

class _IntentPreview extends StatelessWidget {
  final StripePaymentController controller;

  const _IntentPreview({required this.controller});

  @override
  Widget build(BuildContext context) {
    final intent = controller.currentIntent.value!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF635BFF).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF635BFF).withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  PaymentFormatters.shortId(intent.id),
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              PaymentStatusPill(status: intent.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            PaymentFormatters.money(intent.amount, currency: intent.currency),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF635BFF),
            ),
          ),
          if (intent.checkoutUrl != null && intent.checkoutUrl!.isNotEmpty) ...[
            const SizedBox(height: 8),
            SelectableText(
              intent.checkoutUrl!,
              style: TextStyle(fontSize: 12, color: AppColors.grey700),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: controller.isLoading.value
                  ? null
                  : controller.confirmCurrentIntent,
              icon: const Icon(Icons.verified_rounded),
              label: const Text('Confirm Current Intent'),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms).scaleXY(begin: 0.98, end: 1);
  }
}

class _StripeTransactionRow extends StatelessWidget {
  final PaymentTransaction transaction;

  const _StripeTransactionRow({required this.transaction});

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
            icon: Icons.credit_card_rounded,
            color: Color(0xFF635BFF),
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
