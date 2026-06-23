// Lesson content models — served from cache; Firestore in Phase 7.

enum CognitiveLevel {
  recall,
  apply,
  recognise,
  feel,
  solve,
}

class ReadParagraph {
  const ReadParagraph({required this.text});
  final String text;
}

class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.prompt,
    required this.options,
    required this.explanation,
    required this.level,
  });

  final String id;
  final String prompt;
  final List<String> options;
  final String explanation;
  final CognitiveLevel level;
}

class LemonCityConfig {
  const LemonCityConfig({
    required this.unitCost,
    required this.daySeconds,
    required this.customerCount,
    required this.minPrice,
    required this.maxPrice,
    required this.defaultPrice,
  });

  final double unitCost;
  final int daySeconds;
  final int customerCount;
  final double minPrice;
  final double maxPrice;
  final double defaultPrice;
}

class LessonContent {
  const LessonContent({
    required this.lessonId,
    required this.concept,
    required this.title,
    required this.readParagraphs,
    required this.quizQuestions,
    required this.gameConfig,
  });

  final String lessonId;
  final String concept;
  final String title;
  final List<ReadParagraph> readParagraphs;
  final List<QuizQuestion> quizQuestions;
  final LemonCityConfig gameConfig;
}
