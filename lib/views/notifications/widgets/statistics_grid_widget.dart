import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../widgets/common/modern_card.dart';
import '../../../models/device.dart';

class StatisticsGridWidget extends StatelessWidget {
  final DeviceStats stats;

  const StatisticsGridWidget({
    Key? key,
    required this.stats,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: Responsive.isDesktop(context) ? 4 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: Responsive.isDesktop(context) ? 1.5 : 1.3,
      children: [
        _buildStatCard(
          'Total Devices',
          stats.totalDevices.toString(),
          Icons.devices_rounded,
          const Color(0xFF2196F3),
          0,
        ),
        _buildStatCard(
          'Active Devices',
          stats.activeDevices.toString(),
          Icons.check_circle_rounded,
          const Color(0xFF4CAF50),
          1,
        ),
        _buildStatCard(
          'Android Devices',
          stats.androidDevices.toString(),
          Icons.android_rounded,
          const Color(0xFF3DDC84),
          2,
        ),
        _buildStatCard(
          'iOS Devices',
          stats.iosDevices.toString(),
          Icons.apple_rounded,
          const Color(0xFF000000),
          3,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    int index,
  ) {
    return ModernCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.grey600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 100 * (index + 1)))
        .scale(delay: Duration(milliseconds: 100 * (index + 1)));
  }
}
