import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/lq_theme.dart';
import '../../../core/audio/lq_sound_service.dart';
import '../../../core/haptics/lq_haptics.dart';
import 'concept_game_result.dart';
import 'concept_game_types.dart';
import 'concept_mini_game_player.dart';

/// Free-play mode for a single concept game from the hub.
class ConceptGamePracticeScreen extends ConsumerWidget {
  const ConceptGamePracticeScreen({super.key, required this.gameId});

  final ConceptGameId gameId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(lqColorsProvider);

    return Scaffold(
      body: ConceptMiniGamePlayer(
        gameId: gameId,
        colors: colors,
        onBack: () => context.pop(),
        onFinished: (ConceptGameResult result) {
          if (result.won) {
            LQHaptics.levelUp();
            LQSound.celebrate();
          }
          if (context.mounted) context.pop();
        },
      ),
    );
  }
}
