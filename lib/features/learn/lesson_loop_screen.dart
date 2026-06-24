import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/lq_theme.dart';
import '../../core/tokens/lq_tokens.dart';
import '../../core/tokens/lq_typography.dart';
import '../../data/content/lesson_catalog.dart';
import '../../data/repositories/content_repository.dart';
import '../../design/lq_app_shell.dart';
import '../../design/lq_immersive_scene.dart';
import '../game/activity_phase_view.dart';
import '../game/ceremony_screens.dart';
import '../game/ceremony_views.dart';
import '../game/stage_intro_view.dart';
import '../games/lemon_city/game_phase_view.dart';
import 'lesson_session.dart';
import 'read/read_phase_view.dart';
import 'reward/reward_phase_view.dart';

/// Sequential lesson loop — intro → read → activity → game → reward → ceremonies
class LessonLoopScreen extends ConsumerWidget {
  const LessonLoopScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(lqColorsProvider);
    final session = ref.watch(lessonSessionProvider);

    if (session == null || session.lessonId != lessonId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(lessonSessionProvider.notifier).start(lessonId);
      });
      return Scaffold(
        body: LQImmersiveScene(
          colors: colors,
          child: Center(child: CircularProgressIndicator(color: colors.brand)),
        ),
      );
    }

    final contentAsync = ref.watch(lessonContentProvider(lessonId));
    final title = contentAsync.valueOrNull?.title ?? 'Stage';

    Widget phaseBody;
    switch (session.phase) {
      case LessonPhase.stageIntro:
        phaseBody = StageIntroView(
          onContinue: () =>
              ref.read(lessonSessionProvider.notifier).advanceStageIntro(),
        );
      case LessonPhase.read:
        phaseBody = const ReadPhaseView();
      case LessonPhase.quiz:
        phaseBody = const ActivityPhaseView();
      case LessonPhase.game:
        phaseBody = const GamePhaseView();
      case LessonPhase.reward:
        phaseBody = const RewardPhaseView();
      case LessonPhase.exitChallenge:
        final meta = lessonById(session.lessonId);
        phaseBody = ExitChallengeView(questLevel: meta?.questLevel ?? 1);
      case LessonPhase.levelComplete:
        final meta = lessonById(session.lessonId);
        phaseBody = LevelCompleteView(
          questLevel: meta?.questLevel ?? 1,
          questName: meta?.questLevelName ?? kQuestLevelNames[0],
        );
      case LessonPhase.wisdomLetter:
        final meta = lessonById(session.lessonId);
        phaseBody = WisdomLetterView(questLevel: meta?.questLevel ?? 1);
      case LessonPhase.bragCard:
        final meta = lessonById(session.lessonId);
        phaseBody = BragCardView(
          questLevel: meta?.questLevel ?? 1,
          questName: meta?.questLevelName ?? kQuestLevelNames[0],
        );
      case LessonPhase.cityFinale:
        phaseBody = const CityFinaleView();
    }

    return Scaffold(
      body: LQImmersiveScene(
        colors: colors,
        child: SafeArea(
          child: LQAppShell(
            title: title,
            onBack: () {
              ref.read(lessonSessionProvider.notifier).clear();
              context.go('/home');
            },
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: LQSpacing.gutter),
                  child: _PhaseChip(colors: colors, phase: session.phase),
                ),
                Expanded(child: phaseBody),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PhaseChip extends StatelessWidget {
  const _PhaseChip({required this.colors, required this.phase});

  final LQColors colors;
  final LessonPhase phase;

  @override
  Widget build(BuildContext context) {
    final label = switch (phase) {
      LessonPhase.stageIntro => 'Intro',
      LessonPhase.read => 'Read',
      LessonPhase.quiz => 'Activity',
      LessonPhase.game => 'Game',
      LessonPhase.reward => 'Reward',
      LessonPhase.exitChallenge => 'Exit Challenge',
      LessonPhase.levelComplete => 'Level Complete',
      LessonPhase.wisdomLetter => 'Letter',
      LessonPhase.bragCard => 'Celebrate',
      LessonPhase.cityFinale => 'Finale',
    };
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: LQSpacing.md,
          vertical: LQSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: colors.brand.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(LQRadius.chip),
        ),
        child: Text(
          label,
          style: LQTypography.caption(colors).copyWith(
            color: colors.brand,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
