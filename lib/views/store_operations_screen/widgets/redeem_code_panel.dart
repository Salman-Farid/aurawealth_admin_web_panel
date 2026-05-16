import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../core/constants/app_colors.dart';
import 'instructions.dart';

class RedeemCodePanel extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController codeController;
  final bool isLoading;
  final VoidCallback onRedeemCode;

  const RedeemCodePanel({
    super.key,
    required this.formKey,
    required this.codeController,
    required this.isLoading,
    required this.onRedeemCode,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.background,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.qr_code_scanner,
                        color: AppColors.warning,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Redeem Transaction Code',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'For store sell or exchange',
                            style: TextStyle(
                              color: AppColors.grey600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Lottie Animation
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: Lottie.asset(
                        'assets/lottie/Transaction Confirmation.json',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Code Field
                TextFormField(
                  controller: codeController,
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    labelText: 'Redemption Code',
                    hintText: 'A3X9KL',
                    prefixIcon: const Icon(Icons.confirmation_number_outlined),
                    filled: true,
                    fillColor: AppColors.grey100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.grey200,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.warning,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter redemption code';
                    }
                    if (value.length != 6) {
                      return 'Code must be 6 characters';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    codeController.value = codeController.value.copyWith(
                      text: value.toUpperCase(),
                      selection: TextSelection.collapsed(
                        offset: value.length,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Warning Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: AppColors.warning, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Redeeming will approve the transaction and consume locked grams',
                          style: TextStyle(
                            color: AppColors.warning,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                ElevatedButton(
                  onPressed: isLoading ? null : onRedeemCode,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.warning,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: isLoading ? 0 : 2,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Redeem Code',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),

                const SizedBox(height: 24),

                // Expiry Warning
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.schedule, color: AppColors.error, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Codes expire after 60 minutes',
                          style: TextStyle(
                            color: AppColors.error,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Instructions
                const Instructions(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
