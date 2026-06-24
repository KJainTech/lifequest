import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/build_info.dart';
import '../../core/tokens/lq_tokens.dart';
import '../../core/tokens/lq_typography.dart';
import '../../data/content/lesson_catalog.dart';
import 'city_achievements.dart';
import 'city_buildings.dart';

/// Top HUD — 48-stage city progress across 6 quest levels.
class CityHud extends StatelessWidget {
  const CityHud({
    super.key,
    required this.colors,
    required this.snapshot,
    this.onDistrictTap,
    this.xp = 0,
    this.coins = 0,
  });

  final LQColors colors;
  final CityProgressSnapshot snapshot;
  final ValueChanged<int>? onDistrictTap;
  final int xp;
  final int coins;

  @override
  Widget build(BuildContext context) {
    final pct = (snapshot.overallProgress * 100).round();
    final next = snapshot.nextPlot;
    final activeDistrict = next?.building.districtIndex ?? 0;
    final theme = kCityDistrictThemes[activeDistrict.clamp(0, kQuestLevelCount - 1)];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Lemon City', style: LQTypography.h2(colors)),
                  Text(
                    '${snapshot.builtCount}/$kTotalStages buildings · Level ${activeDistrict + 1}',
                    style: LQTypography.bodySm(colors).copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.ink,
                    ),
                  ),
                ],
              ),
            ),
            if (xp > 0) ...[
              _StatBubble(colors: colors, icon: '⚡', value: '$xp'),
              const SizedBox(width: LQSpacing.sm),
            ],
            if (coins > 0)
              _StatBubble(colors: colors, icon: '🪙', value: '$coins'),
            const SizedBox(width: LQSpacing.sm),
            _ProgressBadge(colors: colors, percent: pct),
          ],
        ),
        if (next != null) ...[
          const SizedBox(height: LQSpacing.xs),
          Text(
            'Next build: ${next.building.name} · ${theme.name}',
            style: LQTypography.caption(colors).copyWith(
              color: theme.accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
        const SizedBox(height: LQSpacing.md),
        _BuildingStageStrip(colors: colors, snapshot: snapshot),
        const SizedBox(height: LQSpacing.sm),
        CityAchievementRow(colors: colors, snapshot: snapshot),
        const SizedBox(height: LQSpacing.sm),
        Text(
          '6 levels · $kTotalStages stages · build as you learn',
          style: LQTypography.micro(colors),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: LQSpacing.md),
        SizedBox(
          height: 52,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: kQuestLevelCount,
            separatorBuilder: (_, __) => const SizedBox(width: LQSpacing.sm),
            itemBuilder: (context, i) {
              final districtTheme = kCityDistrictThemes[i];
              final done = snapshot.districtCompletion[i];
              final total = stagesInQuestLevel(i + 1);
              final builtInDistrict = (done * total).round();
              final isActive = i == activeDistrict;
              final isComplete = done >= 1;

              return GestureDetector(
                onTap: onDistrictTap != null ? () => onDistrictTap!(i) : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 72,
                  padding: const EdgeInsets.symmetric(
                    horizontal: LQSpacing.sm,
                    vertical: LQSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? districtTheme.accent.withValues(alpha: 0.14)
                        : districtTheme.surface,
                    borderRadius: BorderRadius.circular(LQRadius.control),
                    border: Border.all(
                      color: isActive || isComplete
                          ? districtTheme.accent
                          : districtTheme.accent.withValues(alpha: 0.25),
                      width: isActive ? 2 : 1,
                    ),
                    boxShadow: isActive ? LQElevation.e1(colors.ink) : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'L${i + 1}',
                        style: LQTypography.micro(colors).copyWith(
                          fontWeight: FontWeight.w800,
                          color: colors.ink,
                        ),
                      ),
                      Text(
                        '$builtInDistrict/$total',
                        style: LQTypography.micro(colors).copyWith(
                          color: districtTheme.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: LQSpacing.xs),
        Text(
          'v${LQBuildInfo.version}',
          style: LQTypography.micro(colors).copyWith(
            color: colors.inkSoft.withValues(alpha: 0.45),
          ),
        ),
      ],
    );
  }
}

class _StatBubble extends StatelessWidget {
  const _StatBubble({
    required this.colors,
    required this.icon,
    required this.value,
  });

  final LQColors colors;
  final String icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(LQRadius.chip),
        boxShadow: LQElevation.e1(colors.ink),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            value,
            style: LQTypography.caption(colors).copyWith(
              fontWeight: FontWeight.w800,
              color: colors.brandDeep,
            ),
          ),
        ],
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
          begin: const Offset(1, 1),
          end: const Offset(1.05, 1.05),
          duration: 1400.ms,
        );
  }
}

class _BuildingStageStrip extends StatelessWidget {
  const _BuildingStageStrip({
    required this.colors,
    required this.snapshot,
  });

  final LQColors colors;
  final CityProgressSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 14,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: kTotalStages,
        separatorBuilder: (_, __) => const SizedBox(width: 2),
        itemBuilder: (context, i) {
          final plot = snapshot.plots[i];
          final isBuilt = plot.isBuilt;
          final isNext = plot.isNext || plot.status == CityPlotStatus.inProgress;
          final district = kCityDistrictThemes[plot.building.districtIndex];

          Color fill;
          if (isBuilt) {
            fill = district.accent;
          } else if (isNext) {
            fill = colors.brand;
          } else {
            fill = colors.ink.withValues(alpha: 0.08);
          }

          return AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            width: isNext ? 12 : 6,
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(3),
              border: isNext
                  ? Border.all(color: colors.gold, width: 1.5)
                  : null,
            ),
          );
        },
      ),
    );
  }
}

class _ProgressBadge extends StatelessWidget {
  const _ProgressBadge({required this.colors, required this.percent});

  final LQColors colors;
  final int percent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: colors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: colors.brand.withValues(alpha: 0.3), width: 2),
        boxShadow: LQElevation.e1(colors.ink),
      ),
      alignment: Alignment.center,
      child: Text(
        '$percent%',
        style: LQTypography.caption(colors).copyWith(
          fontWeight: FontWeight.w800,
          color: colors.brand,
        ),
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
          begin: const Offset(1, 1),
          end: const Offset(1.04, 1.04),
          duration: 1800.ms,
          curve: Curves.easeInOut,
        );
  }
}
