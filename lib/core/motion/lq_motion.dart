import 'package:flutter/physics.dart';
import 'package:flutter/scheduler.dart';

/// Spring physics tokens from §4.5
abstract final class LQMotion {
  /// Standard UI spring: stiffness 220, damping 26, mass 1
  static SpringDescription get standardSpring => const SpringDescription(
        mass: 1,
        stiffness: 220,
        damping: 26,
      );

  /// Playful pop spring: stiffness 320, damping 18
  static SpringDescription get playfulSpring => const SpringDescription(
        mass: 1,
        stiffness: 320,
        damping: 18,
      );

  /// City tower build spring: stiffness 180, damping 14
  static SpringDescription get towerSpring => const SpringDescription(
        mass: 1,
        stiffness: 180,
        damping: 14,
      );

  /// Press feedback duration
  static const Duration pressDuration = Duration(milliseconds: 80);

  /// Press scale
  static const double pressScale = 0.96;

  /// List stagger delay
  static const Duration staggerDelay = Duration(milliseconds: 35);

  /// Reduced motion fade
  static const Duration reducedMotionFade = Duration(milliseconds: 120);

  /// Whether the user prefers reduced motion
  static bool get prefersReducedMotion {
    final dispatcher = SchedulerBinding.instance.platformDispatcher;
    return dispatcher.accessibilityFeatures.disableAnimations;
  }

  /// Duration helper — returns fade duration when reduced motion is on
  static Duration adaptiveDuration(Duration normal) {
    return prefersReducedMotion ? reducedMotionFade : normal;
  }
}
