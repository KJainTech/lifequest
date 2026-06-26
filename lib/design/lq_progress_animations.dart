import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/tokens/lq_tokens.dart';
import '../core/tokens/lq_typography.dart';
import 'lq_celebration.dart';
import 'stat_pill.dart';

/// Animated coin / XP reveal after a stage — pops then shimmers.
class LQRewardReveal extends StatelessWidget {
  const LQRewardReveal({
    super.key,
    required this.colors,
    required this.xp,
    required this.coins,
    this.lqScore,
    this.badgeLabel,
  });

  final LQColors colors;
  final int xp;
  final int coins;
  final int? lqScore;
  final String? badgeLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: LQSpacing.sm,
          runSpacing: LQSpacing.sm,
          alignment: WrapAlignment.center,
          children: [
            _AnimatedRewardChip(
              colors: colors,
              label: '+$xp XP',
              variant: StatPillVariant.xp,
              delay: 0,
            ),
            _AnimatedRewardChip(
              colors: colors,
              label: '+$coins coins',
              variant: StatPillVariant.coins,
              delay: 120,
            ),
            if (lqScore != null)
              _AnimatedRewardChip(
                colors: colors,
                label: 'LQ $lqScore',
                variant: StatPillVariant.trend,
                delay: 220,
              ),
          ],
        ),
        if (badgeLabel != null) ...[
          const SizedBox(height: LQSpacing.md),
          LQAchievementBanner(
            colors: colors,
            title: badgeLabel!,
          ).animate().fadeIn(delay: 380.ms).slideY(begin: 0.15, end: 0),
        ],
      ],
    );
  }
}

class _AnimatedRewardChip extends StatelessWidget {
  const _AnimatedRewardChip({
    required this.colors,
    required this.label,
    required this.variant,
    required this.delay,
  });

  final LQColors colors;
  final String label;
  final StatPillVariant variant;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return StatPill(colors: colors, label: label, variant: variant)
        .animate(delay: delay.ms)
        .fadeIn(duration: 260.ms)
        .scale(
          begin: const Offset(0.4, 0.4),
          end: const Offset(1, 1),
          curve: Curves.elasticOut,
          duration: 620.ms,
        )
        .then(delay: 200.ms)
        .shimmer(duration: 900.ms, color: colors.gold.withValues(alpha: 0.35));
  }
}

/// Level-up banner with arc sweep + title pop.
class LQLevelUpBanner extends StatelessWidget {
  const LQLevelUpBanner({
    super.key,
    required this.colors,
    required this.level,
    required this.title,
    this.subtitle,
  });

  final LQColors colors;
  final int level;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        LQCelebrationBurst(colors: colors, particleCount: 32),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: LQSpacing.lg,
                vertical: LQSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: colors.gold.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(LQRadius.pill),
                border: Border.all(color: colors.gold.withValues(alpha: 0.5)),
              ),
              child: Text(
                'LEVEL $level COMPLETE',
                style: LQTypography.label(colors).copyWith(
                  color: colors.gold,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ).animate().scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1, 1),
                  curve: Curves.elasticOut,
                  duration: 700.ms,
                ),
            const SizedBox(height: LQSpacing.lg),
            Text(
              title,
              style: LQTypography.display(colors),
              textAlign: TextAlign.center,
            ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.12, end: 0),
            if (subtitle != null) ...[
              const SizedBox(height: LQSpacing.sm),
              Text(
                subtitle!,
                style: LQTypography.bodySm(colors),
                textAlign: TextAlign.center,
              ).animate(delay: 360.ms).fadeIn(),
            ],
          ],
        ),
      ],
    );
  }
}

/// Badge / achievement unlock strip.
class LQAchievementBanner extends StatelessWidget {
  const LQAchievementBanner({
    super.key,
    required this.colors,
    required this.title,
  });

  final LQColors colors;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: LQSpacing.lg,
        vertical: LQSpacing.md,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.brand.withValues(alpha: 0.15), colors.gold.withValues(alpha: 0.12)],
        ),
        borderRadius: BorderRadius.circular(LQRadius.control),
        border: Border.all(color: colors.gold.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          Icon(Icons.workspace_premium_rounded, color: colors.gold, size: 28),
          const SizedBox(width: LQSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Achievement unlocked', style: LQTypography.caption(colors)),
                Text(title, style: LQTypography.label(colors)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Floating coins that rise toward the top — overlay during reward.
class LQCoinFlyOverlay extends StatefulWidget {
  const LQCoinFlyOverlay({
    super.key,
    required this.colors,
    required this.count,
    this.active = true,
  });

  final LQColors colors;
  final int count;
  final bool active;

  @override
  State<LQCoinFlyOverlay> createState() => _LQCoinFlyOverlayState();
}

class _LQCoinFlyOverlayState extends State<LQCoinFlyOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    if (widget.active) _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return const SizedBox.shrink();
    final n = widget.count.clamp(3, 12);
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            children: List.generate(n, (i) {
              final t = Curves.easeOutCubic.transform(
                (_controller.value - i * 0.06).clamp(0.0, 1.0),
              );
              final angle = (i / n) * math.pi * 2;
              final startX = MediaQuery.sizeOf(context).width / 2;
              final startY = MediaQuery.sizeOf(context).height * 0.55;
              final dx = math.cos(angle) * 24 * (1 - t);
              final dy = -90 * t - math.sin(angle) * 12;
              return Positioned(
                left: startX + dx - 10,
                top: startY + dy,
                child: Opacity(
                  opacity: (1 - t * 0.85).clamp(0.0, 1.0),
                  child: Icon(
                    Icons.monetization_on_rounded,
                    color: widget.colors.gold,
                    size: 18 + (i % 3) * 2,
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
