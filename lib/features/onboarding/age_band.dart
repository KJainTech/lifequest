import '../../core/tokens/lq_tokens.dart';

/// Maps numeric age to difficulty band per Bible §9.
String ageToBand(int age) {
  if (age <= 8) return '5-8';
  if (age <= 12) return '9-12';
  return '13-17';
}

AgeWorld ageToSuggestedWorld(int age) {
  if (age <= 8) return AgeWorld.penny;
  if (age <= 12) return AgeWorld.finBot;
  return AgeWorld.atlas;
}

AgeWorld guideToWorld(String guide) => switch (guide) {
      'penny' => AgeWorld.penny,
      'finBot' => AgeWorld.finBot,
      'atlas' => AgeWorld.atlas,
      _ => AgeWorld.penny,
    };

String guideDisplayName(String guide) => switch (guide) {
      'penny' => 'Penny',
      'finBot' => 'FinBot',
      'atlas' => 'Atlas',
      _ => 'Penny',
    };

String guidePersonality(String guide) => switch (guide) {
      'penny' =>
        'Warm and gentle — celebrates tiny wins and never gets angry.',
      'finBot' =>
        'Energetic and data-loving — turns every lesson into a quest.',
      'atlas' =>
        'Cool and confident — treats you like a peer, not a kid.',
      _ => '',
    };

String guideAgeHint(String guide) => switch (guide) {
      'penny' => 'Best for ages 5–8',
      'finBot' => 'Best for ages 9–12',
      'atlas' => 'Best for ages 13–17',
      _ => '',
    };

bool guideMatchesAge(String guide, int age) {
  return switch (guide) {
    'penny' => age <= 10,
    'finBot' => age >= 8 && age <= 13,
    'atlas' => age >= 11,
    _ => true,
  };
}
