import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controllers/notification_controller.dart';
import '../../controllers/user_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' as custom_error;
import '../../widgets/common/animated_screen_wrapper.dart';
import 'widgets/notification_header_widget.dart';
import 'widgets/notification_tab_bar_widget.dart';
import 'widgets/targeted_notification_card.dart';
import 'widgets/broadcast_notification_card.dart';
import 'widgets/device_filters_widget.dart';
import 'widgets/device_card_widget.dart';
import 'widgets/empty_device_state_widget.dart';
import 'widgets/statistics_grid_widget.dart';
import 'widgets/platform_distribution_widget.dart';
import 'widgets/user_devices_dialog.dart';
import 'widgets/delete_device_dialog.dart';

/// Main Notifications Screen
/// This screen provides 3 tabs:
/// 1. Send Notifications - Targeted and Broadcast
/// 2. Device Management - View and manage user devices
/// 3. Statistics - Device analytics and platform distribution
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final NotificationController _controller = Get.put(NotificationController());
  final UserController _userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          NotificationHeaderWidget(onRefresh: () => _controller.refresh()),
          NotificationTabBarWidget(tabController: _tabController),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSendNotificationTab(),
                _buildDeviceManagementTab(),
                _buildStatisticsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================
  // TAB 1: SEND NOTIFICATIONS
  // ============================
  Widget _buildSendNotificationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: AnimatedColumn(
        staggerDelay: 120.ms,
        children: [
          if (Responsive.isDesktop(context))
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: const TargetedNotificationCard()
                      .animate()
                      .fadeIn(delay: 100.ms, duration: 500.ms)
                      .slideX(begin: -0.1, end: 0, duration: 500.ms),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: const BroadcastNotificationCard()
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 500.ms)
                      .slideX(begin: 0.1, end: 0, duration: 500.ms),
                ),
              ],
            )
          else
            Column(
              children: const [
                TargetedNotificationCard(),
                SizedBox(height: 20),
                BroadcastNotificationCard(),
              ],
            ),
        ],
      ),
    );
  }

  // ============================
  // TAB 2: DEVICE MANAGEMENT
  // ============================
  Widget _buildDeviceManagementTab() {
    return Column(
      children: [
        const DeviceFiltersWidget(),
        Expanded(
          child: Obx(() {
            if (_controller.isLoading.value) {
              return const LoadingWidget(message: 'Loading devices...');
            }

            if (_controller.errorMessage.value.isNotEmpty) {
              return custom_error.CustomErrorWidget(
                message: _controller.errorMessage.value,
                onRetry: () => _controller.loadDevices(),
              );
            }

            final devices = _controller.filteredDevices;

            if (devices.isEmpty) {
              return const EmptyDeviceStateWidget();
            }

            return _buildDeviceList(devices);
          }),
        ),
      ],
    );
  }

  Widget _buildDeviceList(List devices) {
    return AnimatedListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: devices.length,
      staggerDelay: 50.ms,
      itemBuilder: (context, index) {
        final device = devices[index];
        final user = _userController.findUser(device.userId);
        return DeviceCardWidget(
          device: device,
          user: user,
          index: index,
          onViewUserDevices: () => _showUserDevicesDialog(device.userId),
          onDelete: () => DeleteDeviceDialog.show(device),
        );
      },
    );
  }

  void _showUserDevicesDialog(String userId) {
    final user = _userController.findUser(userId);
    if (user != null) {
      UserDevicesDialog.show(user);
    }
  }

  // ============================
  // TAB 3: STATISTICS
  // ============================
  Widget _buildStatisticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Obx(() {
        final stats = _controller.deviceStats.value;

        if (stats == null) {
          return const LoadingWidget(message: 'Loading statistics...');
        }

        return AnimatedColumn(
          staggerDelay: 120.ms,
          children: [
            StatisticsGridWidget(stats: stats),
            const SizedBox(height: 24),
            PlatformDistributionWidget(stats: stats),
          ],
        );
      }),
    );
  }
}
