import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../core/tokens/lq_tokens.dart';
import '../../data/models/lq_models.dart';
import 'components/city_background.dart';
import 'components/tower_component.dart';
import 'tower_visuals.dart';

/// LifeQuest city scene — rendered skyline with tower build animations.
class LifeQuestCityGame extends FlameGame {
  LifeQuestCityGame({
    required this.colors,
    required List<Tower> towers,
    this.celebrateTowerName,
    this.onBuildAnimationComplete,
  }) : _towers = List.of(towers);

  final LQColors colors;
  List<Tower> _towers;
  final String? celebrateTowerName;
  final VoidCallback? onBuildAnimationComplete;

  CityBackground? _background;
  CityGround? _ground;
  final List<TowerComponent> _towerComponents = [];
  bool _animationStarted = false;
  bool _animationDone = false;

  static const _maxSlots = 8;
  static const _groundRatio = 0.22;

  double get groundY => size.y * (1 - _groundRatio);

  @override
  Color backgroundColor() => colors.canvasStart;

  @override
  Future<void> onLoad() async {
    _background = CityBackground(
      skyTop: colors.canvasEnd,
      skyBottom: colors.canvasStart,
    )..size = size;
    add(_background!);

    _ground = CityGround(
      groundColor: colors.surface.withValues(alpha: 0.85),
      lineColor: colors.ink,
    )..size = size;
    add(_ground!);

    add(CityGrainOverlay()..size = size);
    _rebuildTowers();
    _tryStartCelebration();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _background?.size = size;
    _ground?.size = size;
    for (final g in children.whereType<CityGrainOverlay>()) {
      g.size = size;
    }
    _layoutTowers();
    _tryStartCelebration();
  }

  void updateTowers(List<Tower> towers) {
    _towers = List.of(towers);
    _rebuildTowers();
    _tryStartCelebration();
  }

  void _rebuildTowers() {
    for (final c in _towerComponents) {
      c.removeFromParent();
    }
    _towerComponents.clear();

    if (_towers.isEmpty || size.x <= 0) return;

    final slotW = size.x / _maxSlots.clamp(1, _towers.length + 1);
    final towerH = size.y * 0.55;

    for (var i = 0; i < _towers.length && i < _maxSlots; i++) {
      final tower = _towers[i];
      final visual = towerVisualForType(tower.type, colors);
      final component = TowerComponent(
        tower: tower,
        visual: visual,
        slotSize: Vector2(slotW, towerH),
        groundY: groundY,
      )
        ..position = Vector2(
          slotW * (i + 0.5) +
              (size.x - slotW * _towers.length.clamp(1, _maxSlots)) / 2,
          groundY,
        );

      _towerComponents.add(component);
      add(component);
    }

    _layoutTowers();
  }

  void _layoutTowers() {
    if (_towerComponents.isEmpty || size.x <= 0) return;
    final count = _towerComponents.length;
    final slotW = size.x / _maxSlots.clamp(1, count);
    final offsetX = (size.x - slotW * count) / 2;
    for (var i = 0; i < count; i++) {
      _towerComponents[i].position = Vector2(
        offsetX + slotW * (i + 0.5),
        groundY,
      );
    }
  }

  void _tryStartCelebration() {
    if (_animationDone ||
        _animationStarted ||
        celebrateTowerName == null ||
        _towerComponents.isEmpty) {
      return;
    }
    for (final c in _towerComponents) {
      if (c.tower.name == celebrateTowerName) {
        c.startBuildAnimation();
        _animationStarted = true;
        return;
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_animationStarted || _animationDone || celebrateTowerName == null) {
      return;
    }
    final targets =
        _towerComponents.where((c) => c.tower.name == celebrateTowerName);
    if (targets.isEmpty) return;
    if (targets.every((c) => !c.isBuilding)) {
      _animationDone = true;
      onBuildAnimationComplete?.call();
    }
  }
}
