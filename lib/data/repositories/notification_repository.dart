import 'package:cloud_firestore/cloud_firestore.dart';

enum LqNotificationKind { quest, reward, streak, breakTime, system }

class LqNotification {
  const LqNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.kind,
    required this.createdAt,
    this.read = false,
  });

  final String id;
  final String title;
  final String body;
  final LqNotificationKind kind;
  final DateTime createdAt;
  final bool read;

  factory LqNotification.fromMap(String id, Map<String, dynamic> map) {
    return LqNotification(
      id: id,
      title: map['title'] as String? ?? 'LifeQuest',
      body: map['body'] as String? ?? '',
      kind: _kindFromString(map['kind'] as String?),
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
      read: map['read'] as bool? ?? false,
    );
  }

  static LqNotificationKind _kindFromString(String? raw) {
    return switch (raw) {
      'reward' => LqNotificationKind.reward,
      'streak' => LqNotificationKind.streak,
      'break' => LqNotificationKind.breakTime,
      'system' => LqNotificationKind.system,
      _ => LqNotificationKind.quest,
    };
  }
}

class NotificationRepository {
  NotificationRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _items(String uid) =>
      _firestore.collection('notifications/$uid/items');

  Stream<List<LqNotification>> watchNotifications(String uid) {
    return _items(uid)
        .orderBy('createdAt', descending: true)
        .limit(30)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => LqNotification.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  Future<void> markRead(String uid, String id) async {
    await _items(uid).doc(id).set({'read': true}, SetOptions(merge: true));
  }

  Future<void> markAllRead(String uid, Iterable<String> ids) async {
    final batch = _firestore.batch();
    for (final id in ids) {
      batch.set(_items(uid).doc(id), {'read': true}, SetOptions(merge: true));
    }
    await batch.commit();
  }
}
