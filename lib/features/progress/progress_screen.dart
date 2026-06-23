import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap/firebase_providers.dart';
import '../../app/theme/lq_theme.dart';
import '../../core/tokens/lq_tokens.dart';
import '../../core/tokens/lq_typography.dart';
import '../../data/models/lq_models.dart';
import '../../data/providers/app_providers.dart';
import '../../design/lq_canvas.dart';
import '../../design/lq_card.dart';
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

    return LQCanvas(
      colors: colors,
      child: SafeArea(
        child: lessonsAsync.when(
          loading: () => Center(child: CircularProgressIndicator(color: colors.brand)),
          error: (e, _) => Center(child: Text('$e', style: LQTypography.bodySm(colors))),
          data: (lessons) {
            final weekly = _weeklyCounts(lessons);
            final maxBar = weekly.reduce((a, b) => a > b ? a : b).clamp(1, 99);

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(LQSpacing.gutter),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Progress', style: LQTypography.display(colors)),
                        const SizedBox(height: LQSpacing.sm),
                        Text(
                          'Your growth — no rankings, just you',
                          style: LQTypography.bodySm(colors),
                        ),
                        const SizedBox(height: LQSpacing.xxl),
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
                        Text('Skills mastered', style: LQTypography.h2(colors)),
                        const SizedBox(height: LQSpacing.lg),
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
