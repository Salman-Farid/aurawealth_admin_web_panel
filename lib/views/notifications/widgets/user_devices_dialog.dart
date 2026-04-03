import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/notification_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/user.dart';
import '../helpers/date_formatter.dart';

class UserDevicesDialog {
  static void show(User user) {
    final controller = Get.find<NotificationController>();
    final userDevices = controller.devices
        .where((d) => d.userId == user.id)
        .toList();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(user),
              const SizedBox(height: 20),
              _buildDeviceCount(userDevices.length),
              const SizedBox(height: 12),
              _buildDeviceList(userDevices),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildHeader(User user) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name ?? 'Unknown',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.email ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.grey600,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.close_rounded),
        ),
      ],
    );
  }

  static Widget _buildDeviceCount(int count) {
    return Text(
      '$count Device(s)',
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  static Widget _buildDeviceList(List userDevices) {
    if (userDevices.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text(
            'No devices found',
            style: TextStyle(color: AppColors.grey600),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      itemCount: userDevices.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final device = userDevices[index];
        return ListTile(
          leading: Text(
            device.deviceIcon,
            style: const TextStyle(fontSize: 24),
          ),
          title: Text(device.deviceName ?? device.deviceType),
          subtitle: Text(NotificationDateFormatter.formatDate(device.createdAt)),
          trailing: device.isActive
              ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
              : const Icon(Icons.cancel, color: Colors.red, size: 20),
        );
      },
    );
  }
}
