import 'package:flutter/services.dart';

/// Haptic feedback mapped per §4.6
abstract final class LQHaptics {
  static void selectionClick() {
    HapticFeedback.selectionClick();
  }

  static void lightImpact() {
    HapticFeedback.lightImpact();
  }

  static void mediumImpact() {
    HapticFeedback.mediumImpact();
  }

  static void heavyImpact() {
    HapticFeedback.heavyImpact();
  }

  static void levelUp() {
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 80), () {
      HapticFeedback.mediumImpact();
    });
  }

  static void coinCollect() => lightImpact();
  static void correct() => mediumImpact();
  static void wrong() => heavyImpact();
}
