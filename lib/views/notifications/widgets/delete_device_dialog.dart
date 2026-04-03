import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/notification_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/device.dart';

class DeleteDeviceDialog {
  static Future<void> show(Device device) async {
    final controller = Get.find<NotificationController>();

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Deactivate Device'),
        content: Text(
          'Are you sure you want to deactivate this device for ${device.userName ?? device.userEmail}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await controller.deleteDevice(device.id);
      if (success) {
        Get.snackbar(
          'Success',
          'Device deactivated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          controller.errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
      }
    }
  }
}
