import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/tokens/lq_tokens.dart';
import '../../data/content/lesson_catalog.dart';
import 'city_buildings.dart';

/// Isometric grid position for a plot within a district block.
class IsoPlotLayout {
  const IsoPlotLayout({
    required this.lessonId,
    required this.center,
    required this.tileW,
    required this.tileH,
    required this.districtIndex,
  });

  final String lessonId;
  final Offset center;
  final double tileW;
  final double tileH;
  final int districtIndex;
}

/// Computes isometric plot positions for the city grid.
List<IsoPlotLayout> computeIsoPlotLayouts(Size size, {bool compact = false}) {
  final tileW = compact ? size.width * 0.09 : size.width * 0.075;
  final tileH = tileW * 0.52;
  final districtW = tileW * 3.2;
  final districtH = tileH * 4.2;
  final gapX = compact ? tileW * 0.35 : tileW * 0.55;
  final gapY = compact ? tileH * 1.2 : tileH * 1.8;

  const districtCols = 3;
  const districtRows = 2;
  final totalW = districtCols * districtW + (districtCols - 1) * gapX;
  final originX = (size.width - totalW) / 2 + districtW / 2;
  final originY = compact ? size.height * 0.62 : size.height * 0.58;

  final layouts = <IsoPlotLayout>[];
  for (var d = 0; d < kQuestLevelCount; d++) {
    final col = d % districtCols;
    final row = d ~/ districtCols;
    final cx = originX + col * (districtW + gapX);
    final cy = originY + row * (districtH + gapY);

    final districtBuildings = buildingsInDistrict(d);
    for (var i = 0; i < districtBuildings.length; i++) {
      final ox = (i % 3 - 1) * tileW * 0.85;
      final oy = (i ~/ 3) * tileH * 1.4 - tileH * 0.3;
      layouts.add(
        IsoPlotLayout(
          lessonId: districtBuildings[i].lessonId,
          center: Offset(cx + ox, cy + oy),
          tileW: tileW,
          tileH: tileH,
          districtIndex: d,
        ),
      );
    }
  }
  return layouts;
}

/// Paints a clean low-poly isometric city — kid-friendly, Apple-clean.
class IsometricCityPainter extends CustomPainter {
  IsometricCityPainter({
    required this.snapshot,
    required this.colors,
    required this.pulse,
    this.compact = false,
    this.buildPop = 0,
    this.highlightLessonId,
    this.overlayMode = false,
  });

  final CityProgressSnapshot snapshot;
  final LQColors colors;
  final double pulse;
  final bool compact;
  final double buildPop;
  final String? highlightLessonId;
  final bool overlayMode;

  static const _districtCols = 5;
  static const _districtRows = 2;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final layouts = computeIsoPlotLayouts(size, compact: compact);
    _paintBase(canvas, size);
    _paintRoads(canvas, size, layouts);
    _paintDistrictPads(canvas, layouts);

    for (final layout in layouts) {
      final plot = snapshot.plots.firstWhere(
        (p) => p.building.lessonId == layout.lessonId,
      );
      _paintPlot(canvas, layout, plot);
    }

    if (!compact) {
      _paintDistrictLabels(canvas, layouts);
    }
  }

  void _paintBase(Canvas canvas, Size size) {
    if (overlayMode) {
      // Light scrim so plots read clearly on top of the hero video.
      canvas.drawRect(
        Offset.zero & size,
        Paint()..color = const Color(0xFFE8ECF2).withValues(alpha: 0.12),
      );
      return;
    }

    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colors.canvasEnd, colors.canvasStart],
        ).createShader(rect),
    );

    // Soft grass band — reads as "land" even before any buildings exist.
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.22, size.width, size.height * 0.78),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFE8F5E9).withValues(alpha: 0.35),
            const Color(0xFFD4EDDA).withValues(alpha: 0.55),
          ],
        ).createShader(rect),
    );
  }

  void _paintRoads(Canvas canvas, Size size, List<IsoPlotLayout> layouts) {
    if (layouts.isEmpty) return;
    final roadPaint = Paint()
      ..color = const Color(0xFFD8DCE8)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.04, size.height * 0.35, size.width * 0.92, size.height * 0.08),
        const Radius.circular(12),
      ),
      roadPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.42, size.height * 0.28, size.width * 0.16, size.height * 0.45),
        const Radius.circular(10),
      ),
      roadPaint..color = const Color(0xFFE0E4EE),
    );

    final dashPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..strokeWidth = 2;
    for (var x = size.width * 0.08; x < size.width * 0.92; x += 18) {
      canvas.drawLine(
        Offset(x, size.height * 0.39),
        Offset(x + 8, size.height * 0.39),
        dashPaint,
      );
    }
  }

  void _paintDistrictPads(Canvas canvas, List<IsoPlotLayout> layouts) {
    final seen = <int>{};
    for (final layout in layouts) {
      if (seen.contains(layout.districtIndex)) continue;
      seen.add(layout.districtIndex);
      final theme = kCityDistrictThemes[layout.districtIndex];
      final districtLayouts =
          layouts.where((l) => l.districtIndex == layout.districtIndex);
      final centers = districtLayouts.map((l) => l.center).toList();
      if (centers.isEmpty) continue;

      var minX = centers.first.dx;
      var maxX = centers.first.dx;
      var minY = centers.first.dy;
      var maxY = centers.first.dy;
      for (final c in centers) {
        minX = math.min(minX, c.dx);
        maxX = math.max(maxX, c.dx);
        minY = math.min(minY, c.dy);
        maxY = math.max(maxY, c.dy);
      }

      final pad = Rect.fromLTRB(
        minX - layout.tileW * 1.6,
        minY - layout.tileH * 2.4,
        maxX + layout.tileW * 1.6,
        maxY + layout.tileH * 0.8,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(pad, Radius.circular(layout.tileW * 0.4)),
        Paint()..color = theme.surface.withValues(alpha: overlayMode ? 0.72 : 0.85),
      );

      _paintParkTrees(canvas, pad, theme.park);
    }
  }

  void _paintParkTrees(Canvas canvas, Rect pad, Color park) {
    for (final ox in [0.12, 0.5, 0.88]) {
      final x = pad.left + pad.width * ox;
      final y = pad.top + pad.height * 0.12;
      _drawConicalTree(canvas, Offset(x, y), park, 11);
    }
  }

  void _drawConicalTree(Canvas canvas, Offset base, Color leaf, double h) {
    final trunk = Paint()..color = const Color(0xFF9E8B7A);
    canvas.drawRect(
      Rect.fromCenter(center: Offset(base.dx, base.dy + h * 0.35), width: 4, height: h * 0.35),
      trunk,
    );
    final cone = Path()
      ..moveTo(base.dx, base.dy - h)
      ..lineTo(base.dx - h * 0.45, base.dy + h * 0.1)
      ..lineTo(base.dx + h * 0.45, base.dy + h * 0.1)
      ..close();
    canvas.drawPath(cone, Paint()..color = leaf);
    canvas.drawPath(
      cone,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  void _paintPlot(Canvas canvas, IsoPlotLayout layout, CityPlot plot) {
    final theme = kCityDistrictThemes[layout.districtIndex];
    final accent = theme.accent;
    final activeDistrict = snapshot.nextPlot?.building.districtIndex ?? 0;
    final isNearFuture =
        layout.districtIndex <= activeDistrict + 1;

    switch (plot.status) {
      case CityPlotStatus.locked:
        if (isNearFuture) {
          _drawEmptyLot(canvas, layout, theme, accent, dimmed: true);
          if (layout.districtIndex > activeDistrict) {
            _drawLockedMarker(canvas, layout);
          }
        } else {
          _drawIsoTile(
            canvas,
            layout.center,
            layout.tileW,
            layout.tileH,
            theme.surface.withValues(alpha: 0.25),
          );
          _drawLockedMarker(canvas, layout);
        }
      case CityPlotStatus.next:
        _drawEmptyLot(canvas, layout, theme, accent, dimmed: false);
        _drawBuildStake(canvas, layout, plot.building.emoji, accent);
        _drawGlowRing(canvas, layout.center, layout.tileW, accent, pulse);
      case CityPlotStatus.inProgress:
        _drawEmptyLot(canvas, layout, theme, accent, dimmed: false);
        _drawBuilding(
          canvas,
          layout,
          accent,
          heightScale: 0.28 + pulse * 0.06,
          ghost: true,
        );
        _drawGlowRing(canvas, layout.center, layout.tileW, accent, pulse);
      case CityPlotStatus.built:
        _drawIsoTile(canvas, layout.center, layout.tileW, layout.tileH, theme.surface);
        final isNew = plot.building.lessonId == highlightLessonId && buildPop > 0;
        final popScale = isNew ? 0.35 + buildPop * 0.65 : 1.0;
        _drawBuilding(
          canvas,
          layout,
          accent,
          heightScale: (0.55 + layout.districtIndex * 0.015) * popScale,
        );
        if (buildPop > 0.5 || !isNew) {
          _drawBuildingTop(canvas, layout, plot.building.emoji);
        }
        if (isNew) {
          _drawGlowRing(canvas, layout.center, layout.tileW, accent, buildPop);
        }
    }
  }

  void _drawEmptyLot(
    Canvas canvas,
    IsoPlotLayout layout,
    CityDistrictTheme theme,
    Color accent, {
    required bool dimmed,
  }) {
    final base = Color.lerp(theme.surface, const Color(0xFFEAF6EC), 0.35)!;
    _drawIsoTile(
      canvas,
      layout.center,
      layout.tileW,
      layout.tileH,
      dimmed ? base.withValues(alpha: 0.75) : base,
    );

    final c = layout.center;
    final grass = Paint()..color = theme.park.withValues(alpha: dimmed ? 0.25 : 0.45);
    for (var i = 0; i < 3; i++) {
      final ox = (i - 1) * layout.tileW * 0.18;
      canvas.drawCircle(
        Offset(c.dx + ox, c.dy - layout.tileH * 0.35),
        layout.tileW * 0.06,
        grass,
      );
    }

    if (!dimmed) {
      canvas.drawPath(
        _isoTilePath(c, layout.tileW, layout.tileH),
        Paint()
          ..color = accent.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  Path _isoTilePath(Offset c, double w, double h) {
    final top = Offset(c.dx, c.dy - h);
    final left = Offset(c.dx - w / 2, c.dy);
    final right = Offset(c.dx + w / 2, c.dy);
    final back = Offset(c.dx, c.dy + h * 0.5);
    return Path()
      ..moveTo(top.dx, top.dy)
      ..lineTo(right.dx, right.dy)
      ..lineTo(back.dx, back.dy)
      ..lineTo(left.dx, left.dy)
      ..close();
  }

  void _drawBuildStake(
    Canvas canvas,
    IsoPlotLayout layout,
    String emoji,
    Color accent,
  ) {
    final c = layout.center;
    final stakeY = c.dy - layout.tileH * 1.6;
    canvas.drawLine(
      Offset(c.dx, c.dy - layout.tileH * 0.3),
      Offset(c.dx, stakeY),
      Paint()
        ..color = accent.withValues(alpha: 0.7)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      Offset(c.dx, stakeY),
      layout.tileW * 0.14,
      Paint()..color = accent.withValues(alpha: 0.2),
    );

    if (!compact) {
      final painter = TextPainter(
        text: TextSpan(
          text: emoji,
          style: TextStyle(fontSize: layout.tileW * 0.38),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: layout.tileW);
      painter.paint(
        canvas,
        Offset(c.dx - painter.width / 2, stakeY - layout.tileH * 0.55),
      );
    }
  }

  void _drawIsoTile(Canvas canvas, Offset c, double w, double h, Color color) {
    final top = Offset(c.dx, c.dy - h);
    final left = Offset(c.dx - w / 2, c.dy);
    final right = Offset(c.dx + w / 2, c.dy);
    final back = Offset(c.dx, c.dy + h * 0.5);

    final path = Path()
      ..moveTo(top.dx, top.dy)
      ..lineTo(right.dx, right.dy)
      ..lineTo(back.dx, back.dy)
      ..lineTo(left.dx, left.dy)
      ..close();

    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.06)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  void _drawBuilding(
    Canvas canvas,
    IsoPlotLayout layout,
    Color accent, {
    required double heightScale,
    bool ghost = false,
  }) {
    final w = layout.tileW * 0.62;
    final d = layout.tileW * 0.38;
    final h = layout.tileH * heightScale * 2.8;
    final c = layout.center;
    final baseY = c.dy - layout.tileH * 0.35;

    // Kenney-style isometric box: top + left + right faces
    final topCenter = Offset(c.dx, baseY - h);
    final leftFront = Offset(c.dx - w / 2, baseY - h * 0.15);
    final rightFront = Offset(c.dx + w / 2, baseY - h * 0.15);
    final leftBack = Offset(c.dx - d / 2, baseY + d * 0.35);
    final rightBack = Offset(c.dx + d / 2, baseY + d * 0.35);

    final leftFace = Path()
      ..moveTo(topCenter.dx, topCenter.dy)
      ..lineTo(leftFront.dx, leftFront.dy)
      ..lineTo(leftBack.dx, leftBack.dy)
      ..lineTo(c.dx, baseY + d * 0.15)
      ..close();

    final rightFace = Path()
      ..moveTo(topCenter.dx, topCenter.dy)
      ..lineTo(rightFront.dx, rightFront.dy)
      ..lineTo(rightBack.dx, rightBack.dy)
      ..lineTo(c.dx, baseY + d * 0.15)
      ..close();

    final topFace = Path()
      ..moveTo(topCenter.dx, topCenter.dy)
      ..lineTo(rightFront.dx, rightFront.dy)
      ..lineTo(c.dx + d / 2, baseY - h * 0.15 + d * 0.35)
      ..lineTo(leftFront.dx, leftFront.dy)
      ..close();

    final alpha = ghost ? 0.35 : 1.0;
    const white = Color(0xFFF7F8FA);
    const whiteDark = Color(0xFFE4E8EE);
    const whiteLight = Color(0xFFFFFFFF);
    final leftColor = Color.lerp(whiteDark, accent, ghost ? 0.1 : 0.08)!;
    final rightColor = Color.lerp(white, accent, ghost ? 0.05 : 0.04)!;
    final topColor = whiteLight;

    canvas.drawPath(leftFace, Paint()..color = leftColor.withValues(alpha: alpha));
    canvas.drawPath(rightFace, Paint()..color = rightColor.withValues(alpha: alpha));
    canvas.drawPath(topFace, Paint()..color = topColor.withValues(alpha: alpha));

    if (!ghost) {
      final outline = Paint()
        ..color = Colors.black.withValues(alpha: 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawPath(leftFace, outline);
      canvas.drawPath(rightFace, outline);
      canvas.drawPath(topFace, outline);
      _drawKenneyWindows(canvas, leftFront, rightFront, topCenter, h);
      _drawKenneyDoor(canvas, c, baseY, w, h);
      _drawAccentSign(canvas, rightFront, accent);
    }
  }

  void _drawAccentSign(Canvas canvas, Offset anchor, Color accent) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: anchor + const Offset(0, -6), width: 14, height: 6),
        const Radius.circular(2),
      ),
      Paint()..color = accent,
    );
  }

  void _drawKenneyWindows(
    Canvas canvas,
    Offset leftFront,
    Offset rightFront,
    Offset topCenter,
    double h,
  ) {
    final window = Paint()..color = const Color(0xFFB8E8FF).withValues(alpha: 0.9);
    for (var row = 0; row < 2; row++) {
      final t = 0.35 + row * 0.22;
      final wl = Offset.lerp(topCenter, leftFront, t)!;
      final wr = Offset.lerp(topCenter, rightFront, t)!;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: wl, width: 7, height: 9),
          const Radius.circular(1),
        ),
        window,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: wr, width: 7, height: 9),
          const Radius.circular(1),
        ),
        window,
      );
    }
  }

  void _drawKenneyDoor(Canvas canvas, Offset c, double baseY, double w, double h) {
    final door = Paint()..color = const Color(0xFF5C4033).withValues(alpha: 0.85);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(c.dx, baseY - h * 0.08),
          width: w * 0.22,
          height: h * 0.28,
        ),
        const Radius.circular(2),
      ),
      door,
    );
  }

  void _drawBuildingTop(Canvas canvas, IsoPlotLayout layout, String emoji) {
    if (compact) return;
    final painter = TextPainter(
      text: TextSpan(text: emoji, style: TextStyle(fontSize: layout.tileW * 0.45)),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: layout.tileW);
    painter.paint(
      canvas,
      Offset(layout.center.dx - painter.width / 2, layout.center.dy - layout.tileH * 3.8),
    );
  }

  void _drawLockedMarker(Canvas canvas, IsoPlotLayout layout) {
    canvas.drawCircle(
      layout.center + Offset(0, -layout.tileH * 0.8),
      layout.tileW * 0.12,
      Paint()..color = const Color(0xFFB0B8C8),
    );
  }

  void _drawGlowRing(Canvas canvas, Offset c, double w, Color accent, double pulse) {
    canvas.drawCircle(
      c + Offset(0, -w * 0.4),
      w * (0.55 + pulse * 0.12),
      Paint()
        ..color = accent.withValues(alpha: 0.18 + pulse * 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  void _paintDistrictLabels(Canvas canvas, List<IsoPlotLayout> layouts) {
    final seen = <int>{};
    for (final layout in layouts) {
      if (seen.contains(layout.districtIndex)) continue;
      seen.add(layout.districtIndex);
      final theme = kCityDistrictThemes[layout.districtIndex];
      final districtLayouts =
          layouts.where((l) => l.districtIndex == layout.districtIndex);
      final minY = districtLayouts.map((l) => l.center.dy).reduce(math.min);

      final painter = TextPainter(
        text: TextSpan(
          text: theme.name,
          style: TextStyle(
            fontSize: layout.tileW * 0.32,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E1635),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: layout.tileW * 4);
      painter.paint(
        canvas,
        Offset(layout.center.dx - painter.width / 2, minY - layout.tileH * 3.6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant IsometricCityPainter oldDelegate) {
    return oldDelegate.snapshot.builtCount != snapshot.builtCount ||
        oldDelegate.pulse != pulse ||
        oldDelegate.buildPop != buildPop ||
        oldDelegate.highlightLessonId != highlightLessonId ||
        oldDelegate.compact != compact;
  }

  /// Returns lessonId for tapped plot.
  static String? hitTestPlot(
    Offset local,
    Size size,
    CityProgressSnapshot snapshot, {
    bool compact = false,
  }) {
    final layouts = computeIsoPlotLayouts(size, compact: compact);
    String? closest;
    var closestDist = double.infinity;
    for (final layout in layouts) {
      final d = (local - layout.center).distance;
      if (d < layout.tileW * 1.1 && d < closestDist) {
        closestDist = d;
        closest = layout.lessonId;
      }
    }
    return closest;
  }
}
