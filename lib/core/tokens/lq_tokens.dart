import 'package:flutter/material.dart';

/// Age-world identifiers matching §4.2 of the Bible.
enum AgeWorld { penny, finBot, atlas }

/// Semantic color tokens — never hardcode hex in widgets.
@immutable
class LQColors {
  const LQColors({
    required this.brand,
    required this.brandDeep,
    required this.ink,
    required this.inkSoft,
    required this.accentMint,
    required this.accentViolet,
    required this.surface,
    required this.canvasStart,
    required this.canvasEnd,
    required this.gold,
    required this.coral,
    required this.blue,
    required this.success,
    required this.warn,
    required this.danger,
    required this.info,
    this.glowCyan,
    this.amber,
    this.line,
  });

  final Color brand;
  final Color brandDeep;
  final Color ink;
  final Color inkSoft;
  final Color accentMint;
  final Color accentViolet;
  final Color surface;
  final Color canvasStart;
  final Color canvasEnd;
  final Color gold;
  final Color coral;
  final Color blue;
  final Color success;
  final Color warn;
  final Color danger;
  final Color info;
  final Color? glowCyan;
  final Color? amber;
  final Color? line;

  /// Penny · ages 5–8 — "Warm Dawn"
  static const penny = LQColors(
    brand: Color(0xFFFF8A4C),
    brandDeep: Color(0xFFE2611F),
    ink: Color(0xFF2A2140),
    inkSoft: Color(0xFF6E6385),
    accentMint: Color(0xFF4FD1A5),
    accentViolet: Color(0xFF9D7BFF),
    surface: Color(0xFFFFFFFF),
    canvasStart: Color(0xFFFBF3EC),
    canvasEnd: Color(0xFFF4EEFB),
    gold: Color(0xFFFFC23D),
    coral: Color(0xFFFF6B6B),
    blue: Color(0xFF5B8DEF),
    success: Color(0xFF4FD1A5),
    warn: Color(0xFFFFB23D),
    danger: Color(0xFFFF6B6B),
    info: Color(0xFF5B8DEF),
  );

  /// FinBot · ages 9–12 — "Neon Night"
  static const finBot = LQColors(
    brand: Color(0xFF5B8DEF),
    brandDeep: Color(0xFF3A6FD4),
    ink: Color(0xFF0E1424),
    inkSoft: Color(0xFF8B95B0),
    accentMint: Color(0xFF2BE3C2),
    accentViolet: Color(0xFF7B6FFF),
    surface: Color(0xFF161D33),
    canvasStart: Color(0xFF0B1020),
    canvasEnd: Color(0xFF141B33),
    gold: Color(0xFFFFB23D),
    coral: Color(0xFFFF6B6B),
    blue: Color(0xFF5B8DEF),
    success: Color(0xFF2BE3C2),
    warn: Color(0xFFFFB23D),
    danger: Color(0xFFFF6B6B),
    info: Color(0xFF45F0E0),
    glowCyan: Color(0xFF45F0E0),
    amber: Color(0xFFFFB23D),
  );

  /// Atlas · ages 13–17 — "Emerald Graphite"
  static const atlas = LQColors(
    brand: Color(0xFF1FA873),
    brandDeep: Color(0xFF158A5C),
    ink: Color(0xFF11161B),
    inkSoft: Color(0xFF6B7A82),
    accentMint: Color(0xFF2DD4A0),
    accentViolet: Color(0xFFC8A24A),
    surface: Color(0xFF1A2226),
    canvasStart: Color(0xFF0F1417),
    canvasEnd: Color(0xFF16201C),
    gold: Color(0xFFC8A24A),
    coral: Color(0xFFE85D5D),
    blue: Color(0xFF4A9FD4),
    success: Color(0xFF2DD4A0),
    warn: Color(0xFFC8A24A),
    danger: Color(0xFFE85D5D),
    info: Color(0xFF4A9FD4),
    line: Color(0xFF243038),
  );

  static LQColors forWorld(AgeWorld world) => switch (world) {
        AgeWorld.penny => penny,
        AgeWorld.finBot => finBot,
        AgeWorld.atlas => atlas,
      };
}

/// Elevation shadows from §4.2 — soft, layered.
abstract final class LQElevation {
  static List<BoxShadow> e1(Color ink) => [
        BoxShadow(
          color: ink.withValues(alpha: 0.12),
          blurRadius: 22,
          spreadRadius: -14,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> e2(Color ink) => [
        BoxShadow(
          color: ink.withValues(alpha: 0.14),
          blurRadius: 40,
          spreadRadius: -22,
          offset: const Offset(0, 18),
        ),
      ];

  static List<BoxShadow> e3(Color ink) => [
        BoxShadow(
          color: ink.withValues(alpha: 0.18),
          blurRadius: 60,
          spreadRadius: -24,
          offset: const Offset(0, 30),
        ),
      ];
}

/// Spacing scale from §4.4
abstract final class LQSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double gutter = 20;
}

/// Border radii from §4.4
abstract final class LQRadius {
  static const double card = 28;
  static const double control = 16;
  static const double chip = 30;
  static const double pill = 999;
}

/// Type scale from §4.3 (px)
abstract final class LQTypeScale {
  static const double display = 34;
  static const double h1 = 26;
  static const double h2 = 21;
  static const double h3 = 18;
  static const double body = 16;
  static const double bodySm = 14;
  static const double caption = 12.5;
  static const double micro = 11;

  static const double displaySpacing = -0.02;
  static const double numeralSpacing = -0.03;
  static const double headingHeight = 1.12;
  static const double bodyHeight = 1.5;
}

/// Minimum touch target from §4.4
abstract final class LQTouch {
  static const double minTarget = 48;
}
