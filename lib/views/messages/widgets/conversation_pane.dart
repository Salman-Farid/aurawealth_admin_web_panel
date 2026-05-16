import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/admin_chat_controller.dart';
import '../../../controllers/message_controller.dart';
import 'chat_body.dart';
import 'chat_tab_bar.dart';
import 'conversation_header.dart';
import 'design_tokens.dart';
import 'empty_conversation.dart';
import 'reply_box.dart';

class ConversationPane extends StatelessWidget {
  final MessageController controller;

  const ConversationPane({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final userId = controller.selectedUserId.value;
      if (userId.isEmpty) return const EmptyConversation();

      // Ensure AdminChatController exists
      if (!Get.isRegistered<AdminChatController>(tag: userId)) {
        Get.put(
          AdminChatController(targetUserId: userId),
          tag: userId,
          permanent: false,
        );
      }

      final adminChat = Get.find<AdminChatController>(tag: userId);
      final thread = controller.messageThreads.firstWhereOrNull(
        (t) => t.userId == userId,
      );

      return Container(
        color: surfaceBg,
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────────
            ConversationHeader(
              thread: thread,
              adminChat: adminChat,
              controller: controller,
            ),

            // ── Tab bar (Live Chat | Mail) ────────────────────────────────
            ChatTabBar(adminChat: adminChat),

            // ── Message area ──────────────────────────────────────────────
            // ValueKey = fresh State (scroll + worker) per user conversation
            Expanded(
              child: ChatBody(
                key: ValueKey(adminChat.targetUserId),
                adminChat: adminChat,
              ),
            ),

            // ── Reply box ─────────────────────────────────────────────────
            ReplyBox(adminChat: adminChat),
          ],
        ),
      );
    });
  }
}
