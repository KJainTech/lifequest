import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/lq_theme.dart';
import '../../core/tokens/lq_tokens.dart';
import '../../core/tokens/lq_typography.dart';
import '../../data/content/lesson_catalog.dart';
import '../../data/content/lesson_content_cache.dart';
import '../../data/content/lesson_definitions.dart';
import '../../design/guide_mascot.dart';
import '../../design/lq_button.dart';
import '../../design/lq_canvas.dart';
import '../../design/lq_quiz_choice.dart';
import '../../design/penny_mascot.dart';
import '../../features/onboarding/auth_service.dart';
import '../learn/lesson_session.dart';

/// Exit Challenge — level-end assessment (DevPlan Day 30–32).
class ExitChallengeView extends ConsumerStatefulWidget {
  const ExitChallengeView({super.key, required this.questLevel});

  final int questLevel;

  @override
  ConsumerState<ExitChallengeView> createState() => _ExitChallengeViewState();
}

class _ExitChallengeViewState extends ConsumerState<ExitChallengeView> {
  int _q = 0;
  int _correct = 0;
  int? _selected;
  bool _done = false;
  late final List<_ExitQ> _questions;

  @override
  void initState() {
    super.initState();
    _questions = _buildQuestions(widget.questLevel);
  }

  List<_ExitQ> _buildQuestions(int level) {
    final lessons = lessonsForQuestLevel(level).take(5);
    final qs = <_ExitQ>[];
    for (final meta in lessons) {
      final content = buildLessonContent(meta.id, '9-12');
      if (content.quizQuestions.isEmpty) continue;
      final q = content.quizQuestions.first;
      final key = quizAnswerKeyFor(meta.id);
      qs.add(_ExitQ(
        prompt: '[${meta.title}] ${q.prompt.replaceAll('**', '')}',
        options: q.options,
        correct: key.first,
      ));
    }
    return qs;
  }

  void _pick(int i) {
    if (_done || _selected != null) return;
    final ok = i == _questions[_q].correct;
    setState(() {
      _selected = i;
      if (ok) _correct++;
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      if (_q + 1 >= _questions.length) {
        setState(() => _done = true);
      } else {
        setState(() {
          _q++;
          _selected = null;
        });
      }
    });
  }

  void _continue(bool passed) {
    final notifier = ref.read(lessonSessionProvider.notifier);
    if (passed) {
      notifier.advanceExitChallenge(passed: true);
    } else {
      notifier.finishCeremony();
      context.go('/learn');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(lqColorsProvider);
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final guide = LQGuideX.fromId(profile?.guide ?? 'penny');
    final total = _questions.length;
    final pct = total == 0 ? 100 : (_correct / total * 100).round();
    final passed = pct >= 80;

    return LQCanvas(
      colors: colors,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(LQSpacing.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.brand.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(LQRadius.chip),
                ),
                child: Text(
                  'Exit Challenge · Level ${widget.questLevel}',
                  style: LQTypography.label(colors).copyWith(color: colors.brand),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: LQSpacing.lg),
              GuideMascot(guide: guide, size: 100, state: PennyGuideState.think),
              if (!_done) ...[
                Text(
                  'Question ${_q + 1} of $total',
                  style: LQTypography.caption(colors),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: LQSpacing.md),
                Text(
                  _questions[_q].prompt,
                  style: LQTypography.h3(colors),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: LQSpacing.lg),
                Expanded(
                  child: ListView(
                    children: List.generate(_questions[_q].options.length, (i) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: LQQuizChoice(
                          label: _questions[_q].options[i],
                          colors: colors,
                          state: _selected == null
                              ? QuizChoiceState.idle
                              : i == _questions[_q].correct
                                  ? QuizChoiceState.correct
                                  : _selected == i
                                      ? QuizChoiceState.incorrect
                                      : QuizChoiceState.dimmed,
                          onTap: _selected == null ? () => _pick(i) : null,
                        ),
                      );
                    }),
                  ),
                ),
              ] else ...[
                const Spacer(),
                Text(
                  passed ? 'Level mastered!' : 'Really close!',
                  style: LQTypography.display(colors),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(),
                const SizedBox(height: LQSpacing.md),
                Text(
                  passed
                      ? 'Score: $pct% — you earned the level ceremony.'
                      : 'Score: $pct% — replay a few stages to strengthen weak spots.',
                  style: LQTypography.bodySm(colors),
                  textAlign: TextAlign.center,
                ),
                const Spacer(flex: 2),
                LQButton(
                  label: passed ? 'Continue' : 'Back to map',
                  colors: colors,
                  expanded: true,
                  onPressed: () => _continue(passed),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ExitQ {
  const _ExitQ({required this.prompt, required this.options, required this.correct});
  final String prompt;
  final List<String> options;
  final int correct;
}

/// Programme complete — all six buildings (DevPlan city finale).
class CityFinaleView extends ConsumerWidget {
  const CityFinaleView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(lqColorsProvider);
    return LQCanvas(
      colors: colors,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(LQSpacing.gutter),
          child: Column(
            children: [
              const Spacer(),
              Text('🏙️', style: const TextStyle(fontSize: 72))
                  .animate(onPlay: (c) => c.repeat())
                  .shimmer(duration: 2.seconds),
              const SizedBox(height: LQSpacing.xl),
              Text(
                'Chief Money Officer!',
                style: LQTypography.display(colors),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: LQSpacing.md),
              Text(
                'All six districts shine. Penny, FinBot, and Atlas celebrate with you.',
                style: LQTypography.body(colors),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 2),
              LQButton(
                label: 'See my city',
                colors: colors,
                expanded: true,
                onPressed: () {
                  ref.read(lessonSessionProvider.notifier).finishCeremony();
                  context.push('/city');
                },
              ),
              const SizedBox(height: LQSpacing.sm),
              LQButton(
                label: 'Home',
                colors: colors,
                variant: LQButtonVariant.ghost,
                expanded: true,
                onPressed: () {
                  ref.read(lessonSessionProvider.notifier).finishCeremony();
                  context.go('/home');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LevelCompleteView extends ConsumerWidget {
  const LevelCompleteView({super.key, required this.questLevel, required this.questName});

  final int questLevel;
  final String questName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(lqColorsProvider);
    return LQCanvas(
      colors: colors,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(LQSpacing.gutter),
          child: Column(
            children: [
              const Spacer(),
              Text(
                'LEVEL $questLevel COMPLETE!',
                style: LQTypography.display(colors).copyWith(color: colors.gold),
                textAlign: TextAlign.center,
              ).animate().scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1, 1),
                    curve: Curves.elasticOut,
                  ),
              const SizedBox(height: LQSpacing.lg),
              Text(
                'You are now a $questName',
                style: LQTypography.h2(colors),
                textAlign: TextAlign.center,
              ).animate(delay: 400.ms).fadeIn(),
              const Spacer(flex: 2),
              LQButton(
                label: 'Read your letter',
                colors: colors,
                expanded: true,
                onPressed: () =>
                    ref.read(lessonSessionProvider.notifier).advanceLevelComplete(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
