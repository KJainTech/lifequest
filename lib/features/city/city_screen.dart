import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/bootstrap/firebase_providers.dart';
import '../../app/theme/lq_theme.dart';
import '../../core/audio/lq_sound_service.dart';
import '../../core/tokens/lq_tokens.dart';
import '../../core/tokens/lq_typography.dart';
import '../../data/models/lq_models.dart';
import '../../data/providers/app_providers.dart';
import '../../design/lq_button.dart';
import '../../design/lq_immersive_scene.dart';
import '../../features/onboarding/auth_service.dart';
import 'city_build_overlay.dart';
import 'city_buildings.dart';
import 'city_hud.dart';
import 'city_map_widget.dart';
import 'city_plot_sheet.dart';
import 'city_providers.dart';

/// Lemon City — isometric progress map; each lesson builds a new building.
class CityScreen extends ConsumerStatefulWidget {
  const CityScreen({super.key});

  @override
  ConsumerState<CityScreen> createState() => _CityScreenState();
}

class _CityScreenState extends ConsumerState<CityScreen> {
  CityPlot? _selectedPlot;
  bool _showCelebration = false;
  String? _celebrationName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pending = ref.read(pendingCityCelebrationProvider);
      if (pending != null && mounted) {
        setState(() {
          _showCelebration = true;
          _celebrationName = pending;
        });
      }
    });
  }

  void _dismissCelebration() {
    ref.read(pendingCityCelebrationProvider.notifier).state = null;
    setState(() {
      _showCelebration = false;
      _celebrationName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(lqColorsProvider);
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final stats = ref.watch(userStatsProvider).valueOrNull ?? UserStats.empty;
    final towersAsync = ref.watch(userTowersProvider);
    final lessonsAsync = ref.watch(userLessonsProvider);
    final celebrate = ref.watch(pendingCityCelebrationProvider);

    return LQImmersiveScene(
      colors: colors,
      intensity: 0.7,
      child: towersAsync.when(
        loading: () => _loading(colors),
        error: (e, _) => _error(colors, e),
        data: (towers) {
          return lessonsAsync.when(
            loading: () => _loading(colors),
            error: (e, _) => _error(colors, e),
            data: (lessons) {
              final highlight = _highlightLessonId(towers, celebrate);
              final snapshot = buildCityProgress(
                lessonProgress: lessons,
                towers: towers,
                profile: profile,
                highlightLessonId: highlight,
              );

              if (celebrate != null && !_showCelebration) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _showCelebration = true;
                      _celebrationName = celebrate;
                    });
                    LQSound.celebrate();
                  }
                });
              }

              return _buildMap(
                context,
                colors,
                snapshot,
                snapshot.builtCount == 0,
                highlightLessonId: highlight,
                xp: stats.xp,
                coins: stats.coins,
              );
            },
          );
        },
      ),
    );
  }

  Widget _loading(LQColors colors) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: colors.brand),
          const SizedBox(height: LQSpacing.lg),
          Text('Building your city…', style: LQTypography.bodySm(colors)),
        ],
      ),
    );
  }

  Widget _error(LQColors colors, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(LQSpacing.gutter),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Could not load Lemon City', style: LQTypography.h3(colors)),
            const SizedBox(height: LQSpacing.sm),
            Text('$error', style: LQTypography.bodySm(colors)),
            const SizedBox(height: LQSpacing.xl),
            LQButton(
              label: 'Try again',
              colors: colors,
              onPressed: () {
                ref.invalidate(userTowersProvider);
                ref.invalidate(userLessonsProvider);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMap(
    BuildContext context,
    LQColors colors,
    CityProgressSnapshot snapshot,
    bool isEmpty, {
    String? highlightLessonId,
    int xp = 0,
    int coins = 0,
  }) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  LQSpacing.gutter,
                  52,
                  LQSpacing.gutter,
                  LQSpacing.md,
                ),
                child: CityHud(
                  colors: colors,
                  snapshot: snapshot,
                  xp: xp,
                  coins: coins,
                  onDistrictTap: (district) {
                    final plot = snapshot.plots.firstWhere(
                      (p) => p.building.districtIndex == district,
                      orElse: () => snapshot.nextPlot ?? snapshot.plots.first,
                    );
                    setState(() => _selectedPlot = plot);
                  },
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  LQSpacing.gutter,
                  0,
                  LQSpacing.gutter,
                  LQSpacing.sm,
                ),
                child: CityMapWidget(
                  colors: colors,
                  snapshot: snapshot,
                  highlightLessonId: highlightLessonId,
                  onPlotTap: (plot) {
                    if (plot.status == CityPlotStatus.locked) return;
                    setState(() => _selectedPlot = plot);
                  },
                ),
              ),
            ),
          ],
        ),
        if (isEmpty)
          Positioned(
            left: LQSpacing.gutter,
            right: LQSpacing.gutter,
            bottom: 100,
            child: _EmptyCityCard(
              colors: colors,
              nextPlot: snapshot.nextPlot,
            ),
          ),
        if (_selectedPlot != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CityPlotSheet(
              colors: colors,
              plot: _selectedPlot!,
              onClose: () => setState(() => _selectedPlot = null),
            ),
          ),
        if (_showCelebration && _celebrationName != null)
          CityBuildOverlay(
            colors: colors,
            buildingName: _celebrationName!,
            onDismiss: _dismissCelebration,
          ),
        Positioned(
          top: MediaQuery.paddingOf(context).top + 4,
          left: 4,
          right: 4,
          child: Row(
            children: [
              if (context.canPop())
                _CityNavButton(
                  colors: colors,
                  icon: Icons.arrow_back_ios_new,
                  tooltip: 'Back',
                  onPressed: () => context.pop(),
                )
              else
                const SizedBox(width: 48),
              const Spacer(),
              _CityNavButton(
                colors: colors,
                icon: Icons.cottage_outlined,
                tooltip: 'Home',
                onPressed: () => context.go('/home'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CityNavButton extends StatelessWidget {
  const _CityNavButton({
    required this.colors,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final LQColors colors;
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colors.surface.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: colors.ink.withValues(alpha: 0.12),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, color: colors.ink, size: 20),
      ),
    );
  }
}

String? _highlightLessonId(List<Tower> towers, String? celebrate) {
  if (celebrate == null) return null;
  for (final t in towers) {
    if (t.name == celebrate) return t.type;
  }
  for (final b in kCityBuildings) {
    if (b.name == celebrate) return b.lessonId;
  }
  return null;
}

class _EmptyCityCard extends StatelessWidget {
  const _EmptyCityCard({required this.colors, this.nextPlot});

  final LQColors colors;
  final CityPlot? nextPlot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LQSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(LQRadius.card),
        boxShadow: LQElevation.e2(colors.ink),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Your land is ready!', style: LQTypography.h3(colors)),
          const SizedBox(height: LQSpacing.xs),
          Text(
            nextPlot != null
                ? 'Tap the glowing plot or start a lesson to build ${nextPlot!.building.name}.'
                : 'Complete a lesson to raise your first building!',
            style: LQTypography.bodySm(colors),
          ),
          const SizedBox(height: LQSpacing.lg),
          LQButton(
            label: nextPlot != null ? 'Build ${nextPlot!.building.name}' : 'Start learning',
            colors: colors,
            expanded: true,
            onPressed: () {
              final lessonId = nextPlot?.building.lessonId ?? 'lesson_1';
              context.go('/lesson/$lessonId');
            },
          ),
        ],
      ),
    );
  }
}
