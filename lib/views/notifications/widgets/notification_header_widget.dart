import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';

class NotificationHeaderWidget extends StatelessWidget {
  final VoidCallback onRefresh;

  const NotificationHeaderWidget({
    Key? key,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildAnimatedIcon(),
          const SizedBox(width: 16),
          _buildHeaderText(),
          IconButton(
            onPressed: onRefresh,
            icon: Icon(Icons.refresh_rounded, color: AppColors.primary),
            tooltip: 'Refresh',
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: -0.2, end: 0, curve: Curves.easeOut);
  }

  Widget _buildAnimatedIcon() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        Icons.notifications_active_outlined,
        color: AppColors.primary,
        size: 32,
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 2000.ms, color: AppColors.primary.withOpacity(0.3))
        .shake(duration: 3000.ms, hz: 0.5, curve: Curves.easeInOutCubic);
  }

  Widget _buildHeaderText() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Push Notifications',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Send notifications and manage user devices',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey600,
            ),
          ),
        ],
      ),
    );
  }
}
