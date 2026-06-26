import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/lq_theme.dart';
import '../../core/tokens/lq_tokens.dart';
import '../../core/tokens/lq_typography.dart';
import '../../data/content/lesson_catalog.dart';
import '../../data/content/stage_activity_config.dart';
import '../../data/models/stage_activity.dart';
import '../../data/repositories/content_repository.dart';
import '../../features/onboarding/age_band.dart';
import '../../features/onboarding/auth_service.dart';
import '../learn/lesson_session.dart';
import '../learn/quiz/quiz_phase_view.dart';
import 'activities/budget_split_activity.dart';
import 'activities/stage_activity_widgets.dart';
import 'simulators/stage_simulators.dart';

/// Activity engine — MCQ delegates to quiz; simulators & interactives render here.
class ActivityPhaseView extends ConsumerStatefulWidget {
  const ActivityPhaseView({super.key});

  @override
  ConsumerState<ActivityPhaseView> createState() => _ActivityPhaseViewState();
}

class _ActivityPhaseViewState extends ConsumerState<ActivityPhaseView> {
  int _activityIndex = 0;
  int _score = 0;
  bool _simulatorDone = false;

  void _advance(bool countCorrect) {
    setState(() {
      if (countCorrect) _score++;
      _activityIndex++;
    });
  }

  void _finishSimulator(int scoreOutOf5) {
    if (_simulatorDone) return;
    _simulatorDone = true;
    ref.read(lessonSessionProvider.notifier).setQuizSubmitted(scoreOutOf5);
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(lessonSessionProvider)!;
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final ageBand = profile?.ageBand ?? ageToBand(profile?.age ?? 10);
    final contentAsync = ref.watch(lessonContentProvider(session.lessonId));
    final colors = ref.watch(lqColorsProvider);

    return contentAsync.when(
      loading: () => Center(child: CircularProgressIndicator(color: colors.brand)),
      error: (e, _) => Center(child: Text('Let\'s try that again.')),
      data: (content) {
        final meta = lessonById(session.lessonId);
        if (meta == null) return const QuizPhaseView();

        final simulator = StageActivityConfig.simulatorFor(meta);
        if (simulator != null) {
          if (_simulatorDone) {
            return Center(child: CircularProgressIndicator(color: colors.brand));
          }
          return Padding(
            padding: const EdgeInsets.all(LQSpacing.gutter),
            child: simulator == StageSimulatorId.creditScore
                ? CreditScoreSimulator(
                    colors: colors,
                    onComplete: _finishSimulator,
                  )
                : CrashExperimentSimulator(
                    colors: colors,
                    onComplete: _finishSimulator,
                  ),
          );
        }

        if (StageActivityConfig.primaryKind(meta) == StageActivityKind.mcq) {
          return const QuizPhaseView();
        }

        final activities = StageActivityConfig.activitiesFor(
          meta,
          content.quizQuestions,
          ageBand,
        );

        if (_activityIndex >= activities.length) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref
                .read(lessonSessionProvider.notifier)
                .setQuizSubmitted(_score.clamp(0, 5));
          });
          return Center(child: CircularProgressIndicator(color: colors.brand));
        }

        final activity = activities[_activityIndex];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(LQSpacing.gutter),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.sizeOf(context).height * 0.55,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Activity ${_activityIndex + 1} of ${activities.length}',
                  style: LQTypography.caption(colors),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: LQSpacing.sm),
                Text(
                  activity.prompt,
                  style: LQTypography.h3(colors),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: LQSpacing.lg),
                _ActivityBody(
                  key: ValueKey('activity_${_activityIndex}_${activity.prompt.hashCode}'),
                  activity: activity,
                  colors: colors,
                  onCorrect: () => _advance(true),
                  onComplete: () => _advance(true),
                  onWrong: () {},
                ),
                const SizedBox(height: LQSpacing.xxl),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ActivityBody extends StatelessWidget {
  const _ActivityBody({
    super.key,
    required this.activity,
    required this.colors,
    required this.onCorrect,
    required this.onComplete,
    required this.onWrong,
  });

  final StageActivity activity;
  final LQColors colors;
  final VoidCallback onCorrect;
  final VoidCallback onComplete;
  final VoidCallback onWrong;

  @override
  Widget build(BuildContext context) {
    switch (activity.kind) {
      case StageActivityKind.dragDrop:
        return DragDropBucketActivity(
          activity: activity,
          colors: colors,
          onComplete: onComplete,
        );
      case StageActivityKind.slider:
        if (promptUsesBudgetSplit(activity.prompt)) {
          return BudgetSplitActivity(
            colors: colors,
            prompt: activity.prompt,
            onComplete: onComplete,
          );
        }
        return SliderQuizActivity(
          activity: activity,
          colors: colors,
          onAnswer: (ok) => ok ? onCorrect() : onWrong(),
        );
      case StageActivityKind.cardSort:
        return CardSortActivity(
          activity: activity,
          colors: colors,
          onComplete: onComplete,
        );
      case StageActivityKind.scenario:
        return ScenarioTapActivity(
          activity: activity,
          colors: colors,
          correctIndex: activity.correctIndex,
          onSelect: (i) {
            if (i == activity.correctIndex) {
              onCorrect();
            } else {
              onWrong();
            }
          },
        );
      case StageActivityKind.mcq:
      case StageActivityKind.simulator:
        return const SizedBox.shrink();
    }
  }
}
