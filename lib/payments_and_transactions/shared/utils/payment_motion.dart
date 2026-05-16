import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PaymentMotion {
  PaymentMotion._();

  static const Curve bouncy = Curves.elasticOut;
  static const Curve silky = Curves.easeInOutCubicEmphasized;
  static const Curve slowMo = Curves.easeOutQuart;

  static Duration stagger(int index, {int baseMs = 80}) =>
      Duration(milliseconds: baseMs + (index * 90));

  static List<Effect<dynamic>> cardEntrance({int index = 0}) =>
      <Effect<dynamic>>[
        FadeEffect(delay: stagger(index), duration: 520.ms, curve: slowMo),
        SlideEffect(
          delay: stagger(index),
          duration: 720.ms,
          begin: const Offset(0, 0.12),
          end: Offset.zero,
          curve: bouncy,
        ),
        ScaleEffect(
          delay: stagger(index),
          duration: 760.ms,
          begin: const Offset(0.94, 0.94),
          end: const Offset(1, 1),
          curve: bouncy,
        ),
      ];

  static List<Effect<dynamic>> textFade({int index = 0}) => <Effect<dynamic>>[
    FadeEffect(delay: stagger(index, baseMs: 40), duration: 680.ms),
    SlideEffect(
      delay: stagger(index, baseMs: 40),
      duration: 760.ms,
      begin: const Offset(0, 0.18),
      end: Offset.zero,
      curve: slowMo,
    ),
  ];
}

class FloatingBouncyIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double size;
  final Duration duration;

  const FloatingBouncyIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 28,
    this.duration = const Duration(milliseconds: 1800),
  });

  @override
  State<FloatingBouncyIcon> createState() => _FloatingBouncyIconState();
}

class _FloatingBouncyIconState extends State<FloatingBouncyIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final wave = math.sin(_controller.value * math.pi);
        final y = -4 * wave;
        final scale = 1 + (0.08 * wave);
        return Transform.translate(
          offset: Offset(0, y),
          child: Transform.scale(scale: scale, child: child),
        );
      },
      child: Icon(widget.icon, color: widget.color, size: widget.size),
    );
  }
}
