import 'lesson_catalog.dart';

/// Client-side skill keys — six quest levels (L1–L6).
const kSkillKeys = ['L1', 'L2', 'L3', 'L4', 'L5', 'L6'];

String skillKeyForQuestLevel(int questLevel) =>
    'L${questLevel.clamp(1, kQuestLevelCount)}';

String skillKeyForLesson(String lessonId) {
  final meta = lessonById(lessonId);
  if (meta == null) return 'L1';
  return skillKeyForQuestLevel(meta.questLevel);
}

String skillLabel(String skillKey) {
  final level = int.tryParse(skillKey.replaceFirst('L', '')) ?? 1;
  return kQuestLevelNames[(level - 1).clamp(0, kQuestLevelCount - 1)];
}

int quizScoreToMastery(int quizScore) =>
    ((quizScore.clamp(0, 5) / 5) * 100).round();

Map<String, int> updateConceptSkill(
  Map<String, int> current,
  String skillKey,
  int quizScore,
) {
  final mastery = quizScoreToMastery(quizScore);
  final prev = current[skillKey] ?? mastery;
  final next = (prev * 0.55 + mastery * 0.45).round();
  return {...current, skillKey: next.clamp(0, 100)};
}

int gameDifficultyForConceptSkills(Map<String, int> skills, String lessonId) {
  final key = skillKeyForLesson(lessonId);
  final mastery = skills[key] ?? 40;
  if (mastery >= 75) return 4;
  if (mastery >= 55) return 3;
  if (mastery >= 40) return 2;
  return 1;
}

Map<String, int> baselineScreeningSkills() =>
    {for (final k in kSkillKeys) k: 40};
