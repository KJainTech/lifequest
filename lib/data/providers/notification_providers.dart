import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap/firebase_providers.dart';
import '../../data/repositories/notification_repository.dart';

final userNotificationsProvider =
    StreamProvider<List<LqNotification>>((ref) {
  final user = ref.watch(authProvider).valueOrNull;
  if (user == null) return Stream.value(const []);
  return ref
      .watch(notificationRepositoryProvider)
      .watchNotifications(user.uid);
});

final unreadNotificationCountProvider = Provider<int>((ref) {
  final remote = ref.watch(userNotificationsProvider).valueOrNull ?? const [];
  final local = ref.watch(localNotificationsProvider);
  return [...local, ...remote].where((n) => !n.read).length;
});

final localNotificationsProvider =
    StateNotifierProvider<LocalNotificationsNotifier, List<LqNotification>>(
  (ref) => LocalNotificationsNotifier(),
);

class LocalNotificationsNotifier extends StateNotifier<List<LqNotification>> {
  LocalNotificationsNotifier() : super(const []);

  void push(LqNotification item) {
    if (state.any((n) => n.id == item.id)) return;
    state = [item, ...state];
  }

  void markRead(String id) {
    state = [
      for (final n in state)
        if (n.id == id) LqNotification(
              id: n.id,
              title: n.title,
              body: n.body,
              kind: n.kind,
              createdAt: n.createdAt,
              read: true,
            ) else n,
    ];
  }

  void clear() => state = const [];
}
