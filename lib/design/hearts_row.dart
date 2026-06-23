import 'package:flutter/material.dart';

import '../core/tokens/lq_tokens.dart';

/// Hearts display for quiz phase per §5.9
class HeartsRow extends StatelessWidget {
  const HeartsRow({
    super.key,
    required this.colors,
    required this.hearts,
    this.maxHearts = 3,
  });

  final LQColors colors;
  final int hearts;
  final int maxHearts;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxHearts, (i) {
        final filled = i < hearts;
        return Padding(
          padding: const EdgeInsets.only(right: LQSpacing.xs),
          child: Icon(
            filled ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: filled ? colors.coral : colors.inkSoft.withValues(alpha: 0.35),
            size: 28,
            semanticLabel: filled ? 'Heart remaining' : 'Heart lost',
          ),
        );
      }),
    );
  }
}
