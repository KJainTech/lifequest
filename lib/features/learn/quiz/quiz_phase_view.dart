import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/bootstrap/firebase_providers.dart';
import '../../../app/theme/lq_theme.dart';
import '../../../core/haptics/lq_haptics.dart';
import '../../../core/tokens/lq_tokens.dart';
import '../../../core/tokens/lq_typography.dart';
import '../../../data/content/lesson_content_cache.dart';
import '../../../data/repositories/content_repository.dart';
import '../../../design/guide_mascot.dart';
import '../../../design/hearts_row.dart';
import '../../../design/lq_button.dart';
import '../../../design/lq_card.dart';
import '../../../design/penny_mascot.dart';
import '../../../design/stat_pill.dart';
import '../../../features/onboarding/auth_service.dart';
import '../lesson_session.dart';

/// QUIZ phase per §5.9 — hearts, server-authoritative score
class QuizPhaseView extends ConsumerStatefulWidget {
  const QuizPhaseView({super.key});

  @override
  ConsumerState<QuizPhaseView> createState() => _QuizPhaseViewState();
}

class _QuizPhaseViewState extends ConsumerState<QuizPhaseView> {
  int? _selected;
  bool? _lastCorrect;
  String? _explanation;
  bool _showExplanation = false;
  bool _submitting = false;
  final _shakeKey = GlobalKey<ShakeWidgetState>();

  Future<void> _submitToServer(List<int> answers) async {
    setState(() => _submitting = true);
    try {
      final session = ref.read(lessonSessionProvider)!;
      final result = await ref.read(cloudFunctionsProvider).submitQuiz(
            lessonId: session.lessonId,
            answers: answers,
          );
      ref.read(lessonSessionProvider.notifier).setQuizSubmitted(result.score);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Let\'s try that again. ($e)')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _onSelect(int index, int correctIndex, String explanation, int totalQ) {
    if (_submitting || _showExplanation) return;
    final correct = index == correctIndex;
    setState(() {
      _selected = index;
      _lastCorrect = correct;
      _explanation = explanation;
    });

    if (correct) {
      LQHaptics.mediumImpact();
      ref.read(lessonSessionProvider.notifier).recordQuizAnswer(index, correct: true);
      setState(() => _showExplanation = true);
    } else {
      LQHaptics.heavyImpact();
      _shakeKey.currentState?.shake();
      ref.read(lessonSessionProvider.notifier).recordQuizAnswer(index, correct: false);
      setState(() => _showExplanation = true);
    }
  }

  void _continue(int totalQ, List<int> answerKey) {
    final session = ref.read(lessonSessionProvider)!;
    setState(() {
      _selected = null;
      _showExplanation = false;
      _explanation = null;
      _lastCorrect = null;
    });

    if (session.quizQuestionIndex >= totalQ) {
      final answers = List<int>.from(session.quizAnswers);
      while (answers.length < totalQ) {
        answers.add(0);
      }
      _submitToServer(answers);
      return;
    }

    if (session.hearts <= 0 && session.quizQuestionIndex < totalQ) {
      _submitToServer(session.quizAnswers);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(lqColorsProvider);
    final session = ref.watch(lessonSessionProvider)!;
    final contentAsync = ref.watch(lessonContentProvider(session.lessonId));
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final guide = LQGuideX.fromId(profile?.guide ?? 'penny');

    return contentAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Let\'s try that again.')),
      data: (content) {
        final questions = content.quizQuestions;
        final answerKey = quizAnswerKeyFor(session.lessonId);
        final qIndex = session.quizQuestionIndex.clamp(0, questions.length - 1);
        final q = questions[qIndex];

        if (session.quizQuestionIndex >= questions.length && !_submitting) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _submitToServer(session.quizAnswers);
          });
        }

        return ShakeWidget(
          key: _shakeKey,
          child: Padding(
            padding: const EdgeInsets.all(LQSpacing.gutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    HeartsRow(colors: colors, hearts: session.hearts),
                    const Spacer(),
                    StatPill(
                      colors: colors,
                      label: '+XP',
                      variant: StatPillVariant.xp,
                    ),
                  ],
                ),
                const SizedBox(height: LQSpacing.lg),
                Center(
                  child: GuideMascot(
                    guide: guide,
                    size: 72,
                    state: _lastCorrect == false
                        ? PennyGuideState.worried
                        : _lastCorrect == true
                            ? PennyGuideState.happy
                            : PennyGuideState.think,
                  ),
                ),
                const SizedBox(height: LQSpacing.lg),
                Text(
                  'Question ${qIndex + 1} of ${questions.length}',
                  style: LQTypography.caption(colors),
                ),
                const SizedBox(height: LQSpacing.sm),
                LQCard(
                  colors: colors,
                  child: Text(q.prompt.replaceAll('**', ''), style: LQTypography.h3(colors)),
                ),
                const SizedBox(height: LQSpacing.lg),
                Expanded(
                  child: ListView.separated(
                    itemCount: q.options.length,
                    separatorBuilder: (_, __) => const SizedBox(height: LQSpacing.md),
                    itemBuilder: (context, i) {
                      final isSelected = _selected == i;
                      final showSuccess = _showExplanation && isSelected && _lastCorrect == true;
                      final showFail = _showExplanation && isSelected && _lastCorrect == false;
                      return LQButton(
                        label: q.options[i],
                        colors: colors,
                        variant: showSuccess
                            ? LQButtonVariant.secondary
                            : showFail
                                ? LQButtonVariant.danger
                                : LQButtonVariant.secondary,
                        expanded: true,
                        enabled: !_showExplanation && !_submitting,
                        onPressed: () => _onSelect(i, answerKey[qIndex], q.explanation, questions.length),
                      );
                    },
                  ),
                ),
                if (_showExplanation && _explanation != null) ...[
                  LQCard(
                    colors: colors,
                    child: Text(_explanation!, style: LQTypography.bodySm(colors)),
                  ).animate().fadeIn().slideY(begin: 0.1, end: 0),
                  const SizedBox(height: LQSpacing.md),
                  LQButton(
                    label: 'Continue',
                    colors: colors,
                    expanded: true,
                    onPressed: _submitting
                        ? null
                        : () => _continue(questions.length, answerKey),
                  ),
                ],
                if (_submitting)
                  const Padding(
                    padding: EdgeInsets.only(top: LQSpacing.lg),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Screen shake on wrong answer per §4.5
class ShakeWidget extends StatefulWidget {
  const ShakeWidget({super.key, required this.child});

  final Widget child;

  @override
  ShakeWidgetState createState() => ShakeWidgetState();
}

class ShakeWidgetState extends State<ShakeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  void shake() => _controller.forward(from: 0);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final offset = sin(t * 3.14159 * 6) * 8 * (1 - t);
        return Transform.translate(
          offset: Offset(offset, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
