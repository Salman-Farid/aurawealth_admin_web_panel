import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../widgets/common/modern_card.dart';
import '../../../widgets/common/status_badge.dart';
import '../../../models/device.dart';
import '../../../models/user.dart';
import '../helpers/date_formatter.dart';

class DeviceCardWidget extends StatelessWidget {
  final Device device;
  final User? user;
  final int index;
  final VoidCallback onViewUserDevices;
  final VoidCallback onDelete;

  const DeviceCardWidget({
    Key? key,
    required this.device,
    this.user,
    required this.index,
    required this.onViewUserDevices,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModernCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildDeviceIcon(),
              const SizedBox(width: 16),
              Expanded(child: _buildDeviceInfo()),
              _buildActionsMenu(),
            ],
          ),
        )
        .animate(delay: Duration(milliseconds: 50 * index))
        .fadeIn(duration: 400.ms)
        .slideX(begin: -0.1, end: 0);
  }

  Widget _buildDeviceIcon() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: device.isActive
            ? AppColors.success.withOpacity(0.1)
            : AppColors.grey200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(device.deviceIcon, style: const TextStyle(fontSize: 24)),
    );
  }

  Widget _buildDeviceInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                user?.displayName ??
                    device.userName ??
                    device.userEmail ??
                    'Unknown User',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (device.isActive)
              StatusBadge.success(text: 'Active', icon: Icons.check_circle)
            else
              StatusBadge.error(text: 'Inactive', icon: Icons.cancel),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          user?.email ?? device.userEmail ?? 'No email',
          style: TextStyle(fontSize: 13, color: AppColors.grey600),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.smartphone_rounded, size: 14, color: AppColors.grey500),
            const SizedBox(width: 4),
            Text(
              device.deviceName ?? device.deviceType,
              style: TextStyle(fontSize: 12, color: AppColors.grey600),
            ),
            const SizedBox(width: 12),
            Icon(Icons.access_time_rounded, size: 14, color: AppColors.grey500),
            const SizedBox(width: 4),
            Text(
              NotificationDateFormatter.formatDate(device.createdAt),
              style: TextStyle(fontSize: 12, color: AppColors.grey600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionsMenu() {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert_rounded, color: AppColors.grey600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) => _handleMenuAction(value),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'view_user',
          child: Row(
            children: [
              Icon(Icons.person_search_rounded, size: 18),
              SizedBox(width: 8),
              Text('View User Devices'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'copy_token',
          child: Row(
            children: [
              Icon(Icons.copy_rounded, size: 18),
              SizedBox(width: 8),
              Text('Copy Token'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
              SizedBox(width: 8),
              Text('Deactivate', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'view_user':
        onViewUserDevices();
        break;
      case 'copy_token':
        _copyTokenToClipboard();
        break;
      case 'delete':
        onDelete();
        break;
    }
  }

  void _copyTokenToClipboard() {
    Clipboard.setData(ClipboardData(text: device.token));
    Get.snackbar(
      'Copied',
      'Device token copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }
}
