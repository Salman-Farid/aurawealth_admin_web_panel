import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/admin_chat_controller.dart';
import 'design_tokens.dart';
import 'tab_chip.dart';

class ChatTabBar extends StatelessWidget {
  final AdminChatController adminChat;

  const ChatTabBar({
    super.key,
    required this.adminChat,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLive = adminChat.messageTypeFilter.value == 'live';
      return Container(
        color: headerBg,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Row(
          children: [
            TabChip(
              label: 'Live Chat',
              icon: Icons.chat_bubble_rounded,
              isActive: isLive,
              activeColor: liveAccent,
              onTap: () => adminChat.setMessageTypeFilter('live'),
            ),
            const SizedBox(width: 8),
            TabChip(
              label: 'Mail',
              icon: Icons.mail_rounded,
              isActive: !isLive,
              activeColor: mailAccent,
              onTap: () => adminChat.setMessageTypeFilter('static'),
            ),
            Obx(() {
              final liveCount = adminChat.messages
                  .where((m) => m.messageType == 'live')
                  .length;
              final mailCount = adminChat.messages
                  .where((m) => m.messageType == 'static')
                  .length;
              return Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  isLive
                      ? '$liveCount message${liveCount == 1 ? "" : "s"}'
                      : '$mailCount email${mailCount == 1 ? "" : "s"}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade400,
                  ),
                ),
              );
            }),
          ],
        ),
      );
    });
  }
}
