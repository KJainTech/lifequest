import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../data/models/lq_models.dart';
import '../tower_visuals.dart';

/// Single tower in the city skyline — custom-painted with depth.
class TowerComponent extends PositionComponent {
  TowerComponent({
    required this.tower,
    required this.visual,
    required Vector2 slotSize,
    required this.groundY,
  }) : super(size: slotSize, anchor: Anchor.bottomCenter);

  final Tower tower;
  final TowerVisual visual;
  final double groundY;

  double buildProgress = 1;
  bool isBuilding = false;
  double _buildElapsed = 0;
  static const _buildDuration = 1.4;

  void startBuildAnimation() {
    isBuilding = true;
    buildProgress = 0;
    _buildElapsed = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isBuilding) return;
    _buildElapsed += dt;
    final t = (_buildElapsed / _buildDuration).clamp(0.0, 1.0);
    buildProgress = _elasticOut(t);
    if (t >= 1) {
      isBuilding = false;
      buildProgress = 1;
    }
  }

  double _elasticOut(double t) {
    if (t <= 0) return 0;
    if (t >= 1) return 1;
    return math.pow(2, -10 * t) * math.sin((t - 0.075) * (2 * math.pi) / 0.3) + 1;
  }

  @override
  void render(Canvas canvas) {
    final fullHeight = size.y * visual.heightFactor;
    final height = fullHeight * buildProgress;
    if (height <= 1) return;

    final w = size.x * 0.72;
    final left = (size.x - w) / 2;
    final top = size.y - height;

    final bodyRect = Rect.fromLTWH(left, top, w, height);
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        bodyRect.translate(4, 6),
        const Radius.circular(6),
      ),
      shadowPaint,
    );

    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.lerp(visual.primary, Colors.white, 0.25)!,
        visual.primary,
        Color.lerp(visual.primary, visual.accent, 0.35)!,
      ],
    );
    final bodyPaint = Paint()
      ..shader = gradient.createShader(bodyRect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(6)),
      bodyPaint,
    );

    _drawWindows(canvas, bodyRect);
    _drawMotif(canvas, bodyRect, visual.motif);

    final spireH = math.min(18.0, height * 0.12);
    if (height > 40) {
      final spireRect = Rect.fromLTWH(
        bodyRect.center.dx - 3,
        top - spireH,
        6,
        spireH,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(spireRect, const Radius.circular(2)),
        Paint()..color = visual.accent,
      );
    }
  }

  void _drawWindows(Canvas canvas, Rect body) {
    if (body.height < 24) return;
    final cols = 3;
    final rows = (body.height / 22).floor().clamp(1, 6);
    final cellW = body.width / (cols + 1);
    final cellH = body.height / (rows + 1);
    final windowPaint = Paint()..color = Colors.white.withValues(alpha: 0.55);
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final cx = body.left + cellW * (c + 1);
        final cy = body.top + cellH * (r + 1);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(cx, cy), width: 6, height: 8),
            const Radius.circular(1.5),
          ),
          windowPaint,
        );
      }
    }
  }

  void _drawMotif(Canvas canvas, Rect body, TowerMotif motif) {
    if (body.height < 30) return;
    switch (motif) {
      case TowerMotif.earning:
        final coinPaint = Paint()..color = Colors.white.withValues(alpha: 0.85);
        canvas.drawCircle(
          Offset(body.center.dx, body.top + body.height * 0.22),
          8,
          coinPaint,
        );
        canvas.drawCircle(
          Offset(body.center.dx, body.top + body.height * 0.22),
          8,
          Paint()
            ..color = visual.accent.withValues(alpha: 0.6)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      case TowerMotif.foundation:
        canvas.drawRect(
          Rect.fromLTWH(body.left + 4, body.bottom - 10, body.width - 8, 6),
          Paint()..color = visual.accent.withValues(alpha: 0.7),
        );
      case TowerMotif.skill:
        canvas.drawLine(
          Offset(body.left + 8, body.top + 12),
          Offset(body.right - 8, body.top + 12),
          Paint()
            ..color = Colors.white.withValues(alpha: 0.5)
            ..strokeWidth = 2,
        );
    }
  }
}
