import 'package:flutter/material.dart';

/// Custom duotone icon set — 1.75px stroke, rounded joins per §4.8
enum LQIconType {
  home,
  learn,
  city,
  progress,
  profile,
  coin,
  trophy,
  coffee,
  piggyBank,
  chart,
  settings,
  notification,
}

class LQDuotoneIcon extends StatelessWidget {
  const LQDuotoneIcon({
    super.key,
    required this.icon,
    this.size = 24,
    required this.primaryColor,
    required this.secondaryColor,
  });

  final LQIconType icon;
  final double size;
  final Color primaryColor;
  final Color secondaryColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _DuotoneIconPainter(
        icon: icon,
        primaryColor: primaryColor,
        secondaryColor: secondaryColor,
      ),
    );
  }
}

class _DuotoneIconPainter extends CustomPainter {
  _DuotoneIconPainter({
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
  });

  final LQIconType icon;
  final Color primaryColor;
  final Color secondaryColor;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24;
    canvas.scale(scale);

    final fillPaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.75
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (icon) {
      case LQIconType.home:
        _drawHome(canvas, fillPaint, strokePaint);
      case LQIconType.learn:
        _drawLearn(canvas, fillPaint, strokePaint);
      case LQIconType.city:
        _drawCity(canvas, fillPaint, strokePaint);
      case LQIconType.progress:
        _drawProgress(canvas, fillPaint, strokePaint);
      case LQIconType.profile:
        _drawProfile(canvas, fillPaint, strokePaint);
      case LQIconType.coin:
        _drawCoin(canvas, fillPaint, strokePaint);
      case LQIconType.trophy:
        _drawTrophy(canvas, fillPaint, strokePaint);
      case LQIconType.coffee:
        _drawCoffee(canvas, fillPaint, strokePaint);
      case LQIconType.piggyBank:
        _drawPiggyBank(canvas, fillPaint, strokePaint);
      case LQIconType.chart:
        _drawChart(canvas, fillPaint, strokePaint);
      case LQIconType.settings:
        _drawSettings(canvas, fillPaint, strokePaint);
      case LQIconType.notification:
        _drawNotification(canvas, fillPaint, strokePaint);
    }
  }

  void _drawHome(Canvas canvas, Paint fill, Paint stroke) {
    final roof = Path()
      ..moveTo(12, 3)
      ..lineTo(21, 11)
      ..lineTo(3, 11)
      ..close();
    canvas.drawPath(roof, fill);
    canvas.drawPath(roof, stroke);
    final body = RRect.fromRectAndRadius(
      const Rect.fromLTWH(5, 11, 14, 10),
      const Radius.circular(2),
    );
    canvas.drawRRect(body, fill);
    canvas.drawRRect(body, stroke);
  }

  void _drawLearn(Canvas canvas, Paint fill, Paint stroke) {
    final book = RRect.fromRectAndRadius(
      const Rect.fromLTWH(4, 4, 16, 16),
      const Radius.circular(3),
    );
    canvas.drawRRect(book, fill);
    canvas.drawRRect(book, stroke);
    canvas.drawLine(const Offset(12, 4), const Offset(12, 20), stroke);
  }

  void _drawCity(Canvas canvas, Paint fill, Paint stroke) {
    canvas.drawRect(const Rect.fromLTWH(3, 12, 6, 9), fill);
    canvas.drawRect(const Rect.fromLTWH(3, 12, 6, 9), stroke);
    canvas.drawRect(const Rect.fromLTWH(10, 8, 5, 13), fill);
    canvas.drawRect(const Rect.fromLTWH(10, 8, 5, 13), stroke);
    canvas.drawRect(const Rect.fromLTWH(16, 5, 5, 16), fill);
    canvas.drawRect(const Rect.fromLTWH(16, 5, 5, 16), stroke);
  }

  void _drawProgress(Canvas canvas, Paint fill, Paint stroke) {
    canvas.drawLine(const Offset(4, 18), const Offset(4, 10), stroke);
    canvas.drawLine(const Offset(10, 18), const Offset(10, 6), stroke);
    canvas.drawLine(const Offset(16, 18), const Offset(16, 12), stroke);
    canvas.drawLine(const Offset(22, 18), const Offset(22, 8), stroke);
    canvas.drawCircle(const Offset(4, 10), 2, fill);
    canvas.drawCircle(const Offset(10, 6), 2, fill);
    canvas.drawCircle(const Offset(16, 12), 2, fill);
    canvas.drawCircle(const Offset(22, 8), 2, fill);
  }

  void _drawProfile(Canvas canvas, Paint fill, Paint stroke) {
    canvas.drawCircle(const Offset(12, 8), 4, fill);
    canvas.drawCircle(const Offset(12, 8), 4, stroke);
    final body = Path()
      ..moveTo(5, 20)
      ..quadraticBezierTo(12, 14, 19, 20);
    canvas.drawPath(body, stroke);
    canvas.drawPath(body, fill);
  }

  void _drawCoin(Canvas canvas, Paint fill, Paint stroke) {
    canvas.drawCircle(const Offset(12, 12), 8, fill);
    canvas.drawCircle(const Offset(12, 12), 8, stroke);
    canvas.drawLine(const Offset(12, 7), const Offset(12, 17), stroke);
  }

  void _drawTrophy(Canvas canvas, Paint fill, Paint stroke) {
    final cup = RRect.fromRectAndRadius(
      const Rect.fromLTWH(7, 5, 10, 10),
      const Radius.circular(3),
    );
    canvas.drawRRect(cup, fill);
    canvas.drawRRect(cup, stroke);
    canvas.drawLine(const Offset(7, 18), const Offset(17, 18), stroke);
    canvas.drawLine(const Offset(12, 15), const Offset(12, 18), stroke);
  }

  void _drawCoffee(Canvas canvas, Paint fill, Paint stroke) {
    final cup = RRect.fromRectAndRadius(
      const Rect.fromLTWH(5, 8, 10, 10),
      const Radius.circular(2),
    );
    canvas.drawRRect(cup, fill);
    canvas.drawRRect(cup, stroke);
    canvas.drawArc(
      const Rect.fromLTWH(14, 9, 5, 6),
      -0.5,
      2.5,
      false,
      stroke,
    );
  }

  void _drawPiggyBank(Canvas canvas, Paint fill, Paint stroke) {
    canvas.drawOval(const Rect.fromLTWH(4, 8, 14, 10), fill);
    canvas.drawOval(const Rect.fromLTWH(4, 8, 14, 10), stroke);
    canvas.drawCircle(const Offset(17, 10), 2, stroke);
  }

  void _drawChart(Canvas canvas, Paint fill, Paint stroke) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(4, 4, 16, 16),
        const Radius.circular(3),
      ),
      stroke,
    );
    canvas.drawLine(const Offset(8, 16), const Offset(8, 10), stroke);
    canvas.drawLine(const Offset(12, 16), const Offset(12, 7), stroke);
    canvas.drawLine(const Offset(16, 16), const Offset(16, 12), stroke);
  }

  void _drawSettings(Canvas canvas, Paint fill, Paint stroke) {
    canvas.drawCircle(const Offset(12, 12), 3, fill);
    canvas.drawCircle(const Offset(12, 12), 7, stroke);
  }

  void _drawNotification(Canvas canvas, Paint fill, Paint stroke) {
    final bell = Path()
      ..moveTo(12, 4)
      ..lineTo(18, 10)
      ..lineTo(18, 14)
      ..lineTo(6, 14)
      ..lineTo(6, 10)
      ..close();
    canvas.drawPath(bell, fill);
    canvas.drawPath(bell, stroke);
    canvas.drawCircle(const Offset(12, 17), 2, stroke);
  }

  @override
  bool shouldRepaint(covariant _DuotoneIconPainter oldDelegate) {
    return oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor ||
        oldDelegate.icon != icon;
  }
}
