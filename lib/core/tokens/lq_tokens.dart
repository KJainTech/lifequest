import 'package:flutter/material.dart';

/// Semantic color tokens — never hardcode hex in widgets.
@immutable
class LQColors {
  const LQColors({
    required this.brand,
    required this.brandHover,
    required this.brandDeep,
    required this.ink,
    required this.inkSoft,
    required this.accentMint,
    required this.accentViolet,
    required this.surface,
    required this.surfaceMuted,
    required this.canvas,
    required this.border,
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
  final Color brandHover;
  final Color brandDeep;
  final Color ink;
  final Color inkSoft;
  final Color accentMint;
  final Color accentViolet;
  final Color surface;
  final Color surfaceMuted;
  final Color canvas;
  final Color border;
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

  /// Flat aliases — no gradient backgrounds.
  Color get canvasStart => canvas;
  Color get canvasEnd => canvas;

  static const penny = LQColors(
    brand: Color(0xFF28B77F),
    brandHover: Color(0xFF22A06B),
    brandDeep: Color(0xFF1D8F5D),
    ink: Color(0xFF152620),
    inkSoft: Color(0xFF5C7268),
    accentMint: Color(0xFFDAF7EB),
    accentViolet: Color(0xFFE6F7EF),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFF4FAF7),
    canvas: Color(0xFFFDFBF5),
    border: Color(0xFFDCE8E2),
    gold: Color(0xFFFFB018),
    coral: Color(0xFFFF433C),
    blue: Color(0xFF00BEAA),
    success: Color(0xFF28B77F),
    warn: Color(0xFFFA7F46),
    danger: Color(0xFFFF433C),
    info: Color(0xFF00BEAA),
    amber: Color(0xFFF9EC97),
    line: Color(0xFFE8EFEB),
  );

  static const finBot = LQColors(
    brand: Color(0xFF28B77F),
    brandHover: Color(0xFF22A06B),
    brandDeep: Color(0xFF1D8F5D),
    ink: Color(0xFFF5FBF8),
    inkSoft: Color(0xFFA8C4B8),
    accentMint: Color(0xFFDAF7EB),
    accentViolet: Color(0xFF1D8F5D),
    surface: Color(0xFF1A2E28),
    surfaceMuted: Color(0xFF223830),
    canvas: Color(0xFF142420),
    border: Color(0xFF2A4038),
    gold: Color(0xFFFFB018),
    coral: Color(0xFFFF433C),
    blue: Color(0xFF00BEAA),
    success: Color(0xFF28B77F),
    warn: Color(0xFFFA7F46),
    danger: Color(0xFFFF433C),
    info: Color(0xFF00BEAA),
    glowCyan: Color(0xFF00BEAA),
    amber: Color(0xFFF9EC97),
    line: Color(0xFF2A3830),
  );

  static const atlas = LQColors(
    brand: Color(0xFF28B77F),
    brandHover: Color(0xFF22A06B),
    brandDeep: Color(0xFF1D8F5D),
    ink: Color(0xFFF0F5F2),
    inkSoft: Color(0xFF8FA698),
    accentMint: Color(0xFFDAF7EB),
    accentViolet: Color(0xFF22A06B),
    surface: Color(0xFF1A2220),
    surfaceMuted: Color(0xFF222C28),
    canvas: Color(0xFF121816),
    border: Color(0xFF2A3830),
    gold: Color(0xFFFFB018),
    coral: Color(0xFFFF433C),
    blue: Color(0xFF00BEAA),
    success: Color(0xFF28B77F),
    warn: Color(0xFFFA7F46),
    danger: Color(0xFFFF433C),
    info: Color(0xFF00BEAA),
    line: Color(0xFF2A3830),
    amber: Color(0xFFF9EC97),
  );

  static LQColors forWorld(AgeWorld world) => switch (world) {
        AgeWorld.penny => penny,
        AgeWorld.finBot => finBot,
        AgeWorld.atlas => atlas,
      };
}

/// Age-world identifiers matching §4.2 of the Bible.
enum AgeWorld { penny, finBot, atlas }

/// Crisp elevation — tight, editorial (not glassy).
abstract final class LQElevation {
  static List<BoxShadow> e1(Color ink) => [
        BoxShadow(
          color: ink.withValues(alpha: 0.06),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> e2(Color ink) => [
        BoxShadow(
          color: ink.withValues(alpha: 0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> e3(Color ink) => [
        BoxShadow(
          color: ink.withValues(alpha: 0.1),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> cta(Color brand) => [
        BoxShadow(
          color: brand.withValues(alpha: 0.28),
          blurRadius: 0,
          offset: const Offset(0, 3),
        ),
        BoxShadow(
          color: brand.withValues(alpha: 0.12),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ];
}

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

abstract final class LQRadius {
  static const double card = 20;
  static const double control = 14;
  static const double chip = 24;
  static const double pill = 999;
  static const double button = 14;
}

abstract final class LQTypeScale {
  static const double display = 32;
  static const double h1 = 24;
  static const double h2 = 20;
  static const double h3 = 17;
  static const double body = 16;
  static const double bodySm = 14;
  static const double caption = 12;
  static const double micro = 11;

  static const double displaySpacing = -0.03;
  static const double numeralSpacing = -0.03;
  static const double headingHeight = 1.15;
  static const double bodyHeight = 1.55;
}

abstract final class LQTouch {
  static const double minTarget = 48;
}
