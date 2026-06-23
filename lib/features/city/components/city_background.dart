import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Parallax skyline layers with depth per §4.2 city art direction.
class CityBackground extends PositionComponent {
  CityBackground({required this.skyTop, required this.skyBottom});

  final Color skyTop;
  final Color skyBottom;

  @override
  void render(Canvas canvas) {
    final rect = size.toRect();
    final sky = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [skyTop, skyBottom],
      ).createShader(rect);
    canvas.drawRect(rect, sky);

    _drawHills(canvas, rect, 0.72, 0.08, skyBottom.withValues(alpha: 0.35));
    _drawHills(canvas, rect, 0.78, 0.12, skyBottom.withValues(alpha: 0.55));
    _drawStars(canvas, rect);
  }

  void _drawHills(Canvas canvas, Rect rect, double baseY, double amp, Color color) {
    final path = Path()..moveTo(0, rect.height);
    final segments = 8;
    for (var i = 0; i <= segments; i++) {
      final x = rect.width * i / segments;
      final y = rect.height * baseY +
          math.sin(i * 1.2 + 0.5) * rect.height * amp;
      path.lineTo(x, y);
    }
    path.lineTo(rect.width, rect.height);
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _drawStars(Canvas canvas, Rect rect) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.35);
    const seeds = [0.12, 0.28, 0.45, 0.62, 0.78, 0.9];
    for (var i = 0; i < seeds.length; i++) {
      final x = rect.width * seeds[i];
      final y = rect.height * (0.08 + (i % 3) * 0.04);
      canvas.drawCircle(Offset(x, y), 1.2, paint);
    }
  }
}

/// Ground platform where towers sit.
class CityGround extends PositionComponent {
  CityGround({required this.groundColor, required this.lineColor});

  final Color groundColor;
  final Color lineColor;

  @override
  void render(Canvas canvas) {
    final rect = size.toRect();
    final groundH = rect.height * 0.28;
    final groundRect = Rect.fromLTWH(0, rect.height - groundH, rect.width, groundH);

    canvas.drawRect(
      groundRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            groundColor.withValues(alpha: 0.5),
            groundColor,
          ],
        ).createShader(groundRect),
    );

    canvas.drawLine(
      Offset(0, groundRect.top),
      Offset(rect.width, groundRect.top),
      Paint()
        ..color = lineColor.withValues(alpha: 0.25)
        ..strokeWidth = 1.5,
    );

    for (var i = 0; i < rect.width / 48; i++) {
      final x = i * 48.0 + 12;
      canvas.drawLine(
        Offset(x, groundRect.top + 8),
        Offset(x + 20, groundRect.top + 8),
        Paint()
          ..color = lineColor.withValues(alpha: 0.08)
          ..strokeWidth = 2,
      );
    }
  }
}

/// Subtle grain overlay on the Flame canvas.
class CityGrainOverlay extends PositionComponent {
  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.028);
    final random = _PseudoRandom(17);
    final count = (size.x * size.y / 900).round();
    for (var i = 0; i < count; i++) {
      canvas.drawCircle(
        Offset(random.nextDouble() * size.x, random.nextDouble() * size.y),
        0.55,
        paint,
      );
    }
  }
}

class _PseudoRandom {
  _PseudoRandom(this._seed);
  int _seed;

  double nextDouble() {
    _seed = (_seed * 1103515245 + 12345) & 0x7fffffff;
    return _seed / 0x7fffffff;
  }
}
