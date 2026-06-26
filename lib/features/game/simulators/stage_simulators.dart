import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/tokens/lq_tokens.dart';
import '../../../core/tokens/lq_typography.dart';
import '../../../design/lq_button.dart';

typedef SimulatorComplete = void Function(int scoreOutOf5);

/// Credit Score Simulator — arc gauge + 6 money-trust decisions (review L5.5).
class CreditScoreSimulator extends StatefulWidget {
  const CreditScoreSimulator({
    super.key,
    required this.colors,
    required this.onComplete,
  });

  final LQColors colors;
  final SimulatorComplete onComplete;

  @override
  State<CreditScoreSimulator> createState() => _CreditScoreSimulatorState();
}

class _CreditScoreSimulatorState extends State<CreditScoreSimulator>
    with SingleTickerProviderStateMixin {
  static const _decisions = <_Decision>[
    _Decision(
      prompt: 'You want new headphones. What helps your score most?',
      choices: [
        _Choice('Save half first, then buy', 18),
        _Choice('Buy now on “easy pay later”', -22),
        _Choice('Borrow from a friend secretly', -15),
      ],
    ),
    _Decision(
      prompt: 'A friend asks you to co-sign a big purchase. You…',
      choices: [
        _Choice('Say no — ask a parent first', 12),
        _Choice('Sign to be helpful', -20),
        _Choice('Ignore the message', 0),
      ],
    ),
    _Decision(
      prompt: 'Your allowance arrives. Best move?',
      choices: [
        _Choice('Pay any “IOU” on time', 16),
        _Choice('Spend it all today', -10),
        _Choice('Hide it and forget bills', -18),
      ],
    ),
    _Decision(
      prompt: 'You spot a “double your coins” ad online.',
      choices: [
        _Choice('Report it — too good to be true', 14),
        _Choice('Click and enter details', -25),
        _Choice('Share with friends', -12),
      ],
    ),
    _Decision(
      prompt: 'Splitting a group gift — you…',
      choices: [
        _Choice('Track who paid what clearly', 10),
        _Choice('Let one person cover everything', -5),
        _Choice('Ghost the group chat', -16),
      ],
    ),
    _Decision(
      prompt: 'Goal: raise your trust score long-term.',
      choices: [
        _Choice('Small regular saves + on-time choices', 20),
        _Choice('One big risky bet', -14),
        _Choice('Never spend anything ever', 2),
      ],
    ),
  ];

  int _step = 0;
  int _score = 620;
  int? _finalQuizScore;
  late final AnimationController _needle;
  late Animation<double> _needleAnim;

  @override
  void initState() {
    super.initState();
    _needle = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _needleAnim = CurvedAnimation(parent: _needle, curve: Curves.easeOutCubic);
    _needle.forward();
  }

  @override
  void dispose() {
    _needle.dispose();
    super.dispose();
  }

  void _pick(_Choice choice) {
    setState(() {
      _score = (_score + choice.delta).clamp(300, 850);
      _step++;
    });
    _needle
      ..reset()
      ..forward();

    if (_step >= _decisions.length) {
      _finalQuizScore = _score >= 720
          ? 5
          : _score >= 650
              ? 4
              : _score >= 580
                  ? 3
                  : _score >= 500
                      ? 2
                      : 1;
    }
  }

  void _finishCredit() {
    if (_finalQuizScore != null) widget.onComplete(_finalQuizScore!);
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final done = _step >= _decisions.length;
    final decision = done ? null : _decisions[_step];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Credit Score Simulator',
          style: LQTypography.h2(colors),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: LQSpacing.xs),
        Text(
          'Money Trust Score · like a grown-up credit score, but for smart habits',
          style: LQTypography.bodySm(colors),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: LQSpacing.lg),
        SizedBox(
          height: 180,
          child: AnimatedBuilder(
            animation: _needleAnim,
            builder: (context, _) {
              final display = 300 + (_score - 300) * _needleAnim.value;
              return CustomPaint(
                painter: _ArcGaugePainter(
                  score: display,
                  colors: colors,
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 48),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          display.round().toString(),
                          style: LQTypography.display(colors).copyWith(
                            fontSize: 42,
                            height: 1,
                          ),
                        ),
                        Text(
                          _bandLabel(_score),
                          style: LQTypography.label(colors).copyWith(
                            color: colors.brand,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: LQSpacing.lg),
        if (done)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Nice work! Your choices shaped your score.',
                style: LQTypography.bodySm(colors),
                textAlign: TextAlign.center,
              ).animate().fadeIn(),
              const SizedBox(height: LQSpacing.md),
              LQButton(
                label: 'Continue',
                colors: colors,
                expanded: true,
                onPressed: _finishCredit,
              ),
            ],
          )
        else ...[
          Text(
            'Decision ${_step + 1} of ${_decisions.length}',
            style: LQTypography.caption(colors),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: LQSpacing.sm),
          Text(
            decision!.prompt,
            style: LQTypography.h3(colors),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: LQSpacing.lg),
          ...decision.choices.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: LQSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: _ChoiceTag(colors: colors, delta: c.delta),
                  ),
                  const SizedBox(height: 4),
                  LQButton(
                    label: c.label,
                    colors: colors,
                    variant: LQButtonVariant.secondary,
                    expanded: true,
                    onPressed: () => _pick(c),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _bandLabel(int score) {
    if (score >= 720) return 'Excellent trust';
    if (score >= 650) return 'Good habits';
    if (score >= 580) return 'Building up';
    return 'Needs care';
  }
}

class _Decision {
  const _Decision({required this.prompt, required this.choices});
  final String prompt;
  final List<_Choice> choices;
}

class _Choice {
  const _Choice(this.label, this.delta);
  final String label;
  final int delta;
}

class _ChoiceTag extends StatelessWidget {
  const _ChoiceTag({required this.colors, required this.delta});

  final LQColors colors;
  final int delta;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (delta) {
      > 0 => ('Builds trust', colors.success),
      < 0 => ('Risky move', colors.danger),
      _ => ('Neutral', colors.inkSoft),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(LQRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: LQTypography.micro(colors).copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ArcGaugePainter extends CustomPainter {
  _ArcGaugePainter({required this.score, required this.colors});

  final double score;
  final LQColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.92);
    const sweep = math.pi * 0.85;
    const start = math.pi + (math.pi - sweep) / 2;
    const stroke = 14.0;
    final rect = Rect.fromCircle(center: center, radius: size.width * 0.38);

    final track = Paint()
      ..color = colors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, start, sweep, false, track);

    final zones = [
      (0.0, 0.35, colors.danger),
      (0.35, 0.55, colors.warn),
      (0.55, 0.75, colors.gold),
      (0.75, 1.0, colors.brand),
    ];
    for (final (a, b, color) in zones) {
      final zone = Paint()
        ..color = color.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(rect, start + sweep * a, sweep * (b - a), false, zone);
    }

    final t = ((score - 300) / 550).clamp(0.0, 1.0);
    final angle = start + sweep * t;
    final needleLen = size.width * 0.32;
    final tip = Offset(
      center.dx + needleLen * math.cos(angle),
      center.dy + needleLen * math.sin(angle),
    );
    final needle = Paint()
      ..color = colors.ink
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, tip, needle);
    canvas.drawCircle(center, 8, Paint()..color = colors.gold);
  }

  @override
  bool shouldRepaint(covariant _ArcGaugePainter old) => old.score != score;
}

/// Crash Experiment — market graph + STAY / SELL / BUY (review L4.6).
class CrashExperimentSimulator extends StatefulWidget {
  const CrashExperimentSimulator({
    super.key,
    required this.colors,
    required this.onComplete,
  });

  final LQColors colors;
  final SimulatorComplete onComplete;

  @override
  State<CrashExperimentSimulator> createState() =>
      _CrashExperimentSimulatorState();
}

class _CrashExperimentSimulatorState extends State<CrashExperimentSimulator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _chart;
  bool _crashed = false;
  bool _answered = false;
  String? _feedback;
  int? _score;

  static const _points = <Offset>[
    Offset(0, 0.72),
    Offset(0.12, 0.65),
    Offset(0.24, 0.58),
    Offset(0.36, 0.48),
    Offset(0.48, 0.42),
    Offset(0.58, 0.38),
    Offset(0.68, 0.55),
    Offset(0.76, 0.78),
    Offset(0.84, 0.62),
    Offset(1.0, 0.58),
  ];

  @override
  void initState() {
    super.initState();
    _chart = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..forward().whenComplete(() {
        if (mounted) setState(() => _crashed = true);
      });
  }

  @override
  void dispose() {
    _chart.dispose();
    super.dispose();
  }

  void _respond(String action) {
    if (_answered) return;
    setState(() {
      _answered = true;
      switch (action) {
        case 'STAY':
          _feedback =
              'Smart! Markets bounce — panic selling often locks in losses. '
              'Patient investors think long-term.';
        case 'SELL':
          _feedback =
              'Selling in panic is common — but you may miss the recovery. '
              'Next time: breathe and check your plan first.';
        case 'BUY':
          _feedback =
              'Buying the dip can work — but only with savings set aside and '
              'a parent\'s OK. Never use money you need soon.';
      }
      _score = action == 'STAY' ? 5 : action == 'BUY' ? 3 : 1;
    });
  }

  void _finish() {
    if (_score != null) widget.onComplete(_score!);
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Crash Experiment',
          style: LQTypography.h2(colors),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: LQSpacing.xs),
        Text(
          'Watch the market wobble — what would you do?',
          style: LQTypography.bodySm(colors),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: LQSpacing.lg),
        AspectRatio(
          aspectRatio: 1.4,
          child: AnimatedBuilder(
            animation: _chart,
            builder: (context, _) {
              return CustomPaint(
                painter: _MarketChartPainter(
                  colors: colors,
                  progress: _chart.value,
                  points: _points,
                  showCrash: _crashed,
                ),
                child: _crashed
                    ? Align(
                        alignment: const Alignment(0.72, -0.55),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: LQSpacing.sm,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colors.danger,
                            borderRadius: BorderRadius.circular(LQRadius.pill),
                          ),
                          child: Text(
                            'CRASH!',
                            style: LQTypography.micro(colors).copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ).animate().shake(duration: 400.ms)
                    : null,
              );
            },
          ),
        ),
        const SizedBox(height: LQSpacing.lg),
        if (!_crashed)
          Text(
            'Chart loading…',
            style: LQTypography.caption(colors),
            textAlign: TextAlign.center,
          )
        else if (!_answered) ...[
          Text(
            'The line dropped fast! Your move?',
            style: LQTypography.h3(colors),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: LQSpacing.md),
          Row(
            children: [
              Expanded(
                child: LQButton(
                  label: 'STAY',
                  colors: colors,
                  expanded: true,
                  onPressed: () => _respond('STAY'),
                ),
              ),
              const SizedBox(width: LQSpacing.sm),
              Expanded(
                child: LQButton(
                  label: 'SELL',
                  colors: colors,
                  variant: LQButtonVariant.secondary,
                  expanded: true,
                  onPressed: () => _respond('SELL'),
                ),
              ),
              const SizedBox(width: LQSpacing.sm),
              Expanded(
                child: LQButton(
                  label: 'BUY',
                  colors: colors,
                  variant: LQButtonVariant.secondary,
                  expanded: true,
                  onPressed: () => _respond('BUY'),
                ),
              ),
            ],
          ),
        ] else ...[
          Text(
            _feedback ?? '',
            style: LQTypography.bodySm(colors),
            textAlign: TextAlign.center,
          ).animate().fadeIn(),
          const SizedBox(height: LQSpacing.md),
          LQButton(
            label: 'Continue',
            colors: colors,
            expanded: true,
            onPressed: _finish,
          ),
        ],
      ],
    );
  }
}

class _MarketChartPainter extends CustomPainter {
  _MarketChartPainter({
    required this.colors,
    required this.progress,
    required this.points,
    required this.showCrash,
  });

  final LQColors colors;
  final double progress;
  final List<Offset> points;
  final bool showCrash;

  @override
  void paint(Canvas canvas, Size size) {
    final pad = 16.0;
    final w = size.width - pad * 2;
    final h = size.height - pad * 2;

    final grid = Paint()
      ..color = colors.border
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final y = pad + h * i / 4;
      canvas.drawLine(Offset(pad, y), Offset(size.width - pad, y), grid);
    }

    final visible = (points.length * progress).ceil().clamp(2, points.length);
    final path = Path();
    for (var i = 0; i < visible; i++) {
      final p = points[i];
      final x = pad + p.dx * w;
      final y = pad + p.dy * h;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final fill = Path.from(path)
      ..lineTo(pad + points[visible - 1].dx * w, pad + h)
      ..lineTo(pad, pad + h)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colors.brand.withValues(alpha: 0.25),
            colors.brand.withValues(alpha: 0.02),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = showCrash ? colors.danger : colors.brand
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    if (showCrash && visible > 6) {
      final crash = points[6];
      final cx = pad + crash.dx * w;
      final cy = pad + crash.dy * h;
      canvas.drawCircle(
        Offset(cx, cy),
        8,
        Paint()..color = colors.danger,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MarketChartPainter old) =>
      old.progress != progress || old.showCrash != showCrash;
}
