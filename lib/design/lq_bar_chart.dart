import 'package:flutter/material.dart';

import '../core/tokens/lq_tokens.dart';
import '../core/tokens/lq_typography.dart';

/// Weekly forecast bar chart per §5.13
class LQBarChart extends StatelessWidget {
  const LQBarChart({
    super.key,
    required this.colors,
    required this.data,
    this.highlightIndex = 2,
  });

  final LQColors colors;
  final List<double> data;
  final int highlightIndex;

  static const _labels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  @override
  Widget build(BuildContext context) {
    final maxVal = data.reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 160,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(data.length, (i) {
          final isHighlight = i == highlightIndex;
          final heightFactor = data[i] / maxVal;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isHighlight)
                    Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colors.brand,
                        borderRadius: BorderRadius.circular(LQRadius.chip),
                      ),
                      child: Text(
                        'AED ${data[i].round()}',
                        style: LQTypography.microLabel(colors, color: Colors.white),
                      ),
                    ),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: heightFactor),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return FractionallySizedBox(
                        heightFactor: value.clamp(0.08, 1),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: isHighlight
                                  ? [colors.brand, colors.brandDeep]
                                  : [
                                      colors.brand.withValues(alpha: 0.4),
                                      colors.brand.withValues(alpha: 0.2),
                                    ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _labels[i],
                    style: LQTypography.microLabel(
                      colors,
                      color: isHighlight ? colors.brand : colors.inkSoft,
                    ).copyWith(
                      fontWeight:
                          isHighlight ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
