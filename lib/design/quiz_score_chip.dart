import 'package:flutter/material.dart';

import '../core/tokens/lq_tokens.dart';
import '../core/tokens/lq_typography.dart';

/// Live quiz score — bumps when the child answers correctly.
class QuizScoreChip extends StatefulWidget {
  const QuizScoreChip({
    super.key,
    required this.colors,
    required this.correct,
    required this.total,
    this.pulseToken = 0,
  });

  final LQColors colors;
  final int correct;
  final int total;
  final int pulseToken;

  @override
  State<QuizScoreChip> createState() => _QuizScoreChipState();
}

class _QuizScoreChipState extends State<QuizScoreChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.18), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 1.18, end: 1.0), weight: 65),
    ]).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeOutCubic));
  }

  @override
  void didUpdateWidget(QuizScoreChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pulseToken != oldWidget.pulseToken) {
      _pulse.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (context, child) {
        return Transform.scale(scale: _scale.value, child: child);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: LQSpacing.md,
          vertical: LQSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: widget.colors.success.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(LQRadius.chip),
          border: Border.all(
            color: widget.colors.success.withValues(alpha: 0.28),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star_rounded,
              size: 16,
              color: widget.colors.success,
            ),
            const SizedBox(width: LQSpacing.xs),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              transitionBuilder: (child, anim) => ScaleTransition(
                scale: anim,
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: Text(
                '${widget.correct} / ${widget.total}',
                key: ValueKey(widget.correct),
                style: LQTypography.caption(widget.colors).copyWith(
                  color: widget.colors.success,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Brief “Correct!” toast after a right answer.
class QuizSuccessToast extends StatelessWidget {
  const QuizSuccessToast({super.key, required this.colors});

  final LQColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LQSpacing.lg,
        vertical: LQSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.success,
        borderRadius: BorderRadius.circular(LQRadius.pill),
        boxShadow: LQElevation.e2(colors.ink),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_rounded, color: Colors.white, size: 18),
          const SizedBox(width: LQSpacing.xs),
          Text(
            'Correct! +1',
            style: LQTypography.caption(colors).copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
