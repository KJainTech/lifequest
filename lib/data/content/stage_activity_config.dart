import '../models/lesson_content.dart';
import '../models/stage_activity.dart';
import 'lesson_catalog.dart';
import 'stage_content_bank.dart';

/// Maps stages to activity types + intro copy per Creative DevPlan.
class StageActivityConfig {
  const StageActivityConfig._();

  static StageSimulatorId? simulatorFor(LessonMeta meta) {
    switch (meta.id) {
      case 'lesson_24':
        return StageSimulatorId.crashExperiment;
      case 'lesson_32':
        return StageSimulatorId.creditScore;
      default:
        return null;
    }
  }

  static StageIntroCopy introFor(LessonMeta meta, String firstName) {
    final name = firstName.isEmpty ? 'friend' : firstName;
    final hook = 'Stage ${meta.stageInLevel} · ${meta.title}';
    return StageIntroCopy(
      penny: 'Hey $name! ${meta.subtitle}. Ready when you are.',
      finBot: 'Stage ${meta.questLevel}.${meta.stageInLevel} loaded. Objective: ${meta.title}.',
      atlas: '$name, today we focus on ${meta.title.toLowerCase()}.',
      hook: hook,
    );
  }

  static StageActivityKind primaryKind(LessonMeta meta) {
    final title = meta.title.toLowerCase();
    if (title.contains('needs') ||
        title.contains('want') ||
        title.contains('bucket') ||
        title.contains('deal detective') ||
        title.contains('shopping list')) {
      return StageActivityKind.dragDrop;
    }
    if (title.contains('budget') ||
        title.contains('plan') ||
        title.contains('interest') ||
        title.contains('tax') ||
        title.contains('price')) {
      return StageActivityKind.slider;
    }
    if (title.contains('scenario') ||
        title.contains('decision') ||
        title.contains('real scenario') ||
        title.contains('graduation')) {
      return StageActivityKind.scenario;
    }
    if (title.contains('goal') && meta.questLevel >= 3) {
      return StageActivityKind.cardSort;
    }
    return StageActivityKind.mcq;
  }

  static List<StageActivity> activitiesFor(
    LessonMeta meta,
    List<QuizQuestion> quizQuestions,
    String ageBand,
  ) {
    final kind = primaryKind(meta);
    if (kind == StageActivityKind.mcq) {
      return quizQuestions
          .map(
            (q) => StageActivity(
              kind: StageActivityKind.mcq,
              prompt: q.prompt.replaceAll('**', ''),
              options: q.options,
              correctIndex: 0,
              explanation: q.explanation,
            ),
          )
          .toList();
    }

    if (kind == StageActivityKind.dragDrop) {
      return List.generate(quizQuestions.length, (i) {
        final q = quizQuestions[i];
        final correct = q.options.isNotEmpty ? q.options[0] : 'Need';
        final wrong = q.options.length > 1 ? q.options.sublist(1) : ['Want item'];
        final items = [correct, ...wrong.take(3)];
        return StageActivity(
          kind: StageActivityKind.dragDrop,
          prompt: q.prompt.replaceAll('**', ''),
          dragItems: items,
          dragTargetA: 'Needs',
          dragTargetB: 'Wants',
          dragCorrectBucket: {correct: 'A', for (final w in wrong.take(3)) w: 'B'},
          explanation: q.explanation,
        );
      });
    }

    if (kind == StageActivityKind.slider) {
      return List.generate(quizQuestions.length, (i) {
        final q = quizQuestions[i];
        final correct = _sliderCorrectValue(q, i);
        final min = (correct - 20).clamp(0, correct);
        final max = correct + 20;
        return StageActivity(
          kind: StageActivityKind.slider,
          prompt: q.prompt.replaceAll('**', ''),
          sliderMin: min,
          sliderMax: max,
          sliderCorrect: correct,
          sliderUnit: 'AED',
          explanation: q.explanation,
        );
      });
    }

    if (kind == StageActivityKind.cardSort) {
      return List.generate(quizQuestions.length, (i) {
        final q = quizQuestions[i];
        return StageActivity(
          kind: StageActivityKind.cardSort,
          prompt: q.prompt.replaceAll('**', ''),
          options: q.options,
          dragTargetA: 'Higher priority',
          dragTargetB: 'Lower priority',
          explanation: q.explanation,
        );
      });
    }

    // scenario
    return List.generate(quizQuestions.length, (i) {
      final q = quizQuestions[i];
      final snippet = snippetFor(meta, teen: ageBand == '13-17');
      return StageActivity(
        kind: StageActivityKind.scenario,
        prompt: q.prompt.replaceAll('**', ''),
        sceneText: snippet.learn,
        options: q.options,
        correctIndex: 0,
        explanation: q.explanation,
      );
    });
  }

  /// Parses slider target — handles "50% of AED 100" → 50, not 100.
  static int _sliderCorrectValue(QuizQuestion q, int fallbackIndex) {
    final text = '${q.prompt} ${q.options.join(' ')}';

    final pct = RegExp(r'(\d+)\s*%').firstMatch(text);
    final income = RegExp(r'AED?\s*(\d+)', caseSensitive: false).firstMatch(text);
    if (pct != null && income != null) {
      final p = int.tryParse(pct.group(1) ?? '') ?? 0;
      final base = int.tryParse(income.group(1) ?? '') ?? 0;
      if (p > 0 && base > 0) return ((base * p) / 100).round();
    }

    for (final opt in q.options) {
      final m = RegExp(r'AED?\s*(\d+)', caseSensitive: false).firstMatch(opt);
      if (m != null) {
        final n = int.tryParse(m.group(1) ?? '');
        if (n != null && n > 0) return n;
      }
    }

    final nums = RegExp(r'AED?\s*(\d+)', caseSensitive: false)
        .allMatches(text)
        .map((m) => int.tryParse(m.group(1) ?? '') ?? 0)
        .where((n) => n > 0)
        .toList();
    if (nums.length >= 2) return nums.last;
    if (nums.isNotEmpty) return nums.first;
    return 30 + fallbackIndex * 5;
  }
}
