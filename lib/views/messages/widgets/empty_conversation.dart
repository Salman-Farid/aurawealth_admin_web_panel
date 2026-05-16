import 'package:flutter/material.dart';
import '../../../widgets/common/animated_screen_wrapper.dart';
import 'design_tokens.dart';

class EmptyConversation extends StatelessWidget {
  const EmptyConversation({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: surfaceBg,
      child: Center(
        child: AnimatedEntrance(
          animationType: AnimationType.scaleFade,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: liveAccent.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.chat_bubble_outline_rounded,
                    size: 48, color: liveAccent.withValues(alpha: 0.5)),
              ),
              const SizedBox(height: 20),
              const Text(
                'Select a conversation',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Choose a thread from the left panel to start',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
