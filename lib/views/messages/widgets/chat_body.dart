import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/admin_chat_controller.dart';
import '../../../models/message.dart';
import 'date_chip.dart';
import 'design_tokens.dart';
import 'empty_chat_state.dart';
import 'live_bubble.dart';
import 'mail_bubble.dart';

class ChatBody extends StatefulWidget {
  // Key is required! The parent passes ValueKey(userId) so Flutter creates a
  // FRESH _ChatBodyState for every new conversation — scroll + worker reset.
  const ChatBody({super.key, required this.adminChat});
  final AdminChatController adminChat;

  @override
  State<ChatBody> createState() => _ChatBodyState();
}

class _ChatBodyState extends State<ChatBody> {
  final ScrollController _scroll = ScrollController();

  /// GetX worker — fires every time [messages] list mutates.
  /// Driving scroll from here is reliable because it runs OUTSIDE the build.
  Worker? _messagesWorker;

  @override
  void initState() {
    super.initState();
    _wireWorker();
    // Jump to bottom after the first frame (history is already loaded)
    WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToBottom());
  }

  @override
  void dispose() {
    _messagesWorker?.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _wireWorker() {
    _messagesWorker?.dispose();
    _messagesWorker = ever<List<Message>>(
      widget.adminChat.messages,
      (_) => _scheduleJump(),
    );
  }

  void _scheduleJump() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToBottom());
  }

  void _jumpToBottom() {
    if (!_scroll.hasClients) return;
    try {
      final pos = _scroll.position;
      if (pos.hasContentDimensions) {
        _scroll.jumpTo(pos.maxScrollExtent);
      }
    } catch (_) {
      // Scroll not ready yet
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: chatBg,
      child: Obx(() {
        final filter = widget.adminChat.messageTypeFilter.value;
        final displayed = widget.adminChat.filteredMessages;

        if (widget.adminChat.isLoadingHistory.value && displayed.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (displayed.isEmpty) {
          return EmptyChatState(isLive: filter != 'static');
        }

        return ListView.builder(
          controller: _scroll,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          itemCount: displayed.length,
          itemBuilder: (context, index) {
            final msg = displayed[index];
            final prev = index > 0 ? displayed[index - 1] : null;

            return Column(
              children: [
                if (_shouldShowDate(prev, msg))
                  DateChip(date: msg.parsedCreatedAt),
                if (msg.isStaticMessage)
                  MailBubble(msg: msg)
                else
                  LiveBubble(msg: msg),
              ],
            );
          },
        );
      }),
    );
  }

  bool _shouldShowDate(Message? prev, Message curr) {
    if (prev == null) return true;
    final p = prev.parsedCreatedAt;
    final c = curr.parsedCreatedAt;
    return p.day != c.day || p.month != c.month || p.year != c.year;
  }
}
