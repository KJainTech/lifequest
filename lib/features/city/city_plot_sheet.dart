import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/tokens/lq_tokens.dart';
import '../../core/tokens/lq_typography.dart';
import '../../design/lq_button.dart';
import '../../design/lq_card.dart';
import 'city_buildings.dart';

/// Bottom sheet when a kid taps a city plot.
class CityPlotSheet extends StatelessWidget {
  const CityPlotSheet({
    super.key,
    required this.colors,
    required this.plot,
    required this.onClose,
  });

  final LQColors colors;
  final CityPlot plot;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = kCityDistrictThemes[plot.building.districtIndex];
    final meta = plot.building.meta;

    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.all(LQSpacing.gutter),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(LQRadius.card),
          boxShadow: LQElevation.e3(colors.ink),
        ),
        child: Padding(
          padding: const EdgeInsets.all(LQSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(plot.building.emoji, style: const TextStyle(fontSize: 36)),
                  const SizedBox(width: LQSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plot.building.name,
                          style: LQTypography.h2(colors),
                        ),
                        Text(
                          theme.name,
                          style: LQTypography.caption(colors).copyWith(
                            color: theme.accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onClose,
                    icon: Icon(Icons.close_rounded, color: colors.inkSoft),
                  ),
                ],
              ),
              const SizedBox(height: LQSpacing.md),
              _StatusChip(colors: colors, plot: plot, theme: theme),
              if (meta != null) ...[
                const SizedBox(height: LQSpacing.sm),
                Text(meta.title, style: LQTypography.h3(colors)),
                Text(meta.subtitle, style: LQTypography.bodySm(colors)),
              ],
              const SizedBox(height: LQSpacing.xl),
              if (plot.isBuilt)
                LQButton(
                  label: 'Replay lesson',
                  colors: colors,
                  variant: LQButtonVariant.secondary,
                  expanded: true,
                  onPressed: () {
                    onClose();
                    context.push('/lesson/${plot.building.lessonId}');
                  },
                )
              else if (plot.status == CityPlotStatus.locked)
                LQCard(
                  colors: colors,
                  child: Text(
                    'Complete earlier lessons to unlock this building.',
                    style: LQTypography.bodySm(colors),
                  ),
                )
              else
                LQButton(
                  label: plot.status == CityPlotStatus.inProgress
                      ? 'Continue building'
                      : 'Start & build',
                  colors: colors,
                  expanded: true,
                  onPressed: () {
                    onClose();
                    context.push('/lesson/${plot.building.lessonId}');
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.colors,
    required this.plot,
    required this.theme,
  });

  final LQColors colors;
  final CityPlot plot;
  final CityDistrictTheme theme;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (plot.status) {
      CityPlotStatus.built => ('Built', theme.accent.withValues(alpha: 0.15), theme.accent),
      CityPlotStatus.next => ('Ready to build', colors.gold.withValues(alpha: 0.2), colors.gold),
      CityPlotStatus.inProgress => ('Under construction', colors.blue.withValues(alpha: 0.15), colors.blue),
      CityPlotStatus.locked => ('Locked', colors.inkSoft.withValues(alpha: 0.12), colors.inkSoft),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LQSpacing.md,
        vertical: LQSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(LQRadius.chip),
      ),
      child: Text(
        label,
        style: LQTypography.caption(colors).copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
