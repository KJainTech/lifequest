import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/onboarding/auth_service.dart';

/// App locale — synced with user profile when available.
final appLocaleProvider = StateProvider<String>((ref) {
  final profile = ref.watch(userProfileProvider).valueOrNull;
  return profile?.locale ?? 'en';
});
