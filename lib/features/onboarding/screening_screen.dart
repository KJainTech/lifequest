import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/lq_theme.dart';
import '../../core/haptics/lq_haptics.dart';
import '../../core/tokens/lq_tokens.dart';
import '../../core/tokens/lq_typography.dart';
import '../../design/guide_mascot.dart';
import '../../design/lq_button.dart';
import '../../design/lq_canvas.dart';
import '../../design/lq_card.dart';
import '../../design/penny_mascot.dart';
import 'onboarding_complete.dart';
import 'onboarding_shell.dart';
import 'onboarding_state.dart';
import 'screening_questions.dart';

/// Screening Quest per §5.5 — adaptive difficulty
class ScreeningScreen extends ConsumerStatefulWidget {
  const ScreeningScreen({super.key});

  @override
  ConsumerState<ScreeningScreen> createState() => _ScreeningScreenState();
}

class _ScreeningScreenState extends ConsumerState<ScreeningScreen> {
  late List<ScreeningQuestion> _questions;
  int _index = 0;
  int _difficulty = 1;
  final List<Map<String, dynamic>> _answers = [];
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _questions = buildScreeningSet();
  }

  Future<void> _answer(int selectedIndex) async {
    if (_submitting) return;
    final q = _questions[_index];
    final correct = selectedIndex == q.correctIndex;
    LQHaptics.mediumImpact();

    _answers.add({
      'questionId': q.id,
      'selectedIndex': selectedIndex,
      'correctIndex': q.correctIndex,
    });

    if (correct) {
      _difficulty = (_difficulty + 1).clamp(1, 4);
    } else {
      _difficulty = (_difficulty - 1).clamp(1, 4);
      LQHaptics.heavyImpact();
    }

    if (_index + 1 >= _questions.length) {
      await _finish();
      return;
    }

    setState(() {
      _index++;
      if (_index < _questions.length - 1) {
        // Inject harder question if doing well
        final next = screeningQuestionBank
            .where((item) => item.difficulty <= _difficulty + 1)
            .elementAt((_index + _difficulty) % screeningQuestionBank.length);
        _questions[_index] = next;
      }
    });
  }

  Future<void> _finish() async {
    setState(() => _submitting = true);
    try {
      final result = await submitScreeningToServer(
        ref: ref,
        answerPayload: _answers,
      );
      ref.read(screeningResultProvider.notifier).state = result;
      if (mounted) context.go('/onboarding/placement');
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

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(lqColorsProvider);
    final guide = LQGuideX.fromId(ref.watch(onboardingDraftProvider).guide);
    final q = _questions[_index];

    return Scaffold(
      body: LQCanvas(
        colors: colors,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(LQSpacing.gutter),
            child: OnboardingShell(
              colors: colors,
              step: 4,
              totalSteps: 4,
              title: 'Screening Quest',
              subtitle: 'Question ${_index + 1} of ${_questions.length}',
              onBack: () => context.go('/onboarding/start'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: GuideMascot(
                      guide: guide,
                      size: 80,
                      state: _submitting
                          ? PennyGuideState.think
                          : PennyGuideState.idle,
                    ),
                  ),
                  const SizedBox(height: LQSpacing.xxl),
                  LQCard(
                    colors: colors,
                    child: Text(q.prompt, style: LQTypography.h3(colors)),
                  ),
                  const SizedBox(height: LQSpacing.lg),
                  Expanded(
                    child: ListView.separated(
                      itemCount: q.options.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: LQSpacing.md),
                      itemBuilder: (context, i) {
                        return LQButton(
                          label: q.options[i],
                          colors: colors,
                          variant: LQButtonVariant.secondary,
                          expanded: true,
                          enabled: !_submitting,
                          onPressed: () => _answer(i),
                        );
                      },
                    ),
                  ),
                  if (_submitting)
                    const Padding(
                      padding: EdgeInsets.only(top: LQSpacing.lg),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
