import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap/firebase_providers.dart';
import '../../app/theme/lq_theme.dart';
import '../../core/tokens/lq_tokens.dart';
import '../../core/tokens/lq_typography.dart';
import '../../data/models/lq_models.dart';
import '../../data/providers/app_providers.dart';
import '../../data/content/lesson_catalog.dart';
import '../../data/content/lesson_progression.dart';
import '../../data/content/concept_skills.dart';
import '../../design/lq_card.dart';
import '../../design/lq_immersive_scene.dart';
import '../../features/city/city_buildings.dart';
import '../../features/city/city_map_widget.dart';
import '../../features/city/city_providers.dart';
import '../../features/onboarding/auth_service.dart';
import '../../design/lq_badge.dart';
import '../../design/lq_icons.dart';
import '../../design/lq_quest_ladder.dart';
import '../../design/stat_pill.dart';

/// Progress tab — weekly activity, streak, Business IQ (no leaderboard).
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  List<int> _weeklyCounts(List<LessonProgress> lessons) {
    final now = DateTime.now();
    final counts = List.filled(7, 0);
    for (final l in lessons) {
      if (l.status != LessonStatus.completed || l.completedAt == null) continue;
      final d = DateTime.tryParse(l.completedAt!);
      if (d == null) continue;
      final diff = now.difference(d).inDays;
      if (diff >= 0 && diff < 7) {
        counts[6 - diff]++;
      }
    }
    return counts;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(lqColorsProvider);
    final stats = ref.watch(userStatsProvider).valueOrNull ?? UserStats.empty;
    final lessonsAsync = ref.watch(userLessonsProvider);
    final badgesAsync = ref.watch(userBadgesProvider);

    return LQImmersiveScene(
      colors: colors,
      child: SafeArea(
        child: lessonsAsync.when(
          loading: () => Center(child: CircularProgressIndicator(color: colors.brand)),
          error: (e, _) => Center(child: Text('$e', style: LQTypography.bodySm(colors))),
          data: (lessons) {
            final weekly = _weeklyCounts(lessons);
            final maxBar = weekly.reduce((a, b) => a > b ? a : b).clamp(1, 99);
            final profile = ref.watch(userProfileProvider).valueOrNull;
            final towers = ref.watch(userTowersProvider).valueOrNull ?? const [];
            final citySnapshot = buildCityProgress(
              lessonProgress: lessons,
              towers: towers,
              profile: profile,
            );
            final completed = LessonProgression.completedCount(lessons, profile);
            final questName =
                LessonProgression.displayQuestLevelName(lessons, profile);

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(LQSpacing.gutter),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Awards', style: LQTypography.display(colors)),
                        const SizedBox(height: LQSpacing.sm),
                        Text(
                          'Badges, streaks, and your quest ladder',
                          style: LQTypography.bodySm(colors),
                        ),
                        const SizedBox(height: LQSpacing.lg),
                        Text('Your badges', style: LQTypography.h2(colors)),
                        const SizedBox(height: LQSpacing.md),
                        badgesAsync.when(
                          loading: () => const SizedBox(
                            height: 48,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          error: (_, __) => Text(
                            'Badges loading…',
                            style: LQTypography.bodySm(colors),
                          ),
                          data: (badges) {
                            if (badges.isEmpty) {
                              return LQCard(
                                colors: colors,
                                child: Text(
                                  'Complete your first lesson to earn your first badge!',
                                  style: LQTypography.bodySm(colors),
                                ),
                              );
                            }
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: badges.map((b) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      right: LQSpacing.md,
                                    ),
                                    child: LQBadge(
                                      colors: colors,
                                      title: badgeTitle(b.id),
                                      subtitle: 'Earned',
                                      icon: LQDuotoneIcon(
                                        icon: LQIconType.trophy,
                                        size: 28,
                                        primaryColor: colors.gold,
                                        secondaryColor:
                                            colors.gold.withValues(alpha: 0.3),
                                      ),
                                    ).animate().scale(
                                          begin: const Offset(0.9, 0.9),
                                          end: const Offset(1, 1),
                                        ),
                                  );
                                }).toList(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: LQSpacing.xxl),
                        LQCard(
                          colors: colors,
                          child: LQQuestLadder(
                            colors: colors,
                            progress: lessons,
                            profile: profile,
                          ),
                        ),
                        const SizedBox(height: LQSpacing.lg),
                        LQCard(
                          colors: colors,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text('Lemon City', style: LQTypography.h3(colors)),
                                  ),
                                  Text(
                                    '$completed/$kTotalStages',
                                    style: LQTypography.label(colors).copyWith(
                                      color: colors.brand,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: LQSpacing.sm),
                              Text(
                                'Each lesson builds a new place in your city',
                                style: LQTypography.bodySm(colors),
                              ),
                              const SizedBox(height: LQSpacing.md),
                              CityMapPreview(colors: colors, snapshot: citySnapshot),
                              const SizedBox(height: LQSpacing.lg),
                              ...List.generate(kQuestLevelCount, (i) {
                                final theme = kCityDistrictThemes[i];
                                final pct = citySnapshot.districtCompletion[i];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: LQSpacing.sm),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: theme.accent,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: LQSpacing.sm),
                                          Expanded(
                                            child: Text(
                                              theme.name,
                                              style: LQTypography.bodySm(colors),
                                            ),
                                          ),
                                          Text(
                                            '${(pct * 100).round()}%',
                                            style: LQTypography.micro(colors),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(LQRadius.pill),
                                        child: LinearProgressIndicator(
                                          value: pct.clamp(0, 1),
                                          minHeight: 6,
                                          backgroundColor: colors.inkSoft.withValues(alpha: 0.1),
                                          color: theme.accent,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ).animate(delay: 40.ms).fadeIn(),
                        const SizedBox(height: LQSpacing.lg),
                        LQCard(
                          colors: colors,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('This week', style: LQTypography.h3(colors)),
                              const SizedBox(height: LQSpacing.lg),
                              SizedBox(
                                height: 120,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: List.generate(7, (i) {
                                    final count = weekly[i];
                                    final day = DateTime.now()
                                        .subtract(Duration(days: 6 - i));
                                    final label = _dayLabel(day.weekday);
                                    final h = (count / maxBar) * 88.0;
                                    return Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 3),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            if (count > 0)
                                              Text(
                                                '$count',
                                                style: LQTypography.micro(colors),
                                              ),
                                            const SizedBox(height: 4),
                                            AnimatedContainer(
                                              duration: const Duration(milliseconds: 400),
                                              height: h.clamp(4, 88),
                                              decoration: BoxDecoration(
                                                color: count > 0
                                                    ? colors.brand
                                                    : colors.inkSoft.withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(label, style: LQTypography.micro(colors)),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(),
                        const SizedBox(height: LQSpacing.lg),
                        LQCard(
                          colors: colors,
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Day streak', style: LQTypography.h3(colors)),
                                    const SizedBox(height: LQSpacing.xs),
                                    Text(
                                      stats.streak.count > 0
                                          ? '${stats.streak.count} days in a row — keep going!'
                                          : 'Start today — every day counts',
                                      style: LQTypography.bodySm(colors),
                                    ),
                                  ],
                                ),
                              ),
                              StatPill(
                                colors: colors,
                                label: '${stats.streak.count}',
                                variant: StatPillVariant.streak,
                              ),
                            ],
                          ),
                        ).animate(delay: 80.ms).fadeIn(),
                        const SizedBox(height: LQSpacing.lg),
                        Text('Quest skills (L1–L6)', style: LQTypography.h2(colors)),
                        const SizedBox(height: LQSpacing.lg),
                        ...kSkillKeys.map((key) {
                          final value = stats.conceptSkills[key] ?? 0;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: LQSpacing.md),
                            child: _SkillBar(
                              colors: colors,
                              label: skillLabel(key),
                              value: value,
                            ),
                          );
                        }),
                        const SizedBox(height: LQSpacing.lg),
                        Text('Business IQ', style: LQTypography.h3(colors)),
                        _SkillBar(
                          colors: colors,
                          label: 'Profit sense',
                          value: stats.businessIQ.profit,
                        ),
                        const SizedBox(height: LQSpacing.md),
                        _SkillBar(
                          colors: colors,
                          label: 'Decision quality',
                          value: stats.businessIQ.decision,
                        ),
                        const SizedBox(height: LQSpacing.md),
                        _SkillBar(
                          colors: colors,
                          label: 'Resilience',
                          value: stats.businessIQ.resilience,
                        ),
                        const SizedBox(height: LQSpacing.lg),
                        LQCard(
                          colors: colors,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _StatBlock(colors: colors, label: 'LQ Score', value: '${stats.lqScore}'),
                              _StatBlock(colors: colors, label: 'Level', value: '${stats.level}'),
                              _StatBlock(colors: colors, label: 'Coins', value: '${stats.coins}'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 88),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _dayLabel(int weekday) => switch (weekday) {
        DateTime.monday => 'M',
        DateTime.tuesday => 'T',
        DateTime.wednesday => 'W',
        DateTime.thursday => 'T',
        DateTime.friday => 'F',
        DateTime.saturday => 'S',
        _ => 'S',
      };
}

class _SkillBar extends StatelessWidget {
  const _SkillBar({
    required this.colors,
    required this.label,
    required this.value,
  });

  final LQColors colors;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: LQTypography.bodySm(colors))),
            Text('$value', style: LQTypography.label(colors)),
          ],
        ),
        const SizedBox(height: LQSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(LQRadius.pill),
          child: LinearProgressIndicator(
            value: (value / 100).clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: colors.inkSoft.withValues(alpha: 0.12),
            color: colors.accentMint,
          ),
        ),
      ],
    );
  }
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({
    required this.colors,
    required this.label,
    required this.value,
  });

  final LQColors colors;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: LQTypography.h2(colors)),
        Text(label, style: LQTypography.micro(colors)),
      ],
    );
  }
}
