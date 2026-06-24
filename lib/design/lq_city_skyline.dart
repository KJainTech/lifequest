import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/tokens/lq_tokens.dart';

/// Animated isometric city skyline for splash / hero sections.
class LQCitySkyline extends StatelessWidget {
  const LQCitySkyline({
    super.key,
    required this.colors,
    this.height = 160,
    this.progress = 0.35,
  });

  final LQColors colors;
  final double height;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _SkylinePainter(colors: colors, progress: progress),
      ),
    );
  }
}

class _SkylinePainter extends CustomPainter {
  _SkylinePainter({required this.colors, required this.progress});

  final LQColors colors;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final groundY = size.height * 0.88;
    canvas.drawRect(
      Rect.fromLTWH(0, groundY, size.width, size.height - groundY),
      Paint()..color = colors.accentMint.withValues(alpha: 0.5),
    );

    final buildings = <_Bldg>[
      _Bldg(0.04, 0.55, 0.08, colors.brand.withValues(alpha: 0.35)),
      _Bldg(0.12, 0.42, 0.1, colors.brand),
      _Bldg(0.22, 0.62, 0.09, colors.brandDeep.withValues(alpha: 0.7)),
      _Bldg(0.31, 0.38, 0.11, colors.brand),
      _Bldg(0.42, 0.58, 0.08, colors.info.withValues(alpha: 0.85)),
      _Bldg(0.5, 0.32, 0.13, colors.brandDeep),
      _Bldg(0.63, 0.52, 0.1, colors.warn.withValues(alpha: 0.8)),
      _Bldg(0.73, 0.4, 0.09, colors.brand),
      _Bldg(0.82, 0.6, 0.08, colors.gold.withValues(alpha: 0.75)),
      _Bldg(0.9, 0.45, 0.1, colors.brandDeep),
    ];

    for (var i = 0; i < buildings.length; i++) {
      final b = buildings[i];
      final built = i / buildings.length <= progress;
      final w = size.width * b.wFrac;
      final h = size.height * b.hFrac;
      final x = size.width * b.xFrac;
      final y = groundY - h;

      final fill = built ? b.color : colors.ink.withValues(alpha: 0.08);
      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, w, h),
        const Radius.circular(6),
      );
      canvas.drawRRect(rrect, Paint()..color = fill);

      if (built) {
        for (var row = 0; row < 3; row++) {
          for (var col = 0; col < 2; col++) {
            canvas.drawRRect(
              RRect.fromRectAndRadius(
                Rect.fromLTWH(
                  x + w * 0.2 + col * w * 0.35,
                  y + h * 0.15 + row * h * 0.22,
                  w * 0.22,
                  h * 0.12,
                ),
                const Radius.circular(2),
              ),
              Paint()..color = colors.surface.withValues(alpha: 0.55),
            );
          }
        }
      }
    }

    // Sparkle coins along progress
    final coinPaint = Paint()..color = colors.gold;
    for (var i = 0; i < 5; i++) {
      final t = (progress * 5 + i * 0.3) % 1.0;
      final cx = size.width * (0.1 + t * 0.8);
      final cy = groundY - 12 - math.sin(t * math.pi * 2) * 8;
      canvas.drawCircle(Offset(cx, cy), 4, coinPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SkylinePainter old) =>
      old.progress != progress;
}

class _Bldg {
  const _Bldg(this.xFrac, this.hFrac, this.wFrac, this.color);
  final double xFrac;
  final double hFrac;
  final double wFrac;
  final Color color;
}

/// Learn · Play · Feedback cycle pill row.
class LQCycleStrip extends StatelessWidget {
  const LQCycleStrip({super.key, required this.colors});

  final LQColors colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _PhasePill(colors: colors, label: 'Learn', letter: 'L', tint: colors.brand),
        _Arrow(colors: colors),
        _PhasePill(colors: colors, label: 'Play', letter: 'P', tint: colors.warn),
        _Arrow(colors: colors),
        _PhasePill(colors: colors, label: 'Feedback', letter: 'F', tint: colors.info),
      ],
    );
  }
}

class _PhasePill extends StatelessWidget {
  const _PhasePill({
    required this.colors,
    required this.label,
    required this.letter,
    required this.tint,
  });

  final LQColors colors;
  final String label;
  final String letter;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: tint.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: tint.withValues(alpha: 0.35)),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: tint,
              child: Text(
                letter,
                style: TextStyle(
                  color: colors.surface,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: colors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow({required this.colors});
  final LQColors colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Icon(Icons.arrow_forward_rounded, size: 14, color: colors.warn),
    );
  }
}
