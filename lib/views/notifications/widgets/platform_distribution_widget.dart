import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../widgets/common/modern_card.dart';
import '../../../models/device.dart';

class PlatformDistributionWidget extends StatelessWidget {
  final DeviceStats stats;

  const PlatformDistributionWidget({
    Key? key,
    required this.stats,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final total = stats.totalDevices;
    if (total == 0) return const SizedBox.shrink();

    final androidPercent = (stats.androidDevices / total * 100).toStringAsFixed(1);
    final iosPercent = (stats.iosDevices / total * 100).toStringAsFixed(1);
    final webPercent = (stats.webDevices / total * 100).toStringAsFixed(1);

    return ModernCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Platform Distribution',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 24),
          _buildPlatformBar(
            '📱 Android',
            stats.androidDevices,
            total,
            androidPercent,
            const Color(0xFF3DDC84),
          ),
          const SizedBox(height: 16),
          _buildPlatformBar(
            '🍎 iOS',
            stats.iosDevices,
            total,
            iosPercent,
            const Color(0xFF000000),
          ),
          if (stats.webDevices > 0) ...[
            const SizedBox(height: 16),
            _buildPlatformBar(
              '🌐 Web',
              stats.webDevices,
              total,
              webPercent,
              const Color(0xFF2196F3),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildPlatformBar(
    String label,
    int count,
    int total,
    String percent,
    Color color,
  ) {
    final ratio = total > 0 ? count / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$count devices ($percent%)',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.grey600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 12,
            backgroundColor: AppColors.grey200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
