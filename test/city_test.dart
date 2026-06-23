import 'package:flutter_test/flutter_test.dart';
import 'package:lifequest/core/tokens/lq_tokens.dart';
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
}
