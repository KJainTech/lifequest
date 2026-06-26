import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/audio/lq_sound_service.dart';
import '../../../../core/tokens/lq_tokens.dart';
import '../../../../core/tokens/lq_typography.dart';
import '../../../../design/lq_button.dart';
import '../concept_game_result.dart';
import '../concept_game_types.dart';
import '../widgets/concept_game_scaffold.dart';

/// Tap falling coins into the save jar — ignore spend temptations.
class JarFillGame extends StatefulWidget {
  const JarFillGame({
    super.key,
    required this.colors,
    required this.onFinished,
    this.onBack,
  });

  final LQColors colors;
  final ValueChanged<ConceptGameResult> onFinished;
  final VoidCallback? onBack;

  @override
  State<JarFillGame> createState() => _JarFillGameState();
}

class _JarFillGameState extends State<JarFillGame> {
  static const _goal = 10;
  static const _maxTemptations = 3;

  int _saved = 0;
  int _temptations = 0;
  int _coinsSpawned = 0;
  bool _done = false;

  void _saveCoin() {
    if (_done) return;
    LQSound.coin();
    setState(() {
      _saved++;
      _coinsSpawned++;
      if (_saved >= _goal) _done = true;
    });
  }

  void _temptation() {
    if (_done) return;
    LQSound.wrong();
    setState(() {
      _temptations++;
      if (_temptations >= _maxTemptations) _done = true;
    });
  }

  void _finish() {
    final won = _saved >= _goal;
    widget.onFinished(ConceptGameResult(
      won: won,
      score: _saved,
      total: _goal,
      message: won
          ? 'Your jar is full — those coins are for your goal, not spending today!'
          : 'Save coins in the jar. Skip the “spend now” button.',
    ));
  }

  @override
  Widget build(BuildContext context) {
    final info = infoFor(ConceptGameId.jarFill);
    final c = widget.colors;
    const accent = Color(0xFF4A7FD4);

    if (_done) {
      final won = _saved >= _goal;
      return ConceptGameScaffold(
        info: info,
        colors: c,
        score: _saved,
        total: _goal,
        onBack: widget.onBack,
        child: ConceptGameFinishPanel(
          colors: c,
          info: info,
          result: ConceptGameResult(
            won: won,
            score: _saved,
            total: _goal,
            message: won
                ? 'Jar full! Saving means coins wait for your goal.'
                : 'Tap coins into the jar — not the spend button.',
          ),
          onContinue: _finish,
        ),
      );
    }

    return ConceptGameScaffold(
      info: info,
      colors: c,
      score: _saved,
      total: _goal,
      onBack: widget.onBack,
      child: Padding(
        padding: const EdgeInsets.all(LQSpacing.gutter),
        child: Column(
          children: [
            Text(
              'Saving jar — for your goal later',
              style: LQTypography.label(c).copyWith(color: accent),
            ),
            const SizedBox(height: LQSpacing.lg),
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  width: 120,
                  height: 140,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(24),
                    ),
                    border: Border.all(color: accent, width: 3),
                  ),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 140 * (_saved / _goal).clamp(0.05, 1.0),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.45),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ).animate(onPlay: (c) => _saved > 0 ? c : null).shake(hz: 2, duration: 300.ms),
                Positioned(
                  top: 0,
                  child: Text(
                    '$_saved / $_goal',
                    style: LQTypography.h3(c).copyWith(color: accent),
                  ),
                ),
              ],
            ),
            const SizedBox(height: LQSpacing.xxl),
            Expanded(
              child: Center(
                child: Wrap(
                  spacing: LQSpacing.md,
                  runSpacing: LQSpacing.md,
                  alignment: WrapAlignment.center,
                  children: List.generate(3, (i) {
                    return _CoinButton(
                      onTap: _saveCoin,
                      accent: accent,
                    );
                  }),
                ),
              ),
            ),
            if (_coinsSpawned >= 2 && _coinsSpawned.isOdd)
              Padding(
                padding: const EdgeInsets.only(bottom: LQSpacing.md),
                child: LQButton(
                  label: 'Spend now?',
                  colors: c,
                  variant: LQButtonVariant.secondary,
                  expanded: true,
                  onPressed: _temptation,
                ),
              ),
            Text(
              'Tap coins → jar. Ignore spend temptations.',
              style: LQTypography.caption(c),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CoinButton extends StatelessWidget {
  const _CoinButton({required this.onTap, required this.accent});

  final VoidCallback onTap;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accent.withValues(alpha: 0.15),
            border: Border.all(color: accent, width: 2),
          ),
          child: Icon(Icons.monetization_on_rounded, color: accent, size: 36),
        ),
      ),
    );
  }
}
