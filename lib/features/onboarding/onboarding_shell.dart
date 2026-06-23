import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/motion/lq_motion.dart';
import '../../core/tokens/lq_tokens.dart';

/// Shared-axis page transition per Bible §4.5
CustomTransitionPage<T> lqSharedAxisPage<T>({
  required LocalKey key,
  required Widget child,
  bool forward = true,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionDuration: LQMotion.adaptiveDuration(
      const Duration(milliseconds: 350),
    ),
    reverseTransitionDuration: LQMotion.adaptiveDuration(
      const Duration(milliseconds: 300),
    ),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final offset = forward ? const Offset(0.08, 0) : const Offset(-0.08, 0);
      final slide = Tween<Offset>(begin: offset, end: Offset.zero).animate(
        CurvedAnimation(
          parent: animation,
          curve: LQMotion.prefersReducedMotion
              ? Curves.easeOut
              : Curves.easeOutCubic,
        ),
      );
      final fade = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      );
      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}

/// Onboarding shell with step progress and back navigation.
class OnboardingShell extends StatelessWidget {
  const OnboardingShell({
    super.key,
    required this.colors,
    required this.step,
    required this.totalSteps,
    required this.title,
    required this.child,
    this.subtitle,
    this.onBack,
  });

  final LQColors colors;
  final int step;
  final int totalSteps;
  final String title;
  final String? subtitle;
  final Widget child;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (onBack != null) ...[
          IconButton(
            onPressed: onBack,
            icon: Icon(Icons.arrow_back_rounded, color: colors.ink),
            tooltip: 'Back',
          ),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(LQRadius.pill),
          child: LinearProgressIndicator(
            value: step / totalSteps,
            minHeight: 4,
            backgroundColor: colors.canvasEnd,
            valueColor: AlwaysStoppedAnimation(colors.brand),
          ),
        ),
        const SizedBox(height: LQSpacing.xxl),
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        if (subtitle != null) ...[
          const SizedBox(height: LQSpacing.sm),
          Text(
            subtitle!,
            style: TextStyle(color: colors.inkSoft, height: 1.5),
          ),
        ],
        const SizedBox(height: LQSpacing.xxxl),
        Expanded(child: child),
      ],
    );
  }
}

void onboardingBack(BuildContext context, String route) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(route);
  }
}
