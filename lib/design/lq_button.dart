import 'package:flutter/material.dart';

import '../core/haptics/lq_haptics.dart';
import '../core/motion/lq_motion.dart';
import '../core/tokens/lq_tokens.dart';
import '../core/tokens/lq_typography.dart';

enum LQButtonVariant { primary, secondary, ghost, danger }

enum LQButtonSize { sm, md, lg }

/// Primary interactive button with spring press feedback per §4.5
class LQButton extends StatefulWidget {
  const LQButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.colors,
    this.variant = LQButtonVariant.primary,
    this.size = LQButtonSize.md,
    this.icon,
    this.expanded = false,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final LQColors colors;
  final LQButtonVariant variant;
  final LQButtonSize size;
  final IconData? icon;
  final bool expanded;
  final bool enabled;

  @override
  State<LQButton> createState() => _LQButtonState();
}

class _LQButtonState extends State<LQButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: LQMotion.pressDuration,
      reverseDuration: LQMotion.pressDuration,
    );
    _scale = Tween<double>(begin: 1, end: LQMotion.pressScale).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.enabled && widget.onPressed != null) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails _) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  void _onTap() {
    if (!widget.enabled || widget.onPressed == null) return;
    LQHaptics.selectionClick();
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final height = switch (widget.size) {
      LQButtonSize.sm => 40.0,
      LQButtonSize.md => LQTouch.minTarget,
      LQButtonSize.lg => 56.0,
    };

    final horizontalPadding = switch (widget.size) {
      LQButtonSize.sm => LQSpacing.lg,
      LQButtonSize.md => LQSpacing.xxl,
      LQButtonSize.lg => LQSpacing.xxxl,
    };

    final (bg, fg, border) = _colorsForVariant();

    final child = AnimatedBuilder(
      animation: _scale,
      builder: (context, child) {
        return Transform.scale(scale: _scale.value, child: child);
      },
      child: Material(
        color: bg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LQRadius.control),
          side: border ?? BorderSide.none,
        ),
        child: InkWell(
          onTap: _onTap,
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          borderRadius: BorderRadius.circular(LQRadius.control),
          child: Container(
            height: height,
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            constraints: BoxConstraints(
              minWidth: widget.expanded ? double.infinity : LQTouch.minTarget,
            ),
            child: Row(
              mainAxisSize:
                  widget.expanded ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, color: fg, size: 20),
                  const SizedBox(width: LQSpacing.sm),
                ],
                Text(
                  widget.label,
                  style: LQTypography.h3(widget.colors).copyWith(color: fg),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return Opacity(
      opacity: widget.enabled ? 1 : 0.5,
      child: widget.expanded ? SizedBox(width: double.infinity, child: child) : child,
    );
  }

  (Color, Color, BorderSide?) _colorsForVariant() {
    final c = widget.colors;
    return switch (widget.variant) {
      LQButtonVariant.primary => (c.brand, Colors.white, null),
      LQButtonVariant.secondary => (
          c.surface,
          c.brand,
          BorderSide(color: c.brand.withValues(alpha: 0.3)),
        ),
      LQButtonVariant.ghost => (
          Colors.transparent,
          c.brand,
          null,
        ),
      LQButtonVariant.danger => (c.danger, Colors.white, null),
    };
  }
}
