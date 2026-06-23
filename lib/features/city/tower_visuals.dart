import 'package:flutter/material.dart';

import '../../core/tokens/lq_tokens.dart';

/// Visual definition for a city tower — maps lesson type to art style.
class TowerVisual {
  const TowerVisual({
    required this.primary,
    required this.accent,
    required this.heightFactor,
    required this.motif,
  });

  final Color primary;
  final Color accent;
  final double heightFactor;
  final TowerMotif motif;
}

enum TowerMotif { earning, foundation, skill }

TowerVisual towerVisualForType(String type, LQColors colors) {
  return switch (type) {
    'lesson_6' => TowerVisual(
        primary: colors.gold,
        accent: colors.brand,
        heightFactor: 1.0,
        motif: TowerMotif.earning,
      ),
    'lesson_1' => TowerVisual(
        primary: colors.blue,
        accent: colors.accentMint,
        heightFactor: 0.85,
        motif: TowerMotif.foundation,
      ),
    _ => TowerVisual(
        primary: colors.brand,
        accent: colors.accentViolet,
        heightFactor: 0.75,
        motif: TowerMotif.skill,
      ),
  };
}
