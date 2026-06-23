import 'package:flutter/material.dart';

import '../core/tokens/lq_tokens.dart';
import '../core/tokens/lq_typography.dart';

/// Mastery badge — earned or locked
class LQBadge extends StatelessWidget {
  const LQBadge({
    super.key,
    required this.colors,
    required this.title,
    required this.subtitle,
    this.icon,
    this.locked = false,
    this.size = 88,
  });

  final LQColors colors;
  final String title;
  final String subtitle;
  final Widget? icon;
  final bool locked;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size + 16,
      child: Column(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: locked
                  ? colors.canvasEnd
                  : colors.gold.withValues(alpha: 0.15),
              border: Border.all(
                color: locked
                    ? colors.inkSoft.withValues(alpha: 0.2)
                    : colors.gold.withValues(alpha: 0.4),
                width: 2,
              ),
              boxShadow: locked ? null : LQElevation.e1(colors.ink),
            ),
            child: Center(
              child: Opacity(
                opacity: locked ? 0.35 : 1,
                child: icon ??
                    Icon(
                      locked ? Icons.lock_outline_rounded : Icons.star_rounded,
                      color: locked ? colors.inkSoft : colors.gold,
                      size: 32,
                    ),
              ),
            ),
          ),
          const SizedBox(height: LQSpacing.sm),
          Text(
            title,
            style: LQTypography.caption(colors).copyWith(
              fontWeight: FontWeight.w700,
              color: locked ? colors.inkSoft : colors.ink,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            subtitle,
            style: LQTypography.micro(colors),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
