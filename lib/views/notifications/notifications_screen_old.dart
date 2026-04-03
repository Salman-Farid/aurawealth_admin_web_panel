import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../controllers/notification_controller.dart';
import '../../controllers/user_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' as custom_error;
import '../../widgets/common/modern_card.dart';
import '../../widgets/common/status_badge.dart';
import '../../models/device.dart';

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
          _buildHeader(),
          _buildTabBar(),
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

  Widget _buildHeader() {
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
          Container(
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
              .shake(duration: 3000.ms, hz: 0.5, curve: Curves.easeInOutCubic),
          const SizedBox(width: 16),
          Expanded(
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
          ),
          IconButton(
            onPressed: () => _controller.refresh(),
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

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.grey600,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        tabs: const [
          Tab(icon: Icon(Icons.send_rounded), text: 'Send Notifications'),
          Tab(icon: Icon(Icons.devices_rounded), text: 'Device Management'),
          Tab(icon: Icon(Icons.analytics_outlined), text: 'Statistics'),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }

  // ============================
  // TAB 1: SEND NOTIFICATIONS
  // ============================
  Widget _buildSendNotificationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          if (Responsive.isDesktop(context))
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildTargetedNotificationCard()),
                const SizedBox(width: 20),
                Expanded(child: _buildBroadcastNotificationCard()),
              ],
            )
          else ...[
            _buildTargetedNotificationCard(),
            const SizedBox(height: 20),
            _buildBroadcastNotificationCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildTargetedNotificationCard() {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    final imageUrlController = TextEditingController();
    final dataController = TextEditingController();
    String? selectedUserId;
    bool includeImage = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return ModernCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0288D1).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: Color(0xFF0288D1),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Targeted Notification',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Send to specific user(s)',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // User Selection
              Obx(() {
                final users = _userController.filteredUsers;
                return DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Select User',
                    prefixIcon: const Icon(Icons.person_search_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  value: selectedUserId,
                  items: users.map((user) {
                    return DropdownMenuItem(
                      value: user.id,
                      child: Text(
                        '${user.name ?? user.email ?? 'Unknown'} (${user.email ?? ''})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedUserId = value);
                  },
                );
              }),
              
              const SizedBox(height: 16),
              
              // Title
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Notification Title',
                  hintText: 'e.g., Flash Sale Alert!',
                  prefixIcon: const Icon(Icons.title_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLength: 100,
              ),
              
              const SizedBox(height: 16),
              
              // Body
              TextField(
                controller: bodyController,
                decoration: InputDecoration(
                  labelText: 'Notification Body',
                  hintText: 'Enter your message here...',
                  prefixIcon: const Icon(Icons.message_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
                maxLength: 250,
              ),
              
              const SizedBox(height: 16),
              
              // Include Image Toggle
              SwitchListTile(
                value: includeImage,
                onChanged: (value) => setState(() => includeImage = value),
                title: const Text('Include Image'),
                subtitle: const Text('Add an image URL for rich notification'),
                secondary: const Icon(Icons.image_outlined),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              
              if (includeImage) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: imageUrlController,
                  decoration: InputDecoration(
                    labelText: 'Image URL',
                    hintText: 'https://example.com/image.jpg',
                    prefixIcon: const Icon(Icons.link_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 16),
              
              // Custom Data (Optional)
              TextField(
                controller: dataController,
                decoration: InputDecoration(
                  labelText: 'Custom Data (JSON, Optional)',
                  hintText: '{"key": "value"}',
                  prefixIcon: const Icon(Icons.data_object_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 2,
              ),
              
              const SizedBox(height: 24),
              
              // Send Button
              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _controller.isSending.value
                          ? null
                          : () => _sendTargetedNotification(
                                context,
                                userId: selectedUserId,
                                title: titleController.text,
                                body: bodyController.text,
                                imageUrl: includeImage ? imageUrlController.text : null,
                                dataJson: dataController.text,
                              ),
                      icon: _controller.isSending.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send_rounded),
                      label: Text(
                        _controller.isSending.value ? 'Sending...' : 'Send Notification',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0288D1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  )),
            ],
          ),
        ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1, end: 0);
      },
    );
  }

  Widget _buildBroadcastNotificationCard() {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    final imageUrlController = TextEditingController();
    final dataController = TextEditingController();
    bool includeImage = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return ModernCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53935).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.campaign_outlined,
                      color: Color(0xFFE53935),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Broadcast Notification',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Send to all active users',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Warning Banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFF9800).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFFF9800),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This will send to ALL active users. Use carefully!',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Title
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Notification Title',
                  hintText: 'e.g., System Maintenance',
                  prefixIcon: const Icon(Icons.title_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLength: 100,
              ),
              
              const SizedBox(height: 16),
              
              // Body
              TextField(
                controller: bodyController,
                decoration: InputDecoration(
                  labelText: 'Notification Body',
                  hintText: 'Enter broadcast message...',
                  prefixIcon: const Icon(Icons.message_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
                maxLength: 250,
              ),
              
              const SizedBox(height: 16),
              
              // Include Image Toggle
              SwitchListTile(
                value: includeImage,
                onChanged: (value) => setState(() => includeImage = value),
                title: const Text('Include Image'),
                subtitle: const Text('Add an image URL for rich notification'),
                secondary: const Icon(Icons.image_outlined),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              
              if (includeImage) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: imageUrlController,
                  decoration: InputDecoration(
                    labelText: 'Image URL',
                    hintText: 'https://example.com/image.jpg',
                    prefixIcon: const Icon(Icons.link_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 16),
              
              // Custom Data (Optional)
              TextField(
                controller: dataController,
                decoration: InputDecoration(
                  labelText: 'Custom Data (JSON, Optional)',
                  hintText: '{"key": "value"}',
                  prefixIcon: const Icon(Icons.data_object_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 2,
              ),
              
              const SizedBox(height: 24),
              
              // Send Button
              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _controller.isSending.value
                          ? null
                          : () => _sendBroadcast(
                                context,
                                title: titleController.text,
                                body: bodyController.text,
                                imageUrl: includeImage ? imageUrlController.text : null,
                                dataJson: dataController.text,
                              ),
                      icon: _controller.isSending.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.campaign_rounded),
                      label: Text(
                        _controller.isSending.value ? 'Broadcasting...' : 'Send Broadcast',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  )),
            ],
          ),
        ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1, end: 0);
      },
    );
  }

  // ============================
  // TAB 2: DEVICE MANAGEMENT
  // ============================
  Widget _buildDeviceManagementTab() {
    return Column(
      children: [
        _buildDeviceFilters(),
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
              return _buildEmptyDeviceState();
            }

            return _buildDeviceList(devices);
          }),
        ),
      ],
    );
  }

  Widget _buildDeviceFilters() {
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
          Row(
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (value) => _controller.setSearchQuery(value),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Obx(() => DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Device Type',
                        prefixIcon: const Icon(Icons.devices_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      value: _controller.selectedDeviceType.value,
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All Devices')),
                        DropdownMenuItem(value: 'android', child: Text('📱 Android')),
                        DropdownMenuItem(value: 'ios', child: Text('🍎 iOS')),
                        DropdownMenuItem(value: 'web', child: Text('🌐 Web')),
                      ],
                      onChanged: (value) {
                        if (value != null) _controller.setDeviceTypeFilter(value);
                      },
                    )),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Obx(() => FilterChip(
                    label: Text('Active Only (${_controller.activeOnly.value ? 'ON' : 'OFF'})'),
                    selected: _controller.activeOnly.value,
                    onSelected: (_) => _controller.toggleActiveOnly(),
                    avatar: Icon(
                      _controller.activeOnly.value ? Icons.check_circle : Icons.circle_outlined,
                      size: 18,
                    ),
                  )),
              const SizedBox(width: 12),
              Obx(() => Chip(
                    avatar: const Icon(Icons.devices, size: 18),
                    label: Text('${_controller.filteredDevices.length} devices'),
                  )),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildDeviceList(List<Device> devices) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: devices.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final device = devices[index];
        return _buildDeviceCard(device, index);
      },
    );
  }

  Widget _buildDeviceCard(Device device, int index) {
    return ModernCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Device Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: device.isActive
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.grey200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              device.deviceIcon,
              style: const TextStyle(fontSize: 24),
            ),
          ),
          const SizedBox(width: 16),
          
          // Device Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        device.userName ?? device.userEmail ?? 'Unknown User',
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
                  device.userEmail ?? 'No email',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.grey600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.smartphone_rounded, size: 14, color: AppColors.grey500),
                    const SizedBox(width: 4),
                    Text(
                      device.deviceName ?? device.deviceType,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.grey600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.access_time_rounded, size: 14, color: AppColors.grey500),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(device.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.grey600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Actions
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: AppColors.grey600),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (value) {
              if (value == 'copy_token') {
                Clipboard.setData(ClipboardData(text: device.token));
                Get.snackbar(
                  'Copied',
                  'Device token copied to clipboard',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.success,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                );
              } else if (value == 'delete') {
                _confirmDeleteDevice(device);
              } else if (value == 'view_user') {
                _showUserDevicesDialog(device.userId);
              }
            },
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
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: 50 * index))
        .fadeIn(duration: 400.ms)
        .slideX(begin: -0.1, end: 0);
  }

  Widget _buildEmptyDeviceState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.devices_rounded,
            size: 80,
            color: AppColors.grey400,
          ),
          const SizedBox(height: 16),
          Text(
            'No devices found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey500,
            ),
          ),
        ],
      ),
    );
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

        return Column(
          children: [
            _buildStatsGrid(stats),
            const SizedBox(height: 24),
            _buildPlatformDistribution(stats),
          ],
        );
      }),
    );
  }

  Widget _buildStatsGrid(DeviceStats stats) {
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
        ).animate().fadeIn(delay: 100.ms).scale(delay: 100.ms),
        _buildStatCard(
          'Active Devices',
          stats.activeDevices.toString(),
          Icons.check_circle_rounded,
          const Color(0xFF4CAF50),
        ).animate().fadeIn(delay: 200.ms).scale(delay: 200.ms),
        _buildStatCard(
          'Android Devices',
          stats.androidDevices.toString(),
          Icons.android_rounded,
          const Color(0xFF3DDC84),
        ).animate().fadeIn(delay: 300.ms).scale(delay: 300.ms),
        _buildStatCard(
          'iOS Devices',
          stats.iosDevices.toString(),
          Icons.apple_rounded,
          const Color(0xFF000000),
        ).animate().fadeIn(delay: 400.ms).scale(delay: 400.ms),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
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
    );
  }

  Widget _buildPlatformDistribution(DeviceStats stats) {
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

  // ============================
  // HELPER METHODS
  // ============================

  Future<void> _sendTargetedNotification(
    BuildContext context, {
    String? userId,
    required String title,
    required String body,
    String? imageUrl,
    String? dataJson,
  }) async {
    if (title.isEmpty || body.isEmpty) {
      Get.snackbar(
        'Error',
        'Title and body are required',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    if (userId == null) {
      Get.snackbar(
        'Error',
        'Please select a user',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    Map<String, dynamic>? data;
    if (dataJson != null && dataJson.isNotEmpty) {
      try {
        data = Map<String, dynamic>.from(
          jsonDecode(dataJson),
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Invalid JSON format in custom data',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
        return;
      }
    }

    final response = await _controller.sendNotification(
      userId: userId,
      title: title,
      body: body,
      imageUrl: imageUrl,
      data: data,
    );

    if (response != null && response.success) {
      Get.snackbar(
        'Success',
        response.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Error',
        _controller.errorMessage.value.isEmpty
            ? 'Failed to send notification'
            : _controller.errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _sendBroadcast(
    BuildContext context, {
    required String title,
    required String body,
    String? imageUrl,
    String? dataJson,
  }) async {
    if (title.isEmpty || body.isEmpty) {
      Get.snackbar(
        'Error',
        'Title and body are required',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    // Confirmation dialog
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Broadcast'),
        content: const Text(
          'This will send a notification to ALL active users. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    Map<String, dynamic>? data;
    if (dataJson != null && dataJson.isNotEmpty) {
      try {
        data = Map<String, dynamic>.from(
          jsonDecode(dataJson),
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Invalid JSON format in custom data',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
        return;
      }
    }

    final response = await _controller.sendBroadcast(
      title: title,
      body: body,
      imageUrl: imageUrl,
      data: data,
    );

    if (response != null && response.success) {
      Get.snackbar(
        'Success',
        response.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Error',
        _controller.errorMessage.value.isEmpty
            ? 'Failed to send broadcast'
            : _controller.errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _confirmDeleteDevice(Device device) async {
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
      final success = await _controller.deleteDevice(device.id);
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
          _controller.errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
      }
    }
  }

  Future<void> _showUserDevicesDialog(String userId) async {
    // Find user
    final user = _userController.users.firstWhereOrNull((u) => u.id == userId);
    if (user == null) return;

    final userDevices = _controller.devices.where((d) => d.userId == userId).toList();

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
              Row(
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
              ),
              const SizedBox(height: 20),
              Text(
                '${userDevices.length} Device(s)',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              if (userDevices.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'No devices found',
                      style: TextStyle(color: AppColors.grey600),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  itemCount: userDevices.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final device = userDevices[index];
                    return ListTile(
                      leading: Text(device.deviceIcon, style: const TextStyle(fontSize: 24)),
                      title: Text(device.deviceName ?? device.deviceType),
                      subtitle: Text(_formatDate(device.createdAt)),
                      trailing: device.isActive
                          ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
                          : const Icon(Icons.cancel, color: Colors.red, size: 20),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today at ${DateFormat('HH:mm').format(date)}';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }
}
