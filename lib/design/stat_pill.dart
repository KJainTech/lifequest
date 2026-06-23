import 'package:flutter/material.dart';

import '../core/tokens/lq_tokens.dart';
import '../core/tokens/lq_typography.dart';

enum StatPillVariant { xp, coins, streak, trend, custom }

/// Compact stat chip for XP, coins, streaks, trends
class StatPill extends StatelessWidget {
  const StatPill({
    super.key,
    required this.colors,
    required this.label,
    this.icon,
    this.variant = StatPillVariant.custom,
    this.accentColor,
  });

  final LQColors colors;
  final String label;
  final Widget? icon;
  final StatPillVariant variant;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? _accentForVariant();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LQSpacing.md,
        vertical: LQSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(LQRadius.chip),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: LQSpacing.xs),
          ],
          Text(
            label,
            style: LQTypography.caption(colors).copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Color _accentForVariant() {
    return switch (variant) {
      StatPillVariant.xp => colors.accentViolet,
      StatPillVariant.coins => colors.gold,
      StatPillVariant.streak => colors.brand,
      StatPillVariant.trend => colors.success,
      StatPillVariant.custom => colors.brand,
    };
  }
}
