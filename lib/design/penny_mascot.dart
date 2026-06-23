import 'package:flutter/material.dart';
import 'package:rive/rive.dart' hide RadialGradient;

/// Guide expression states from §6 — min 8 each
enum PennyGuideState {
  idle,
  happy,
  think,
  worried,
  celebrate,
  wave,
  sleep,
  levelUp,
}

/// Penny mascot — Rive rig with custom-painted fallback per Phase 1
class PennyMascot extends StatefulWidget {
  const PennyMascot({
    super.key,
    required this.state,
    this.size = 160,
    this.onRiveLoaded,
  });

  final PennyGuideState state;
  final double size;
  final VoidCallback? onRiveLoaded;

  @override
  State<PennyMascot> createState() => _PennyMascotState();
}

class _PennyMascotState extends State<PennyMascot>
    with SingleTickerProviderStateMixin {
  Artboard? _riveArtboard;
  StateMachineController? _controller;
  late AnimationController _breathController;
  late Animation<double> _breathAnimation;
  bool _useRive = false;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _breathAnimation = Tween<double>(begin: 0, end: 3).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );
    _loadRive();
  }

  Future<void> _loadRive() async {
    try {
      final file = await RiveFile.asset('assets/rive/penny.riv');
      final artboard = file.mainArtboard;
      final controller = StateMachineController.fromArtboard(
        artboard,
        'PennyStateMachine',
      );
      if (controller != null) {
        artboard.addController(controller);
        setState(() {
          _riveArtboard = artboard;
          _controller = controller;
          _useRive = true;
        });
        widget.onRiveLoaded?.call();
        _applyState(widget.state);
      }
    } catch (_) {
      // Rive asset not yet commissioned — fallback painter is used
    }
  }

  @override
  void didUpdateWidget(PennyMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _applyState(widget.state);
    }
  }

  void _applyState(PennyGuideState state) {
    if (_controller == null) return;
    final inputName = switch (state) {
      PennyGuideState.idle => 'idle',
      PennyGuideState.happy => 'happy',
      PennyGuideState.think => 'think',
      PennyGuideState.worried => 'worried',
      PennyGuideState.celebrate => 'celebrate',
      PennyGuideState.wave => 'wave',
      PennyGuideState.sleep => 'sleep',
      PennyGuideState.levelUp => 'levelUp',
    };
    final trigger = _controller!.findInput(inputName) as SMITrigger?;
    trigger?.fire();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_useRive && _riveArtboard != null) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: Rive(artboard: _riveArtboard!),
      );
    }

    return AnimatedBuilder(
      animation: _breathAnimation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _PennyFallbackPainter(
            state: widget.state,
            breathOffset: _breathAnimation.value,
          ),
        );
      },
    );
  }
}

/// Premium custom-painted Penny until Rive rig is commissioned
class _PennyFallbackPainter extends CustomPainter {
  _PennyFallbackPainter({
    required this.state,
    required this.breathOffset,
  });

  final PennyGuideState state;
  final double breathOffset;

  static const _brand = Color(0xFFFF8A4C);
  static const _brandDeep = Color(0xFFE2611F);
  static const _mint = Color(0xFF4FD1A5);
  static const _violet = Color(0xFF9D7BFF);
  static const _ink = Color(0xFF2A2140);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + breathOffset);
    final scale = size.width / 160;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(scale);

    _drawShadow(canvas);
    _drawBody(canvas);
    _drawEars(canvas);
    _drawFace(canvas);
    _drawAccessories(canvas);

    canvas.restore();
  }

  void _drawShadow(Canvas canvas) {
    final shadow = Paint()
      ..color = _ink.withValues(alpha: 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 52), width: 90, height: 20),
      shadow,
    );
  }

  void _drawBody(Canvas canvas) {
    final bodyGradient = RadialGradient(
      colors: [_brand, _brandDeep],
      center: const Alignment(-0.2, -0.3),
    );
    final bodyPaint = Paint()
      ..shader = bodyGradient.createShader(
        Rect.fromCenter(center: const Offset(0, 10), width: 100, height: 90),
      );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 10), width: 100, height: 90),
      bodyPaint,
    );

    final belly = Paint()..color = Colors.white.withValues(alpha: 0.15);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 20), width: 50, height: 40),
      belly,
    );
  }

  void _drawEars(Canvas canvas) {
    final earPaint = Paint()..color = _brandDeep;
    canvas.drawCircle(const Offset(-38, -30), 18, earPaint);
    canvas.drawCircle(const Offset(38, -30), 18, earPaint);
    final innerEar = Paint()..color = const Color(0xFFFFB088);
    canvas.drawCircle(const Offset(-38, -28), 10, innerEar);
    canvas.drawCircle(const Offset(38, -28), 10, innerEar);
  }

  void _drawFace(Canvas canvas) {
    final snout = Paint()..color = const Color(0xFFFFB088);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 18), width: 44, height: 32),
      snout,
    );

    final eyeY = switch (state) {
      PennyGuideState.sleep => -8.0,
      PennyGuideState.worried => -14.0,
      _ => -12.0,
    };

    if (state == PennyGuideState.sleep) {
      _drawClosedEyes(canvas, eyeY);
    } else if (state == PennyGuideState.happy ||
        state == PennyGuideState.celebrate ||
        state == PennyGuideState.levelUp) {
      _drawHappyEyes(canvas, eyeY);
    } else if (state == PennyGuideState.worried) {
      _drawWorriedEyes(canvas, eyeY);
    } else {
      _drawNormalEyes(canvas, eyeY);
    }

    canvas.drawCircle(const Offset(0, 12), 5, Paint()..color = _ink);
    _drawMouth(canvas);
  }

  void _drawNormalEyes(Canvas canvas, double y) {
    canvas.drawCircle(Offset(-16, y), 8, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(16, y), 8, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(-14, y + 1), 4, Paint()..color = _ink);
    canvas.drawCircle(Offset(18, y + 1), 4, Paint()..color = _ink);
    canvas.drawCircle(Offset(-13, y), 1.5, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(19, y), 1.5, Paint()..color = Colors.white);
  }

  void _drawHappyEyes(Canvas canvas, double y) {
    final paint = Paint()
      ..color = _ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(-16, y), width: 14, height: 10),
      0.2,
      2.8,
      false,
      paint,
    );
    canvas.drawArc(
      Rect.fromCenter(center: Offset(16, y), width: 14, height: 10),
      0.2,
      2.8,
      false,
      paint,
    );
  }

  void _drawWorriedEyes(Canvas canvas, double y) {
    _drawNormalEyes(canvas, y);
    final brow = Paint()
      ..color = _ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(-24, -22), const Offset(-8, -18), brow);
    canvas.drawLine(const Offset(24, -22), const Offset(8, -18), brow);
  }

  void _drawClosedEyes(Canvas canvas, double y) {
    final paint = Paint()
      ..color = _ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(-22, y), Offset(-10, y), paint);
    canvas.drawLine(Offset(10, y), Offset(22, y), paint);
  }

  void _drawMouth(Canvas canvas) {
    final paint = Paint()
      ..color = _ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    switch (state) {
      case PennyGuideState.happy:
      case PennyGuideState.celebrate:
      case PennyGuideState.levelUp:
      case PennyGuideState.wave:
        canvas.drawArc(
          Rect.fromCenter(center: const Offset(0, 24), width: 20, height: 12),
          0.2,
          2.8,
          false,
          paint,
        );
      case PennyGuideState.worried:
        canvas.drawArc(
          Rect.fromCenter(center: const Offset(0, 30), width: 14, height: 8),
          3.5,
          2,
          false,
          paint,
        );
      case PennyGuideState.think:
        canvas.drawCircle(const Offset(6, 26), 3, paint);
      case PennyGuideState.sleep:
        canvas.drawLine(const Offset(-4, 26), const Offset(4, 26), paint);
      default:
        canvas.drawLine(const Offset(-6, 26), const Offset(6, 26), paint);
    }
  }

  void _drawAccessories(Canvas canvas) {
    final coin = Paint()..color = const Color(0xFFFFC23D);
    canvas.drawCircle(const Offset(0, 38), 12, coin);
    canvas.drawCircle(
      const Offset(0, 38),
      12,
      Paint()
        ..color = _ink.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    final cPaint = Paint()
      ..color = _ink.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawArc(
      Rect.fromCenter(center: const Offset(0, 38), width: 8, height: 8),
      -0.5,
      4,
      false,
      cPaint,
    );

    if (state == PennyGuideState.wave) {
      final arm = Paint()
        ..color = _brand
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(const Offset(42, 0), const Offset(58, -30), arm);
      canvas.drawCircle(const Offset(58, -30), 8, Paint()..color = _brand);
    }

    if (state == PennyGuideState.celebrate ||
        state == PennyGuideState.levelUp) {
      _drawSparkle(canvas, const Offset(-50, -40), _mint);
      _drawSparkle(canvas, const Offset(50, -35), _violet);
      _drawSparkle(canvas, const Offset(45, 50), _mint);
    }

    if (state == PennyGuideState.think) {
      canvas.drawCircle(const Offset(50, -40), 14, Paint()..color = Colors.white);
      canvas.drawCircle(
        const Offset(50, -40),
        14,
        Paint()
          ..color = _ink.withValues(alpha: 0.15)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
      canvas.drawCircle(const Offset(46, -44), 2, Paint()..color = _violet);
      canvas.drawCircle(const Offset(52, -42), 2, Paint()..color = _mint);
      canvas.drawCircle(const Offset(50, -36), 2, Paint()..color = _violet);
    }
  }

  void _drawSparkle(Canvas canvas, Offset pos, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(pos, pos + const Offset(0, -8), paint);
    canvas.drawLine(pos, pos + const Offset(6, 0), paint);
    canvas.drawLine(pos, pos + const Offset(0, 6), paint);
    canvas.drawLine(pos, pos + const Offset(-6, 0), paint);
  }

  @override
  bool shouldRepaint(covariant _PennyFallbackPainter oldDelegate) {
    return oldDelegate.state != state ||
        oldDelegate.breathOffset != breathOffset;
  }
}
