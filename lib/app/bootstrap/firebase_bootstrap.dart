import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';
import 'firebase_web_config.dart';

/// Set true to connect to local Firebase emulators (pass --dart-define=USE_FIREBASE_EMULATORS=true).
const kUseFirebaseEmulators = bool.fromEnvironment(
  'USE_FIREBASE_EMULATORS',
  defaultValue: false,
);

/// Initializes Firebase before [runApp]. Retries help Safari and flaky networks.
Future<void> bootstrapFirebase() async {
  await configureFirebaseWeb();

  Object? lastError;
  for (var attempt = 0; attempt < 8; attempt++) {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } else {
        // Hot restart / cached shell — verify the default app is usable.
        Firebase.app();
      }

      await _configureClientsAfterInit();
      await _connectEmulatorsIfNeeded();
      return;
    } catch (e) {
      lastError = e;
      if (attempt == 7) break;
      await Future<void>.delayed(
        Duration(milliseconds: 350 * (attempt + 1) + (isSafariWeb ? 200 : 0)),
      );
    }
  }

  throw lastError ?? StateError('Firebase initialization failed');
}

Future<void> _configureClientsAfterInit() async {
  FirebaseFunctions.instanceFor(region: 'europe-west1');

  if (kIsWeb && isSafariWeb) {
    // Safari (especially Private Browsing) can fail IndexedDB persistence.
    try {
      await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
    } catch (_) {
      try {
        await FirebaseAuth.instance.setPersistence(Persistence.SESSION);
      } catch (_) {}
    }
    try {
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: false,
      );
    } catch (_) {}
  }

  // Warm auth channel early so splash sign-in does not hit a cold channel-error.
  if (kIsWeb) {
    await FirebaseAuth.instance.authStateChanges().first.timeout(
          const Duration(seconds: 8),
          onTimeout: () => null,
        );
  }
}

Future<void> _connectEmulatorsIfNeeded() async {
  if (!kUseFirebaseEmulators) return;

  const host = kIsWeb ? 'localhost' : '10.0.2.2';
  FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
  FirebaseFunctions.instanceFor(region: 'europe-west1')
      .useFunctionsEmulator(host, 5001);
  await FirebaseAuth.instance.useAuthEmulator(host, 9099);
}
