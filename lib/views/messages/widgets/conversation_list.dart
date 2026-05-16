import 'package:flutter/material.dart';
import '../../../controllers/message_controller.dart';
import 'sidebar_header.dart';
import 'thread_list_body.dart';

class ConversationList extends StatelessWidget {
  final MessageController controller;

  const ConversationList({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SidebarHeader(controller: controller),
        Expanded(child: ThreadListBody(controller: controller)),
      ],
    );
  }
}
