import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/motion/lq_motion.dart';
import '../core/tokens/lq_tokens.dart';
import '../core/tokens/lq_typography.dart';

/// Circular progress arc with spring animation
class ProgressArc extends StatefulWidget {
  const ProgressArc({
    super.key,
    required this.colors,
    required this.progress,
    this.size = 120,
    this.strokeWidth = 10,
    this.center,
    this.segments,
  });

  final LQColors colors;
  final double progress;
  final double size;
  final double strokeWidth;
  final Widget? center;
  final List<ArcSegment>? segments;

  @override
  State<ProgressArc> createState() => _ProgressArcState();
}

class ArcSegment {
  const ArcSegment({
    required this.value,
    required this.color,
  });

  final double value;
  final Color color;
}

class _ProgressArcState extends State<ProgressArc>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: LQMotion.prefersReducedMotion
          ? Curves.easeOut
          : Curves.elasticOut,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(ProgressArc oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: _ArcPainter(
              progress: widget.progress * _animation.value,
              colors: widget.colors,
              strokeWidth: widget.strokeWidth,
              segments: widget.segments,
            ),
            child: Center(child: widget.center),
          );
        },
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  _ArcPainter({
    required this.progress,
    required this.colors,
    required this.strokeWidth,
    this.segments,
  });

  final double progress;
  final LQColors colors;
  final double strokeWidth;
  final List<ArcSegment>? segments;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    const startAngle = -math.pi / 2;
    const fullSweep = 2 * math.pi;

    final bgPaint = Paint()
      ..color = colors.canvasEnd
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      fullSweep,
      false,
      bgPaint,
    );

    if (segments != null && segments!.isNotEmpty) {
      var offset = 0.0;
      for (final segment in segments!) {
        final sweep = fullSweep * segment.value * progress;
        final paint = Paint()
          ..color = segment.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle + offset,
          sweep,
          false,
          paint,
        );
        offset += sweep;
      }
    } else {
      final paint = Paint()
        ..shader = SweepGradient(
          colors: [colors.brand, colors.accentMint],
          startAngle: startAngle,
          endAngle: startAngle + fullSweep * progress,
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        fullSweep * progress,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ArcPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Spending breakdown arc with center label
class SpendingArc extends StatelessWidget {
  const SpendingArc({
    super.key,
    required this.colors,
    required this.total,
    required this.percentUsed,
    required this.segments,
    this.centerWidget,
  });

  final LQColors colors;
  final String total;
  final double percentUsed;
  final List<ArcSegment> segments;
  final Widget? centerWidget;

  @override
  Widget build(BuildContext context) {
    return ProgressArc(
      colors: colors,
      progress: 1,
      size: 200,
      strokeWidth: 14,
      segments: segments,
      center: centerWidget ??
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(total, style: LQTypography.numeral(colors, size: 22)),
              Text(
                '${(percentUsed * 100).round()}%',
                style: LQTypography.caption(colors),
              ),
            ],
          ),
    );
  }
}
