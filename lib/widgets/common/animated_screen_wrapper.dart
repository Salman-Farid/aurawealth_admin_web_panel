import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// A reusable wrapper that applies beautiful staggered entrance animations
/// to all children of a screen.
///
/// Usage:
/// ```dart
/// AnimatedScreenWrapper(
///   child: YourScreenContent(),
///   animationType: AnimationType.fadeSlideUp,
/// )
/// ```
class AnimatedScreenWrapper extends StatelessWidget {
  final Widget child;
  final AnimationType animationType;
  final Duration delay;
  final Duration duration;
  final Curve curve;

  const AnimatedScreenWrapper({
    Key? key,
    required this.child,
    this.animationType = AnimationType.fadeSlideUp,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeOutCubic,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _applyAnimation(child),
    );
  }

  Widget _applyAnimation(Widget widget) {
    switch (animationType) {
      case AnimationType.fadeSlideUp:
        return widget
            .animate(delay: delay)
            .fadeIn(duration: duration, curve: curve)
            .slideY(begin: 0.08, end: 0, duration: duration, curve: curve);

      case AnimationType.fadeSlideDown:
        return widget
            .animate(delay: delay)
            .fadeIn(duration: duration, curve: curve)
            .slideY(begin: -0.08, end: 0, duration: duration, curve: curve);

      case AnimationType.fadeSlideLeft:
        return widget
            .animate(delay: delay)
            .fadeIn(duration: duration, curve: curve)
            .slideX(begin: 0.08, end: 0, duration: duration, curve: curve);

      case AnimationType.fadeSlideRight:
        return widget
            .animate(delay: delay)
            .fadeIn(duration: duration, curve: curve)
            .slideX(begin: -0.08, end: 0, duration: duration, curve: curve);

      case AnimationType.scaleFade:
        return widget
            .animate(delay: delay)
            .fadeIn(duration: duration, curve: curve)
            .scaleXY(begin: 0.92, end: 1.0, duration: duration, curve: curve);

      case AnimationType.blurFade:
        return widget
            .animate(delay: delay)
            .fadeIn(duration: duration, curve: curve)
            .blurXY(begin: 4, end: 0, duration: duration, curve: curve);

      case AnimationType.elasticScale:
        return widget
            .animate(delay: delay)
            .fadeIn(duration: duration, curve: curve)
            .scaleXY(
              begin: 0.8,
              end: 1.0,
              duration: duration,
              curve: Curves.elasticOut,
            );

      case AnimationType.flipX:
        return widget
            .animate(delay: delay)
            .fadeIn(duration: duration, curve: curve)
            .flipH(duration: duration, curve: curve);

      case AnimationType.flipY:
        return widget
            .animate(delay: delay)
            .fadeIn(duration: duration, curve: curve)
            .flipV(duration: duration, curve: curve);

      case AnimationType.shimmer:
        return widget
            .animate(delay: delay)
            .shimmer(duration: duration * 2, color: Colors.white.withOpacity(0.3));

      case AnimationType.bounce:
        return widget
            .animate(delay: delay)
            .fadeIn(duration: duration, curve: curve)
            .moveY(
              begin: -20,
              end: 0,
              duration: duration,
              curve: Curves.bounceOut,
            );

      case AnimationType.smoothFade:
        // Pure fade with ease-in-out — no movement, very subtle
        return widget
            .animate(delay: delay)
            .fadeIn(duration: duration, curve: Curves.easeInOut)
            .then()
            .custom(
              duration: duration,
              curve: Curves.easeInOut,
              builder: (_, value, child) => Opacity(
                opacity: value,
                child: child,
              ),
            );

      case AnimationType.easeInOutSlideUp:
        // Smooth slide up with ease-in-out curve
        return widget
            .animate(delay: delay)
            .fadeIn(duration: duration, curve: Curves.easeInOutCubic)
            .slideY(
              begin: 0.06,
              end: 0,
              duration: duration,
              curve: Curves.easeInOutCubic,
            );

      case AnimationType.easeInOutSlideDown:
        return widget
            .animate(delay: delay)
            .fadeIn(duration: duration, curve: Curves.easeInOutCubic)
            .slideY(
              begin: -0.06,
              end: 0,
              duration: duration,
              curve: Curves.easeInOutCubic,
            );

      case AnimationType.easeInOutScale:
        // Smooth scale + fade with ease-in-out
        return widget
            .animate(delay: delay)
            .fadeIn(duration: duration, curve: Curves.easeInOutCubic)
            .scaleXY(
              begin: 0.95,
              end: 1.0,
              duration: duration,
              curve: Curves.easeInOutCubic,
            );

      case AnimationType.gentleFade:
        // Very gentle fade — perfect for cards and content
        return widget
            .animate(delay: delay)
            .fadeIn(duration: duration, curve: Curves.easeInOutQuad)
            .then()
            .tint(
              duration: duration * 0.5,
              color: Colors.transparent,
              curve: Curves.easeInOut,
            );

      case AnimationType.chatGPTFade:
        // ChatGPT-like smooth fade + slight slide up
        // Very slow, elegant, professional
        return widget
            .animate(delay: delay)
            .fadeIn(duration: duration, curve: Curves.easeInOutCubicEmphasized)
            .slideY(
              begin: 0.04,
              end: 0,
              duration: duration,
              curve: Curves.easeInOutCubicEmphasized,
            );

      case AnimationType.slowFadeSlide:
        // Slow motion fade + slide — dramatic entrance
        return widget
            .animate(delay: delay)
            .fadeIn(duration: duration, curve: Curves.easeOutQuart)
            .slideY(
              begin: 0.05,
              end: 0,
              duration: duration,
              curve: Curves.easeOutQuart,
            );
    }
  }
}

/// Different animation types for variety across screens
enum AnimationType {
  fadeSlideUp,
  fadeSlideDown,
  fadeSlideLeft,
  fadeSlideRight,
  scaleFade,
  blurFade,
  elasticScale,
  flipX,
  flipY,
  shimmer,
  bounce,
  smoothFade,
  easeInOutSlideUp,
  easeInOutSlideDown,
  easeInOutScale,
  gentleFade,
  chatGPTFade,
  slowFadeSlide,
}

/// Extension to easily animate lists of widgets with stagger
extension AnimatedListExtension on List<Widget> {
  /// Animate each child with a staggered delay
  ///
  /// Example:
  /// ```dart
  /// children.animateList(
  ///   animationType: AnimationType.fadeSlideUp,
  ///   staggerDelay: 80.ms,
  ///   duration: 500.ms,
  /// )
  /// ```
  List<Widget> animateList({
    AnimationType animationType = AnimationType.fadeSlideUp,
    Duration staggerDelay = const Duration(milliseconds: 80),
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.easeOutCubic,
  }) {
    return asMap().entries.map((entry) {
      final index = entry.key;
      final widget = entry.value;
      final delay = Duration(milliseconds: staggerDelay.inMilliseconds * index);

      return AnimatedScreenWrapper(
        animationType: animationType,
        delay: delay,
        duration: duration,
        curve: curve,
        child: widget,
      );
    }).toList();
  }
}

/// A widget that animates its child when it first appears
class AnimatedEntrance extends StatelessWidget {
  final Widget child;
  final AnimationType animationType;
  final Duration delay;
  final Duration duration;
  final Curve curve;

  const AnimatedEntrance({
    Key? key,
    required this.child,
    this.animationType = AnimationType.fadeSlideUp,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeOutCubic,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedScreenWrapper(
      animationType: animationType,
      delay: delay,
      duration: duration,
      curve: curve,
      child: child,
    );
  }
}

/// A widget that applies staggered animations to its column children
class AnimatedColumn extends StatelessWidget {
  final List<Widget> children;
  final AnimationType animationType;
  final Duration staggerDelay;
  final Duration duration;
  final Curve curve;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;

  const AnimatedColumn({
    Key? key,
    required this.children,
    this.animationType = AnimationType.fadeSlideUp,
    this.staggerDelay = const Duration(milliseconds: 80),
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeOutCubic,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.min,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: children
          .asMap()
          .entries
          .map((entry) {
            final index = entry.key;
            final widget = entry.value;
            final delay = Duration(
              milliseconds: staggerDelay.inMilliseconds * index,
            );

            return AnimatedEntrance(
              animationType: animationType,
              delay: delay,
              duration: duration,
              curve: curve,
              child: widget,
            );
          })
          .toList(),
    );
  }
}

/// A widget that applies staggered animations to its row children
class AnimatedRow extends StatelessWidget {
  final List<Widget> children;
  final AnimationType animationType;
  final Duration staggerDelay;
  final Duration duration;
  final Curve curve;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;

  const AnimatedRow({
    Key? key,
    required this.children,
    this.animationType = AnimationType.fadeSlideLeft,
    this.staggerDelay = const Duration(milliseconds: 80),
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeOutCubic,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.min,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: children
          .asMap()
          .entries
          .map((entry) {
            final index = entry.key;
            final widget = entry.value;
            final delay = Duration(
              milliseconds: staggerDelay.inMilliseconds * index,
            );

            return AnimatedEntrance(
              animationType: animationType,
              delay: delay,
              duration: duration,
              curve: curve,
              child: widget,
            );
          })
          .toList(),
    );
  }
}

/// A widget that animates a list view with staggered items
class AnimatedListView extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final AnimationType animationType;
  final Duration staggerDelay;
  final Duration duration;
  final Curve curve;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollController? controller;

  const AnimatedListView({
    Key? key,
    required this.itemCount,
    required this.itemBuilder,
    this.animationType = AnimationType.fadeSlideUp,
    this.staggerDelay = const Duration(milliseconds: 60),
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeOutCubic,
    this.physics,
    this.padding,
    this.shrinkWrap = false,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      physics: physics,
      padding: padding,
      shrinkWrap: shrinkWrap,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        final delay = Duration(
          milliseconds: staggerDelay.inMilliseconds * index,
        );

        return AnimatedEntrance(
          animationType: animationType,
          delay: delay,
          duration: duration,
          curve: curve,
          child: itemBuilder(context, index),
        );
      },
    );
  }
}
