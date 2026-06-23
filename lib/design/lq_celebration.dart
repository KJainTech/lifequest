import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/tokens/lq_tokens.dart';

/// Kid-friendly success burst — confetti + scale pop (Apple-playful, not casino).
class LQCelebrationBurst extends StatefulWidget {
  const LQCelebrationBurst({
    super.key,
    required this.colors,
    this.active = true,
    this.particleCount = 24,
  });

  final LQColors colors;
  final bool active;
  final int particleCount;

  @override
  State<LQCelebrationBurst> createState() => _LQCelebrationBurstState();
}

class _LQCelebrationBurstState extends State<LQCelebrationBurst>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (widget.active) _controller.forward();
  }

  @override
  void didUpdateWidget(LQCelebrationBurst oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return const SizedBox.shrink();

    final palette = [
      widget.colors.gold,
      widget.colors.brand,
      widget.colors.accentMint,
      widget.colors.coral,
    ];

    return IgnorePointer(
      child: SizedBox.expand(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Stack(
              children: List.generate(widget.particleCount, (i) {
                final t = Curves.easeOutCubic.transform(_controller.value);
                final angle = (i / widget.particleCount) * math.pi * 2;
                final radius = 40 + (i % 5) * 18 + t * 120;
                final dx = math.cos(angle) * radius;
                final dy = math.sin(angle) * radius - t * 30;
                final size = 6.0 + (i % 4) * 3;
                final color = palette[i % palette.length];

                return Positioned(
                  left: MediaQuery.sizeOf(context).width / 2 + dx - size / 2,
                  top: MediaQuery.sizeOf(context).height * 0.32 + dy,
                  child: Opacity(
                    opacity: (1 - t).clamp(0.0, 1.0),
                    child: Transform.rotate(
                      angle: t * 3 + i,
                      child: Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(i.isOdd ? 2 : 99),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}

/// Pops in with elastic bounce — use for stars, badges, CTAs.
class LQSuccessPop extends StatelessWidget {
  const LQSuccessPop({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  final Widget child;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return child
        .animate(delay: delay)
        .fadeIn(duration: 280.ms)
        .scale(
          begin: const Offset(0.6, 0.6),
          end: const Offset(1, 1),
          curve: Curves.elasticOut,
          duration: 650.ms,
        );
  }
}
