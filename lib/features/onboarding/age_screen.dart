import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/lq_theme.dart';
import '../../core/haptics/lq_haptics.dart';
import '../../core/motion/lq_motion.dart';
import '../../core/tokens/lq_tokens.dart';
import '../../core/tokens/lq_typography.dart';
import '../../design/lq_button.dart';
import '../../design/lq_canvas.dart';
import 'age_band.dart';
import 'onboarding_shell.dart';
import 'onboarding_state.dart';

/// Age stepper per §5.2
class AgeScreen extends ConsumerStatefulWidget {
  const AgeScreen({super.key});

  @override
  ConsumerState<AgeScreen> createState() => _AgeScreenState();
}

class _AgeScreenState extends ConsumerState<AgeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _numController;
  late Animation<double> _numAnim;

  @override
  void initState() {
    super.initState();
    _numController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _numAnim = CurvedAnimation(
      parent: _numController,
      curve: LQMotion.prefersReducedMotion
          ? Curves.easeOut
          : Curves.elasticOut,
    );
    _numController.forward();
  }

  @override
  void dispose() {
    _numController.dispose();
    super.dispose();
  }

  void _changeAge(int delta) {
    final draft = ref.read(onboardingDraftProvider);
    final next = (draft.age + delta).clamp(5, 17);
    if (next == draft.age) return;
    LQHaptics.selectionClick();
    ref.read(onboardingDraftProvider.notifier).setAge(next);
    _numController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(lqColorsProvider);
    final age = ref.watch(onboardingDraftProvider).age;
    final progress = (age - 5) / 12;

    return Scaffold(
      body: LQCanvas(
        colors: colors,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(LQSpacing.gutter),
            child: OnboardingShell(
              colors: colors,
              step: 1,
              totalSteps: 4,
              title: 'How old are you?',
              subtitle: 'This sets how tricky your questions are.',
              onBack: () => context.go('/'),
              child: Column(
                children: [
                  const Spacer(),
                  ScaleTransition(
                    scale: Tween<double>(begin: 0.85, end: 1).animate(_numAnim),
                    child: Text(
                      '$age',
                      style: LQTypography.numeral(
                        colors,
                        size: LQTypeScale.display * 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: LQSpacing.xxxl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _StepperButton(
                        colors: colors,
                        icon: Icons.remove_rounded,
                        onTap: () => _changeAge(-1),
                        enabled: age > 5,
                      ),
                      const SizedBox(width: LQSpacing.xxxl),
                      _StepperButton(
                        colors: colors,
                        icon: Icons.add_rounded,
                        onTap: () => _changeAge(1),
                        enabled: age < 17,
                      ),
                    ],
                  ),
                  const SizedBox(height: LQSpacing.xxxl),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(LQRadius.pill),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: colors.canvasEnd,
                      valueColor: AlwaysStoppedAnimation(colors.brand),
                    ),
                  ),
                  const Spacer(flex: 2),
                  LQButton(
                    label: 'Continue',
                    colors: colors,
                    expanded: true,
                    onPressed: () {
                      ref.read(ageWorldProvider.notifier).state =
                          ageToSuggestedWorld(age);
                      context.go('/onboarding/guide');
                    },
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

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.colors,
    required this.icon,
    required this.onTap,
    required this.enabled,
  });

  final LQColors colors;
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colors.surface,
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        onTap: enabled ? onTap : null,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: LQTouch.minTarget,
          height: LQTouch.minTarget,
          child: Icon(
            icon,
            color: enabled ? colors.brand : colors.inkSoft.withValues(alpha: 0.4),
            size: 28,
          ),
        ),
      ),
    );
  }
}
