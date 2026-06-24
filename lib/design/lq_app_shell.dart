import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/lq_theme.dart';
import '../../core/tokens/lq_tokens.dart';
import '../../core/tokens/lq_typography.dart';
import '../../features/onboarding/auth_service.dart';

/// Universal navigation wrapper — back, home, exit dialog (DevPlan Day 1).
class LQAppShell extends ConsumerWidget {
  const LQAppShell({
    super.key,
    required this.title,
    required this.body,
    this.showBack = true,
    this.onBack,
    this.showHome = true,
    this.showExit = true,
  });

  final String title;
  final Widget body;
  final bool showBack;
  final VoidCallback? onBack;
  final bool showHome;
  final bool showExit;

  static void showExitDialog(BuildContext context, WidgetRef ref) {
    final colors = ref.read(lqColorsProvider);
    final guide = ref.read(userProfileProvider).valueOrNull?.guide ?? 'penny';
    final emoji = switch (guide) {
      'finBot' => '🤖',
      'atlas' => '🧭',
      _ => '🦋',
    };

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black54,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFF5C84A),
                shape: BoxShape.circle,
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 28)),
            ).animate().scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1, 1),
                  curve: Curves.elasticOut,
                ),
            const SizedBox(height: 12),
            Text('Take a break?', style: LQTypography.h2(colors)),
            const SizedBox(height: 6),
            Text(
              'Your progress is always saved ✓',
              style: LQTypography.bodySm(colors).copyWith(color: colors.inkSoft),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(ctx),
                style: FilledButton.styleFrom(backgroundColor: colors.gold),
                child: const Text('Keep Playing'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.go('/home');
                },
                child: const Text('Yes, exit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(lqColorsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: LQSpacing.sm,
            vertical: LQSpacing.xs,
          ),
          child: Row(
            children: [
              if (showBack)
                IconButton(
                  icon: Icon(Icons.arrow_back_ios_new, color: colors.ink, size: 20),
                  onPressed: onBack ?? () => context.pop(),
                )
              else
                const SizedBox(width: 48),
              Expanded(
                child: Text(
                  title,
                  style: LQTypography.h3(colors),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (showHome)
                IconButton(
                  icon: Icon(Icons.cottage_outlined, color: colors.ink, size: 22),
                  onPressed: () => context.go('/home'),
                )
              else
                const SizedBox(width: 48),
              if (showExit)
                IconButton(
                  icon: Icon(Icons.close_rounded, color: colors.ink, size: 22),
                  onPressed: () => showExitDialog(context, ref),
                )
              else
                const SizedBox(width: 48),
            ],
          ),
        ),
        Expanded(child: body),
      ],
    );
  }
}
