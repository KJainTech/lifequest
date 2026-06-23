import '../models/lesson_content.dart';
import 'lesson_definitions.dart';

export 'lesson_definitions.dart' show kQuizAnswerKeys, quizAnswerKeyFor;

/// Cached lesson variants keyed by (lessonId, ageBand).
class LessonContentCache {
  static LessonContent get(String lessonId, String ageBand) {
    return buildLessonContent(lessonId, ageBand);
  }
}

/// @deprecated Use [quizAnswerKeyFor].
const lesson6AnswerKey = [1, 2, 0, 3, 1];
