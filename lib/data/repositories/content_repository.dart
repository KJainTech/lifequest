import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../content/lesson_catalog.dart';
import '../content/lesson_content_cache.dart';
import '../models/lesson_content.dart';
import '../services/cloud_functions_service.dart';
import '../../app/bootstrap/firebase_providers.dart';
import '../../features/onboarding/auth_service.dart';

/// Server-provided answer keys for AI-adaptive lessons (quiz UI validation).
final adaptiveAnswerKeysProvider =
    StateProvider<Map<String, List<int>>>((ref) => {});

class ContentRepository {
  ContentRepository(this._functions, this._auth);

  final CloudFunctionsService _functions;
  final FirebaseAuth _auth;

  Future<LessonContent> loadLesson({
    required String lessonId,
    required String ageBand,
    required String guide,
    String locale = 'en',
    void Function(List<int> answerKey)? onAnswerKey,
  }) async {
    final meta = lessonById(lessonId);
    final uid = _auth.currentUser?.uid;

    // Lessons 1–6 are handcrafted — keep local content; adaptive from lesson 7+.
    final useAdaptive = uid != null && (meta?.conceptOrder ?? 99) > 6;

    if (useAdaptive && meta != null) {
      try {
        final adaptive = await _functions.generateAdaptiveLesson(
          lessonId: lessonId,
          ageBand: ageBand,
          guide: guide,
          locale: locale,
          title: meta.title,
          subtitle: meta.subtitle,
          conceptSlug: meta.conceptSlug,
          questLevel: meta.questLevel,
          stageInLevel: meta.stageInLevel,
        );
        final content = _parseAdaptiveContent(adaptive, lessonId, ageBand);
        final key = (adaptive['answerKey'] as List?)
            ?.map((e) => (e as num).toInt())
            .toList();
        if (key != null && key.length == 5) {
          onAnswerKey?.call(key);
        }
        return content;
      } catch (_) {
        // Fall through to local cache
      }
    }

    await Future<void>.delayed(const Duration(milliseconds: 80));
    return LessonContentCache.get(lessonId, ageBand);
  }

  LessonContent _parseAdaptiveContent(
    Map<String, dynamic> adaptive,
    String lessonId,
    String ageBand,
  ) {
    final raw = adaptive['content'] as Map<String, dynamic>?;
    if (raw == null) {
      return LessonContentCache.get(lessonId, ageBand);
    }

    final fallback = LessonContentCache.get(lessonId, ageBand);
    final paragraphs = (raw['readParagraphs'] as List?)
            ?.map((p) => ReadParagraph(text: p.toString()))
            .toList() ??
        fallback.readParagraphs;

    final questions = (raw['quizQuestions'] as List?)?.map((q) {
      final map = q as Map<String, dynamic>;
      return QuizQuestion(
        id: map['id'] as String? ?? 'q',
        prompt: map['prompt'] as String? ?? '',
        options: (map['options'] as List?)?.cast<String>() ?? const [],
        explanation: map['explanation'] as String? ?? 'Nice work!',
        level: CognitiveLevel.recall,
      );
    }).toList();

    final gameRaw = raw['gameConfig'] as Map<String, dynamic>?;
    final game = gameRaw != null
        ? LemonCityConfig(
            unitCost: (gameRaw['unitCost'] as num?)?.toDouble() ??
                fallback.gameConfig.unitCost,
            daySeconds: (gameRaw['daySeconds'] as num?)?.toInt() ??
                fallback.gameConfig.daySeconds,
            customerCount: (gameRaw['customerCount'] as num?)?.toInt() ??
                fallback.gameConfig.customerCount,
            minPrice: (gameRaw['minPrice'] as num?)?.toDouble() ??
                fallback.gameConfig.minPrice,
            maxPrice: (gameRaw['maxPrice'] as num?)?.toDouble() ??
                fallback.gameConfig.maxPrice,
            defaultPrice: (gameRaw['defaultPrice'] as num?)?.toDouble() ??
                fallback.gameConfig.defaultPrice,
          )
        : fallback.gameConfig;

    return LessonContent(
      lessonId: lessonId,
      concept: raw['concept'] as String? ?? fallback.concept,
      title: metaTitle(lessonId) ?? fallback.title,
      readParagraphs: paragraphs,
      quizQuestions: (questions != null && questions.length == 5)
          ? questions
          : fallback.quizQuestions,
      gameConfig: game,
    );
  }

  String? metaTitle(String lessonId) => lessonById(lessonId)?.title;
}

final contentRepositoryProvider = Provider<ContentRepository>(
  (ref) => ContentRepository(
    ref.watch(cloudFunctionsProvider),
    FirebaseAuth.instance,
  ),
);

final lessonContentProvider =
    FutureProvider.family<LessonContent, String>((ref, lessonId) async {
  final profile = ref.watch(userProfileProvider).valueOrNull;
  final ageBand = profile?.ageBand ?? '9-12';
  final guide = profile?.guide ?? 'penny';
  final locale = profile?.locale ?? 'en';

  return ref.read(contentRepositoryProvider).loadLesson(
        lessonId: lessonId,
        ageBand: ageBand,
        guide: guide,
        locale: locale,
        onAnswerKey: (key) {
          ref.read(adaptiveAnswerKeysProvider.notifier).update(
                (state) => {...state, lessonId: key},
              );
        },
      );
});
