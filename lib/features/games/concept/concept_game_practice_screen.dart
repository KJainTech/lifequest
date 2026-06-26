import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/lq_theme.dart';
import '../../../core/audio/lq_sound_service.dart';
import '../../../core/haptics/lq_haptics.dart';
import 'concept_game_navigation.dart';
import 'concept_game_result.dart';
import 'concept_game_types.dart';
import 'concept_mini_game_player.dart';
import 'games/lemon_city_practice_widget.dart';

/// Free-play mode for a single concept game — works from direct URLs.
class ConceptGamePracticeScreen extends ConsumerWidget {
  const ConceptGamePracticeScreen({super.key, required this.gameId});

  final ConceptGameId gameId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(lqColorsProvider);

    if (gameId == ConceptGameId.lemonCity) {
      return Scaffold(
        body: LemonCityPracticeWidget(
          colors: colors,
          onBack: () => leaveConceptGame(context),
        ),
      );
    }

    return Scaffold(
      body: ConceptMiniGamePlayer(
        gameId: gameId,
        colors: colors,
        onBack: () => leaveConceptGame(context),
        onFinished: (ConceptGameResult result) {
          if (result.won) {
            LQHaptics.levelUp();
            LQSound.celebrate();
          }
          if (context.mounted) leaveConceptGame(context);
        },
      ),
    );
  }
}
