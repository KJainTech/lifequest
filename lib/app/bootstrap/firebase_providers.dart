import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/lq_models.dart';
import '../../data/repositories/lq_repositories.dart';
import '../../data/services/cloud_functions_service.dart';

/// Set true to connect to local Firebase emulators.
const kUseFirebaseEmulators = bool.fromEnvironment(
  'USE_FIREBASE_EMULATORS',
  defaultValue: kDebugMode,
);

final firebaseInitializedProvider = FutureProvider<bool>((ref) async {
  const apiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: 'demo-api-key',
  );
  const projectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'lifequest-dev',
  );
  const appId = String.fromEnvironment(
    'FIREBASE_APP_ID',
    defaultValue: '1:000000000000:web:demo',
  );

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: const String.fromEnvironment(
        'FIREBASE_MESSAGING_SENDER_ID',
        defaultValue: '000000000000',
      ),
      projectId: projectId,
      authDomain: const String.fromEnvironment(
        'FIREBASE_AUTH_DOMAIN',
        defaultValue: 'lifequest-dev.firebaseapp.com',
      ),
      storageBucket: const String.fromEnvironment(
        'FIREBASE_STORAGE_BUCKET',
        defaultValue: 'lifequest-dev.appspot.com',
      ),
    ),
  );

  if (kUseFirebaseEmulators) {
    const host = kIsWeb ? 'localhost' : '10.0.2.2';
    FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
    FirebaseFunctions.instanceFor(region: 'europe-west1')
        .useFunctionsEmulator(host, 5001);
    await FirebaseAuth.instance.useAuthEmulator(host, 9099);
  }

  return true;
});

final authProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final functionsProvider = Provider<FirebaseFunctions>((ref) {
  return FirebaseFunctions.instanceFor(region: 'europe-west1');
});

final statsRepositoryProvider = Provider<StatsRepository>((ref) {
  return StatsRepository(ref.watch(firestoreProvider));
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(firestoreProvider));
});

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return ProgressRepository(ref.watch(firestoreProvider));
});

final cityRepositoryProvider = Provider<CityRepository>((ref) {
  return CityRepository(ref.watch(firestoreProvider));
});

final cloudFunctionsProvider = Provider<CloudFunctionsService>((ref) {
  return CloudFunctionsService(ref.watch(functionsProvider));
});

final userStatsProvider = StreamProvider<UserStats>((ref) {
  final user = ref.watch(authProvider).valueOrNull;
  if (user == null) return Stream.value(UserStats.empty);
  return ref.watch(statsRepositoryProvider).watchStats(user.uid);
});
