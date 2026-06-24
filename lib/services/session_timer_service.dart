import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/theme/lq_theme.dart';
import '../core/tokens/lq_tokens.dart';
import '../core/tokens/lq_typography.dart';
import '../design/lq_button.dart';

/// 30-minute soft break reminder (DevPlan / UK AADC).
class SessionTimerNotifier extends StateNotifier<Duration> {
  SessionTimerNotifier() : super(Duration.zero) {
    _tick = Timer.periodic(const Duration(seconds: 30), (_) {
      state = state + const Duration(seconds: 30);
    });
  }

  late final Timer _tick;
  DateTime? _snoozedUntil;

  bool get shouldShowBreak {
    if (_snoozedUntil != null && DateTime.now().isBefore(_snoozedUntil!)) {
      return false;
    }
    return state >= const Duration(minutes: 30);
  }

  bool get mustBreak =>
      state >= const Duration(minutes: 45) &&
      (_snoozedUntil == null || DateTime.now().isAfter(_snoozedUntil!));

  void snooze15() {
    _snoozedUntil = DateTime.now().add(const Duration(minutes: 15));
  }

  @override
  void dispose() {
    _tick.cancel();
    super.dispose();
  }
}

final sessionTimerProvider =
    StateNotifierProvider<SessionTimerNotifier, Duration>(
  (ref) => SessionTimerNotifier(),
);

class SessionBreakOverlay extends ConsumerWidget {
  const SessionBreakOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(lqColorsProvider);
    final timer = ref.watch(sessionTimerProvider.notifier);
    final duration = ref.watch(sessionTimerProvider);
    if (duration < const Duration(minutes: 30)) return const SizedBox.shrink();
    if (!timer.shouldShowBreak && !timer.mustBreak) return const SizedBox.shrink();

    return Positioned(
      left: LQSpacing.gutter,
      right: LQSpacing.gutter,
      bottom: 100,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(LQRadius.card),
        child: Container(
          padding: const EdgeInsets.all(LQSpacing.lg),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(LQRadius.card),
            border: Border.all(color: colors.gold.withValues(alpha: 0.5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Time for a short break?', style: LQTypography.h3(colors)),
              const SizedBox(height: LQSpacing.sm),
              Text(
                'You\'ve been learning for ${duration.inMinutes} minutes.',
                style: LQTypography.bodySm(colors),
              ),
              const SizedBox(height: LQSpacing.lg),
              LQButton(
                label: 'Take a break',
                colors: colors,
                expanded: true,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              if (!timer.mustBreak) ...[
                const SizedBox(height: LQSpacing.sm),
                LQButton(
                  label: 'Keep going (15 min)',
                  colors: colors,
                  variant: LQButtonVariant.ghost,
                  expanded: true,
                  onPressed: timer.snooze15,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
