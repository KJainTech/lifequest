import '../../../data/content/lesson_catalog.dart';

/// Five lesson mini-games — each teaches one money idea with its own colour theme.
enum ConceptGameId {
  needsWants,
  jarFill,
  coinJars,
  dealPick,
  lemonCity,
}

class ConceptGameInfo {
  const ConceptGameInfo({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.conceptLabel,
    required this.howToPlay,
    required this.accent,
    required this.surface,
    required this.icon,
  });

  final ConceptGameId id;
  final String title;
  final String subtitle;
  final String conceptLabel;
  final String howToPlay;
  final int accent;
  final int surface;
  final String icon;
}

const kAllConceptGames = ConceptGameId.values;

ConceptGameInfo infoFor(ConceptGameId id) => switch (id) {
      ConceptGameId.needsWants => const ConceptGameInfo(
            id: ConceptGameId.needsWants,
            title: 'Need or Want?',
            subtitle: 'Tap the right bucket fast',
            conceptLabel: 'Needs vs Wants',
            howToPlay: 'Each item appears — tap Needs (must-have) or Wants (extra fun).',
            accent: 0xFF2D9F6F,
            surface: 0xFFE8F7F0,
            icon: 'sort',
          ),
      ConceptGameId.jarFill => const ConceptGameInfo(
            id: ConceptGameId.jarFill,
            title: 'Fill the Jar',
            subtitle: 'Save coins for your goal',
            conceptLabel: 'Saving Jar',
            howToPlay: 'Tap coins into the jar. Ignore the “spend now” temptations.',
            accent: 0xFF4A7FD4,
            surface: 0xFFEAF1FC,
            icon: 'jar',
          ),
      ConceptGameId.coinJars => const ConceptGameInfo(
            id: ConceptGameId.coinJars,
            title: 'Three Jars',
            subtitle: 'Give every coin a job',
            conceptLabel: 'Budget Basics',
            howToPlay: 'Tap a jar, then tap coins — split across Needs, Wants, and Save.',
            accent: 0xFF9B6BD4,
            surface: 0xFFF3EDFC,
            icon: 'jars',
          ),
      ConceptGameId.dealPick => const ConceptGameInfo(
            id: ConceptGameId.dealPick,
            title: 'Pick the Deal',
            subtitle: 'Compare before you buy',
            conceptLabel: 'Smart Spending',
            howToPlay: 'Two prices appear — tap the smarter choice (better value).',
            accent: 0xFFE07A4A,
            surface: 0xFFFFF0EA,
            icon: 'deal',
          ),
      ConceptGameId.lemonCity => const ConceptGameInfo(
            id: ConceptGameId.lemonCity,
            title: 'Lemon City',
            subtitle: 'Run your stand for profit',
            conceptLabel: 'Profit & Cost',
            howToPlay: 'Set price above cost and serve customers before time runs out.',
            accent: 0xFFF5B942,
            surface: 0xFFFFFAED,
            icon: 'lemon',
          ),
    };

/// Pick the mini-game that matches this stage’s money concept.
ConceptGameId conceptGameFor(LessonMeta meta) {
  final title = meta.title.toLowerCase();
  final slug = meta.conceptSlug.toLowerCase();

  if (title.contains('profit') ||
      title.contains('cost') ||
      title.contains('stand') ||
      title.contains('revenue') ||
      title.contains('reinvest') ||
      title.contains('busy day') ||
      slug.contains('profit') ||
      slug.contains('cost')) {
    return ConceptGameId.lemonCity;
  }
  if (title.contains('jar') ||
      title.contains('save') ||
      title.contains('goal') ||
      title.contains('rainy') ||
      slug.contains('saving')) {
    return ConceptGameId.jarFill;
  }
  if (title.contains('budget') ||
      title.contains('plan') ||
      title.contains('bucket') ||
      title.contains('split') ||
      title.contains('track spend') ||
      slug.contains('budget')) {
    return ConceptGameId.coinJars;
  }
  if (title.contains('deal') ||
      title.contains('price') ||
      title.contains('compare') ||
      title.contains('shop') ||
      title.contains('wait a day') ||
      slug.contains('smart') ||
      slug.contains('spending')) {
    return ConceptGameId.dealPick;
  }
  if (title.contains('need') ||
      title.contains('want') ||
      title.contains('choice') ||
      slug.contains('need')) {
    return ConceptGameId.needsWants;
  }

  return switch (meta.questLevel) {
    1 => ConceptGameId.needsWants,
    2 => ConceptGameId.dealPick,
    3 => ConceptGameId.coinJars,
    _ => ConceptGameId.lemonCity,
  };
}

ConceptGameId conceptGameFromParam(String? raw) {
  return ConceptGameId.values.firstWhere(
    (g) => g.name == raw,
    orElse: () => ConceptGameId.needsWants,
  );
}
