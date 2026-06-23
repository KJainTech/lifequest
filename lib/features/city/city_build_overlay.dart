import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/haptics/lq_haptics.dart';
import '../../core/tokens/lq_tokens.dart';
import '../../core/tokens/lq_typography.dart';
import '../../design/lq_button.dart';

/// Celebration overlay during tower build sequence.
class CityBuildOverlay extends StatefulWidget {
  const CityBuildOverlay({
    super.key,
    required this.colors,
    required this.towerName,
    required this.onDismiss,
  });

  final LQColors colors;
  final String towerName;
  final VoidCallback onDismiss;

  @override
  State<CityBuildOverlay> createState() => _CityBuildOverlayState();
}

class _CityBuildOverlayState extends State<CityBuildOverlay> {
  @override
  void initState() {
    super.initState();
    LQHaptics.levelUp();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: LQSpacing.gutter,
      right: LQSpacing.gutter,
      bottom: 100,
      child: Material(
        color: widget.colors.surface,
        elevation: 8,
        shadowColor: widget.colors.ink.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(LQRadius.card),
        child: Padding(
          padding: const EdgeInsets.all(LQSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'New tower rising!',
                style: LQTypography.h3(widget.colors),
              ).animate().fadeIn(duration: 300.ms),
              const SizedBox(height: LQSpacing.sm),
              Text(
                widget.towerName,
                style: LQTypography.h2(widget.colors).copyWith(
                  color: widget.colors.gold,
                ),
              ).animate(delay: 150.ms).fadeIn().slideY(begin: 0.2, end: 0),
              const SizedBox(height: LQSpacing.lg),
              Text(
                'Your city grows with every lesson you master.',
                textAlign: TextAlign.center,
                style: LQTypography.bodySm(widget.colors),
              ),
              const SizedBox(height: LQSpacing.xl),
              LQButton(
                label: 'Continue exploring',
                colors: widget.colors,
                expanded: true,
                onPressed: widget.onDismiss,
              ),
            ],
          ),
        ),
      ).animate().fadeIn().slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic),
    );
  }
}
