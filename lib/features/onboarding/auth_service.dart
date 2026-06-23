import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap/firebase_providers.dart';
import '../../data/models/lq_models.dart';
import '../../data/repositories/lq_repositories.dart';

class AuthService {
  AuthService(this._auth, this._profiles);

  final FirebaseAuth _auth;
  final ProfileRepository _profiles;

  User? get currentUser => _auth.currentUser;

  Future<User> signInAnonymously() async {
    if (_auth.currentUser != null) return _auth.currentUser!;
    final cred = await _auth.signInAnonymously();
    return cred.user!;
  }

  Future<UserProfile?> fetchProfile(String uid) => _profiles.getProfile(uid);

  Future<void> saveOnboardingProfile({
    required String uid,
    required int age,
    required String ageBand,
    required String guide,
    required int proficiencyLevel,
    String locale = 'en',
    String displayName = 'Explorer',
  }) async {
    final profile = UserProfile(
      uid: uid,
      role: 'child',
      displayName: displayName,
      ageBand: ageBand,
      guide: guide,
      proficiencyLevel: proficiencyLevel,
      locale: locale,
      region: 'AE',
      onboardingComplete: true,
      age: age,
    );
    await _profiles.saveProfile(profile);
    await _profiles.markOnboardingComplete(uid, age: age);
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    FirebaseAuth.instance,
    ref.watch(profileRepositoryProvider),
  );
});

final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final user = ref.watch(authProvider).valueOrNull;
  if (user == null) return Stream.value(null);
  return ref.watch(profileRepositoryProvider).watchProfile(user.uid);
});
