import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/lq_theme.dart';
import '../../core/tokens/lq_tokens.dart';
import '../../core/tokens/lq_typography.dart';
import '../../data/content/lesson_catalog.dart';
import '../../data/content/lesson_progression.dart';
import '../../data/models/lq_models.dart';
import '../../data/providers/app_providers.dart';
import '../../design/lq_card.dart';
import '../../design/lq_immersive_scene.dart';
import '../../features/city/city_buildings.dart';
import '../../features/onboarding/auth_service.dart';

/// Learn tab — 6 levels · 48 stages · proficiency-gated path.
class LearnScreen extends ConsumerStatefulWidget {
  const LearnScreen({super.key});

  @override
  ConsumerState<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends ConsumerState<LearnScreen> {
  int _expandedLevel = 1;
  final _scrollController = ScrollController();
  final _currentNodeKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrent(LessonMeta? current) {
    if (current == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _currentNodeKey.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
          alignment: 0.25,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(lqColorsProvider);
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final lessonsAsync = ref.watch(userLessonsProvider);
    final progressList = lessonsAsync.valueOrNull ?? const [];
    final placement = LessonProgression.displayQuestLevel(progressList, profile);

    return LQImmersiveScene(
      colors: colors,
      child: SafeArea(
        child: lessonsAsync.when(
          loading: () => Center(child: CircularProgressIndicator(color: colors.brand)),
          error: (e, _) => Center(
            child: Text('Could not load lessons ($e)', style: LQTypography.bodySm(colors)),
          ),
          data: (progress) {
            final current = LessonProgression.currentLesson(progress, profile);
            final done = LessonProgression.completedCount(progress, profile);
            final journeyDone = LessonProgression.isJourneyComplete(progress, profile);
            final journeyPct = LessonProgression.journeyProgress(progress, profile);

            if (current != null && _expandedLevel != current.questLevel) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) setState(() => _expandedLevel = current.questLevel);
              });
            }
            _scrollToCurrent(current);

            final stageCount = stagesInQuestLevel(_expandedLevel);
            final levelUnlocked =
                LessonProgression.isQuestLevelUnlocked(_expandedLevel, progress, profile);
            final levelPct = LessonProgression.levelProgress(_expandedLevel, progress, profile);
            final tier = kQuestLevelTiers[_expandedLevel - 1];
            final district = kCityDistrictThemes[_expandedLevel - 1];

            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(LQSpacing.gutter),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            LQProgressRing(
                              colors: colors,
                              progress: journeyPct,
                              size: 56,
                              stroke: 6,
                              child: Text(
                                'L$placement',
                                style: LQTypography.caption(colors).copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: colors.brand,
                                ),
                              ),
                            ),
                            const SizedBox(width: LQSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Your Quest Path', style: LQTypography.display(colors)),
                                  Text(
                                    journeyDone
                                        ? 'Programme complete · $done/$kTotalStages'
                                        : '$done/$kTotalStages stages · ${(journeyPct * 100).round()}%',
                                    style: LQTypography.bodySm(colors),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: LQSpacing.lg),
                        _LevelPicker(
                          colors: colors,
                          selected: _expandedLevel,
                          progress: progress,
                          profile: profile,
                          onSelect: (l) => setState(() => _expandedLevel = l),
                        ),
                        const SizedBox(height: LQSpacing.lg),
                        _LevelHeader(
                          colors: colors,
                          level: _expandedLevel,
                          tier: tier,
                          district: district,
                          levelPct: levelPct,
                          unlocked: levelUnlocked,
                          daysLeft: levelUnlocked
                              ? 0
                              : LessonProgression.daysUntilLevelUnlock(
                                  _expandedLevel, progress, profile),
                        ),
                        if (!levelUnlocked) ...[
                          const SizedBox(height: LQSpacing.md),
                          _GateBanner(
                            colors: colors,
                            daysLeft: LessonProgression.daysUntilLevelUnlock(
                              _expandedLevel, progress, profile),
                            gateLabel: timeGateLabel(_expandedLevel),
                            masteryHint: LessonProgression.levelUnlockHint(
                              _expandedLevel, progress, profile),
                          ),
                        ],
                        const SizedBox(height: LQSpacing.lg),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final meta = lessonsForQuestLevel(_expandedLevel)[i];
                      final status = LessonProgression.statusFor(meta, progress, profile);
                      final isCurrent = current?.id == meta.id;
                      final stored = progress
                          .where((p) => p.lessonId == meta.id)
                          .firstOrNull;
                      return Padding(
                        padding: EdgeInsets.only(
                          left: LQSpacing.gutter,
                          right: LQSpacing.gutter,
                          bottom: LQSpacing.md,
                        ),
                        child: _LessonNode(
                          key: isCurrent ? _currentNodeKey : null,
                          colors: colors,
                          meta: meta,
                          status: status,
                          isCurrent: isCurrent,
                          quizScore: stored?.quizScore,
                          onTap: status == LessonStatus.locked || !levelUnlocked
                              ? null
                              : () => context.push('/lesson/${meta.id}'),
                        ).animate(delay: (i * 35).ms).fadeIn().slideX(begin: 0.04, end: 0),
                      );
                    },
                    childCount: stageCount,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LevelHeader extends StatelessWidget {
  const _LevelHeader({
    required this.colors,
    required this.level,
    required this.tier,
    required this.district,
    required this.levelPct,
    required this.unlocked,
    required this.daysLeft,
  });

  final LQColors colors;
  final int level;
  final QuestTier tier;
  final CityDistrictTheme district;
  final double levelPct;
  final bool unlocked;
  final int daysLeft;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LQSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(LQRadius.card),
        border: Border.all(color: colors.border),
        boxShadow: LQElevation.e1(colors.ink),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 72,
            decoration: BoxDecoration(
              color: district.accent,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: LQSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: district.accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(LQRadius.chip),
                      ),
                      child: Text(
                        tierLabel(tier),
                        style: LQTypography.caption(colors).copyWith(
                          color: district.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      timeGateLabel(level),
                      style: LQTypography.micro(colors).copyWith(color: colors.inkSoft),
                    ),
                  ],
                ),
                const SizedBox(height: LQSpacing.sm),
                Text(
                  'Level $level · ${kQuestLevelNames[level - 1]}',
                  style: LQTypography.h2(colors),
                ),
                const SizedBox(height: LQSpacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: levelPct.clamp(0, 1),
                    minHeight: 8,
                    backgroundColor: colors.border,
                    color: district.accent,
                  ),
                ),
                const SizedBox(height: LQSpacing.xs),
                Text(
                  unlocked
                      ? '${(levelPct * 100).round()}% complete · aim for 80% quiz to master'
                      : 'Finish the previous level to unlock',
                  style: LQTypography.micro(colors).copyWith(color: colors.inkSoft),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GateBanner extends StatelessWidget {
  const _GateBanner({
    required this.colors,
    required this.daysLeft,
    required this.gateLabel,
    this.masteryHint = '',
  });

  final LQColors colors;
  final int daysLeft;
  final String gateLabel;
  final String masteryHint;

  @override
  Widget build(BuildContext context) {
    final mastery = masteryHint.isNotEmpty;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(LQSpacing.md),
      decoration: BoxDecoration(
        color: colors.amber?.withValues(alpha: 0.35) ?? colors.warn.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(LQRadius.control),
        border: Border.all(color: colors.gold.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.hourglass_top_rounded, color: colors.gold, size: 20),
          const SizedBox(width: LQSpacing.sm),
          Expanded(
            child: Text(
              mastery
                  ? masteryHint
                  : daysLeft > 0
                      ? 'Level gate: $gateLabel · $daysLeft days until unlock'
                      : 'Finish all prior stages with 80%+ mastery to unlock',
              style: LQTypography.bodySm(colors),
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelPicker extends StatelessWidget {
  const _LevelPicker({
    required this.colors,
    required this.selected,
    required this.progress,
    required this.profile,
    required this.onSelect,
  });

  final LQColors colors;
  final int selected;
  final List<LessonProgress> progress;
  final UserProfile? profile;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: kQuestLevelCount,
        separatorBuilder: (_, __) => const SizedBox(width: LQSpacing.sm),
        itemBuilder: (context, i) {
          final level = i + 1;
          final lessons = lessonsForQuestLevel(level);
          final complete = lessons.every(
            (m) =>
                LessonProgression.statusFor(m, progress, profile) ==
                LessonStatus.completed,
          );
          final active = level == selected;
          final district = kCityDistrictThemes[i];
          final pct = LessonProgression.levelProgress(level, progress, profile);
          final locked = !LessonProgression.isQuestLevelUnlocked(level, progress, profile);

          return GestureDetector(
            onTap: () => onSelect(level),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 64,
              padding: const EdgeInsets.symmetric(
                horizontal: LQSpacing.sm,
                vertical: LQSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: active ? district.accent : district.surface,
                borderRadius: BorderRadius.circular(LQRadius.control),
                boxShadow: active ? LQElevation.e1(colors.ink) : null,
                border: complete
                    ? Border.all(color: colors.gold, width: 1.5)
                    : Border.all(
                        color: district.accent.withValues(alpha: locked ? 0.2 : 0.5),
                      ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'L$level',
                    style: LQTypography.caption(colors).copyWith(
                      color: active ? colors.surface : colors.ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    locked ? '🔒' : '${(pct * 100).round()}%',
                    style: LQTypography.micro(colors).copyWith(
                      color: active ? colors.surface.withValues(alpha: 0.9) : district.accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LessonNode extends StatelessWidget {
  const _LessonNode({
    super.key,
    required this.colors,
    required this.meta,
    required this.status,
    required this.isCurrent,
    this.quizScore,
    this.onTap,
  });

  final LQColors colors;
  final LessonMeta meta;
  final LessonStatus status;
  final bool isCurrent;
  final int? quizScore;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isLocked = status == LessonStatus.locked;
    final isDone = status == LessonStatus.completed;
    final needsMastery =
        isDone && quizScore != null && !LessonProgression.meetsMastery(
          LessonProgress(lessonId: meta.id, status: status, quizScore: quizScore),
        );

    return LQCard(
      colors: colors,
      onTap: onTap,
      elevation: isCurrent ? 2 : 1,
      selected: isCurrent,
      child: Row(
        children: [
          _NodeIcon(
            colors: colors,
            index: meta.stageInLevel,
            isLocked: isLocked,
            isDone: isDone,
            isCurrent: isCurrent,
          ),
          const SizedBox(width: LQSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stage ${meta.stageInLevel}',
                  style: LQTypography.caption(colors).copyWith(color: colors.brand),
                ),
                Text(meta.title, style: LQTypography.h3(colors)),
                Text(meta.subtitle, style: LQTypography.bodySm(colors)),
                if (needsMastery)
                  Padding(
                    padding: const EdgeInsets.only(top: LQSpacing.xs),
                    child: Text(
                      'Passed · replay for 80% mastery (you got $quizScore/5)',
                      style: LQTypography.micro(colors).copyWith(color: colors.warn),
                    ),
                  ),
              ],
            ),
          ),
          if (isCurrent)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: LQSpacing.sm,
                vertical: LQSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: colors.brand,
                borderRadius: BorderRadius.circular(LQRadius.chip),
              ),
              child: Text(
                'Play',
                style: LQTypography.caption(colors).copyWith(
                  color: colors.surface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NodeIcon extends StatelessWidget {
  const _NodeIcon({
    required this.colors,
    required this.index,
    required this.isLocked,
    required this.isDone,
    required this.isCurrent,
  });

  final LQColors colors;
  final int index;
  final bool isLocked;
  final bool isDone;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final bg = isDone
        ? colors.success
        : isCurrent
            ? colors.brand
            : isLocked
                ? colors.inkSoft.withValues(alpha: 0.12)
                : colors.accentMint.withValues(alpha: 0.6);

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        boxShadow: isCurrent ? LQElevation.e1(colors.brand) : null,
      ),
      child: Center(
        child: isLocked
            ? Icon(Icons.lock_rounded, size: 20, color: colors.inkSoft)
            : isDone
                ? Icon(Icons.star_rounded, size: 24, color: colors.gold)
                : Text(
                    '$index',
                    style: LQTypography.h3(colors).copyWith(
                      color: isCurrent ? colors.surface : colors.ink,
                    ),
                  ),
      ),
    );
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    return it.moveNext() ? it.current : null;
  }
}
