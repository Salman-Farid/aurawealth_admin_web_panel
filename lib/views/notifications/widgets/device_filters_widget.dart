import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../controllers/notification_controller.dart';

class DeviceFiltersWidget extends StatelessWidget {
  const DeviceFiltersWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationController>();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSearchAndFilter(controller),
          const SizedBox(height: 12),
          _buildFilterChips(controller),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildSearchAndFilter(NotificationController controller) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search by user, email, or device...',
              prefixIcon: const Icon(Icons.search_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) => controller.setSearchQuery(value),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: _buildDeviceTypeDropdown(controller),
        ),
      ],
    );
  }

  Widget _buildDeviceTypeDropdown(NotificationController controller) {
    return Obx(() => DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Device Type',
            prefixIcon: const Icon(Icons.devices_rounded),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          value: controller.selectedDeviceType.value,
          items: const [
            DropdownMenuItem(value: 'all', child: Text('All Devices')),
            DropdownMenuItem(value: 'android', child: Text('📱 Android')),
            DropdownMenuItem(value: 'ios', child: Text('🍎 iOS')),
            DropdownMenuItem(value: 'web', child: Text('🌐 Web')),
          ],
          onChanged: (value) {
            if (value != null) controller.setDeviceTypeFilter(value);
          },
        ));
  }

  Widget _buildFilterChips(NotificationController controller) {
    return Row(
      children: [
        Obx(() => FilterChip(
              label: Text(
                'Active Only (${controller.activeOnly.value ? 'ON' : 'OFF'})',
              ),
              selected: controller.activeOnly.value,
              onSelected: (_) => controller.toggleActiveOnly(),
              avatar: Icon(
                controller.activeOnly.value
                    ? Icons.check_circle
                    : Icons.circle_outlined,
                size: 18,
              ),
            )),
        const SizedBox(width: 12),
        Obx(() => Chip(
              avatar: const Icon(Icons.devices, size: 18),
              label: Text('${controller.filteredDevices.length} devices'),
            )),
      ],
    );
  }
}
