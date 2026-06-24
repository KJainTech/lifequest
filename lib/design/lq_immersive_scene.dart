import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/tokens/lq_tokens.dart';

/// Clean flat canvas — no gradient glass. Optional subtle grid only.
class LQImmersiveScene extends StatelessWidget {
  const LQImmersiveScene({
    super.key,
    required this.colors,
    required this.child,
    this.intensity = 1,
    this.showOrbs = false,
    this.showGrid = true,
  });

  final LQColors colors;
  final Widget child;
  final double intensity;
  final bool showOrbs;
  final bool showGrid;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: colors.canvas,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (showGrid)
            CustomPaint(
              painter: _DotGridPainter(color: colors.border),
              size: Size.infinite,
            ),
          if (showOrbs)
            CustomPaint(
              painter: _AccentBlockPainter(colors: colors),
              size: Size.infinite,
            ),
          child,
        ],
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  _DotGridPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const step = 24.0;
    final paint = Paint()..color = color.withValues(alpha: 0.45);
    for (var x = 0.0; x < size.width; x += step) {
      for (var y = 0.0; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 0.6, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotGridPainter old) => false;
}

class _AccentBlockPainter extends CustomPainter {
  _AccentBlockPainter({required this.colors});
  final LQColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.08),
      48,
      Paint()..color = colors.accentMint.withValues(alpha: 0.35),
    );
    canvas.drawCircle(
      Offset(size.width * 0.08, size.height * 0.75),
      36,
      Paint()..color = colors.amber!.withValues(alpha: 0.25),
    );
  }

  @override
  bool shouldRepaint(covariant _AccentBlockPainter old) => false;
}

class LQProgressRing extends StatelessWidget {
  const LQProgressRing({
    super.key,
    required this.colors,
    required this.progress,
    this.size = 72,
    this.stroke = 8,
    this.child,
  });

  final LQColors colors;
  final double progress;
  final double size;
  final double stroke;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              progress: progress.clamp(0, 1),
              stroke: stroke,
              trackColor: colors.border,
              progressColor: colors.brand,
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.stroke,
    required this.trackColor,
    required this.progressColor,
  });

  final double progress;
  final double stroke;
  final Color trackColor;
  final Color progressColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - stroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final arc = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, track);
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * progress, false, arc);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class LQFloaty extends StatelessWidget {
  const LQFloaty({super.key, required this.child, this.amplitude = 6});

  final Widget child;
  final double amplitude;

  @override
  Widget build(BuildContext context) {
    return child
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .moveY(
          begin: 0,
          end: -amplitude,
          duration: 2200.ms,
          curve: Curves.easeInOut,
        );
  }
}
