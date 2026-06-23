import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap/firebase_providers.dart';
import '../../data/models/lq_models.dart';

/// Live tower list from Firestore `city/{uid}`.
final userTowersProvider = StreamProvider<List<Tower>>((ref) {
  final user = ref.watch(authProvider).valueOrNull;
  if (user == null) return Stream.value(const []);
  return ref.watch(cityRepositoryProvider).watchTowers(user.uid);
});

/// Set by reward screen before navigating — triggers build celebration on city.
final pendingCityCelebrationProvider = StateProvider<String?>((ref) => null);
