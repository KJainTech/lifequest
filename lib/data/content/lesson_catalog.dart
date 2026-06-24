import 'curriculum_builder.dart';

export 'curriculum_builder.dart'
    show
        kQuestLevelCount,
        kQuestLevelNames,
        kQuestLevelTiers,
        kStagesPerLevel,
        kStagesPerQuestLevel,
        kTotalStages,
        kMasteryQuizScore,
        kLevelTimeGateDays,
        QuestTier,
        stagesInQuestLevel,
        firstOrderForQuestLevel,
        tierLabel,
        timeGateLabel;

/// Curriculum metadata — 48 stages across 6 quest levels.
class LessonMeta {
  const LessonMeta({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.conceptOrder,
    required this.questLevel,
    required this.stageInLevel,
    required this.questLevelName,
    required this.conceptSlug,
    this.prerequisiteId,
  });

  final String id;
  final String title;
  final String subtitle;
  final int conceptOrder;
  final int questLevel;
  final int stageInLevel;
  final String questLevelName;
  final String conceptSlug;
  final String? prerequisiteId;
}

final kCurriculum = buildCurriculum();

LessonMeta? lessonById(String id) {
  for (final l in kCurriculum) {
    if (l.id == id) return l;
  }
  return null;
}

LessonMeta? lessonByOrder(int conceptOrder) {
  for (final l in kCurriculum) {
    if (l.conceptOrder == conceptOrder) return l;
  }
  return null;
}

List<LessonMeta> lessonsForQuestLevel(int questLevel) {
  return kCurriculum.where((l) => l.questLevel == questLevel).toList();
}
