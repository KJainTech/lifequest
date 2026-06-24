import 'package:flutter_test/flutter_test.dart';
import 'package:lifequest/core/tokens/lq_tokens.dart';
import 'package:lifequest/data/content/lesson_catalog.dart';
import 'package:lifequest/data/content/lesson_progression.dart';
import 'package:lifequest/data/models/lq_models.dart';
import 'package:lifequest/features/city/city_buildings.dart';
import 'package:lifequest/features/city/tower_visuals.dart';

void main() {
  test('lesson_6 maps to earning tower motif', () {
    final visual = towerVisualForType('lesson_6', LQColors.penny);
    expect(visual.motif, TowerMotif.earning);
    expect(visual.heightFactor, 1.0);
  });

  test('unknown lesson uses skill motif fallback', () {
    final visual = towerVisualForType('lesson_99', LQColors.penny);
    expect(visual.motif, TowerMotif.skill);
  });

  test('city has 48 building plots across 6 districts', () {
    expect(kCityBuildings.length, kTotalStages);
    expect(cityBuildingForLesson('lesson_1')?.name, 'Needs vs Wants');
    expect(cityBuildingForLesson('lesson_48')?.name, 'Graduation');
  });

  test('district themes cover six quest levels', () {
    expect(kCityDistrictThemes.length, kQuestLevelCount);
    expect(kCityDistrictThemes.length, 6);
  });

  test('new user sees one buildable plot and empty land', () {
    final snapshot = buildCityProgress(
      lessonProgress: const [],
      towers: const [],
      profile: null,
    );
    expect(snapshot.builtCount, 0);
    expect(snapshot.nextPlot?.building.lessonId, 'lesson_1');
    expect(snapshot.plots.where((p) => p.status == CityPlotStatus.next).length, 1);
    expect(snapshot.plots.where((p) => p.isBuilt).length, 0);
  });

  test('completed lesson marks plot as built on map', () {
    final snapshot = buildCityProgress(
      lessonProgress: [
        const LessonProgress(
          lessonId: 'lesson_1',
          status: LessonStatus.completed,
          stars: 5,
          quizScore: 5,
        ),
      ],
      towers: const [],
      profile: null,
    );
    expect(snapshot.builtCount, 1);
    expect(
      snapshot.plots.firstWhere((p) => p.building.lessonId == 'lesson_1').isBuilt,
      isTrue,
    );
    expect(snapshot.nextPlot?.building.lessonId, 'lesson_2');
  });

  test('low quiz score still unlocks next stage (no stuck path)', () {
    const low = LessonProgress(
      lessonId: 'lesson_1',
      status: LessonStatus.completed,
      quizScore: 2,
    );
    expect(LessonProgression.meetsMastery(low), isFalse);
    final next = LessonProgression.statusFor(
      lessonById('lesson_2')!,
      [low],
      null,
    );
    expect(next, LessonStatus.available);
  });
}
