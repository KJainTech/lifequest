import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/bootstrap/firebase_providers.dart';
import '../../../app/theme/lq_theme.dart';
import '../../../core/audio/lq_sound_service.dart';
import '../../../core/tokens/lq_tokens.dart';
import '../../../core/tokens/lq_typography.dart';
import '../../../data/content/lesson_content_cache.dart';
import '../../../data/repositories/content_repository.dart';
import '../../../design/guide_mascot.dart';
import '../../../design/hearts_row.dart';
import '../../../design/lq_button.dart';
import '../../../design/lq_immersive_scene.dart';
import '../../../design/lq_quiz_choice.dart';
import '../../../design/penny_mascot.dart';
import '../../../design/quiz_score_chip.dart';
import '../../../features/onboarding/auth_service.dart';
import '../lesson_session.dart';
import 'quiz_shuffle.dart';

/// QUIZ phase — readable choices until pick; Continue only after feedback.
class QuizPhaseView extends ConsumerStatefulWidget {
  const QuizPhaseView({super.key});

  @override
  ConsumerState<QuizPhaseView> createState() => _QuizPhaseViewState();
}

class _QuizPhaseViewState extends ConsumerState<QuizPhaseView> {
  int _displayQuestionIndex = 0;
  String? _boundLessonId;
  int? _selected;
  bool? _lastCorrect;
  String? _explanation;
  bool _showExplanation = false;
  bool _submitting = false;
  int _scorePulse = 0;
  bool _showSuccessToast = false;
  final _shakeKey = GlobalKey<ShakeWidgetState>();

  void _syncLesson(String lessonId, int sessionIndex) {
    if (_boundLessonId != lessonId) {
      _boundLessonId = lessonId;
      _displayQuestionIndex = sessionIndex;
      _selected = null;
      _lastCorrect = null;
      _explanation = null;
      _showExplanation = false;
    }
  }

  Future<void> _submitToServer(List<int> answers) async {
    setState(() => _submitting = true);
    final session = ref.read(lessonSessionProvider)!;
    try {
      final result = await ref.read(cloudFunctionsProvider).submitQuiz(
            lessonId: session.lessonId,
            answers: answers,
          );
      ref.read(lessonSessionProvider.notifier).setQuizSubmitted(result.score);
    } catch (_) {
      final adaptiveKeys = ref.read(adaptiveAnswerKeysProvider);
      final key = adaptiveKeys[session.lessonId] ??
          quizAnswerKeyFor(session.lessonId);
      var score = 0;
      for (var i = 0; i < answers.length && i < key.length; i++) {
        if (answers[i] == key[i]) score++;
      }
      ref.read(lessonSessionProvider.notifier).setQuizSubmitted(score);
      final user = ref.read(authProvider).valueOrNull;
      if (user != null) {
        try {
          await ref
              .read(progressRepositoryProvider)
              .markLessonInProgress(user.uid, session.lessonId);
        } catch (_) {}
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              score >= answers.length - 1
                  ? 'Great job! Continuing to your game…'
                  : 'Quiz saved — let\'s keep going!',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _onSelect(int index, int correctIndex, String explanation) {
    if (_submitting || _showExplanation) return;
    LQSound.unlock();
    final correct = index == correctIndex;
    setState(() {
      _selected = index;
      _lastCorrect = correct;
      _explanation = explanation;
      if (correct) {
        _scorePulse++;
        _showSuccessToast = true;
      }
    });

    if (correct) {
      LQSound.success();
      ref.read(lessonSessionProvider.notifier).recordCorrectQuizAnswer(index);
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) setState(() => _showSuccessToast = false);
      });
    } else {
      LQSound.wrong();
      _shakeKey.currentState?.shake();
      ref.read(lessonSessionProvider.notifier).penalizeWrongQuizAnswer();
    }
    setState(() => _showExplanation = true);
  }

  void _continue(int totalQ) {
    final wasCorrect = _lastCorrect == true;

    setState(() {
      _selected = null;
      _showExplanation = false;
      _explanation = null;
      _lastCorrect = null;
      if (wasCorrect) _displayQuestionIndex++;
    });

    if (wasCorrect) {
      ref.read(lessonSessionProvider.notifier).advanceQuizQuestion();
    }

    final updated = ref.read(lessonSessionProvider)!;
    final nextIndex = _displayQuestionIndex;

    if (nextIndex >= totalQ) {
      final answers = ref.read(lessonSessionProvider.notifier).originalQuizAnswers();
      while (answers.length < totalQ) {
        answers.add(0);
      }
      _submitToServer(answers);
      return;
    }

    if (updated.hearts <= 0 && nextIndex < totalQ) {
      _submitToServer(ref.read(lessonSessionProvider.notifier).originalQuizAnswers());
    }
  }

  QuizChoiceState _choiceState(int i) {
    if (!_showExplanation) {
      if (_selected == null) return QuizChoiceState.idle;
      if (_selected == i) return QuizChoiceState.selected;
      return QuizChoiceState.dimmed;
    }
    if (_selected == i) {
      return _lastCorrect == true ? QuizChoiceState.correct : QuizChoiceState.incorrect;
    }
    return QuizChoiceState.dimmed;
  }

  static const _optionLabels = ['A', 'B', 'C', 'D'];

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(lqColorsProvider);
    final session = ref.watch(lessonSessionProvider)!;
    _syncLesson(session.lessonId, session.quizQuestionIndex);
    final contentAsync = ref.watch(lessonContentProvider(session.lessonId));
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final guide = LQGuideX.fromId(profile?.guide ?? 'penny');

    return contentAsync.when(
      loading: () => Center(child: CircularProgressIndicator(color: colors.brand)),
      error: (e, _) => Center(child: Text('Let\'s try that again.', style: LQTypography.bodySm(colors))),
      data: (content) {
        final questions = content.quizQuestions;
        final adaptiveKeys = ref.watch(adaptiveAnswerKeysProvider);
        final answerKey = adaptiveKeys[session.lessonId] ??
            quizAnswerKeyFor(session.lessonId);
        final qIndex = _displayQuestionIndex.clamp(0, questions.length - 1);
        final q = questions[qIndex];

        if (_displayQuestionIndex >= questions.length && !_submitting) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _submitToServer(
              ref.read(lessonSessionProvider.notifier).originalQuizAnswers(),
            );
          });
        }

        final shuffle = session.quizOptionPermutations.isEmpty
            ? null
            : QuizOptionShuffle.fromPermutations(session.quizOptionPermutations);
        final displayedOptions = shuffle == null
            ? q.options
            : shuffle.shuffledOptions(q.options, qIndex);
        final correctDisplayedIndex = shuffle == null
            ? answerKey[qIndex]
            : shuffle.permutations[qIndex].indexOf(answerKey[qIndex]);

        return LQImmersiveScene(
          colors: colors,
          intensity: 0.55,
          child: Stack(
            children: [
              ShakeWidget(
                key: _shakeKey,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    LQSpacing.gutter,
                    LQSpacing.sm,
                    LQSpacing.gutter,
                    LQSpacing.gutter,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          HeartsRow(colors: colors, hearts: session.hearts),
                          const Spacer(),
                          QuizScoreChip(
                            colors: colors,
                            correct: session.quizAnswers.length,
                            total: questions.length,
                            pulseToken: _scorePulse,
                          ),
                        ],
                      ),
                  const SizedBox(height: LQSpacing.md),
                  LQQuizProgress(
                    colors: colors,
                    current: qIndex,
                    total: questions.length,
                  ),
                  const SizedBox(height: LQSpacing.lg),
                  Center(
                    child: GuideMascot(
                      guide: guide,
                      size: 68,
                      state: _lastCorrect == false
                          ? PennyGuideState.worried
                          : _lastCorrect == true
                              ? PennyGuideState.celebrate
                              : PennyGuideState.think,
                    ),
                  )
                      .animate(
                        target: _lastCorrect == true && _showExplanation ? 1 : 0,
                      )
                      .scale(
                        begin: const Offset(1, 1),
                        end: const Offset(1.08, 1.08),
                        duration: 320.ms,
                        curve: Curves.elasticOut,
                      )
                      .then()
                      .scale(
                        begin: const Offset(1.08, 1.08),
                        end: const Offset(1, 1),
                        duration: 240.ms,
                      ),
                  const SizedBox(height: LQSpacing.lg),
                  Text(
                    'Question ${qIndex + 1} of ${questions.length}',
                    style: LQTypography.caption(colors).copyWith(
                      color: colors.inkSoft,
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: LQSpacing.sm),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    layoutBuilder: (currentChild, previousChildren) {
                      return Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          ...previousChildren,
                          if (currentChild != null) currentChild,
                        ],
                      );
                    },
                    child: Container(
                      key: ValueKey('prompt-$qIndex'),
                      width: double.infinity,
                      padding: const EdgeInsets.all(LQSpacing.xl),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(LQRadius.card),
                        boxShadow: LQElevation.e1(colors.ink),
                      ),
                      child: Text(
                        q.prompt.replaceAll('**', ''),
                        style: LQTypography.h3(colors).copyWith(height: 1.35),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: LQSpacing.lg),
                  Expanded(
                    child: ListView.separated(
                      key: ValueKey('options-$qIndex'),
                      itemCount: displayedOptions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: LQSpacing.sm),
                      itemBuilder: (context, i) {
                        return LQQuizChoice(
                          key: ValueKey('q$qIndex-opt$i'),
                          label: displayedOptions[i],
                          colors: colors,
                          state: _choiceState(i),
                          indexLabel: i < _optionLabels.length ? _optionLabels[i] : '${i + 1}',
                          enabled: !_showExplanation && !_submitting,
                          onTap: () => _onSelect(
                            i,
                            correctDisplayedIndex,
                            q.explanation,
                          ),
                        );
                      },
                    ),
                  ),
                  if (_showExplanation && _explanation != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(LQSpacing.lg),
                      decoration: BoxDecoration(
                        color: colors.surface.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(LQRadius.control),
                        border: Border.all(
                          color: (_lastCorrect == true ? colors.success : colors.warn)
                              .withValues(alpha: 0.35),
                        ),
                      ),
                      child: Text(
                        _explanation!,
                        style: LQTypography.bodySm(colors),
                        textAlign: TextAlign.center,
                      ),
                    ).animate().fadeIn(duration: 280.ms).slideY(begin: 0.08, end: 0),
                    const SizedBox(height: LQSpacing.md),
                    LQButton(
                      label: 'Continue',
                      colors: colors,
                      variant: LQButtonVariant.primary,
                      size: LQButtonSize.lg,
                      expanded: true,
                      onPressed: _submitting ? null : () => _continue(questions.length),
                    ).animate().fadeIn(delay: 120.ms).slideY(begin: 0.12, end: 0),
                  ] else
                    const SizedBox(height: LQTouch.minTarget + LQSpacing.md),
                  if (_submitting)
                    const Padding(
                      padding: EdgeInsets.only(top: LQSpacing.md),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    ],
                  ),
                ),
              ),
              if (_showSuccessToast)
                Positioned(
                  top: LQSpacing.xl,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: QuizSuccessToast(colors: colors)
                        .animate()
                        .fadeIn(duration: 180.ms)
                        .slideY(begin: -0.35, end: 0, curve: Curves.easeOutBack)
                        .then(delay: 500.ms)
                        .fadeOut(duration: 200.ms),
                  ),
                ),
            ],
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
        final offset = sin(t * pi * 6) * 8 * (1 - t);
        return Transform.translate(
          offset: Offset(offset, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
