import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/lq_models.dart';

class StatsRepository {
  StatsRepository(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _statsRef(String uid) =>
      _firestore.doc('profiles/$uid/stats/current');

  Stream<UserStats> watchStats(String uid) {
    return _statsRef(uid).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return UserStats.empty;
      return UserStats.fromMap(snap.data()!);
    });
  }

  Future<UserStats> getStats(String uid) async {
    final snap = await _statsRef(uid).get();
    if (!snap.exists || snap.data() == null) return UserStats.empty;
    return UserStats.fromMap(snap.data()!);
  }
}

class ProfileRepository {
  ProfileRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Future<UserProfile?> getProfile(String uid) async {
    return _withFirestoreRetry(() async {
      final snap = await _firestore.doc('users/$uid').get();
      if (!snap.exists || snap.data() == null) return null;
      return UserProfile.fromMap(uid, snap.data()!);
    });
  }

  /// Creates a minimal child profile so rules and onboarding can proceed.
  Future<void> ensureChildStub(String uid) async {
    await _withFirestoreRetry(() async {
      await _firestore.doc('users/$uid').set(
        {
          'role': 'child',
          'displayName': 'Explorer',
          'onboardingComplete': false,
          'locale': 'en',
          'region': 'AE',
          'proficiencyLevel': 1,
        },
        SetOptions(merge: true),
      );
    });
  }

  Future<T> _withFirestoreRetry<T>(Future<T> Function() action) async {
    const attempts = 3;
    for (var i = 0; i < attempts; i++) {
      try {
        return await action();
      } on FirebaseException catch (e) {
        final isLast = i == attempts - 1;
        if (e.code != 'permission-denied' || isLast) rethrow;
        await FirebaseAuth.instance.currentUser?.getIdToken(true);
        await Future<void>.delayed(Duration(milliseconds: 200 * (i + 1)));
      }
    }
    throw StateError('unreachable');
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _firestore.doc('users/${profile.uid}').set(
          profile.toMap(),
          SetOptions(merge: true),
        );
  }

  Future<void> markOnboardingComplete(String uid, {int? age}) async {
    await _firestore.doc('users/$uid').set(
      {
        'onboardingComplete': true,
        if (age != null) 'age': age,
      },
      SetOptions(merge: true),
    );
  }

  Stream<UserProfile?> watchProfile(String uid) {
    return _firestore.doc('users/$uid').snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return UserProfile.fromMap(uid, snap.data()!);
    });
  }
}

class ProgressRepository {
  ProgressRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Future<LessonProgress?> getLessonProgress(String uid, String lessonId) async {
    final snap =
        await _firestore.doc('progress/$uid/lessons/$lessonId').get();
    if (!snap.exists || snap.data() == null) return null;
    return LessonProgress.fromMap(lessonId, snap.data()!);
  }

  Stream<List<LessonProgress>> watchLessons(String uid) {
    return _firestore.collection('progress/$uid/lessons').snapshots().map(
          (snap) => snap.docs
              .map((d) => LessonProgress.fromMap(d.id, d.data()))
              .toList(),
        );
  }
}

class CityRepository {
  CityRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Future<List<Tower>> getTowers(String uid) async {
    final snap = await _firestore.doc('city/$uid').get();
    if (!snap.exists) return [];
    final towers = snap.data()?['towers'] as List<dynamic>? ?? [];
    return towers
        .whereType<Map<String, dynamic>>()
        .map(Tower.fromMap)
        .toList();
  }

  Stream<List<Tower>> watchTowers(String uid) {
    return _firestore.doc('city/$uid').snapshots().map((snap) {
      if (!snap.exists) return <Tower>[];
      final towers = snap.data()?['towers'] as List<dynamic>? ?? [];
      return towers
          .whereType<Map<String, dynamic>>()
          .map(Tower.fromMap)
          .toList();
    });
  }
}
