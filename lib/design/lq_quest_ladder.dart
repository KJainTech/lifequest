import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/tokens/lq_tokens.dart';
import '../core/tokens/lq_typography.dart';
import '../data/content/curriculum_builder.dart';
import '../data/content/lesson_catalog.dart';
import '../data/content/lesson_progression.dart';
import '../data/models/lq_models.dart';
import '../features/city/city_buildings.dart';

/// Vertical quest ladder — L1–L6 with current position marker.
class LQQuestLadder extends StatelessWidget {
  const LQQuestLadder({
    super.key,
    required this.colors,
    required this.progress,
    this.profile,
    this.compact = false,
  });

  final LQColors colors;
  final List<LessonProgress> progress;
  final UserProfile? profile;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final currentLevel = LessonProgression.displayQuestLevel(progress, profile);
    final currentName = LessonProgression.displayQuestLevelName(progress, profile);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!compact) ...[
          Row(
            children: [
              Expanded(
                child: Text('Quest ladder', style: LQTypography.h3(colors)),
              ),
              Text(
                currentName,
                style: LQTypography.label(colors).copyWith(color: colors.brand),
              ),
            ],
          ),
          const SizedBox(height: LQSpacing.md),
        ],
        ...List.generate(kQuestLevelCount, (i) {
          final level = i + 1;
          final theme = kCityDistrictThemes[i];
          final lessons = lessonsForQuestLevel(level);
          final done = lessons.where((m) {
            LessonProgress? stored;
            for (final p in progress) {
              if (p.lessonId == m.id) {
                stored = p;
                break;
              }
            }
            return stored?.status == LessonStatus.completed;
          }).length;
          final total = lessons.length;
          final pct = total == 0 ? 0.0 : done / total;
          final isCurrent = level == currentLevel;
          final isPast = level < currentLevel;
          final unlocked = LessonProgression.isQuestLevelUnlocked(level, progress, profile);

          return _LadderRung(
            colors: colors,
            level: level,
            name: kQuestLevelNames[i],
            accent: theme.accent,
            progress: pct,
            isCurrent: isCurrent,
            isPast: isPast,
            isLocked: !unlocked && !isPast && !isCurrent,
            compact: compact,
          ).animate(delay: (i * 40).ms).fadeIn().slideX(begin: 0.05, end: 0);
        }),
      ],
    );
  }
}

class _LadderRung extends StatelessWidget {
  const _LadderRung({
    required this.colors,
    required this.level,
    required this.name,
    required this.accent,
    required this.progress,
    required this.isCurrent,
    required this.isPast,
    required this.isLocked,
    required this.compact,
  });

  final LQColors colors;
  final int level;
  final String name;
  final Color accent;
  final double progress;
  final bool isCurrent;
  final bool isPast;
  final bool isLocked;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final height = compact ? 44.0 : 56.0;
    return Padding(
      padding: EdgeInsets.only(bottom: compact ? LQSpacing.xs : LQSpacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Column(
              children: [
                Container(
                  width: isCurrent ? 28 : 22,
                  height: isCurrent ? 28 : 22,
                  decoration: BoxDecoration(
                    color: isLocked
                        ? colors.border
                        : isCurrent
                            ? accent
                            : isPast
                                ? colors.brand
                                : accent.withValues(alpha: 0.35),
                    shape: BoxShape.circle,
                    border: isCurrent
                        ? Border.all(color: colors.gold, width: 2)
                        : null,
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: accent.withValues(alpha: 0.45),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: isLocked
                        ? Icon(Icons.lock, size: 12, color: colors.inkSoft)
                        : Text(
                            '$level',
                            style: LQTypography.micro(colors).copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
                if (level < kQuestLevelCount)
                  Container(
                    width: 2,
                    height: compact ? 12 : 20,
                    color: isPast || isCurrent
                        ? colors.brand.withValues(alpha: 0.35)
                        : colors.border,
                  ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              height: height,
              padding: const EdgeInsets.symmetric(horizontal: LQSpacing.md),
              decoration: BoxDecoration(
                color: isCurrent ? colors.accentMint : colors.surface,
                borderRadius: BorderRadius.circular(LQRadius.control),
                border: Border.all(
                  color: isCurrent ? colors.brand : colors.border,
                  width: isCurrent ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: LQTypography.bodySm(colors).copyWith(
                            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                        if (!compact && !isLocked)
                          Text(
                            '${(progress * 100).round()}% complete',
                            style: LQTypography.micro(colors),
                          ),
                      ],
                    ),
                  ),
                  if (isCurrent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: LQSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colors.brand,
                        borderRadius: BorderRadius.circular(LQRadius.pill),
                      ),
                      child: Text(
                        'You',
                        style: LQTypography.micro(colors).copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
