import 'package:flutter/material.dart';

import '../core/tokens/lq_tokens.dart';
import '../core/tokens/lq_typography.dart';

/// Guide speech card per §5.8
class SpeechCard extends StatelessWidget {
  const SpeechCard({
    super.key,
    required this.colors,
    required this.guideName,
    required this.text,
    this.trailing,
  });

  final LQColors colors;
  final String guideName;
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(LQSpacing.xl),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(LQRadius.card),
        boxShadow: LQElevation.e1(colors.ink),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            guideName,
            style: LQTypography.caption(colors).copyWith(
              color: colors.brand,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: LQSpacing.md),
          Text(
            text.replaceAll('**', ''),
            style: LQTypography.body(colors),
          ),
          if (trailing != null) ...[
            const SizedBox(height: LQSpacing.lg),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// Segmented read progress bar
class SegmentedProgressBar extends StatelessWidget {
  const SegmentedProgressBar({
    super.key,
    required this.colors,
    required this.total,
    required this.current,
  });

  final LQColors colors;
  final int total;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final filled = i <= current;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < total - 1 ? LQSpacing.xs : 0),
            height: 4,
            decoration: BoxDecoration(
              color: filled ? colors.brand : colors.canvasEnd,
              borderRadius: BorderRadius.circular(LQRadius.pill),
            ),
          ),
        );
      }),
    );
  }
}
