import 'package:flutter/material.dart';

import '../../core/tokens/lq_tokens.dart';
import '../../data/models/lq_models.dart';
import 'tower_visuals.dart';

/// Mini skyline preview for the home dashboard.
class CityPreviewPainter extends CustomPainter {
  CityPreviewPainter({
    required this.towers,
    required this.colors,
  });

  final List<Tower> towers;
  final LQColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    final groundY = size.height * 0.82;
    canvas.drawLine(
      Offset(0, groundY),
      Offset(size.width, groundY),
      Paint()
        ..color = colors.ink.withValues(alpha: 0.12)
        ..strokeWidth = 1,
    );

    if (towers.isEmpty) {
      _drawPlaceholder(canvas, size, groundY);
      return;
    }

    final display = towers.take(4).toList();
    final slotW = size.width / display.length;
    for (var i = 0; i < display.length; i++) {
      final visual = towerVisualForType(display[i].type, colors);
      final cx = slotW * (i + 0.5);
      final h = size.height * 0.55 * visual.heightFactor;
      _drawMiniTower(canvas, Offset(cx, groundY), slotW * 0.5, h, visual);
    }
  }

  void _drawPlaceholder(Canvas canvas, Size size, double groundY) {
    final paint = Paint()..color = colors.inkSoft.withValues(alpha: 0.2);
    for (var i = 0; i < 3; i++) {
      final x = size.width * (0.25 + i * 0.25);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(x, groundY - 12), width: 16, height: 24),
          const Radius.circular(3),
        ),
        paint,
      );
    }
  }

  void _drawMiniTower(
    Canvas canvas,
    Offset base,
    double w,
    double h,
    TowerVisual visual,
  ) {
    final rect = Rect.fromCenter(
      center: Offset(base.dx, base.dy - h / 2),
      width: w,
      height: h,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(3)),
      Paint()..color = visual.primary.withValues(alpha: 0.85),
    );
    if (visual.motif == TowerMotif.earning) {
      canvas.drawCircle(
        Offset(rect.center.dx, rect.top + h * 0.25),
        3,
        Paint()..color = Colors.white.withValues(alpha: 0.7),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CityPreviewPainter oldDelegate) {
    return oldDelegate.towers.length != towers.length ||
        oldDelegate.colors != colors;
  }
}
