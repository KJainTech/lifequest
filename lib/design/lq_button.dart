import 'package:flutter/material.dart';

import '../core/audio/lq_sound_service.dart';
import '../core/motion/lq_motion.dart';
import '../core/tokens/lq_tokens.dart';
import '../core/tokens/lq_typography.dart';

enum LQButtonVariant { primary, secondary, ghost, danger }

enum LQButtonSize { sm, md, lg }

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
  bool _pressed = false;

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
      LQSound.unlock();
      setState(() => _pressed = true);
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails _) {
    setState(() => _pressed = false);
    _controller.reverse();
  }

  void _onTapCancel() {
    setState(() => _pressed = false);
    _controller.reverse();
  }

  void _onTap() {
    if (!widget.enabled || widget.onPressed == null) return;
    LQSound.tap();
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final height = switch (widget.size) {
      LQButtonSize.sm => 40.0,
      LQButtonSize.md => LQTouch.minTarget,
      LQButtonSize.lg => 54.0,
    };

    final horizontalPadding = switch (widget.size) {
      LQButtonSize.sm => LQSpacing.lg,
      LQButtonSize.md => LQSpacing.xxl,
      LQButtonSize.lg => 28.0,
    };

    final (bg, fg, borderSide, shadow) = _styleForVariant();

    final child = AnimatedBuilder(
      animation: _scale,
      builder: (context, child) => Transform.scale(scale: _scale.value, child: child),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: height,
        constraints: BoxConstraints(
          minWidth: widget.expanded ? double.infinity : LQTouch.minTarget,
        ),
        decoration: BoxDecoration(
          color: _pressed && widget.variant == LQButtonVariant.primary
              ? widget.colors.brandHover
              : bg,
          borderRadius: BorderRadius.circular(LQRadius.button),
          border: borderSide != null ? Border.fromBorderSide(borderSide) : null,
          boxShadow: shadow,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _onTap,
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            borderRadius: BorderRadius.circular(LQRadius.button),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Row(
                mainAxisSize:
                    widget.expanded ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, color: fg, size: 20),
                    const SizedBox(width: LQSpacing.sm),
                  ],
                  Text(widget.label, style: LQTypography.button(widget.colors, fg: fg)),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return Opacity(
      opacity: widget.enabled ? 1 : 0.45,
      child: widget.expanded ? SizedBox(width: double.infinity, child: child) : child,
    );
  }

  (Color, Color, BorderSide?, List<BoxShadow>?) _styleForVariant() {
    final c = widget.colors;
    return switch (widget.variant) {
      LQButtonVariant.primary => (
          c.brand,
          Colors.white,
          null,
          LQElevation.cta(c.brand),
        ),
      LQButtonVariant.secondary => (
          c.surface,
          c.ink,
          BorderSide(color: c.border, width: 1.5),
          LQElevation.e1(c.ink),
        ),
      LQButtonVariant.ghost => (
          Colors.transparent,
          c.brandDeep,
          BorderSide(color: c.border),
          null,
        ),
      LQButtonVariant.danger => (
          c.danger,
          Colors.white,
          null,
          LQElevation.cta(c.danger),
        ),
    };
  }
}
