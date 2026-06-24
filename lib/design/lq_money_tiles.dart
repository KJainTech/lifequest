import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/tokens/lq_tokens.dart';
import '../../core/tokens/lq_typography.dart';

/// GoHenry-style 2-column feature tile for the Money hub.
class LQMoneyFeatureTile extends StatelessWidget {
  const LQMoneyFeatureTile({
    super.key,
    required this.colors,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
    required this.onTap,
    this.wide = false,
    this.trailing,
  });

  final LQColors colors;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBg;
  final VoidCallback onTap;
  final bool wide;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(LQRadius.card),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(LQRadius.card),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(LQRadius.card),
            border: Border.all(color: colors.border),
            boxShadow: [
              BoxShadow(
                color: colors.ink.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(LQSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: iconBg.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: iconBg, size: 24),
                    ),
                    if (trailing != null) ...[
                      const Spacer(),
                      trailing!,
                    ],
                  ],
                ),
                const Spacer(),
                Text(
                  title,
                  style: LQTypography.label(colors).copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: LQTypography.micro(colors),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Mini card preview for Money hub Card tile.
class LQCardMiniPreview extends StatelessWidget {
  const LQCardMiniPreview({
    super.key,
    required this.colors,
    required this.lqScore,
  });

  final LQColors colors;
  final int lqScore;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: LinearGradient(
          colors: [colors.brand, colors.brandDeep],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        'LQ $lqScore',
        style: LQTypography.micro(colors).copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 9,
        ),
      ),
    );
  }
}

/// Animated success pulse for balance updates.
class LQBalanceHero extends StatelessWidget {
  const LQBalanceHero({
    super.key,
    required this.colors,
    required this.coins,
    required this.subtitle,
  });

  final LQColors colors;
  final int coins;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$coins',
          style: LQTypography.display(colors).copyWith(
            fontSize: 48,
            height: 1,
            color: colors.ink,
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(
              duration: 2400.ms,
              color: colors.gold.withValues(alpha: 0.25),
            ),
        const SizedBox(height: LQSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(subtitle, style: LQTypography.bodySm(colors)),
            Icon(Icons.keyboard_arrow_down_rounded, color: colors.inkSoft, size: 18),
          ],
        ),
      ],
    );
  }
}
