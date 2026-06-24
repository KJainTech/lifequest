import 'package:flutter_test/flutter_test.dart';

import 'package:lifequest/design/lq_mastery_card.dart';

void main() {
  test('formatMasteryId pads LQ score segments', () {
    expect(LQMasteryCard.formatMasteryId(62), '0062 · LQ · 0434 · 0806');
    expect(LQMasteryCard.formatMasteryId(0), '0000 · LQ · 0000 · 0000');
  });
}
