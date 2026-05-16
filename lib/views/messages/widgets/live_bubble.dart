import 'package:flutter/material.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/message.dart';
import 'design_tokens.dart';

class LiveBubble extends StatelessWidget {
  final Message msg;

  const LiveBubble({
    super.key,
    required this.msg,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = msg.isFromUser;

    return Align(
      alignment: isUser ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        margin: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              decoration: BoxDecoration(
                color: isUser ? Colors.white : liveAccent,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(kBubbleRadius),
                  topRight: const Radius.circular(kBubbleRadius),
                  bottomLeft: Radius.circular(isUser ? 4 : kBubbleRadius),
                  bottomRight: Radius.circular(isUser ? kBubbleRadius : 4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isUser
                        ? Colors.black.withValues(alpha: 0.06)
                        : liveAccent.withValues(alpha: 0.30),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (msg.attachmentUrl != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          msg.attachmentUrl!,
                          width: 220,
                          height: 160,
                          fit: BoxFit.cover,
                          errorBuilder: (_, e, st) => Container(
                            width: 220,
                            height: 60,
                            color: Colors.grey.shade200,
                            child: const Center(
                                child: Text('Image failed to load',
                                    style: TextStyle(fontSize: 12))),
                          ),
                        ),
                      ),
                    ),
                  Text(
                    msg.body,
                    style: TextStyle(
                      color: isUser
                          ? const Color(0xFF1A1D26)
                          : Colors.white,
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  Formatters.formatRelativeTime(msg.parsedCreatedAt),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade500,
                  ),
                ),
                if (!isUser) ...[
                  const SizedBox(width: 4),
                  Icon(
                    msg.isRead
                        ? Icons.done_all_rounded
                        : Icons.done_rounded,
                    size: 13,
                    color: msg.isRead ? liveAccent : Colors.grey.shade400,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}
