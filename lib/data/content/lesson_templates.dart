import '../models/lesson_content.dart';
import 'lesson_catalog.dart';
import 'stage_content_bank.dart';

/// Deterministic answer key for template lessons (mirrors functions answerKeys.ts).
List<int> templateQuizAnswerKey(int conceptOrder) {
  return List.generate(5, (i) => (conceptOrder * 7 + i * 3 + 2) % 4);
}

LessonContent buildTemplateLesson(LessonMeta meta, String ageBand) {
  final young = ageBand == '5-8';
  final teen = ageBand == '13-17';
  final order = meta.conceptOrder;
  final keys = templateQuizAnswerKey(order);

  final readParagraphs = _readParagraphs(meta, young, teen);
  final quizQuestions = _quizQuestions(meta, keys, young, teen);
  final game = _gameConfig(meta, young, teen, order);

  return LessonContent(
    lessonId: meta.id,
    concept: meta.conceptSlug,
    title: meta.title,
    readParagraphs: readParagraphs,
    quizQuestions: quizQuestions,
    gameConfig: game,
  );
}

List<ReadParagraph> _readParagraphs(
  LessonMeta meta,
  bool young,
  bool teen,
) {
  return [
    ReadParagraph(text: readIntro(meta, young, teen: teen)),
    ReadParagraph(text: readLevelContext(meta, teen: teen)),
    ReadParagraph(text: readApply(meta, young, teen: teen)),
    ReadParagraph(text: readGameHook(meta, teen: teen)),
  ];
}

List<QuizQuestion> _quizQuestions(
  LessonMeta meta,
  List<int> keys,
  bool young,
  bool teen,
) {
  final prompts = quizPromptsFor(meta, young, teen: teen);
  const levels = [
    CognitiveLevel.recall,
    CognitiveLevel.recognise,
    CognitiveLevel.apply,
    CognitiveLevel.feel,
    CognitiveLevel.solve,
  ];
  return List.generate(5, (i) {
    final correct = keys[i];
    final options = optionsForQuiz(meta, i, correct, teen: teen);
    return QuizQuestion(
      id: 'q${i + 1}',
      prompt: prompts[i],
      options: options,
      explanation: quizExplanation(meta, i, options[correct], teen: teen),
      level: levels[i],
    );
  });
}

LemonCityConfig _gameConfig(
  LessonMeta meta,
  bool young,
  bool teen,
  int order,
) {
  if (teen && meta.questLevel >= 4) {
    final unitCost = 2.0 + (order % 4) * 0.5;
    final defaultPrice = unitCost + 1.0 + (order % 3) * 0.25;
    return LemonCityConfig(
      unitCost: unitCost,
      daySeconds: 40,
      customerCount: 10 + (order % 5),
      minPrice: unitCost,
      maxPrice: defaultPrice + 3,
      defaultPrice: defaultPrice,
    );
  }

  final unitCost = 1.0 + (order % 5) * 0.25 + (teen ? 0.5 : 0);
  final defaultPrice = unitCost + 0.5 + (order % 3) * 0.25;
  final customers = 6 + (order % 6);

  return LemonCityConfig(
    unitCost: unitCost,
    daySeconds: young ? 45 : 55,
    customerCount: customers,
    minPrice: unitCost,
    maxPrice: defaultPrice + 2,
    defaultPrice: defaultPrice,
  );
}
