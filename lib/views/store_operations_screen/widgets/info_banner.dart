import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';

class InfoBanner extends StatelessWidget {
  final List<String> tips;
  final int currentTipIndex;

  const InfoBanner({
    super.key,
    required this.tips,
    required this.currentTipIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.grey200, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Store icon with shimmer (kept)
          Icon(
            Icons.store,
            color: AppColors.primary,
            size: 20,
          )
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(
                duration: 2000.ms,
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
          const SizedBox(width: 12),
          // Title
          Text(
            'Store Operations',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          // Separator dot
          Container(
            width: 3,
            height: 3,
            decoration: BoxDecoration(
              color: AppColors.grey400,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          // Rotating tip
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: Text(
                tips[currentTipIndex],
                key: ValueKey(currentTipIndex),
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.grey500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Active badge (static, no pulsing)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Active',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
