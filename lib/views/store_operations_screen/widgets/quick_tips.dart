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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.grey100.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tips_and_updates, size: 14, color: AppColors.grey500),
              const SizedBox(width: 6),
              Text(
                'Quick Tips',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...tips.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle,
                        size: 13, color: AppColors.success),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        tip,
                        style: TextStyle(
                          fontSize: 11,
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
