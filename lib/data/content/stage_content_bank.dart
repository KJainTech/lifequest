import 'curriculum_builder.dart';
import 'lesson_catalog.dart';
import 'stage_snippets_data.dart';
import 'stage_teen_variants.dart';

/// Stage-specific teaching snippets — keyed by curriculum stage title.
class StageSnippet {
  const StageSnippet({
    required this.learn,
    required this.apply,
    required this.quizPrompts,
    required this.correctAnswers,
    required this.wrongPool,
  });

  final String learn;
  final String apply;
  final List<String> quizPrompts;
  final List<String> correctAnswers;
  final List<List<String>> wrongPool;
}

StageSnippet _fromCopy(StageCopy copy) {
  return StageSnippet(
    learn: copy.learn,
    apply: copy.apply,
    quizPrompts: copy.quiz.map((q) => q.prompt).toList(),
    correctAnswers: copy.quiz.map((q) => q.correct).toList(),
    wrongPool: copy.quiz.map((q) => q.wrong).toList(),
  );
}

StageCopy? _copyFor(LessonMeta meta, bool teen) {
  if (teen && meta.questLevel >= 4) {
    final teenCopy = kTeenStageCopyByTitle[meta.title];
    if (teenCopy != null) return teenCopy;
  }
  return kStageCopyByTitle[meta.title];
}

StageSnippet snippetFor(LessonMeta meta, {bool teen = false}) {
  final copy = _copyFor(meta, teen);
  if (copy != null) return _fromCopy(copy);
  return StageSnippet(
    learn: meta.subtitle,
    apply: 'Try one choice today that matches ${meta.title}.',
    quizPrompts: List.generate(5, (i) => 'What fits **${meta.title}**? (Q${i + 1})'),
    correctAnswers: List.generate(5, (_) => 'Best choice for ${meta.title}'),
    wrongPool: List.generate(
      5,
      (_) => ['Random guess', 'Ignore the plan', 'Spend without thinking'],
    ),
  );
}

StageSnippet snippetForStage(LessonMeta meta, {bool teen = false}) =>
    snippetFor(meta, teen: teen);

String readIntro(LessonMeta meta, bool young, {bool teen = false}) {
  final s = snippetFor(meta, teen: teen);
  if (young) {
    return '**${meta.title}** — ${meta.subtitle}. ${s.learn}';
  }
  if (teen && meta.questLevel >= 4) {
    return '**${meta.title}** (${meta.questLevelName}): ${s.learn}';
  }
  return '**${meta.questLevelName}** · **${meta.title}**: ${meta.subtitle}. ${s.learn}';
}

String readApply(LessonMeta meta, bool young, {bool teen = false}) {
  final s = snippetFor(meta, teen: teen);
  if (young) {
    return 'Try this: ${s.apply}';
  }
  if (teen && meta.questLevel >= 4) {
    return 'Your move: ${s.apply} Log results and reflect in your journal.';
  }
  return 'Apply it: ${s.apply} Use AED and track results in your journal.';
}

String readLevelContext(LessonMeta meta, {bool teen = false}) {
  if (teen && meta.questLevel >= 4) {
    return 'Level ${meta.questLevel} · ${meta.questLevelName} — stage ${meta.stageInLevel}/${stagesInQuestLevel(meta.questLevel)}. '
        'Real scenarios, AED math, and Lemon City profit targets.';
  }
  return 'You are on **Level ${meta.questLevel}** (${meta.questLevelName}), stage ${meta.stageInLevel} of ${stagesInQuestLevel(meta.questLevel)}.';
}

String readGameHook(LessonMeta meta, {bool teen = false}) {
  if (teen && meta.questLevel >= 4) {
    return '**Lemon City** — price above unit cost, hit positive profit, and tie the result to **${meta.title}**.';
  }
  return 'Finish in **Lemon City** — set a fair price, serve customers, and keep profit for **${meta.title}**.';
}

List<String> quizPromptsFor(LessonMeta meta, bool young, {bool teen = false}) {
  final s = snippetFor(meta, teen: teen);
  final t = meta.title;
  if (young) {
    return [
      '**$t** — ${s.quizPrompts[0]}',
      s.quizPrompts[1],
      'Which fits **${meta.subtitle}**?',
      s.quizPrompts[3],
      s.quizPrompts[4],
    ];
  }
  if (teen && meta.questLevel >= 4) {
    return s.quizPrompts;
  }
  return [
    '**$t**: ${s.quizPrompts[0]}',
    '**${meta.subtitle}** — ${s.quizPrompts[1]}',
    s.quizPrompts[2],
    s.quizPrompts[3],
    s.quizPrompts[4],
  ];
}

List<String> optionsForQuiz(
  LessonMeta meta,
  int qIndex,
  int correctIndex, {
  bool teen = false,
}) {
  final s = snippetFor(meta, teen: teen);
  final good = s.correctAnswers[qIndex];
  final bad = s.wrongPool[qIndex];
  final options = List<String>.filled(4, '');
  options[correctIndex] = good;
  var d = 0;
  for (var i = 0; i < 4; i++) {
    if (i == correctIndex) continue;
    options[i] = bad[d++];
  }
  return options;
}

String quizExplanation(
  LessonMeta meta,
  int qIndex,
  String correctOption, {
  bool teen = false,
}) {
  if (teen && meta.questLevel >= 4) {
    return 'Correct — **${meta.title}**: $correctOption. ${meta.subtitle}.';
  }
  return 'Nice! **${meta.title}** — "$correctOption" matches ${meta.subtitle.toLowerCase()}.';
}
