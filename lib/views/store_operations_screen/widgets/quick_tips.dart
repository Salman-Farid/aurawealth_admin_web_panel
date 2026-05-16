import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class QuickTips extends StatelessWidget {
  final List<String> tips;

  const QuickTips({
    super.key,
    required this.tips,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tips_and_updates, size: 16, color: AppColors.grey600),
              const SizedBox(width: 8),
              Text(
                'Quick Tips',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...tips.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle,
                        size: 14, color: AppColors.success),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tip,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.grey600,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
