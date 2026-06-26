import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/audio/lq_sound_service.dart';
import '../../../../core/tokens/lq_tokens.dart';
import '../../../../core/tokens/lq_typography.dart';
import '../concept_game_result.dart';
import '../concept_game_types.dart';
import '../widgets/concept_game_scaffold.dart';

class _Round {
  const _Round(this.label, this.isNeed, this.icon);
  final String label;
  final bool isNeed;
  final IconData icon;
}

const _rounds = [
  _Round('School lunch', true, Icons.restaurant_rounded),
  _Round('New game skin', false, Icons.videogame_asset_outlined),
  _Round('Winter coat', true, Icons.checkroom_outlined),
  _Round('Extra candy', false, Icons.cookie_outlined),
  _Round('Bus pass', true, Icons.directions_bus_rounded),
  _Round('Movie ticket', false, Icons.local_movies_outlined),
  _Round('Water bottle', true, Icons.water_drop_outlined),
  _Round('Trendy headphones', false, Icons.headphones_rounded),
];

/// Tap Needs (green) or Wants (coral) for each item.
class NeedsWantsTapGame extends StatefulWidget {
  const NeedsWantsTapGame({
    super.key,
    required this.colors,
    required this.onFinished,
    this.onBack,
  });

  final LQColors colors;
  final ValueChanged<ConceptGameResult> onFinished;
  final VoidCallback? onBack;

  @override
  State<NeedsWantsTapGame> createState() => _NeedsWantsTapGameState();
}

class _NeedsWantsTapGameState extends State<NeedsWantsTapGame> {
  int _index = 0;
  int _score = 0;
  bool _done = false;
  String? _feedback;

  static const _needColor = Color(0xFF2D9F6F);
  static const _wantColor = Color(0xFFE07A4A);

  void _answer(bool pickedNeed) {
    if (_done) return;
    LQSound.tap();
    final round = _rounds[_index];
    final ok = pickedNeed == round.isNeed;
    setState(() {
      if (ok) _score++;
      _feedback = ok
          ? 'Correct — ${round.isNeed ? 'a need' : 'a want'}.'
          : round.isNeed
              ? 'That is a need — must-have for school or health.'
              : 'That is a want — fun, but optional.';
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      if (_index + 1 >= _rounds.length) {
        setState(() => _done = true);
      } else {
        setState(() {
          _index++;
          _feedback = null;
        });
      }
    });
  }

  void _finish() {
    final won = _score >= 6;
    widget.onFinished(ConceptGameResult(
      won: won,
      score: _score,
      total: _rounds.length,
      message: won
          ? 'You sorted needs and wants like a pro — needs come first!'
          : 'Remember: needs keep you going, wants are extras.',
    ));
  }

  @override
  Widget build(BuildContext context) {
    final info = infoFor(ConceptGameId.needsWants);
    final c = widget.colors;

    if (_done) {
      return ConceptGameScaffold(
        info: info,
        colors: c,
        score: _score,
        total: _rounds.length,
        onBack: widget.onBack,
        child: ConceptGameFinishPanel(
          colors: c,
          info: info,
          result: ConceptGameResult(
            won: _score >= 6,
            score: _score,
            total: _rounds.length,
            message: _score >= 6
                ? 'You sorted needs and wants like a pro!'
                : 'Needs = must-haves. Wants = fun extras.',
          ),
          onContinue: _finish,
        ),
      );
    }

    final round = _rounds[_index];
    return ConceptGameScaffold(
      info: info,
      colors: c,
      score: _score,
      total: _rounds.length,
      onBack: widget.onBack,
      child: Padding(
        padding: const EdgeInsets.all(LQSpacing.gutter),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(LQSpacing.xxl),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(LQRadius.card),
                    border: Border.all(color: c.border),
                    boxShadow: [
                      BoxShadow(
                        color: c.ink.withValues(alpha: 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(round.icon, size: 64, color: _needColor),
                      const SizedBox(height: LQSpacing.lg),
                      Text(
                        round.label,
                        style: LQTypography.h2(c),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ).animate(key: ValueKey(_index)).fadeIn().scale(
                      begin: const Offset(0.92, 0.92),
                      end: const Offset(1, 1),
                    ),
              ),
            ),
            if (_feedback != null)
              Padding(
                padding: const EdgeInsets.only(bottom: LQSpacing.md),
                child: Text(_feedback!, style: LQTypography.bodySm(c), textAlign: TextAlign.center),
              ),
            Row(
              children: [
                Expanded(
                  child: _ChoiceButton(
                    label: 'Need',
                    hint: 'Must-have',
                    color: _needColor,
                    onTap: () => _answer(true),
                  ),
                ),
                const SizedBox(width: LQSpacing.md),
                Expanded(
                  child: _ChoiceButton(
                    label: 'Want',
                    hint: 'Extra fun',
                    color: _wantColor,
                    onTap: () => _answer(false),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.label,
    required this.hint,
    required this.color,
    required this.onTap,
  });

  final String label;
  final String hint;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(LQRadius.control),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(LQRadius.control),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: LQSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(LQRadius.control),
            border: Border.all(color: color, width: 2),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Text(hint, style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.8))),
            ],
          ),
        ),
      ),
    );
  }
}
