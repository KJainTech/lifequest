import 'package:flutter/material.dart';

import '../../core/tokens/lq_tokens.dart';
import 'city_buildings.dart';
import 'city_hero_video_io.dart'
    if (dart.library.html) 'city_hero_video_web.dart' as platform;

/// Full-screen hero city — your reference video is the main visual.
class CityHeroVideo extends StatelessWidget {
  const CityHeroVideo({
    super.key,
    required this.progress,
    this.snapshot,
  });

  final double progress;
  final CityProgressSnapshot? snapshot;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        platform.buildPlatformCityHero(progress: progress),
        if (snapshot?.nextPlot != null)
          Positioned(
            left: LQSpacing.md,
            right: LQSpacing.md,
            bottom: LQSpacing.md,
            child: _NextBuildPill(
              plot: snapshot!.nextPlot!,
              built: snapshot!.builtCount,
              total: snapshot!.plots.length,
            ),
          ),
      ],
    );
  }
}

class _NextBuildPill extends StatelessWidget {
  const _NextBuildPill({
    required this.plot,
    required this.built,
    required this.total,
  });

  final CityPlot plot;
  final int built;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = kCityDistrictThemes[plot.building.districtIndex];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(LQRadius.pill),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(plot.building.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Next: ${plot.building.name}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A2E28),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$built / $total buildings · ${theme.name}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: theme.accent,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: theme.accent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.accent.withValues(alpha: 0.6),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
