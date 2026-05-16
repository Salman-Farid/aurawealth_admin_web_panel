import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

enum PaymentGateway { stripe, bkash }

extension PaymentGatewayX on PaymentGateway {
  String get id {
    switch (this) {
      case PaymentGateway.stripe:
        return 'stripe';
      case PaymentGateway.bkash:
        return 'bkash';
    }
  }

  String get title {
    switch (this) {
      case PaymentGateway.stripe:
        return 'Stripe';
      case PaymentGateway.bkash:
        return 'bKash';
    }
  }

  String get subtitle {
    switch (this) {
      case PaymentGateway.stripe:
        return 'Cards, wallets, and Stripe supported payment methods';
      case PaymentGateway.bkash:
        return 'Bangladesh mobile wallet checkout';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentGateway.stripe:
        return Icons.credit_card_rounded;
      case PaymentGateway.bkash:
        return Icons.phone_iphone_rounded;
    }
  }

  Color get color {
    switch (this) {
      case PaymentGateway.stripe:
        return const Color(0xFF635BFF);
      case PaymentGateway.bkash:
        return const Color(0xFFE2136E);
    }
  }

  Color get softColor => color.withValues(alpha: 0.10);

  Color get successColor => AppColors.success;
}
