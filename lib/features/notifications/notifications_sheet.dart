import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap/firebase_providers.dart';
import '../../app/theme/lq_theme.dart';
import '../../core/audio/lq_sound_service.dart';
import '../../core/tokens/lq_tokens.dart';
import '../../core/tokens/lq_typography.dart';
import '../../data/providers/notification_providers.dart';
import '../../data/repositories/notification_repository.dart';
import '../../design/lq_button.dart';
import '../../design/lq_icons.dart';

/// In-app notification inbox (Firestore + local session alerts).
class NotificationsSheet extends ConsumerWidget {
  const NotificationsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NotificationsSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(lqColorsProvider);
    final remote = ref.watch(userNotificationsProvider);
    final local = ref.watch(localNotificationsProvider);
    final user = ref.watch(authProvider).valueOrNull;

    final items = [
      ...local,
      ...?remote.valueOrNull,
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Container(
      margin: const EdgeInsets.all(LQSpacing.md),
      padding: EdgeInsets.only(
        left: LQSpacing.lg,
        right: LQSpacing.lg,
        top: LQSpacing.lg,
        bottom: MediaQuery.paddingOf(context).bottom + LQSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(LQRadius.card),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('Notifications', style: LQTypography.h2(colors)),
              const Spacer(),
              IconButton(
                tooltip: 'Close',
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.close_rounded, color: colors.inkSoft),
              ),
            ],
          ),
          const SizedBox(height: LQSpacing.md),
          if (remote.isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: LQSpacing.xl),
              child: Center(
                child: CircularProgressIndicator(color: colors.brand),
              ),
            )
          else if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: LQSpacing.xl),
              child: Text(
                'You\'re all caught up. Complete a stage to earn new updates.',
                style: LQTypography.bodySm(colors),
                textAlign: TextAlign.center,
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: LQSpacing.sm),
                itemBuilder: (context, i) {
                  final n = items[i];
                  return _NotificationTile(
                    colors: colors,
                    notification: n,
                    onTap: () async {
                      LQSound.tap();
                      ref.read(localNotificationsProvider.notifier).markRead(n.id);
                      if (user != null && !n.id.startsWith('local_')) {
                        await ref
                            .read(notificationRepositoryProvider)
                            .markRead(user.uid, n.id);
                      }
                    },
                  );
                },
              ),
            ),
          if (items.any((n) => !n.read) && user != null) ...[
            const SizedBox(height: LQSpacing.lg),
            LQButton(
              label: 'Mark all read',
              colors: colors,
              variant: LQButtonVariant.ghost,
              expanded: true,
              onPressed: () async {
                ref.read(localNotificationsProvider.notifier).clear();
                final unread = items.where((n) => !n.read && !n.id.startsWith('local_'));
                await ref.read(notificationRepositoryProvider).markAllRead(
                      user.uid,
                      unread.map((n) => n.id),
                    );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.colors,
    required this.notification,
    required this.onTap,
  });

  final LQColors colors;
  final LqNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: notification.read
          ? colors.canvasEnd.withValues(alpha: 0.35)
          : colors.brand.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(LQRadius.control),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(LQRadius.control),
        child: Padding(
          padding: const EdgeInsets.all(LQSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LQDuotoneIcon(
                icon: LQIconType.notification,
                size: 22,
                primaryColor: colors.brand,
                secondaryColor: colors.brand.withValues(alpha: 0.35),
              ),
              const SizedBox(width: LQSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: LQTypography.label(colors).copyWith(
                        fontWeight:
                            notification.read ? FontWeight.w500 : FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: LQSpacing.xs),
                    Text(
                      notification.body,
                      style: LQTypography.bodySm(colors),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
