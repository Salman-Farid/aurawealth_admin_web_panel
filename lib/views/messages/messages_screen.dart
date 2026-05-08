import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controllers/message_controller.dart';
import '../../core/utils/responsive.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' as custom_error;
import '../../widgets/common/animated_screen_wrapper.dart';
import 'widgets/conversation_list.dart';
import 'widgets/conversation_pane.dart';
import 'widgets/design_tokens.dart';
import 'widgets/empty_conversation.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MessageController>();
    final isMobile = Responsive.isMobile(context);

    return Obx(() {
      if (controller.isLoading.value && controller.messageThreads.isEmpty) {
        return const LoadingWidget(message: 'Loading conversations…');
      }

      if (controller.errorMessage.value.isNotEmpty &&
          controller.messageThreads.isEmpty) {
        return custom_error.CustomErrorWidget(
          message: controller.errorMessage.value,
          onRetry: controller.refresh,
        );
      }

      if (isMobile) {
        return controller.selectedUserId.value.isEmpty
            ? ConversationList(controller: controller)
            : ConversationPane(controller: controller);
      }

      return Row(
        children: [
          // ── Left sidebar ──────────────────────────────────────────────
          AnimatedEntrance(
            animationType: AnimationType.fadeSlideLeft,
            duration: 400.ms,
            child: Container(
              width: kSidebarWidth,
              color: sidebarBg,
              child: ConversationList(controller: controller),
            ),
          ),

          // ── Right pane ────────────────────────────────────────────────
          Expanded(
            child: AnimatedEntrance(
              animationType: AnimationType.fadeSlideRight,
              delay: 150.ms,
              duration: 400.ms,
              child: controller.selectedUserId.value.isEmpty
                  ? const EmptyConversation()
                  : ConversationPane(controller: controller),
            ),
          ),
        ],
      );
    });
  }
}
