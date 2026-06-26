import 'package:flutter/material.dart';

import '../../../core/tokens/lq_tokens.dart';
import 'concept_game_result.dart';
import 'concept_game_types.dart';
import 'games/coin_jars_game.dart';
import 'games/deal_pick_game.dart';
import 'games/jar_fill_game.dart';
import 'games/needs_wants_tap_game.dart';

/// Renders the correct concept mini-game (Lemon City handled separately).
class ConceptMiniGamePlayer extends StatelessWidget {
  const ConceptMiniGamePlayer({
    super.key,
    required this.gameId,
    required this.colors,
    required this.onFinished,
    this.onBack,
  });

  final ConceptGameId gameId;
  final LQColors colors;
  final ValueChanged<ConceptGameResult> onFinished;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return switch (gameId) {
      ConceptGameId.needsWants => NeedsWantsTapGame(
          colors: colors,
          onFinished: onFinished,
          onBack: onBack,
        ),
      ConceptGameId.jarFill => JarFillGame(
          colors: colors,
          onFinished: onFinished,
          onBack: onBack,
        ),
      ConceptGameId.coinJars => CoinJarsGame(
          colors: colors,
          onFinished: onFinished,
          onBack: onBack,
        ),
      ConceptGameId.dealPick => DealPickGame(
          colors: colors,
          onFinished: onFinished,
          onBack: onBack,
        ),
      ConceptGameId.lemonCity => const SizedBox.shrink(),
    };
  }
}
