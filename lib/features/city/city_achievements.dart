import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/tokens/lq_tokens.dart';
import '../../core/tokens/lq_typography.dart';
import '../../data/content/lesson_catalog.dart';
import 'city_buildings.dart';

/// Achievement row — district medals for completed quest levels.
class CityAchievementRow extends StatelessWidget {
  const CityAchievementRow({
    super.key,
    required this.colors,
    required this.snapshot,
  });

  final LQColors colors;
  final CityProgressSnapshot snapshot;

  static const _medals = ['🥉', '🥈', '🥇', '💎', '🏆', '👑'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: kQuestLevelCount,
        separatorBuilder: (_, __) => const SizedBox(width: LQSpacing.sm),
        itemBuilder: (context, i) {
          final done = snapshot.districtCompletion[i] >= 1;
          final active = snapshot.nextPlot?.building.districtIndex == i;
          final theme = kCityDistrictThemes[i];

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: done
                  ? theme.accent.withValues(alpha: 0.15)
                  : colors.surface.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(LQRadius.pill),
              border: Border.all(
                color: active
                    ? theme.accent
                    : done
                        ? theme.accent.withValues(alpha: 0.5)
                        : colors.ink.withValues(alpha: 0.08),
                width: active ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  done ? _medals[i] : '🔒',
                  style: TextStyle(
                    fontSize: 14,
                    color: done ? null : colors.inkSoft.withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'L${i + 1}',
                  style: LQTypography.micro(colors).copyWith(
                    fontWeight: FontWeight.w800,
                    color: done ? theme.accent : colors.inkSoft,
                  ),
                ),
              ],
            ),
          )
              .animate(target: done ? 1 : 0)
              .scale(
                begin: const Offset(0.92, 0.92),
                end: const Offset(1, 1),
                duration: 400.ms,
                curve: Curves.easeOutBack,
              );
        },
      ),
    );
  }
}
