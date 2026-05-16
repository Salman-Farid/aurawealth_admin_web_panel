import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/admin_chat_controller.dart';
import 'design_tokens.dart';

class ReplyBox extends StatefulWidget {
  final AdminChatController adminChat;

  const ReplyBox({
    super.key,
    required this.adminChat,
  });

  @override
  State<ReplyBox> createState() => _ReplyBoxState();
}

class _ReplyBoxState extends State<ReplyBox> {
  final _bodyCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _bodyCtrl.dispose();
    _subjectCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _send() {
    final text = _bodyCtrl.text.trim();
    if (text.isEmpty) return;
    final isLive = widget.adminChat.messageTypeFilter.value == 'live';

    widget.adminChat
        .sendMessage(
          body: text,
          messageType: isLive ? 'live' : 'static',
          subject: isLive ? null : _subjectCtrl.text.trim(),
        )
        .then((_) {
      _bodyCtrl.clear();
      _subjectCtrl.clear();
      _focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLive = widget.adminChat.messageTypeFilter.value == 'live';
      final accent = isLive ? liveAccent : mailAccent;

      return Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: headerBg,
          border: Border(
            top: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Subject row — only for mail
            if (!isLive)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: mailAccent.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Subject',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: mailAccent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _subjectCtrl,
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Enter email subject…',
                          hintStyle: TextStyle(
                              color: Colors.grey.shade400, fontSize: 13),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: accent, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Message row
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 120),
                    decoration: BoxDecoration(
                      color: surfaceBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: TextField(
                      controller: _bodyCtrl,
                      focusNode: _focusNode,
                      maxLines: null,
                      maxLength: 1000,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: isLive
                            ? 'Send a live message…'
                            : 'Compose email body…',
                        hintStyle: TextStyle(
                            color: Colors.grey.shade400, fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        counterText: '',
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Obx(() => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: widget.adminChat.isSending.value
                            ? Colors.grey.shade300
                            : accent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: widget.adminChat.isSending.value
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : IconButton(
                              icon: const Icon(Icons.send_rounded,
                                  size: 20, color: Colors.white),
                              onPressed: _send,
                              padding: EdgeInsets.zero,
                            ),
                    )),
              ],
            ),
          ],
        ),
      );
    });
  }
}
