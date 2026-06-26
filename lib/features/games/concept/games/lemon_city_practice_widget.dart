import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../../../core/tokens/lq_tokens.dart';
import '../../../../core/tokens/lq_typography.dart';
import '../../../../data/models/lesson_content.dart';
import '../../lemon_city/lemon_city_game.dart';
import '../concept_game_navigation.dart';

/// Standalone Lemon City — no lesson session required (direct URL safe).
class LemonCityPracticeWidget extends StatefulWidget {
  const LemonCityPracticeWidget({
    super.key,
    required this.colors,
    this.onBack,
  });

  final LQColors colors;
  final VoidCallback? onBack;

  @override
  State<LemonCityPracticeWidget> createState() => _LemonCityPracticeWidgetState();
}

class _LemonCityPracticeWidgetState extends State<LemonCityPracticeWidget> {
  static const _config = LemonCityConfig(
    unitCost: 2,
    daySeconds: 50,
    customerCount: 10,
    minPrice: 1,
    maxPrice: 8,
    defaultPrice: 3,
  );

  LemonCityGame? _game;
  String? _message;

  @override
  void dispose() {
    _game?.disposeGame();
    super.dispose();
  }

  void _initGame() {
    if (_game != null) return;
    _game = LemonCityGame(
      config: _config,
      difficulty: 2,
      onFinished: (result) {
        if (!mounted) return;
        setState(() {
          _message = result.won
              ? 'Profit AED ${result.profit.toStringAsFixed(0)} — price above cost wins!'
              : 'Set price above AED ${result.unitCost.round()} and serve customers.';
        });
      },
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _initGame();
    final game = _game!;
    final c = widget.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: LQSpacing.sm),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'All games',
                  onPressed: widget.onBack ?? () => leaveConceptGame(context),
                  icon: Icon(Icons.arrow_back_rounded, color: c.ink),
                ),
                Expanded(
                  child: Text(
                    'Lemon City · Practice',
                    style: LQTypography.h3(c),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
        ),
        _PnLRow(colors: c, label: 'Earned', value: 'AED ${game.revenue.toStringAsFixed(0)}', accent: c.success),
        _PnLRow(colors: c, label: 'Spent', value: 'AED ${game.cost.toStringAsFixed(0)}', accent: c.coral),
        _PnLRow(
          colors: c,
          label: 'Balance',
          value: 'AED ${game.profit.toStringAsFixed(0)}',
          accent: game.profit >= 0 ? c.brand : c.danger,
          bold: true,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: LQSpacing.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Price per cup: AED ${game.price.round()}', style: LQTypography.h3(c)),
              Slider(
                value: game.price,
                min: _config.minPrice,
                max: _config.maxPrice,
                divisions: (_config.maxPrice - _config.minPrice).round().clamp(1, 20),
                activeColor: c.brand,
                onChanged: (v) => setState(() => game.setPrice(v)),
              ),
              Text('Cost per cup: AED ${_config.unitCost.round()}', style: LQTypography.caption(c)),
            ],
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: game.serveCustomer,
            child: Stack(
              fit: StackFit.expand,
              children: [
                GameWidget(game: game),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.touch_app_rounded, size: 48, color: c.brand.withValues(alpha: 0.6)),
                      const SizedBox(height: LQSpacing.sm),
                      Text(
                        'Tap to serve ${game.customersServed + 1}/${_config.customerCount}',
                        style: LQTypography.bodySm(c),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_message != null)
          Padding(
            padding: const EdgeInsets.all(LQSpacing.gutter),
            child: Text(_message!, style: LQTypography.bodySm(c), textAlign: TextAlign.center),
          ),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: LQSpacing.gutter, vertical: LQSpacing.xs),
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
