import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/audio/lq_sound_service.dart';
import '../../../../core/tokens/lq_tokens.dart';
import '../../../../core/tokens/lq_typography.dart';
import '../../../../data/content/money_concept_copy.dart';
import '../concept_game_result.dart';
import '../concept_game_types.dart';
import '../widgets/concept_game_scaffold.dart';

/// Tap a jar, then tap coins — split 12 coins across Needs / Wants / Save.
class CoinJarsGame extends StatefulWidget {
  const CoinJarsGame({
    super.key,
    required this.colors,
    required this.onFinished,
    this.onBack,
  });

  final LQColors colors;
  final ValueChanged<ConceptGameResult> onFinished;
  final VoidCallback? onBack;

  @override
  State<CoinJarsGame> createState() => _CoinJarsGameState();
}

class _CoinJarsGameState extends State<CoinJarsGame> {
  static const _totalCoins = 12;
  int _selectedJar = 0;
  int _placed = 0;
  int _needs = 0;
  int _wants = 0;
  int _save = 0;
  bool _done = false;

  static const _jarColors = [
    Color(0xFF2D9F6F),
    Color(0xFFE07A4A),
    Color(0xFF4A7FD4),
  ];

  static const _jarLabels = [
    MoneyConceptCopy.needsTitle,
    MoneyConceptCopy.wantsTitle,
    MoneyConceptCopy.saveTitle,
  ];

  void _placeCoin() {
    if (_done || _placed >= _totalCoins) return;
    LQSound.coin();
    setState(() {
      switch (_selectedJar) {
        case 0:
          _needs++;
        case 1:
          _wants++;
        case 2:
          _save++;
      }
      _placed++;
      if (_placed >= _totalCoins) _done = true;
    });
  }

  bool get _won {
    return _needs >= 5 &&
        _needs <= 7 &&
        _wants >= 3 &&
        _wants <= 5 &&
        _save >= 2 &&
        _save <= 4;
  }

  void _finish() {
    widget.onFinished(ConceptGameResult(
      won: _won,
      score: _won ? _totalCoins : _needs + _wants + _save,
      total: _totalCoins,
      message: _won
          ? 'Every coin has a job — needs first, some fun, and save for later!'
          : 'Try about 6 needs, 4 wants, 2 save (roughly half / third / rest).',
    ));
  }

  @override
  Widget build(BuildContext context) {
    final info = infoFor(ConceptGameId.coinJars);
    final c = widget.colors;

    if (_done) {
      return ConceptGameScaffold(
        info: info,
        colors: c,
        score: _placed,
        total: _totalCoins,
        onBack: widget.onBack,
        child: ConceptGameFinishPanel(
          colors: c,
          info: info,
          result: ConceptGameResult(
            won: _won,
            score: _placed,
            total: _totalCoins,
            message: _won
                ? 'Strong budget split!'
                : 'Aim for ~6 needs, ~4 wants, ~2 save.',
          ),
          onContinue: _finish,
        ),
      );
    }

    final remaining = _totalCoins - _placed;

    return ConceptGameScaffold(
      info: info,
      colors: c,
      score: _placed,
      total: _totalCoins,
      onBack: widget.onBack,
      child: Padding(
        padding: const EdgeInsets.all(LQSpacing.gutter),
        child: Column(
          children: [
            Text(
              '$remaining coin${remaining == 1 ? '' : 's'} left — pick a jar, then tap the coin',
              style: LQTypography.bodySm(c),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: LQSpacing.lg),
            Row(
              children: List.generate(3, (i) {
                final count = switch (i) {
                  0 => _needs,
                  1 => _wants,
                  _ => _save,
                };
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i < 2 ? LQSpacing.sm : 0),
                    child: _JarTile(
                      label: _jarLabels[i],
                      count: count,
                      color: _jarColors[i],
                      selected: _selectedJar == i,
                      onTap: () => setState(() => _selectedJar = i),
                    ),
                  ),
                );
              }),
            ),
            const Spacer(),
            GestureDetector(
              onTap: _placeCoin,
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _jarColors[_selectedJar].withValues(alpha: 0.2),
                  border: Border.all(color: _jarColors[_selectedJar], width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: _jarColors[_selectedJar].withValues(alpha: 0.35),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.monetization_on_rounded,
                  size: 48,
                  color: _jarColors[_selectedJar],
                ),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.06, 1.06),
                  duration: 800.ms,
                ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _JarTile extends StatelessWidget {
  const _JarTile({
    required this.label,
    required this.count,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: selected ? 0.22 : 0.08),
      borderRadius: BorderRadius.circular(LQRadius.control),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(LQRadius.control),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: LQSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(LQRadius.control),
            border: Border.all(
              color: color,
              width: selected ? 2.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: color,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
