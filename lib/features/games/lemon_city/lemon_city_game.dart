import 'dart:async';
import 'dart:math';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../../data/models/lesson_content.dart';

/// Result from a Lemon City play session.
class LemonCityResult {
  const LemonCityResult({
    required this.revenue,
    required this.cost,
    required this.profit,
    required this.cupsSold,
    required this.price,
    required this.unitCost,
    required this.won,
  });

  final double revenue;
  final double cost;
  final double profit;
  final int cupsSold;
  final double price;
  final double unitCost;
  final bool won;

  bool get appliedLessonConcept => price > unitCost;
}

/// Game archetype interface — other 6 games plug in here per §7.3
abstract class LQGameResult {
  bool get won;
  double get profit;
  double get revenue;
  double get cost;
}

/// Lemon City — real-time stand sim; win requires price > cost (profit concept).
class LemonCityGame extends FlameGame {
  LemonCityGame({
    required this.config,
    required this.onFinished,
    required this.onStateChanged,
    this.difficulty = 1,
  });

  final LemonCityConfig config;
  final void Function(LemonCityResult result) onFinished;
  final VoidCallback onStateChanged;
  final int difficulty;

  double price = 3;
  double revenue = 0;
  double cost = 0;
  int cupsSold = 0;
  int customersServed = 0;
  int customersSpawned = 0;
  double _timer = 0;
  double _spawnTimer = 0;
  bool _running = false;
  bool _finished = false;
  final _rng = Random();

  double get profit => revenue - cost;
  double get unitCost => config.unitCost;

  @override
  Color backgroundColor() => const Color(0xFFFBF3EC);

  @override
  Future<void> onLoad() async {
    price = config.defaultPrice.roundToDouble();
    _running = true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_running || _finished) return;

    _timer += dt;
    _spawnTimer += dt;

    final spawnInterval = max(2.5 - difficulty * 0.2, 1.2);
    if (_spawnTimer >= spawnInterval &&
        customersSpawned < config.customerCount) {
      _spawnTimer = 0;
      customersSpawned++;
      onStateChanged();
    }

    if (_timer >= config.daySeconds) {
      _finish();
    }
  }

  void setPrice(double p) {
    price = p.roundToDouble().clamp(
      config.minPrice.roundToDouble(),
      config.maxPrice.roundToDouble(),
    );
    onStateChanged();
  }

  /// Tap to serve the next waiting customer.
  void serveCustomer() {
    if (!_running || _finished || customersServed >= customersSpawned) return;

    customersServed++;
    final maxWilling = config.minPrice +
        _rng.nextDouble() * (config.maxPrice - config.minPrice + 1);

    if (price <= maxWilling) {
      cupsSold++;
      revenue += price;
      cost += config.unitCost;
    }
    onStateChanged();

    if (customersServed >= config.customerCount) {
      _finish();
    }
  }

  void _finish() {
    if (_finished) return;
    _finished = true;
    _running = false;

    final won = profit > 0 && price > config.unitCost;
    onFinished(
      LemonCityResult(
        revenue: revenue,
        cost: cost,
        profit: profit,
        cupsSold: cupsSold,
        price: price,
        unitCost: config.unitCost,
        won: won,
      ),
    );
  }

  void disposeGame() {
    _running = false;
  }
}