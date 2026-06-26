import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/bootstrap/firebase_providers.dart';
import '../../../app/theme/lq_theme.dart';
import '../../../core/tokens/lq_tokens.dart';
import '../../../core/tokens/lq_typography.dart';
import '../../../data/content/concept_skills.dart';
import '../../../data/content/lesson_catalog.dart';
import '../../../data/models/lesson_content.dart';
import '../../../data/repositories/content_repository.dart';
import '../../../design/guide_mascot.dart';
import '../../../design/lq_canvas.dart';
import '../../../design/penny_mascot.dart';
import '../../../features/onboarding/auth_service.dart';
import '../../learn/lesson_session.dart';
import '../concept/concept_game_result.dart';
import '../concept/concept_game_types.dart';
import '../concept/concept_mini_game_player.dart';
import 'lemon_city_game.dart';

/// GAME phase — Lemon City wrapper per §5.10
class GamePhaseView extends ConsumerStatefulWidget {
  const GamePhaseView({super.key});

  @override
  ConsumerState<GamePhaseView> createState() => _GamePhaseViewState();
}

class _GamePhaseViewState extends ConsumerState<GamePhaseView> {
  LemonCityGame? _game;
  bool _submitting = false;
  String? _guideMessage;

  @override
  void dispose() {
    _game?.disposeGame();
    super.dispose();
  }

  Future<void> _onConceptGameFinished(ConceptGameResult result) async {
    if (_submitting) return;
    setState(() {
      _submitting = true;
      _guideMessage = result.message;
    });

    try {
      final session = ref.read(lessonSessionProvider)!;
      final stats = ref.read(userStatsProvider).valueOrNull;
      final difficulty = gameDifficultyForConceptSkills(
        stats?.conceptSkills ?? const {},
        session.lessonId,
      );
      await ref.read(cloudFunctionsProvider).submitGamePlay(
            lessonId: session.lessonId,
            profit: result.profit,
            revenue: result.revenue,
            cost: result.cost,
            won: result.won,
            difficulty: difficulty,
          );
    } catch (_) {}

    if (!mounted) return;
    ref.read(lessonSessionProvider.notifier).setGameResult(
          won: result.won,
          profit: result.profit,
          revenue: result.revenue,
          cost: result.cost,
        );
    setState(() => _submitting = false);
  }

  Future<void> _onGameFinished(LemonCityResult result) async {
    if (_submitting) return;
    setState(() {
      _submitting = true;
      _guideMessage = result.won
          ? 'You made a profit! Revenue AED ${result.revenue.toStringAsFixed(0)} minus cost AED ${result.cost.toStringAsFixed(0)} = AED ${result.profit.toStringAsFixed(0)}.'
          : result.price <= result.unitCost
              ? 'Your price was below cost — you lost on every cup. Try setting price above AED ${result.unitCost.toStringAsFixed(0)}.'
              : 'You sold cups but did not cover costs. Adjust price or serve more customers.';
    });

    try {
      final session = ref.read(lessonSessionProvider)!;
      final stats = ref.read(userStatsProvider).valueOrNull;
      final difficulty = gameDifficultyForConceptSkills(
        stats?.conceptSkills ?? const {},
        session.lessonId,
      );
      await ref.read(cloudFunctionsProvider).submitGamePlay(
            lessonId: session.lessonId,
            profit: result.profit,
            revenue: result.revenue,
            cost: result.cost,
            won: result.won,
            difficulty: difficulty,
          );
    } catch (_) {
      // Game result still counts — server sync is best-effort.
    }

    if (!mounted) return;
    ref.read(lessonSessionProvider.notifier).setGameResult(
          won: result.won,
          profit: result.profit,
          revenue: result.revenue,
          cost: result.cost,
        );
    setState(() => _submitting = false);
  }

  void _initGame(LemonCityConfig config, String lessonId) {
    if (_game != null) return;
    final stats = ref.read(userStatsProvider).valueOrNull;
    final difficulty = gameDifficultyForConceptSkills(
      stats?.conceptSkills ?? const {},
      lessonId,
    );
    _game = LemonCityGame(
      config: config,
      difficulty: difficulty,
      onFinished: _onGameFinished,
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(lqColorsProvider);
    final session = ref.watch(lessonSessionProvider)!;
    final contentAsync = ref.watch(lessonContentProvider(session.lessonId));
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final guide = LQGuideX.fromId(profile?.guide ?? 'penny');

    return contentAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Let\'s try that again.')),
      data: (content) {
        final meta = lessonById(session.lessonId);
        final gameId = meta != null ? conceptGameFor(meta) : ConceptGameId.lemonCity;

        if (gameId != ConceptGameId.lemonCity) {
          if (_submitting && session.phase == LessonPhase.reward) {
            return const SizedBox.shrink();
          }
          return ConceptMiniGamePlayer(
            gameId: gameId,
            colors: colors,
            onFinished: _onConceptGameFinished,
          );
        }

        _initGame(content.gameConfig, session.lessonId);
        final game = _game!;

        if (_submitting && session.phase == LessonPhase.reward) {
          return const SizedBox.shrink();
        }

        return LQCanvas(
          colors: colors,
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(LQSpacing.gutter),
                  child: Row(
                    children: [
                      GuideMascot(
                        guide: guide,
                        size: 56,
                        state: game.profit > 0
                            ? PennyGuideState.happy
                            : PennyGuideState.idle,
                      ),
                      const SizedBox(width: LQSpacing.md),
                      Expanded(
                        child: Text(
                          'Lemon City',
                          style: LQTypography.h2(colors),
                        ),
                      ),
                    ],
                  ),
                ),
                _PnLRow(
                  colors: colors,
                  label: 'Earned',
                  value: 'AED ${game.revenue.toStringAsFixed(0)}',
                  accent: colors.success,
                ),
                _PnLRow(
                  colors: colors,
                  label: 'Spent',
                  value: 'AED ${game.cost.toStringAsFixed(0)}',
                  accent: colors.coral,
                ),
                _PnLRow(
                  colors: colors,
                  label: 'Balance',
                  value: 'AED ${game.profit.toStringAsFixed(0)}',
                  accent: game.profit >= 0 ? colors.brand : colors.danger,
                  bold: true,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: LQSpacing.gutter),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Price per cup: AED ${game.price.round()}',
                        style: LQTypography.h3(colors),
                      ),
                      Slider(
                        value: game.price,
                        min: content.gameConfig.minPrice.roundToDouble(),
                        max: content.gameConfig.maxPrice.roundToDouble(),
                        divisions: (content.gameConfig.maxPrice.round() -
                                content.gameConfig.minPrice.round())
                            .clamp(1, 100),
                        activeColor: colors.brand,
                        onChanged: _submitting
                            ? null
                            : (v) => setState(() => game.setPrice(v.roundToDouble())),
                      ),
                      Text(
                        'Cost per cup: AED ${game.unitCost.round()}',
                        style: LQTypography.caption(colors),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: _submitting ? null : game.serveCustomer,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        GameWidget(game: game),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.touch_app_rounded,
                                  size: 48, color: colors.brand.withValues(alpha: 0.6)),
                              const SizedBox(height: LQSpacing.sm),
                              Text(
                                'Tap to serve customer ${game.customersServed + 1}/${content.gameConfig.customerCount}',
                                style: LQTypography.bodySm(colors),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_guideMessage != null)
                  Padding(
                    padding: const EdgeInsets.all(LQSpacing.gutter),
                    child: Text(
                      _guideMessage!,
                      style: LQTypography.bodySm(colors),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PnLRow extends StatelessWidget {
  const _PnLRow({
    required this.colors,
    required this.label,
    required this.value,
    required this.accent,
    this.bold = false,
  });

  final LQColors colors;
  final String label;
  final String value;
  final Color accent;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: LQSpacing.gutter,
        vertical: LQSpacing.xs,
      ),
      child: Row(
        children: [
          Text(label, style: LQTypography.bodySm(colors)),
          const Spacer(),
          Text(
            value,
            style: (bold ? LQTypography.h3(colors) : LQTypography.body(colors))
                .copyWith(color: accent, fontWeight: bold ? FontWeight.w800 : FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
