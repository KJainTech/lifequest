import 'package:flutter/material.dart';

import '../core/tokens/lq_tokens.dart';
import '../core/tokens/lq_typography.dart';

class LQCard extends StatelessWidget {
  const LQCard({
    super.key,
    required this.colors,
    required this.child,
    this.padding = const EdgeInsets.all(LQSpacing.xl),
    this.elevation = 1,
    this.onTap,
    this.borderRadius = LQRadius.card,
    this.selected = false,
  });

  final LQColors colors;
  final Widget child;
  final EdgeInsets padding;
  final int elevation;
  final VoidCallback? onTap;
  final double borderRadius;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final shadows = switch (elevation) {
      1 => LQElevation.e1(colors.ink),
      2 => LQElevation.e2(colors.ink),
      3 => LQElevation.e3(colors.ink),
      _ => LQElevation.e1(colors.ink),
    };

    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: selected ? colors.surfaceMuted : colors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: selected ? colors.brand : colors.border,
          width: selected ? 2 : 1,
        ),
        boxShadow: shadows,
      ),
      padding: padding,
      child: child,
    );

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: card,
      ),
    );
  }
}

class LQHeroCard extends StatelessWidget {
  const LQHeroCard({
    super.key,
    required this.colors,
    required this.level,
    required this.xp,
    required this.xpProgress,
    required this.lqScore,
    this.trendLabel = 'On track',
    this.trendPositive = true,
  });

  final LQColors colors;
  final int level;
  final int xp;
  final double xpProgress;
  final int lqScore;
  final String trendLabel;
  final bool trendPositive;

  @override
  Widget build(BuildContext context) {
    return LQCard(
      colors: colors,
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.brand.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(LQRadius.chip),
                ),
                child: Text(
                  'Level $level',
                  style: LQTypography.caption(colors).copyWith(
                    color: colors.brandDeep,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Text('${_formatNumber(xp)} XP', style: LQTypography.caption(colors)),
            ],
          ),
          const SizedBox(height: LQSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(LQRadius.pill),
            child: LinearProgressIndicator(
              value: xpProgress,
              minHeight: 8,
              backgroundColor: colors.border,
              valueColor: AlwaysStoppedAnimation(colors.brand),
            ),
          ),
          const SizedBox(height: LQSpacing.xxl),
          Text('LQ Score', style: LQTypography.caption(colors)),
          const SizedBox(height: LQSpacing.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                lqScore.toString(),
                style: LQTypography.numeral(colors, size: LQTypeScale.display),
              ),
              const SizedBox(width: LQSpacing.md),
              _TrendChip(
                colors: colors,
                label: trendLabel,
                positive: trendPositive,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toString();
  }
}

class _TrendChip extends StatelessWidget {
  const _TrendChip({
    required this.colors,
    required this.label,
    required this.positive,
  });

  final LQColors colors;
  final String label;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final tint = positive ? colors.success : colors.warn;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LQSpacing.md,
        vertical: LQSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(LQRadius.chip),
        border: Border.all(color: tint.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: LQTypography.caption(colors).copyWith(
          color: tint,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
