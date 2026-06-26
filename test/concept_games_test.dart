import 'package:flutter_test/flutter_test.dart';
import 'package:lifequest/data/content/lesson_catalog.dart';
import 'package:lifequest/features/games/concept/concept_game_types.dart';

void main() {
  test('legacy lessons map to concept games', () {
    expect(conceptGameFor(lessonById('lesson_1')!), ConceptGameId.needsWants);
    expect(conceptGameFor(lessonById('lesson_2')!), ConceptGameId.jarFill);
    expect(conceptGameFor(lessonById('lesson_3')!), ConceptGameId.dealPick);
    expect(conceptGameFor(lessonById('lesson_4')!), ConceptGameId.coinJars);
    expect(conceptGameFor(lessonById('lesson_6')!), ConceptGameId.lemonCity);
  });

  test('all five games have unique themes', () {
    final accents = kAllConceptGames.map((g) => infoFor(g).accent).toSet();
    expect(accents.length, 5);
  });
}
