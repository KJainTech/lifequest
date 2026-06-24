import 'package:flutter_test/flutter_test.dart';

import 'package:lifequest/data/content/lesson_catalog.dart';
import 'package:lifequest/data/content/stage_activity_config.dart';
import 'package:lifequest/data/models/stage_activity.dart';

void main() {
  test('simulator mapping matches review best-screen stages', () {
    final crash = lessonById('lesson_24');
    final credit = lessonById('lesson_32');
    expect(crash?.title, 'Interest Intro');
    expect(credit?.title, 'Scam Shield');
    expect(StageActivityConfig.simulatorFor(crash!), StageSimulatorId.crashExperiment);
    expect(StageActivityConfig.simulatorFor(credit!), StageSimulatorId.creditScore);
  });
}
