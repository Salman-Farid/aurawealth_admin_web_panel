import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../utils/payment_motion.dart';

class PaymentGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;
  final Color? backgroundColor;
  final int animationIndex;
  final VoidCallback? onTap;

  const PaymentGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.borderColor,
    this.backgroundColor,
    this.animationIndex = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: borderColor ?? AppColors.grey200),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 0.5,
                offset: Offset(0, 0.5),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );

    return card.animate(
      effects: PaymentMotion.cardEntrance(index: animationIndex),
    );
  }
}

class PaymentGradientIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final bool animate;

  const PaymentGradientIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 44,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.20),
            color.withValues(alpha: 0.06),
          ],
        ),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Center(
        child: FloatingBouncyIcon(icon: icon, color: color, size: size * 0.46),
      ),
    );

    if (!animate) return child;
    return child
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scaleXY(
          begin: 0.98,
          end: 1.04,
          duration: 1600.ms,
          curve: Curves.easeInOut,
        );
  }
}

class FadeSlideText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int index;
  final TextAlign? textAlign;
  final int? maxLines;

  const FadeSlideText(
    this.text, {
    super.key,
    this.style,
    this.index = 0,
    this.textAlign,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
    ).animate(effects: PaymentMotion.textFade(index: index));
  }
}
