import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/audio/lq_sound_service.dart';
import '../../../../core/tokens/lq_tokens.dart';
import '../../../../core/tokens/lq_typography.dart';
import '../concept_game_result.dart';
import '../concept_game_types.dart';
import '../widgets/concept_game_scaffold.dart';

class _Deal {
  const _Deal(this.item, this.shopA, this.priceA, this.shopB, this.priceB, this.correctIsA);
  final String item;
  final String shopA;
  final int priceA;
  final String shopB;
  final int priceB;
  final bool correctIsA;
}

const _deals = [
  _Deal('Notebook pack', 'Shop A', 12, 'Shop B', 9, false),
  _Deal('Water bottle', 'Mall', 18, 'Grocery', 14, false),
  _Deal('Bus card top-up', 'Kiosk', 25, 'App', 25, true),
  _Deal('Same headphones', 'Online', 89, 'Store', 110, true),
  _Deal('Lunch combo', 'Cafeteria', 22, 'Canteen', 19, false),
];

/// Pick the smarter price — same item, two shops.
class DealPickGame extends StatefulWidget {
  const DealPickGame({
    super.key,
    required this.colors,
    required this.onFinished,
    this.onBack,
  });

  final LQColors colors;
  final ValueChanged<ConceptGameResult> onFinished;
  final VoidCallback? onBack;

  @override
  State<DealPickGame> createState() => _DealPickGameState();
}

class _DealPickGameState extends State<DealPickGame> {
  int _index = 0;
  int _score = 0;
  bool _done = false;
  String? _feedback;

  static const _accent = Color(0xFFE07A4A);

  void _pick(bool choseA) {
    if (_done || _feedback != null) return;
    final deal = _deals[_index];
    final ok = choseA == deal.correctIsA;
    LQSound.tap();
    if (!ok) LQSound.wrong();
    setState(() {
      if (ok) _score++;
      _feedback = ok
          ? 'Smart pick — you compared before buying!'
          : 'Check both prices — the lower one saves coins.';
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      if (_index + 1 >= _deals.length) {
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
    final won = _score >= 4;
    widget.onFinished(ConceptGameResult(
      won: won,
      score: _score,
      total: _deals.length,
      message: won
          ? 'You compare prices like a smart spender!'
          : 'Always check two prices before you tap pay.',
    ));
  }

  @override
  Widget build(BuildContext context) {
    final info = infoFor(ConceptGameId.dealPick);
    final c = widget.colors;

    if (_done) {
      return ConceptGameScaffold(
        info: info,
        colors: c,
        score: _score,
        total: _deals.length,
        onBack: widget.onBack,
        child: ConceptGameFinishPanel(
          colors: c,
          info: info,
          result: ConceptGameResult(
            won: _score >= 4,
            score: _score,
            total: _deals.length,
            message: _score >= 4
                ? 'Smart spending = compare first!'
                : 'Same item, different price — pick the better deal.',
          ),
          onContinue: _finish,
        ),
      );
    }

    final deal = _deals[_index];
    return ConceptGameScaffold(
      info: info,
      colors: c,
      score: _score,
      total: _deals.length,
      onBack: widget.onBack,
      child: Padding(
        padding: const EdgeInsets.all(LQSpacing.gutter),
        child: Column(
          children: [
            Text(deal.item, style: LQTypography.h2(c), textAlign: TextAlign.center)
                .animate(key: ValueKey(_index))
                .fadeIn(),
            const SizedBox(height: LQSpacing.xxl),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _DealCard(
                      shop: deal.shopA,
                      price: deal.priceA,
                      accent: _accent,
                      onTap: () => _pick(true),
                    ),
                  ),
                  const SizedBox(width: LQSpacing.md),
                  Expanded(
                    child: _DealCard(
                      shop: deal.shopB,
                      price: deal.priceB,
                      accent: _accent,
                      onTap: () => _pick(false),
                    ),
                  ),
                ],
              ),
            ),
            if (_feedback != null)
              Padding(
                padding: const EdgeInsets.only(top: LQSpacing.md),
                child: Text(_feedback!, style: LQTypography.bodySm(c), textAlign: TextAlign.center),
              ),
          ],
        ),
      ),
    );
  }
}

class _DealCard extends StatelessWidget {
  const _DealCard({
    required this.shop,
    required this.price,
    required this.accent,
    required this.onTap,
  });

  final String shop;
  final int price;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: accent.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(LQRadius.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(LQRadius.card),
        child: Container(
          padding: const EdgeInsets.all(LQSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(LQRadius.card),
            border: Border.all(color: accent.withValues(alpha: 0.5), width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(shop, style: TextStyle(fontWeight: FontWeight.w700, color: accent)),
              const SizedBox(height: LQSpacing.lg),
              Text(
                'AED $price',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
