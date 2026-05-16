import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../controllers/message_controller.dart';
import '../../../widgets/common/animated_screen_wrapper.dart';
import '../../../widgets/common/empty_state_widget.dart';
import 'thread_tile.dart';

class ThreadListBody extends StatelessWidget {
  final MessageController controller;

  const ThreadListBody({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.messageThreads.isEmpty) {
        return const EmptyStateWidget(
          message: 'No conversations yet',
          icon: Icons.inbox_outlined,
        );
      }

      return AnimatedListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: controller.messageThreads.length,
        staggerDelay: 40.ms,
        itemBuilder: (context, index) {
          return ThreadTile(
            thread: controller.messageThreads[index],
            controller: controller,
          );
        },
      );
    });
  }
}
