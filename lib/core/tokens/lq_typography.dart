import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../tokens/lq_tokens.dart';

/// Typography — Outfit for headlines, Inter for UI/body (clean, readable).
abstract final class LQTypography {
  static TextStyle display(LQColors colors) => GoogleFonts.outfit(
        fontSize: LQTypeScale.display,
        fontWeight: FontWeight.w700,
        letterSpacing: LQTypeScale.displaySpacing * LQTypeScale.display,
        height: LQTypeScale.headingHeight,
        color: colors.ink,
      );

  static TextStyle h1(LQColors colors) => GoogleFonts.outfit(
        fontSize: LQTypeScale.h1,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        height: LQTypeScale.headingHeight,
        color: colors.ink,
      );

  static TextStyle h2(LQColors colors) => GoogleFonts.outfit(
        fontSize: LQTypeScale.h2,
        fontWeight: FontWeight.w600,
        height: LQTypeScale.headingHeight,
        color: colors.ink,
      );

  static TextStyle h3(LQColors colors) => GoogleFonts.inter(
        fontSize: LQTypeScale.h3,
        fontWeight: FontWeight.w600,
        height: LQTypeScale.headingHeight,
        color: colors.ink,
      );

  static TextStyle body(LQColors colors) => GoogleFonts.inter(
        fontSize: LQTypeScale.body,
        fontWeight: FontWeight.w400,
        height: LQTypeScale.bodyHeight,
        color: colors.ink,
      );

  static TextStyle bodySm(LQColors colors) => GoogleFonts.inter(
        fontSize: LQTypeScale.bodySm,
        fontWeight: FontWeight.w400,
        height: LQTypeScale.bodyHeight,
        color: colors.inkSoft,
      );

  static TextStyle caption(LQColors colors) => GoogleFonts.inter(
        fontSize: LQTypeScale.caption,
        fontWeight: FontWeight.w500,
        height: LQTypeScale.bodyHeight,
        color: colors.inkSoft,
      );

  static TextStyle numeral(LQColors colors, {double size = LQTypeScale.h1}) =>
      GoogleFonts.outfit(
        fontSize: size,
        fontWeight: FontWeight.w700,
        letterSpacing: LQTypeScale.numeralSpacing * size,
        height: LQTypeScale.headingHeight,
        color: colors.ink,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static TextStyle label(LQColors colors) => GoogleFonts.inter(
        fontSize: LQTypeScale.micro,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        color: colors.inkSoft,
      );

  static TextStyle micro(LQColors colors) => GoogleFonts.inter(
        fontSize: LQTypeScale.micro,
        fontWeight: FontWeight.w500,
        color: colors.inkSoft,
      );

  static TextStyle microNav(LQColors colors, {required bool isActive}) =>
      GoogleFonts.inter(
        fontSize: LQTypeScale.micro,
        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
        color: isActive ? colors.brand : colors.inkSoft,
      );

  static TextStyle microLabel(LQColors colors, {Color? color}) =>
      GoogleFonts.inter(
        fontSize: LQTypeScale.micro,
        fontWeight: FontWeight.w600,
        color: color ?? colors.inkSoft,
      );

  static TextStyle button(LQColors colors, {Color? fg}) => GoogleFonts.inter(
        fontSize: LQTypeScale.body,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.2,
        color: fg ?? Colors.white,
      );
}
