import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../content/lesson_content_cache.dart';
import '../models/lesson_content.dart';
import '../../features/onboarding/auth_service.dart';

class ContentRepository {
  Future<LessonContent> loadLesson({
    required String lessonId,
    required String ageBand,
    required String guide,
  }) async {
    // Phase 7: fetch from Firestore content/{concept}/variants/{ageBand}
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return LessonContentCache.get(lessonId, ageBand);
  }
}

final contentRepositoryProvider = Provider<ContentRepository>(
  (ref) => ContentRepository(),
);

final lessonContentProvider =
    FutureProvider.family<LessonContent, String>((ref, lessonId) async {
  final profile = ref.watch(userProfileProvider).valueOrNull;
  final ageBand = profile?.ageBand ?? '9-12';
  final guide = profile?.guide ?? 'penny';
  return ref.read(contentRepositoryProvider).loadLesson(
        lessonId: lessonId,
        ageBand: ageBand,
        guide: guide,
      );
});
