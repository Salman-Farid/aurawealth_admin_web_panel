import 'package:flutter/material.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/message.dart';
import 'design_tokens.dart';

class MailBubble extends StatelessWidget {
  final Message msg;

  const MailBubble({
    super.key,
    required this.msg,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = msg.isFromUser;

    return Align(
      alignment: isUser ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 560),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(kRadius),
          border: Border.all(
            color: isUser
                ? Colors.grey.shade200
                : mailAccent.withValues(alpha: 0.25),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: mailAccent.withValues(alpha: 0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Mail header bar ────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? Colors.grey.shade50
                    : mailAccent.withValues(alpha: 0.06),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(kRadius),
                  topRight: Radius.circular(kRadius),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: isUser
                          ? Colors.grey.shade200
                          : mailAccent.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.mail_rounded,
                      size: 15,
                      color: isUser ? Colors.grey.shade600 : mailAccent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? Colors.grey.shade300
                                    : mailAccent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isUser ? 'USER' : 'ADMIN',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                  color: isUser
                                      ? Colors.grey.shade700
                                      : mailAccent,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          msg.subject ?? '(No Subject)',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1D26),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Mail body ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
              child: Text(
                msg.body,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  color: Color(0xFF3B3F4E),
                ),
              ),
            ),

            // ── Mail footer ────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(kRadius),
                  bottomRight: Radius.circular(kRadius),
                ),
                border: Border(
                  top: BorderSide(color: Colors.grey.shade100),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule_rounded,
                      size: 12, color: Colors.grey.shade400),
                  const SizedBox(width: 4),
                  Text(
                    Formatters.formatRelativeTime(msg.parsedCreatedAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const Spacer(),
                  if (msg.isRead)
                    Row(
                      children: [
                        Icon(Icons.done_all_rounded,
                            size: 13, color: mailAccent),
                        const SizedBox(width: 4),
                        Text(
                          'Read',
                          style: TextStyle(
                            fontSize: 10,
                            color: mailAccent,
                          ),
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
}
