import 'package:flutter/material.dart';

import '../../../../core/tokens/lq_tokens.dart';
import '../../../../core/tokens/lq_typography.dart';
import '../../../../design/lq_button.dart';
import '../concept_game_result.dart';
import '../concept_game_types.dart';

class ConceptGameScaffold extends StatelessWidget {
  const ConceptGameScaffold({
    super.key,
    required this.info,
    required this.colors,
    required this.score,
    required this.total,
    required this.child,
    this.onBack,
  });

  final ConceptGameInfo info;
  final LQColors colors;
  final int score;
  final int total;
  final Widget child;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final accent = Color(info.accent);
    final surface = Color(info.surface);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [surface, colors.canvas],
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                LQSpacing.sm,
                LQSpacing.xs,
                LQSpacing.gutter,
                0,
              ),
              child: Row(
                children: [
                  if (onBack != null)
                    IconButton(
                      onPressed: onBack,
                      icon: Icon(Icons.arrow_back_rounded, color: colors.ink),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          info.title,
                          style: LQTypography.h3(colors).copyWith(color: accent),
                        ),
                        Text(info.conceptLabel, style: LQTypography.caption(colors)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: LQSpacing.md,
                      vertical: LQSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(LQRadius.pill),
                      border: Border.all(color: accent.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      '$score / $total',
                      style: LQTypography.label(colors).copyWith(color: accent),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: LQSpacing.gutter,
                vertical: LQSpacing.sm,
              ),
              child: Text(
                info.howToPlay,
                style: LQTypography.bodySm(colors),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class ConceptGameFinishPanel extends StatelessWidget {
  const ConceptGameFinishPanel({
    super.key,
    required this.colors,
    required this.info,
    required this.result,
    required this.onContinue,
  });

  final LQColors colors;
  final ConceptGameInfo info;
  final ConceptGameResult result;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final accent = Color(info.accent);
    return Padding(
      padding: const EdgeInsets.all(LQSpacing.gutter),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            result.won ? Icons.emoji_events_rounded : Icons.replay_rounded,
            size: 56,
            color: result.won ? colors.gold : accent,
          ),
          const SizedBox(height: LQSpacing.lg),
          Text(
            result.won ? 'Nice work!' : 'Try again',
            style: LQTypography.h2(colors),
          ),
          const SizedBox(height: LQSpacing.sm),
          Text(
            result.message,
            style: LQTypography.bodySm(colors),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: LQSpacing.xxl),
          LQButton(
            label: 'Continue',
            colors: colors,
            expanded: true,
            onPressed: onContinue,
          ),
        ],
      ),
    );
  }
}
