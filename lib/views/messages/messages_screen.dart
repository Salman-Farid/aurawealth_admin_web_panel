import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/message_controller.dart';
import '../../controllers/admin_chat_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' as custom_error;
import '../../widgets/common/empty_state_widget.dart';
import '../../models/message.dart';
import '../../models/message_thread.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MessageController>();
    final isMobile = Responsive.isMobile(context);

    return Obx(() {
      if (controller.isLoading.value && controller.messageThreads.isEmpty) {
        return LoadingWidget(message: 'Loading messages...');
      }

      if (controller.errorMessage.value.isNotEmpty && controller.messageThreads.isEmpty) {
        return custom_error.CustomErrorWidget(
          message: controller.errorMessage.value,
          onRetry: controller.refresh,
        );
      }

      if (isMobile) {
        // Mobile: Show either thread list or conversation
        return controller.selectedUserId.value.isEmpty
            ? _buildThreadsList(context, controller)
            : _buildConversation(context, controller);
      }

      // Desktop/Tablet: Split view
      return Row(
        children: [
          // Thread List
          Container(
            width: 350,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: AppColors.grey200, width: 1),
              ),
            ),
            child: _buildThreadsList(context, controller),
          ),

          // Conversation
          Expanded(
            child: controller.selectedUserId.value.isEmpty
                ? EmptyStateWidget(
                    message: 'Select a conversation',
                    icon: Icons.message_outlined,
                  )
                : _buildConversation(context, controller),
          ),
        ],
      );
    });
  }

  Widget _buildThreadsList(BuildContext context, MessageController controller) {
    return Column(
      children: [
        // Header
        Container(
          padding: EdgeInsets.all(AppConstants.defaultPadding),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.grey200, width: 1),
            ),
          ),
          child: Row(
            children: [
              Text(
                'Conversations',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Spacer(),
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: controller.loadMessageThreads,
              ),
            ],
          ),
        ),

        // Thread List
        Expanded(
          child: Obx(() {
            if (controller.messageThreads.isEmpty) {
              return EmptyStateWidget(
                message: 'No messages yet',
                icon: Icons.inbox_outlined,
              );
            }

            return ListView.builder(
              itemCount: controller.messageThreads.length,
              itemBuilder: (context, index) {
                final thread = controller.messageThreads[index];
                return _buildThreadItem(context, thread, controller);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildThreadItem(
      BuildContext context, MessageThread thread, MessageController controller) {
    return Obx(() {
      final isSelected = controller.selectedUserId.value == thread.userId;

      return Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.grey100 : Colors.white,
          border: Border(
            bottom: BorderSide(color: AppColors.grey200, width: 1),
            left: isSelected ? BorderSide(color: AppColors.primary, width: 3) : BorderSide.none,
          ),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Text(
              thread.userName.isNotEmpty ? thread.userName[0].toUpperCase() : 'U',
              style: TextStyle(color: Colors.white),
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  thread.userName,
                  style: TextStyle(
                    fontWeight: thread.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (thread.unreadCount > 0)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    thread.unreadCount.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4),
              Text(
                thread.lastMessage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.grey600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                Formatters.formatRelativeTime(thread.lastMessageAt),
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.grey600,
                ),
              ),
            ],
          ),
          onTap: () {
            controller.loadUserMessages(thread.userId);
            // Initialize AdminChatController for this user
            if (!Get.isRegistered<AdminChatController>(tag: thread.userId)) {
              Get.put(
                AdminChatController(targetUserId: thread.userId),
                tag: thread.userId,
                permanent: false,
              );
            }
          },
        ),
      );
    });
  }

  Widget _buildConversation(BuildContext context, MessageController controller) {
    final isMobile = Responsive.isMobile(context);

    return Column(
      children: [
        // Conversation Header with Live/Mail Toggle
        Container(
          padding: EdgeInsets.all(AppConstants.defaultPadding),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.grey200, width: 1),
            ),
          ),
          child: Row(
            children: [
              if (isMobile)
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => controller.selectedUserId.value = '',
                ),
              Expanded(
                child: Obx(() {
                  final thread = controller.messageThreads.firstWhereOrNull(
                    (t) => t.userId == controller.selectedUserId.value,
                  );
                  return Text(
                    thread?.userName ?? 'User',
                    style: Theme.of(context).textTheme.headlineSmall,
                  );
                }),
              ),
              // Live/Mail Toggle
              Obx(() {
                final adminChat = Get.find<AdminChatController>(tag: controller.selectedUserId.value);
                return Row(
                  children: [
                    // Connection Status Dot
                    Container(
                      width: 8,
                      height: 8,
                      margin: EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: adminChat.isConnected.value ? Colors.green : Colors.orange,
                      ),
                    ),
                    Text(
                      adminChat.isConnected.value ? 'Live' : 'Connecting…',
                      style: TextStyle(
                        fontSize: 12,
                        color: adminChat.isConnected.value ? Colors.green : Colors.orange,
                      ),
                    ),
                    SizedBox(width: 12),
                    // Toggle Buttons
                    _buildMessageTypeToggle(context, adminChat),
                  ],
                );
              }),
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () => controller.loadUserMessages(
                  controller.selectedUserId.value,
                ),
              ),
            ],
          ),
        ),

        // Messages
        Expanded(
          child: Obx(() {
            final adminChat = Get.find<AdminChatController>(tag: controller.selectedUserId.value);
            final displayMessages = adminChat.filteredMessages;

            if (adminChat.isLoadingHistory.value && displayMessages.isEmpty) {
              return LoadingWidget();
            }

            if (displayMessages.isEmpty) {
              return EmptyStateWidget(
                message: 'No messages in this conversation',
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(AppConstants.defaultPadding),
              reverse: false,
              itemCount: displayMessages.length,
              itemBuilder: (context, index) {
                final message = displayMessages[index];
                return _buildMessageBubble(message);
              },
            );
          }),
        ),

        // Reply Box
        _buildReplyBox(context, controller),
      ],
    );
  }

  Widget _buildMessageTypeToggle(BuildContext context, AdminChatController adminChat) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _buildToggleButton(
            'Live',
            adminChat.messageTypeFilter.value == 'live' || adminChat.messageTypeFilter.value == 'all',
            () => adminChat.setMessageTypeFilter('live'),
          ),
          Container(
            width: 1,
            height: 24,
            color: AppColors.grey300,
          ),
          _buildToggleButton(
            'Mail',
            adminChat.messageTypeFilter.value == 'static' || adminChat.messageTypeFilter.value == 'all',
            () => adminChat.setMessageTypeFilter('static'),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, bool isActive, VoidCallback onPressed) {
    return SizedBox(
      width: 60,
      height: 36,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: isActive ? AppColors.primary : Colors.transparent,
          padding: EdgeInsets.zero,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    final isFromUser = message.isFromUser;
    final isStaticMessage = message.isStaticMessage;

    if (isStaticMessage) {
      return _buildStaticMailBubble(message, isFromUser);
    }

    // Live message bubble
    return Align(
      alignment: isFromUser ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(maxWidth: 500),
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isFromUser ? AppColors.grey300 : AppColors.primary,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.attachmentUrl != null)
              Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    message.attachmentUrl!,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 200,
                      height: 50,
                      color: AppColors.grey200,
                      child: Center(child: Text('Image failed to load')),
                    ),
                  ),
                ),
              ),
            Text(
              message.body,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 4),
            Text(
              Formatters.formatRelativeTime(message.parsedCreatedAt),
              style: TextStyle(
                fontSize: 11,
                color: AppColors.grey600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaticMailBubble(Message message, bool isFromUser) {
    return Align(
      alignment: isFromUser ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(maxWidth: 600),
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isFromUser ? Color(0xFFF5F5F5) : Color(0xFFF0F4FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isFromUser ? AppColors.grey300 : AppColors.primary.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with "FORMAL MESSAGE" or "EMAIL" badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isFromUser ? AppColors.grey300 : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FORMAL MESSAGE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          message.subject ?? '(No Subject)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.mail_outline,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ),
            // Body
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.body,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        Formatters.formatRelativeTime(message.parsedCreatedAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.grey600,
                        ),
                      ),
                      if (message.isRead)
                        Icon(
                          Icons.done_all,
                          size: 14,
                          color: AppColors.primary,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyBox(BuildContext context, MessageController controller) {
    final replyController = TextEditingController();
    final subjectController = TextEditingController();
    final messageType = 'live'.obs;

    return Container(
      padding: EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.grey200, width: 1),
        ),
      ),
      child: Obx(() {
        final adminChat = Get.find<AdminChatController>(tag: controller.selectedUserId.value);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Message Type Selector
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      _buildTypeButton(
                        '💬 Live',
                        messageType.value == 'live',
                        () => messageType.value = 'live',
                      ),
                      SizedBox(width: 8),
                      _buildTypeButton(
                        '📧 Mail',
                        messageType.value == 'static',
                        () => messageType.value = 'static',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            // Subject field (only for Mail)
            if (messageType.value == 'static')
              Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: TextField(
                  controller: subjectController,
                  maxLines: 1,
                  decoration: InputDecoration(
                    hintText: 'Subject (required for mail)...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    prefixIcon: Icon(Icons.subject),
                  ),
                ),
              ),
            // Body field
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: replyController,
                    maxLines: null,
                    maxLength: 500,
                    decoration: InputDecoration(
                      hintText: messageType.value == 'live'
                          ? 'Type your message...'
                          : 'Type your message body...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      counterText: '',
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: adminChat.isSending.value
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        )
                      : Icon(Icons.send),
                  color: AppColors.primary,
                  onPressed: adminChat.isSending.value
                      ? null
                      : () {
                          final text = replyController.text.trim();
                          if (text.isEmpty) return;

                          adminChat.sendMessage(
                            body: text,
                            messageType: messageType.value,
                            subject: messageType.value == 'static' ? subjectController.text.trim() : null,
                          ).then((_) {
                            replyController.clear();
                            subjectController.clear();
                          });
                        },
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTypeButton(String label, bool isActive, VoidCallback onPressed) {
    return Expanded(
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.grey100,
          borderRadius: BorderRadius.circular(8),
          border: isActive ? Border.all(color: AppColors.primary, width: 2) : null,
        ),
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
