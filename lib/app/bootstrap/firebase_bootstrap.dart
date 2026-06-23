import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';

/// Set true to connect to local Firebase emulators (pass --dart-define=USE_FIREBASE_EMULATORS=true).
const kUseFirebaseEmulators = bool.fromEnvironment(
  'USE_FIREBASE_EMULATORS',
  defaultValue: false,
);

/// Initializes Firebase before [runApp]. Retries help embedded browsers (Instagram, etc.).
Future<void> bootstrapFirebase() async {
  if (Firebase.apps.isNotEmpty) {
    await _connectEmulatorsIfNeeded();
    return;
  }

  Object? lastError;
  for (var attempt = 0; attempt < 5; attempt++) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await _connectEmulatorsIfNeeded();
      return;
    } catch (e) {
      lastError = e;
      if (attempt == 4) break;
      await Future<void>.delayed(Duration(milliseconds: 200 * (attempt + 1)));
    }
  }

  throw lastError ?? StateError('Firebase initialization failed');
}

Future<void> _connectEmulatorsIfNeeded() async {
  if (!kUseFirebaseEmulators) return;

  const host = kIsWeb ? 'localhost' : '10.0.2.2';
  FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
  FirebaseFunctions.instanceFor(region: 'europe-west1')
      .useFunctionsEmulator(host, 5001);
  await FirebaseAuth.instance.useAuthEmulator(host, 9099);
}
