import 'package:flutter/material.dart';
import 'design_tokens.dart';

class EmptyChatState extends StatelessWidget {
  final bool isLive;

  const EmptyChatState({
    super.key,
    required this.isLive,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: (isLive ? liveAccent : mailAccent)
                  .withValues(alpha: 0.07),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isLive
                  ? Icons.chat_bubble_outline_rounded
                  : Icons.mail_outline_rounded,
              size: 40,
              color: (isLive ? liveAccent : mailAccent)
                  .withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isLive ? 'No live messages yet' : 'No emails yet',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isLive
                ? 'Messages will appear here in real-time'
                : 'Formal emails will show here',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}
