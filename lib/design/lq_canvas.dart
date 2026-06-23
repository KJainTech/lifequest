import 'package:flutter/material.dart';

import '../core/tokens/lq_tokens.dart';

/// Canvas gradient background with optional grain overlay per §4.2
class LQCanvas extends StatelessWidget {
  const LQCanvas({
    super.key,
    required this.colors,
    required this.child,
    this.showGrain = true,
  });

  final LQColors colors;
  final Widget child;
  final bool showGrain;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colors.canvasStart, colors.canvasEnd],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (showGrain) const _GrainOverlay(),
          child,
        ],
      ),
    );
  }
}

class _GrainOverlay extends StatelessWidget {
  const _GrainOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _GrainPainter(),
        size: Size.infinite,
      ),
    );
  }
}

class _GrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.035);
    final random = _PseudoRandom(42);
    for (var i = 0; i < (size.width * size.height / 800).round(); i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), 0.6, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PseudoRandom {
  _PseudoRandom(this._seed);
  int _seed;

  double nextDouble() {
    _seed = (_seed * 1103515245 + 12345) & 0x7fffffff;
    return _seed / 0x7fffffff;
  }
}
