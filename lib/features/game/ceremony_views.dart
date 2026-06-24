import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/lq_theme.dart';
import '../../core/tokens/lq_tokens.dart';
import '../../core/tokens/lq_typography.dart';
import '../../data/content/wisdom_letters_data.dart';
import '../../design/guide_mascot.dart';
import '../../design/lq_button.dart';
import '../../design/lq_canvas.dart';
import '../../design/lq_celebration.dart';
import '../../design/penny_mascot.dart';
import '../../features/onboarding/auth_service.dart';
import '../learn/lesson_session.dart';

/// Money Wisdom Letter — typewriter reveal (DevPlan Day 29).
class WisdomLetterView extends ConsumerStatefulWidget {
  const WisdomLetterView({super.key, required this.questLevel});

  final int questLevel;

  @override
  ConsumerState<WisdomLetterView> createState() => _WisdomLetterViewState();
}

class _WisdomLetterViewState extends ConsumerState<WisdomLetterView> {
  int _visibleChars = 0;
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(lqColorsProvider);
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final guideId = profile?.guide ?? 'penny';
    final guide = LQGuideX.fromId(guideId);
    final letter = wisdomLetterForLevel(widget.questLevel);
    if (letter == null) {
      return Center(
        child: LQButton(
          label: 'Continue',
          colors: colors,
          onPressed: () => ref.read(lessonSessionProvider.notifier).advanceWisdomLetter(),
        ),
      );
    }

    final body = letter.bodyForGuide(guideId);
    final full = '${letter.rule}\n\n$body\n\n${letter.signoffForGuide(guideId)}';
    if (_revealed) _visibleChars = full.length;
    final shown = full.substring(0, _visibleChars.clamp(0, full.length));

    if (!_revealed && _visibleChars < full.length) {
      Future.delayed(const Duration(milliseconds: 20), () {
        if (mounted && !_revealed) setState(() => _visibleChars++);
      });
    }

    return Stack(
      children: [
        LQCanvas(
          colors: colors,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(LQSpacing.gutter),
              child: Column(
                children: [
                  GuideMascot(guide: guide, size: 56, state: PennyGuideState.idle),
                  const SizedBox(height: LQSpacing.lg),
                  Text('Money Wisdom Letter', style: LQTypography.h2(colors)),
                  const SizedBox(height: LQSpacing.lg),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _revealed = true),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(LQSpacing.xl),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF6EE),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: LQElevation.e2(colors.ink),
                        ),
                        child: SingleChildScrollView(
                          child: Text(
                            shown,
                            style: LQTypography.body(colors).copyWith(
                              fontStyle: FontStyle.italic,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  LQButton(
                    label: 'Add to my bookcase 📚',
                    colors: colors,
                    variant: LQButtonVariant.secondary,
                    expanded: true,
                    onPressed: () => ref.read(lessonSessionProvider.notifier).advanceWisdomLetter(),
                  ),
                  const SizedBox(height: LQSpacing.sm),
                  LQButton(
                    label: 'Continue',
                    colors: colors,
                    expanded: true,
                    onPressed: () => ref.read(lessonSessionProvider.notifier).advanceWisdomLetter(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Shareable brag card — no guilt, Maybe Later prominent (DevPlan).
class BragCardView extends ConsumerWidget {
  const BragCardView({super.key, required this.questLevel, required this.questName});

  final int questLevel;
  final String questName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(lqColorsProvider);
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final name = profile?.displayName ?? 'Explorer';

    return LQCanvas(
      colors: colors,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(LQSpacing.gutter),
          child: Column(
            children: [
              const Spacer(),
              LQCelebrationBurst(colors: colors, active: true),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(LQSpacing.xxl),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colors.brand, colors.brandDeep],
                  ),
                  borderRadius: BorderRadius.circular(LQRadius.card),
                ),
                child: Column(
                  children: [
                    Text(
                      name,
                      style: LQTypography.display(colors).copyWith(color: colors.surface),
                    ),
                    const SizedBox(height: LQSpacing.sm),
                    Text(
                      'Level $questLevel · $questName',
                      style: LQTypography.h3(colors).copyWith(color: colors.gold),
                    ),
                    const SizedBox(height: LQSpacing.md),
                    Text(
                      'I completed a LifeQuest level today!',
                      style: LQTypography.body(colors).copyWith(color: colors.surface),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ).animate().scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
              const Spacer(flex: 2),
              LQButton(
                label: 'Share with someone who loves you 💛',
                colors: colors,
                expanded: true,
                onPressed: () async {
                  await Clipboard.setData(
                    const ClipboardData(
                      text: 'I completed a LifeQuest level today! 🍋',
                    ),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Copied — paste anywhere to share!',
                          style: LQTypography.bodySm(colors).copyWith(
                            color: colors.surface,
                          ),
                        ),
                        backgroundColor: colors.brandDeep,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: LQSpacing.sm),
              LQButton(
                label: 'Maybe later',
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
