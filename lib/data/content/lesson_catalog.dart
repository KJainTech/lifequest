/// Curriculum metadata — full ladder; content served from cache/Firestore.
class LessonMeta {
  const LessonMeta({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.conceptOrder,
    this.prerequisiteId,
  });

  final String id;
  final String title;
  final String subtitle;
  final int conceptOrder;
  final String? prerequisiteId;
}

const kCurriculum = <LessonMeta>[
  LessonMeta(
    id: 'lesson_1',
    title: 'Needs vs Wants',
    subtitle: 'Spot the difference before you spend',
    conceptOrder: 1,
  ),
  LessonMeta(
    id: 'lesson_2',
    title: 'Saving Jar',
    subtitle: 'Set a goal and watch it grow',
    conceptOrder: 2,
    prerequisiteId: 'lesson_1',
  ),
  LessonMeta(
    id: 'lesson_3',
    title: 'Smart Spending',
    subtitle: 'Compare before you buy',
    conceptOrder: 3,
    prerequisiteId: 'lesson_2',
  ),
  LessonMeta(
    id: 'lesson_4',
    title: 'Budget Basics',
    subtitle: 'Plan your AED for the week',
    conceptOrder: 4,
    prerequisiteId: 'lesson_3',
  ),
  LessonMeta(
    id: 'lesson_5',
    title: 'Cost of Goods',
    subtitle: 'What it takes to make something',
    conceptOrder: 5,
    prerequisiteId: 'lesson_4',
  ),
  LessonMeta(
    id: 'lesson_6',
    title: 'Profit = Revenue − Cost',
    subtitle: 'Run your stand and learn when you earn',
    conceptOrder: 6,
    prerequisiteId: 'lesson_5',
  ),
];

LessonMeta? lessonById(String id) {
  for (final l in kCurriculum) {
    if (l.id == id) return l;
  }
  return null;
}
