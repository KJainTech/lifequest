import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/lq_theme.dart';
import '../../core/tokens/lq_tokens.dart';
import '../../core/tokens/lq_typography.dart';
import '../../data/repositories/content_repository.dart';
import '../../design/lq_canvas.dart';
import 'lesson_session.dart';
import 'read/read_phase_view.dart';
import 'quiz/quiz_phase_view.dart';
import 'reward/reward_phase_view.dart';
import '../games/lemon_city/game_phase_view.dart';

/// Sequential lesson loop shell — Read → Quiz → Game → Reward
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
        body: LQCanvas(
          colors: colors,
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final contentAsync = ref.watch(lessonContentProvider(lessonId));

    return Scaffold(
      body: LQCanvas(
        colors: colors,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: LQSpacing.gutter,
                  vertical: LQSpacing.sm,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        ref.read(lessonSessionProvider.notifier).clear();
                        context.go('/home');
                      },
                      icon: Icon(Icons.close_rounded, color: colors.inkSoft),
                      tooltip: 'Exit lesson',
                    ),
                    Expanded(
                      child: contentAsync.when(
                        data: (c) => Text(
                          c.title,
                          style: LQTypography.h3(colors),
                          textAlign: TextAlign.center,
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ),
                    _PhaseChip(colors: colors, phase: session.phase),
                  ],
                ),
              ),
              Expanded(
                child: switch (session.phase) {
                  LessonPhase.read => const ReadPhaseView(),
                  LessonPhase.quiz => const QuizPhaseView(),
                  LessonPhase.game => const GamePhaseView(),
                  LessonPhase.reward => const RewardPhaseView(),
                },
              ),
            ],
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
      LessonPhase.read => 'Read',
      LessonPhase.quiz => 'Quiz',
      LessonPhase.game => 'Game',
      LessonPhase.reward => 'Reward',
    };
    return Container(
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
    );
  }
}
