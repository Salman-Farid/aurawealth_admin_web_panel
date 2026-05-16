import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class PaymentFormatters {
  PaymentFormatters._();

  static String money(double amount, {String currency = 'BDT'}) {
    final fixed = amount.toStringAsFixed(
      amount.truncateToDouble() == amount ? 0 : 2,
    );
    if (currency.toUpperCase() == 'BDT') return '৳$fixed';
    if (currency.toUpperCase() == 'USD') return '\$$fixed';
    return '$fixed ${currency.toUpperCase()}';
  }

  static String shortId(String id) {
    if (id.length <= 12) return id;
    return '${id.substring(0, 6)}…${id.substring(id.length - 4)}';
  }

  static String date(DateTime value) {
    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${value.day} ${months[value.month - 1]} ${value.year}';
  }

  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'succeeded':
      case 'success':
      case 'paid':
      case 'completed':
        return AppColors.success;
      case 'failed':
      case 'cancelled':
      case 'canceled':
        return AppColors.error;
      case 'processing':
        return AppColors.primary;
      case 'refunded':
        return const Color(0xFF7C5CBF);
      case 'pending':
      default:
        return AppColors.warning;
    }
  }
}
