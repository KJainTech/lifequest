import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/lq_theme.dart';
import '../../core/tokens/lq_tokens.dart';
import '../../core/tokens/lq_typography.dart';
import '../../data/models/lq_models.dart';
import '../../design/lq_button.dart';
import '../../design/lq_canvas.dart';
import '../../design/lq_card.dart';
import 'city_build_overlay.dart';
import 'city_providers.dart';
import 'lifequest_city_game.dart';

/// Full city view per §5.12 — Flame skyline + tower build sequence.
class CityScreen extends ConsumerStatefulWidget {
  const CityScreen({super.key});

  @override
  ConsumerState<CityScreen> createState() => _CityScreenState();
}

class _CityScreenState extends ConsumerState<CityScreen> {
  LifeQuestCityGame? _game;
  bool _showOverlay = false;
  String? _overlayTowerName;

  void _ensureGame(List<Tower> towers, LQColors colors) {
    final celebrate = ref.read(pendingCityCelebrationProvider);
    if (_game == null) {
      _game = LifeQuestCityGame(
        colors: colors,
        towers: towers,
        celebrateTowerName: celebrate,
        onBuildAnimationComplete: () {
          if (celebrate != null && mounted) {
            setState(() {
              _showOverlay = true;
              _overlayTowerName = celebrate;
            });
          }
        },
      );
    } else {
      _game!.updateTowers(towers);
    }
  }

  void _dismissCelebration() {
    ref.read(pendingCityCelebrationProvider.notifier).state = null;
    setState(() {
      _showOverlay = false;
      _overlayTowerName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(lqColorsProvider);
    final towersAsync = ref.watch(userTowersProvider);

    ref.listen<AsyncValue<List<Tower>>>(userTowersProvider, (prev, next) {
      final towers = next.valueOrNull;
      if (towers != null && _game != null) {
        _game!.updateTowers(towers);
      }
    });

    return LQCanvas(
      colors: colors,
      child: towersAsync.when(
        loading: () => _buildLoading(colors),
        error: (e, _) => _buildError(colors, e),
        data: (towers) {
          _ensureGame(towers, colors);
          return _buildCity(context, colors, towers);
        },
      ),
    );
  }

  Widget _buildLoading(LQColors colors) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: colors.brand),
          const SizedBox(height: LQSpacing.lg),
          Text('Loading your city…', style: LQTypography.bodySm(colors)),
        ],
      ),
    );
  }

  Widget _buildError(LQColors colors, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(LQSpacing.gutter),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Could not load your city', style: LQTypography.h3(colors)),
            const SizedBox(height: LQSpacing.sm),
            Text('$error', style: LQTypography.bodySm(colors)),
            const SizedBox(height: LQSpacing.xl),
            LQButton(
              label: 'Try again',
              colors: colors,
              onPressed: () => ref.invalidate(userTowersProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCity(BuildContext context, LQColors colors, List<Tower> towers) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (_game != null) GameWidget(game: _game!),
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(LQSpacing.gutter),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your City', style: LQTypography.h2(colors)),
                    Text(
                      towers.isEmpty
                          ? 'Complete lessons to build towers'
                          : '${towers.length} ${towers.length == 1 ? 'tower' : 'towers'} built',
                      style: LQTypography.bodySm(colors),
                    ),
                  ],
                ),
              ),
              if (towers.isEmpty) ...[
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(LQSpacing.gutter),
                  child: LQCard(
                    colors: colors,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Your skyline awaits', style: LQTypography.h3(colors)),
                        const SizedBox(height: LQSpacing.sm),
                        Text(
                          'Finish a lesson to raise your first tower. '
                          'Each concept you master adds to your city.',
                          style: LQTypography.bodySm(colors),
                        ),
                        const SizedBox(height: LQSpacing.xl),
                        LQButton(
                          label: 'Start a lesson',
                          colors: colors,
                          expanded: true,
                          onPressed: () => context.go('/lesson/lesson_6'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 80),
              ] else ...[
                const Spacer(),
                _TowerShelf(colors: colors, towers: towers),
                const SizedBox(height: 88),
              ],
            ],
          ),
        ),
        if (_showOverlay && _overlayTowerName != null)
          CityBuildOverlay(
            colors: colors,
            towerName: _overlayTowerName!,
            onDismiss: _dismissCelebration,
          ),
      ],
    );
  }
}

class _TowerShelf extends StatelessWidget {
  const _TowerShelf({required this.colors, required this.towers});

  final LQColors colors;
  final List<Tower> towers;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: LQSpacing.gutter),
        itemCount: towers.length,
        separatorBuilder: (_, __) => const SizedBox(width: LQSpacing.sm),
        itemBuilder: (context, i) {
          final t = towers[i];
          return Container(
            width: 140,
            padding: const EdgeInsets.all(LQSpacing.md),
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(LQRadius.control),
              boxShadow: LQElevation.e1(colors.ink),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  t.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LQTypography.label(colors),
                ),
                Text(
                  _formatDate(t.builtAt),
                  style: LQTypography.micro(colors),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(String iso) {
    if (iso.length >= 10) return iso.substring(0, 10);
    return iso;
  }
}
