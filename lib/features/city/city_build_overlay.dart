import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/audio/lq_sound_service.dart';
import '../../core/haptics/lq_haptics.dart';
import '../../core/tokens/lq_tokens.dart';
import '../../core/tokens/lq_typography.dart';
import '../../design/lq_button.dart';
import '../../design/lq_celebration.dart';

/// Celebration when a new building rises in Lemon City.
class CityBuildOverlay extends StatefulWidget {
  const CityBuildOverlay({
    super.key,
    required this.colors,
    required this.buildingName,
    required this.onDismiss,
  });

  final LQColors colors;
  final String buildingName;
  final VoidCallback onDismiss;

  @override
  State<CityBuildOverlay> createState() => _CityBuildOverlayState();
}

class _CityBuildOverlayState extends State<CityBuildOverlay> {
  @override
  void initState() {
    super.initState();
    LQHaptics.levelUp();
    LQSound.build();
    Future.delayed(const Duration(milliseconds: 400), () => LQSound.celebrate());
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        LQCelebrationBurst(colors: widget.colors, active: true),
        Positioned(
          left: LQSpacing.gutter,
          right: LQSpacing.gutter,
          bottom: 120,
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
                  Text('🏗️', style: const TextStyle(fontSize: 40))
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(
                        begin: const Offset(1, 1),
                        end: const Offset(1.08, 1.08),
                        duration: 800.ms,
                      ),
                  const SizedBox(height: LQSpacing.sm),
                  Text(
                    'New building!',
                    style: LQTypography.h3(widget.colors),
                  ).animate().fadeIn(duration: 300.ms),
                  const SizedBox(height: LQSpacing.sm),
                  Text(
                    widget.buildingName,
                    style: LQTypography.h2(widget.colors).copyWith(
                      color: widget.colors.gold,
                    ),
                  ).animate(delay: 150.ms).fadeIn().slideY(begin: 0.2, end: 0),
                  const SizedBox(height: LQSpacing.lg),
                  Text(
                    'Lemon City grows every time you learn. Tap plots to explore!',
                    textAlign: TextAlign.center,
                    style: LQTypography.bodySm(widget.colors),
                  ),
                  const SizedBox(height: LQSpacing.xl),
                  LQButton(
                    label: 'Explore my city',
                    colors: widget.colors,
                    expanded: true,
                    onPressed: widget.onDismiss,
                  ),
                ],
              ),
            ),
          ).animate().fadeIn().slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic),
        ),
      ],
    );
  }
}
