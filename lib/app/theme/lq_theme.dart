import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/tokens/lq_tokens.dart';

/// Provides the active age-world theme to the widget tree.
final ageWorldProvider = StateProvider<AgeWorld>((ref) => AgeWorld.penny);

/// Current semantic colors derived from active world.
final lqColorsProvider = Provider<LQColors>((ref) {
  return LQColors.forWorld(ref.watch(ageWorldProvider));
});

/// App-wide theme data built from design tokens.
ThemeData buildLQTheme(LQColors colors, {bool isDark = false}) {
  final isPenny = colors.surface == LQColors.penny.surface;

  return ThemeData(
    useMaterial3: true,
    brightness: isPenny ? Brightness.light : Brightness.dark,
    scaffoldBackgroundColor: colors.canvasStart,
    colorScheme: ColorScheme(
      brightness: isPenny ? Brightness.light : Brightness.dark,
      primary: colors.brand,
      onPrimary: Colors.white,
      secondary: colors.accentMint,
      onSecondary: colors.ink,
      error: colors.danger,
      onError: Colors.white,
      surface: colors.surface,
      onSurface: colors.ink,
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(color: colors.ink),
      bodyLarge: TextStyle(color: colors.ink),
      bodyMedium: TextStyle(color: colors.inkSoft),
    ),
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
  );
}
