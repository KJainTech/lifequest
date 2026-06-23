import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/lq_theme.dart';
import '../../core/haptics/lq_haptics.dart';
import '../../core/tokens/lq_tokens.dart';
import '../../core/tokens/lq_typography.dart';
import '../../design/guide_mascot.dart';
import '../../design/lq_button.dart';
import '../../design/lq_canvas.dart';
import '../../design/penny_mascot.dart';
import 'onboarding_complete.dart';
import 'onboarding_state.dart';

/// Placement result per §5.5
class PlacementResultScreen extends ConsumerStatefulWidget {
  const PlacementResultScreen({super.key});

  @override
  ConsumerState<PlacementResultScreen> createState() =>
      _PlacementResultScreenState();
}

class _PlacementResultScreenState extends ConsumerState<PlacementResultScreen> {
  bool _saving = false;

  Future<void> _continue() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final result = ref.read(screeningResultProvider);
      await completeOnboarding(
        ref: ref,
        proficiencyLevel: result?.placementLevel ?? 1,
      );
      LQHaptics.levelUp();
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save profile. ($e)')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(lqColorsProvider);
    final result = ref.watch(screeningResultProvider);
    final guide = LQGuideX.fromId(ref.watch(onboardingDraftProvider).guide);

    if (result == null) {
      return Scaffold(
        body: LQCanvas(
          colors: colors,
          child: Center(
            child: LQButton(
              label: 'Back to start',
              colors: colors,
              onPressed: () => context.go('/onboarding/start'),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: LQCanvas(
        colors: colors,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(LQSpacing.gutter),
            child: Column(
              children: [
                const Spacer(),
                GuideMascot(
                  guide: guide,
                  size: 160,
                  state: PennyGuideState.celebrate,
                )
                    .animate()
                    .scale(
                      begin: const Offset(0.7, 0.7),
                      end: const Offset(1, 1),
                      curve: Curves.elasticOut,
                      duration: 700.ms,
                    ),
                const SizedBox(height: LQSpacing.xxxl),
                Text(
                  result.skipAhead ? 'Great work!' : 'Good start!',
                  style: LQTypography.display(colors),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: LQSpacing.lg),
                Text(
                  result.message,
                  style: LQTypography.h2(colors),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 350.ms),
                const SizedBox(height: LQSpacing.md),
                Text(
                  '${result.correct} of ${result.total} correct',
                  style: LQTypography.bodySm(colors),
                ).animate().fadeIn(delay: 450.ms),
                const Spacer(flex: 2),
                LQButton(
                  label: result.skipAhead
                      ? 'Skip ahead to Level ${result.placementLevel}'
                      : 'Start at Level 1',
                  colors: colors,
                  expanded: true,
                  onPressed: _saving ? null : _continue,
                ).animate().fadeIn(delay: 550.ms),
                const SizedBox(height: LQSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
