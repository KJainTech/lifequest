import 'package:flutter/material.dart';

import '../features/onboarding/age_band.dart';
import '../core/tokens/lq_tokens.dart';
import 'penny_mascot.dart';

enum LQGuide { penny, finBot, atlas }

extension LQGuideX on LQGuide {
  String get id => switch (this) {
        LQGuide.penny => 'penny',
        LQGuide.finBot => 'finBot',
        LQGuide.atlas => 'atlas',
      };

  static LQGuide fromId(String id) => switch (id) {
        'finBot' => LQGuide.finBot,
        'atlas' => LQGuide.atlas,
        _ => LQGuide.penny,
      };
}

/// Guide mascot — Penny uses Rive/fallback; FinBot & Atlas use custom painters.
class GuideMascot extends StatelessWidget {
  const GuideMascot({
    super.key,
    required this.guide,
    this.state = PennyGuideState.idle,
    this.size = 120,
    this.selected = false,
  });

  final LQGuide guide;
  final PennyGuideState state;
  final double size;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    Widget mascot = switch (guide) {
      LQGuide.penny => PennyMascot(state: state, size: size),
      LQGuide.finBot => CustomPaint(
          size: Size(size, size),
          painter: _FinBotPainter(state: state),
        ),
      LQGuide.atlas => CustomPaint(
          size: Size(size, size),
          painter: _AtlasPainter(state: state),
        ),
    };

    if (!selected) return mascot;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: LQColors.forWorld(guideToWorld(guide.id)).brand,
          width: 3,
        ),
      ),
      child: mascot,
    );
  }
}

class _FinBotPainter extends CustomPainter {
  _FinBotPainter({required this.state});

  final PennyGuideState state;
  static const _navy = Color(0xFF161D33);
  static const _cyan = Color(0xFF45F0E0);
  static const _blue = Color(0xFF5B8DEF);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 120;
    canvas.scale(s);
    final body = Paint()..color = _navy;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(30, 35, 60, 55),
        const Radius.circular(12),
      ),
      body,
    );
    canvas.drawCircle(const Offset(60, 30), 22, body);
    final eye = Paint()..color = _cyan;
    canvas.drawCircle(const Offset(50, 28), 6, eye);
    canvas.drawCircle(const Offset(70, 28), 6, eye);
    final ticker = Paint()..color = _blue.withValues(alpha: 0.4);
    canvas.drawRect(const Rect.fromLTWH(40, 55, 40, 16), ticker);
    final tickerLine = Paint()
      ..color = _cyan
      ..strokeWidth = 2;
    canvas.drawLine(const Offset(42, 63), const Offset(78, 63), tickerLine);
    if (state == PennyGuideState.happy ||
        state == PennyGuideState.celebrate) {
      canvas.drawLine(const Offset(48, 42), const Offset(72, 42),
          tickerLine..strokeCap = StrokeCap.round);
    }
  }

  @override
  bool shouldRepaint(covariant _FinBotPainter oldDelegate) =>
      oldDelegate.state != state;
}

class _AtlasPainter extends CustomPainter {
  _AtlasPainter({required this.state});

  final PennyGuideState state;
  static const _graphite = Color(0xFF1A2226);
  static const _emerald = Color(0xFF1FA873);
  static const _gold = Color(0xFFC8A24A);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 120;
    canvas.scale(s);
    final head = Paint()..color = const Color(0xFFE8C4A8);
    canvas.drawCircle(const Offset(60, 32), 20, head);
    final visor = Paint()..color = _emerald.withValues(alpha: 0.7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(38, 24, 44, 14),
        const Radius.circular(7),
      ),
      visor,
    );
    final body = Paint()..color = _graphite;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(35, 52, 50, 45),
        const Radius.circular(10),
      ),
      body,
    );
    final accent = Paint()..color = _gold;
    canvas.drawCircle(const Offset(60, 70), 8, accent);
    if (state == PennyGuideState.celebrate) {
      canvas.drawCircle(const Offset(30, 20), 3, accent);
      canvas.drawCircle(const Offset(90, 18), 3, accent);
    }
  }

  @override
  bool shouldRepaint(covariant _AtlasPainter oldDelegate) =>
      oldDelegate.state != state;
}
