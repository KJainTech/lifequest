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

/// Penny — cute modern bear guide (Rive rig + custom-painted fallback).
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
    _breathAnimation = Tween<double>(begin: 0, end: 2.5).animate(
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
      // Rive asset not yet commissioned — bear fallback is used
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
          painter: _BearFallbackPainter(
            state: widget.state,
            breathOffset: _breathAnimation.value,
          ),
        );
      },
    );
  }
}

/// Modern low-poly bear — warm, cute, clean (matches Lemon City aesthetic).
class _BearFallbackPainter extends CustomPainter {
  _BearFallbackPainter({
    required this.state,
    required this.breathOffset,
  });

  final PennyGuideState state;
  final double breathOffset;

  static const _fur = Color(0xFFC4956A);
  static const _furDark = Color(0xFFA67B52);
  static const _furLight = Color(0xFFD4AD82);
  static const _muzzle = Color(0xFFFFF5EB);
  static const _belly = Color(0xFFFFFAF4);
  static const _nose = Color(0xFF3D3028);
  static const _cheek = Color(0xFFFFB8A0);
  static const _brand = Color(0xFF28B77F);
  static const _brandLight = Color(0xFF9AF4C8);
  static const _gold = Color(0xFFFFD93D);
  static const _ink = Color(0xFF2A2420);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + breathOffset);
    final scale = size.width / 160;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(scale);

    _drawShadow(canvas);
    _drawBody(canvas);
    _drawHead(canvas);
    _drawFace(canvas);
    _drawExtras(canvas);

    canvas.restore();
  }

  void _drawShadow(Canvas canvas) {
    final shadow = Paint()
      ..color = _ink.withValues(alpha: 0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 58), width: 80, height: 16),
      shadow,
    );
  }

  void _drawBody(Canvas canvas) {
    // Round torso
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 28), width: 72, height: 64),
      Paint()..color = _fur,
    );
    // Belly patch
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 32), width: 40, height: 36),
      Paint()..color = _belly,
    );
    // Green coin badge — brand tie-in
    canvas.drawCircle(const Offset(0, 30), 14, Paint()..color = _brand);
    canvas.drawCircle(
      const Offset(0, 30),
      14,
      Paint()
        ..color = _ink.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    final coinText = TextPainter(
      text: const TextSpan(
        text: '¢',
        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    coinText.paint(canvas, const Offset(-4, 22));
  }

  void _drawHead(Canvas canvas) {
    // Ears
    canvas.drawCircle(const Offset(-34, -28), 16, Paint()..color = _furDark);
    canvas.drawCircle(const Offset(34, -28), 16, Paint()..color = _furDark);
    canvas.drawCircle(const Offset(-34, -26), 9, Paint()..color = _furLight);
    canvas.drawCircle(const Offset(34, -26), 9, Paint()..color = _furLight);

    // Head
    canvas.drawCircle(const Offset(0, -8), 38, Paint()..color = _fur);
    // Subtle highlight
    canvas.drawCircle(
      const Offset(-8, -16),
      12,
      Paint()..color = _furLight.withValues(alpha: 0.35),
    );
  }

  void _drawFace(Canvas canvas) {
    // Muzzle
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 2), width: 36, height: 28),
      Paint()..color = _muzzle,
    );

    // Nose
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, -2), width: 12, height: 9),
      Paint()..color = _nose,
    );

    final eyeY = switch (state) {
      PennyGuideState.sleep => -6.0,
      PennyGuideState.worried => -12.0,
      _ => -10.0,
    };

    if (state == PennyGuideState.sleep) {
      _drawClosedEyes(canvas, eyeY);
    } else if (_isHappy) {
      _drawHappyEyes(canvas, eyeY);
      _drawBlush(canvas);
    } else if (state == PennyGuideState.worried) {
      _drawNormalEyes(canvas, eyeY);
      _drawWorriedBrows(canvas);
    } else {
      _drawNormalEyes(canvas, eyeY);
    }

    _drawMouth(canvas);

    if (state == PennyGuideState.think) {
      canvas.drawCircle(const Offset(48, -36), 12, Paint()..color = Colors.white);
      canvas.drawCircle(
        const Offset(48, -36),
        12,
        Paint()
          ..color = _ink.withValues(alpha: 0.12)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  bool get _isHappy =>
      state == PennyGuideState.happy ||
      state == PennyGuideState.celebrate ||
      state == PennyGuideState.levelUp ||
      state == PennyGuideState.wave;

  void _drawBlush(Canvas canvas) {
    final blush = Paint()..color = _cheek.withValues(alpha: 0.5);
    canvas.drawCircle(const Offset(-24, 2), 6, blush);
    canvas.drawCircle(const Offset(24, 2), 6, blush);
  }

  void _drawNormalEyes(Canvas canvas, double y) {
    canvas.drawCircle(Offset(-14, y), 7, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(14, y), 7, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(-12, y + 1), 3.5, Paint()..color = _ink);
    canvas.drawCircle(Offset(16, y + 1), 3.5, Paint()..color = _ink);
    canvas.drawCircle(Offset(-11, y - 1), 1.5, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(17, y - 1), 1.5, Paint()..color = Colors.white);
  }

  void _drawHappyEyes(Canvas canvas, double y) {
    final paint = Paint()
      ..color = _ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(-14, y), width: 12, height: 8),
      0.3, 2.6, false, paint,
    );
    canvas.drawArc(
      Rect.fromCenter(center: Offset(14, y), width: 12, height: 8),
      0.3, 2.6, false, paint,
    );
  }

  void _drawWorriedBrows(Canvas canvas) {
    final brow = Paint()
      ..color = _ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(-22, -20), const Offset(-8, -16), brow);
    canvas.drawLine(const Offset(22, -20), const Offset(8, -16), brow);
  }

  void _drawClosedEyes(Canvas canvas, double y) {
    final paint = Paint()
      ..color = _ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(-20, y), Offset(-8, y), paint);
    canvas.drawLine(Offset(8, y), Offset(20, y), paint);
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
          Rect.fromCenter(center: const Offset(0, 10), width: 18, height: 10),
          0.2, 2.8, false, paint,
        );
      case PennyGuideState.worried:
        canvas.drawArc(
          Rect.fromCenter(center: const Offset(0, 16), width: 12, height: 7),
          3.5, 2, false, paint,
        );
      case PennyGuideState.think:
        canvas.drawCircle(const Offset(4, 12), 2.5, paint);
      case PennyGuideState.sleep:
        canvas.drawLine(const Offset(-3, 12), const Offset(3, 12), paint);
      default:
        canvas.drawLine(const Offset(-5, 12), const Offset(5, 12), paint);
    }
  }

  void _drawExtras(Canvas canvas) {
    if (state == PennyGuideState.wave) {
      final arm = Paint()
        ..color = _furLight
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(const Offset(36, 8), const Offset(54, -24), arm);
      canvas.drawCircle(const Offset(54, -24), 9, Paint()..color = _fur);
    }

    if (state == PennyGuideState.celebrate || state == PennyGuideState.levelUp) {
      _sparkle(canvas, const Offset(-48, -44), _gold);
      _sparkle(canvas, const Offset(50, -40), _brandLight);
      _sparkle(canvas, const Offset(44, 48), _brand);
    }
  }

  void _sparkle(Canvas canvas, Offset pos, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(pos, pos + const Offset(0, -7), paint);
    canvas.drawLine(pos, pos + const Offset(5, 0), paint);
    canvas.drawLine(pos, pos + const Offset(0, 5), paint);
    canvas.drawLine(pos, pos + const Offset(-5, 0), paint);
  }

  @override
  bool shouldRepaint(covariant _BearFallbackPainter oldDelegate) {
    return oldDelegate.state != state ||
        oldDelegate.breathOffset != breathOffset;
  }
}
