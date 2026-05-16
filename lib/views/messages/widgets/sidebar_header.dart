import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/message_controller.dart';
import 'design_tokens.dart';

class SidebarHeader extends StatelessWidget {
  final MessageController controller;

  const SidebarHeader({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 12, 16),
      decoration: BoxDecoration(
        color: sidebarBg,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conversations',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1D26)),
                ),
                Obx(() {
                  final count = controller.messageThreads.length;
                  return Text(
                    '$count ${count == 1 ? "thread" : "threads"}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  );
                }),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            tooltip: 'Refresh',
            style: IconButton.styleFrom(
              backgroundColor: surfaceBg,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: controller.loadMessageThreads,
          ),
        ],
      ),
    );
  }
}
