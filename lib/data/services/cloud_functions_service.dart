import 'package:cloud_functions/cloud_functions.dart';
import 'package:uuid/uuid.dart';

import '../models/lq_models.dart';

class CloudFunctionsService {
  CloudFunctionsService(this._functions);

  final FirebaseFunctions _functions;
  static const _uuid = Uuid();

  Future<QuizSubmitResult> submitQuiz({
    required String lessonId,
    required List<int> answers,
  }) async {
    final callable = _functions.httpsCallable('submitQuiz');
    final result = await callable.call<Map<String, dynamic>>({
      'lessonId': lessonId,
      'answers': answers,
    });
    return QuizSubmitResult.fromMap(result.data);
  }

  Future<Map<String, dynamic>> submitGamePlay({
    required String lessonId,
    required double profit,
    required double revenue,
    required double cost,
    required bool won,
    required int difficulty,
  }) async {
    final callable = _functions.httpsCallable('submitGamePlay');
    final result = await callable.call<Map<String, dynamic>>({
      'lessonId': lessonId,
      'profit': profit,
      'revenue': revenue,
      'cost': cost,
      'won': won,
      'difficulty': difficulty,
    });
    return result.data;
  }

  Future<LessonCompletionResult> completeLesson({
    required String lessonId,
    required int quizScore,
    required bool gameWon,
    required double gameProfit,
    String? idempotencyKey,
  }) async {
    final callable = _functions.httpsCallable('completeLesson');
    final result = await callable.call<Map<String, dynamic>>({
      'lessonId': lessonId,
      'quizScore': quizScore,
      'gameWon': gameWon,
      'gameProfit': gameProfit,
      'idempotencyKey': idempotencyKey ?? _uuid.v4(),
    });
    return LessonCompletionResult.fromMap(result.data);
  }

  Future<Map<String, dynamic>> runScreening({
    required List<Map<String, dynamic>> answers,
  }) async {
    final callable = _functions.httpsCallable('runScreening');
    final result = await callable.call<Map<String, dynamic>>({
      'answers': answers,
    });
    return result.data;
  }
}
