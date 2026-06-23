import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap/firebase_providers.dart';
import '../../data/models/lq_models.dart';

final userLessonsProvider = StreamProvider<List<LessonProgress>>((ref) {
  final user = ref.watch(authProvider).valueOrNull;
  if (user == null) return Stream.value(const []);
  return ref.watch(progressRepositoryProvider).watchLessons(user.uid);
});

class BadgeEarned {
  const BadgeEarned({required this.id, required this.earnedAt});

  final String id;
  final String earnedAt;
}

class BadgesRepository {
  BadgesRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<BadgeEarned>> watchBadges(String uid) {
    return _firestore.collection('badges/$uid').snapshots().map((snap) {
      return snap.docs
          .map(
            (d) => BadgeEarned(
              id: d.id,
              earnedAt: d.data()['earnedAt'] as String? ?? '',
            ),
          )
          .toList();
    });
  }
}

final badgesRepositoryProvider = Provider<BadgesRepository>((ref) {
  return BadgesRepository(ref.watch(firestoreProvider));
});

final userBadgesProvider = StreamProvider<List<BadgeEarned>>((ref) {
  final user = ref.watch(authProvider).valueOrNull;
  if (user == null) return Stream.value(const []);
  return ref.watch(badgesRepositoryProvider).watchBadges(user.uid);
});

String badgeTitle(String id) => switch (id) {
      'first_profit' => 'First Profit',
      'five_day_streak' => '5-Day Streak',
      'super_saver' => 'Super Saver',
      _ => id.replaceAll('_', ' '),
    };
