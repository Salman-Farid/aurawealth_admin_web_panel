import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../controllers/notification_controller.dart';
import '../../../controllers/user_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../widgets/common/modern_card.dart';

class TargetedNotificationCard extends StatefulWidget {
  const TargetedNotificationCard({Key? key}) : super(key: key);

  @override
  State<TargetedNotificationCard> createState() => _TargetedNotificationCardState();
}

class _TargetedNotificationCardState extends State<TargetedNotificationCard> {
  final NotificationController _controller = Get.find<NotificationController>();
  final UserController _userController = Get.find<UserController>();
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();
  
  String? _selectedUserId;
  bool _includeImage = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _imageUrlController.dispose();
    _dataController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildUserDropdown(),
          const SizedBox(height: 16),
          _buildTitleInput(),
          const SizedBox(height: 16),
          _buildBodyInput(),
          const SizedBox(height: 16),
          _buildImageToggle(),
          if (_includeImage) ...[
            const SizedBox(height: 16),
            _buildImageUrlInput(),
          ],
          const SizedBox(height: 16),
          _buildDataInput(),
          const SizedBox(height: 24),
          _buildSendButton(),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1, end: 0);
  }

  Widget _buildHeader() {
    return Row(
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
    );
  }

  Widget _buildUserDropdown() {
    return Obx(() {
      final users = _userController.filteredUsers;
      return DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Select User',
          prefixIcon: const Icon(Icons.person_search_rounded),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        value: _selectedUserId,
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
          setState(() => _selectedUserId = value);
        },
      );
    });
  }

  Widget _buildTitleInput() {
    return TextField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: 'Notification Title',
        hintText: 'e.g., Flash Sale Alert!',
        prefixIcon: const Icon(Icons.title_rounded),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      maxLength: 100,
    );
  }

  Widget _buildBodyInput() {
    return TextField(
      controller: _bodyController,
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
    );
  }

  Widget _buildImageToggle() {
    return SwitchListTile(
      value: _includeImage,
      onChanged: (value) => setState(() => _includeImage = value),
      title: const Text('Include Image'),
      subtitle: const Text('Add an image URL for rich notification'),
      secondary: const Icon(Icons.image_outlined),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildImageUrlInput() {
    return TextField(
      controller: _imageUrlController,
      decoration: InputDecoration(
        labelText: 'Image URL',
        hintText: 'https://example.com/image.jpg',
        prefixIcon: const Icon(Icons.link_rounded),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildDataInput() {
    return TextField(
      controller: _dataController,
      decoration: InputDecoration(
        labelText: 'Custom Data (JSON, Optional)',
        hintText: '{"key": "value"}',
        prefixIcon: const Icon(Icons.data_object_rounded),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      maxLines: 2,
    );
  }

  Widget _buildSendButton() {
    return Obx(() => SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _controller.isSending.value ? null : _handleSend,
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
        ));
  }

  Future<void> _handleSend() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    final imageUrl = _includeImage ? _imageUrlController.text.trim() : null;
    final dataJson = _dataController.text.trim();

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

    if (_selectedUserId == null) {
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
    if (dataJson.isNotEmpty) {
      try {
        data = Map<String, dynamic>.from(jsonDecode(dataJson));
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
      userId: _selectedUserId,
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
      _clearForm();
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

  void _clearForm() {
    _titleController.clear();
    _bodyController.clear();
    _imageUrlController.clear();
    _dataController.clear();
    setState(() {
      _selectedUserId = null;
      _includeImage = false;
    });
  }
}
