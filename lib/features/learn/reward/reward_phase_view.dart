import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/bootstrap/firebase_providers.dart';
import '../../../app/theme/lq_theme.dart';
import '../../../core/haptics/lq_haptics.dart';
import '../../../core/tokens/lq_tokens.dart';
import '../../../core/tokens/lq_typography.dart';
import '../../../design/guide_mascot.dart';
import '../../../design/lq_button.dart';
import '../../../design/lq_canvas.dart';
import '../../../design/penny_mascot.dart';
import '../../../design/stat_pill.dart';
import '../../../features/onboarding/auth_service.dart';
import '../../../data/content/lesson_catalog.dart';
import '../../../data/content/lesson_progression.dart';
import '../../../data/content/lesson_progression.dart';
import '../../../design/lq_celebration.dart';
import '../../city/city_providers.dart';
import '../lesson_session.dart';

/// REWARD phase per §5.11 — stars, server completeLesson, CTA to city
class RewardPhaseView extends ConsumerStatefulWidget {
  const RewardPhaseView({super.key});

  @override
  ConsumerState<RewardPhaseView> createState() => _RewardPhaseViewState();
}

class _RewardPhaseViewState extends ConsumerState<RewardPhaseView> {
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _complete());
  }

  Future<void> _complete() async {
    if (_loaded) return;
    final session = ref.read(lessonSessionProvider);
    if (session == null) return;

    ref.read(lessonSessionProvider.notifier).setLoading(true);
    try {
      final result = await ref.read(cloudFunctionsProvider).completeLesson(
            lessonId: session.lessonId,
            quizScore: session.quizScore ?? 0,
            gameWon: session.gameWon ?? false,
            gameProfit: session.gameProfit ?? 0,
          );
      ref.read(lessonSessionProvider.notifier).setCompletion({
        'xp': result.xp,
        'coins': result.coins,
        'lqScore': result.lqScore,
        'level': result.level,
        'stars': result.stars,
        'towerName': result.towerName,
        'badgeUnlocked': result.badgeUnlocked,
      });
      LQHaptics.levelUp();
      setState(() => _loaded = true);
    } catch (e) {
      ref.read(lessonSessionProvider.notifier).setError('$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(lqColorsProvider);
    final session = ref.watch(lessonSessionProvider)!;
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final guide = LQGuideX.fromId(profile?.guide ?? 'penny');
    final result = session.completionResult;

    if (session.isLoading || result == null) {
      return LQCanvas(
        colors: colors,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GuideMascot(guide: guide, size: 100, state: PennyGuideState.celebrate),
              const SizedBox(height: LQSpacing.xxl),
              const CircularProgressIndicator(),
              if (session.error != null) ...[
                const SizedBox(height: LQSpacing.lg),
                Text(session.error!, style: LQTypography.bodySm(colors)),
                LQButton(
                  label: 'Retry',
                  colors: colors,
                  onPressed: () {
                    setState(() => _loaded = false);
                    _complete();
                  },
                ),
              ],
            ],
          ),
        ),
      );
    }

    final stars = (result['stars'] as num?)?.toInt() ?? 0;
    final xp = (result['xp'] as num?)?.toInt() ?? 0;
    final coins = (result['coins'] as num?)?.toInt() ?? 0;
    final lqScore = (result['lqScore'] as num?)?.toInt() ?? 0;
    final towerName = result['towerName'] as String?;
    final nextLesson = LessonProgression.nextAfter(session.lessonId);
    final journeyDone = nextLesson == null;

    return Stack(
      children: [
        LQCelebrationBurst(colors: colors, active: stars >= 4),
        LQCanvas(
          colors: colors,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(LQSpacing.gutter),
              child: Column(
                children: [
                  const Spacer(),
                  LQSuccessPop(
                    child: GuideMascot(
                      guide: guide,
                      size: 140,
                      state: PennyGuideState.celebrate,
                    ),
                  ),
                  const SizedBox(height: LQSpacing.xxxl),
                  LQSuccessPop(
                    delay: 120.ms,
                    child: Text(
                      journeyDone ? 'Journey complete!' : 'Stage complete!',
                      style: LQTypography.display(colors),
                    ),
                  ),
                  const SizedBox(height: LQSpacing.lg),
                  _StarsRow(colors: colors, count: stars),
                  const SizedBox(height: LQSpacing.xxl),
                  Wrap(
                    spacing: LQSpacing.sm,
                    alignment: WrapAlignment.center,
                    children: [
                      StatPill(colors: colors, label: '+$xp XP', variant: StatPillVariant.xp),
                      StatPill(colors: colors, label: '+$coins coins', variant: StatPillVariant.coins),
                      StatPill(colors: colors, label: 'LQ $lqScore', variant: StatPillVariant.trend),
                    ],
                  ).animate().fadeIn(delay: 450.ms),
                  if (towerName != null) ...[
                    const SizedBox(height: LQSpacing.lg),
                    LQSuccessPop(
                      delay: 200.ms,
                      child: Text(
                        '$towerName built!',
                        style: LQTypography.h3(colors).copyWith(color: colors.gold),
                      ),
                    ),
                  ],
                  if (nextLesson != null) ...[
                    const SizedBox(height: LQSpacing.lg),
                    Text(
                      'Next: ${nextLesson.title}',
                      style: LQTypography.bodySm(colors),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 520.ms),
                  ],
                  const Spacer(flex: 2),
                  LQButton(
                    label: nextLesson != null
                        ? 'Next stage'
                        : 'Back to home',
                    colors: colors,
                    expanded: true,
                    onPressed: () {
                      if (towerName != null) {
                        ref.read(pendingCityCelebrationProvider.notifier).state =
                            towerName;
                      }
                      ref.read(lessonSessionProvider.notifier).clear();
                      if (nextLesson != null) {
                        context.go('/lesson/${nextLesson.id}');
                      } else {
                        context.go('/home');
                      }
                    },
                  ).animate().fadeIn(delay: 650.ms),
                  const SizedBox(height: LQSpacing.md),
                  LQButton(
                    label: 'See my city',
                    colors: colors,
                    variant: LQButtonVariant.ghost,
                    expanded: true,
                    onPressed: () {
                      if (towerName != null) {
                        ref.read(pendingCityCelebrationProvider.notifier).state =
                            towerName;
                      }
                      ref.read(lessonSessionProvider.notifier).clear();
                      context.go('/city');
                    },
                  ).animate().fadeIn(delay: 720.ms),
                  const SizedBox(height: LQSpacing.lg),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StarsRow extends StatelessWidget {
  const _StarsRow({required this.colors, required this.count});

  final LQColors colors;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (i) {
        final filled = i < count;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Icon(
            filled ? Icons.star_rounded : Icons.star_outline_rounded,
            color: filled ? colors.gold : colors.inkSoft.withValues(alpha: 0.3),
            size: 36,
          )
              .animate(delay: (i * 80).ms)
              .scale(
                begin: const Offset(0, 0),
                end: const Offset(1, 1),
                curve: Curves.elasticOut,
              ),
        );
      }),
    );
  }
}
