import 'package:flutter/material.dart';

import '../../core/tokens/lq_tokens.dart';
import '../../core/tokens/lq_typography.dart';
import 'city_buildings.dart';
import 'city_hero_video.dart';

/// City map — reference video fills the screen; progress shown in HUD overlay.
class CityMapWidget extends StatelessWidget {
  const CityMapWidget({
    super.key,
    required this.colors,
    required this.snapshot,
    required this.onPlotTap,
    this.highlightLessonId,
    this.autoFocusNext = false,
  });

  final LQColors colors;
  final CityProgressSnapshot snapshot;
  final ValueChanged<CityPlot> onPlotTap;
  final String? highlightLessonId;
  final bool autoFocusNext;

  @override
  Widget build(BuildContext context) {
    final next = snapshot.nextPlot;

    return ClipRRect(
      borderRadius: BorderRadius.circular(LQRadius.card),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CityHeroVideo(
            progress: snapshot.overallProgress,
            snapshot: snapshot,
          ),
          if (next != null)
            Positioned(
              top: LQSpacing.md,
              left: LQSpacing.md,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onPlotTap(next),
                  borderRadius: BorderRadius.circular(LQRadius.pill),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(LQRadius.pill),
                      border: Border.all(
                        color: colors.brand.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(next.building.emoji,
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          'Tap to build',
                          style: LQTypography.caption(colors).copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.brandDeep,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Compact preview — poster image + progress bar.
class CityMapPreview extends StatelessWidget {
  const CityMapPreview({
    super.key,
    required this.colors,
    required this.snapshot,
  });

  final LQColors colors;
  final CityProgressSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final pct = snapshot.overallProgress;
    return ClipRRect(
      borderRadius: BorderRadius.circular(LQRadius.control),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/img/city/city_poster.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFFEEF1F6),
              child: Icon(Icons.location_city, color: colors.brand, size: 40),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 4,
              backgroundColor: Colors.white.withValues(alpha: 0.4),
              color: colors.brand,
            ),
          ),
        ],
      ),
    );
  }
}
