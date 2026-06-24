import 'package:flutter/material.dart';

import '../core/audio/lq_sound_service.dart';
import '../core/tokens/lq_tokens.dart';
import '../core/tokens/lq_typography.dart';

enum QuizChoiceState { idle, selected, correct, incorrect, dimmed }

/// Apple-clean quiz answer tile — soft when idle, bold only on selection.
class LQQuizChoice extends StatefulWidget {
  const LQQuizChoice({
    super.key,
    required this.label,
    required this.colors,
    required this.state,
    required this.onTap,
    this.enabled = true,
    this.indexLabel,
  });

  final String label;
  final LQColors colors;
  final QuizChoiceState state;
  final VoidCallback? onTap;
  final bool enabled;
  final String? indexLabel;

  @override
  State<LQQuizChoice> createState() => _LQQuizChoiceState();
}

class _LQQuizChoiceState extends State<LQQuizChoice>
    with SingleTickerProviderStateMixin {
  late AnimationController _press;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 120),
    );
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    final dimmed = s == QuizChoiceState.dimmed;
    final selected = s == QuizChoiceState.selected;
    final correct = s == QuizChoiceState.correct;
    final wrong = s == QuizChoiceState.incorrect;
    final idle = s == QuizChoiceState.idle;

    final bg = correct
        ? widget.colors.success.withValues(alpha: 0.14)
        : wrong
            ? widget.colors.danger.withValues(alpha: 0.12)
            : selected
                ? widget.colors.brand.withValues(alpha: 0.08)
                : idle
                    ? widget.colors.surface
                    : widget.colors.surface;

    final borderColor = correct
        ? widget.colors.success
        : wrong
            ? widget.colors.danger
            : selected
                ? widget.colors.brand
                : idle
                    ? widget.colors.ink.withValues(alpha: 0.12)
                    : widget.colors.ink.withValues(alpha: 0.08);

    final borderWidth = selected || correct || wrong ? 2.0 : 1.0;

    final textColor = dimmed
        ? widget.colors.inkSoft.withValues(alpha: 0.45)
        : idle
            ? widget.colors.ink
            : widget.colors.ink;

    final opacity = dimmed ? 0.55 : 1.0;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 220),
      opacity: opacity,
      child: GestureDetector(
        onTapDown: widget.enabled && widget.onTap != null
            ? (_) {
                LQSound.unlock();
                _press.forward();
              }
            : null,
        onTapUp: widget.enabled && widget.onTap != null
            ? (_) => _press.reverse()
            : null,
        onTapCancel: () => _press.reverse(),
        onTap: widget.enabled && widget.onTap != null
            ? () => widget.onTap!()
            : null,
        child: AnimatedBuilder(
          animation: _press,
          builder: (context, child) {
            return Transform.scale(
              scale: 1 - (_press.value * 0.02),
              child: child,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            transform: correct
                ? (Matrix4.identity()..scale(1.02))
                : Matrix4.identity(),
            constraints: const BoxConstraints(minHeight: LQTouch.minTarget),
            padding: const EdgeInsets.symmetric(
              horizontal: LQSpacing.lg,
              vertical: LQSpacing.md,
            ),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(LQRadius.control),
              border: Border.all(color: borderColor, width: borderWidth),
              boxShadow: selected || correct
                  ? LQElevation.e1(widget.colors.ink)
                  : idle
                      ? LQElevation.e1(widget.colors.ink.withValues(alpha: 0.06))
                      : null,
            ),
            child: Row(
              children: [
                if (widget.indexLabel != null) ...[
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected || correct || wrong
                          ? borderColor.withValues(alpha: 0.15)
                          : widget.colors.canvasStart,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      widget.indexLabel!,
                      style: LQTypography.caption(widget.colors).copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: LQSpacing.md),
                ],
                Expanded(
                  child: Text(
                    widget.label,
                    style: LQTypography.body(widget.colors).copyWith(
                      color: textColor,
                      fontWeight: selected || correct || wrong
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                ),
                if (correct)
                  Icon(Icons.check_circle_rounded, color: widget.colors.success, size: 22)
                else if (wrong)
                  Icon(Icons.cancel_rounded, color: widget.colors.danger, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Question progress — soft dots like premium learning apps.
class LQQuizProgress extends StatelessWidget {
  const LQQuizProgress({
    super.key,
    required this.colors,
    required this.current,
    required this.total,
  });

  final LQColors colors;
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final done = i < current;
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: done
                ? colors.brand
                : active
                    ? colors.brandDeep
                    : colors.ink.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(LQRadius.pill),
          ),
        );
      }),
    );
  }
}
