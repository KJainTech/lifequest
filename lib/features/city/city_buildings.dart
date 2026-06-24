import 'package:flutter/material.dart';

import '../../data/content/lesson_catalog.dart';
import '../../data/content/lesson_progression.dart';
import '../../data/models/lq_models.dart';

/// Low-poly building archetypes for the city map.
enum CityBuildingKind {
  coinMint,
  piggyShop,
  needsMart,
  wantArcade,
  firstStand,
  supermarket,
  dealStore,
  waitCafe,
  listLibrary,
  budgetBooth,
  goalGarden,
  jarFactory,
  patiencePark,
  interestBank,
  trophyHall,
  planOffice,
  trackStation,
  fixWorkshop,
  needsHub,
  reviewCenter,
  lemonStand,
  priceTower,
  busyMarket,
  profitPlaza,
  reinvestHq,
  choreCenter,
  timeClock,
  tradeMarket,
  kindnessCafe,
  valuesSchool,
  dreamObservatory,
  rainyShelter,
  emergencyStation,
  stepsPath,
  futureBridge,
  adAlertTower,
  qualityShop,
  reviewReader,
  returnDesk,
  scamShield,
  fairSplitPark,
  groupGoalHall,
  talkCafe,
  teamBudgetHq,
  winStadium,
  masterMix,
  scenarioLab,
  giveGrowGarden,
  seedInvest,
  graduationArch,
}

enum CityPlotStatus { locked, next, inProgress, built }

class CityBuildingDef {
  const CityBuildingDef({
    required this.lessonId,
    required this.kind,
    required this.name,
    required this.emoji,
    required this.districtIndex,
    required this.plotIndex,
  });

  final String lessonId;
  final CityBuildingKind kind;
  final String name;
  final String emoji;
  final int districtIndex;
  final int plotIndex;

  LessonMeta? get meta => lessonById(lessonId);
}

class CityDistrictTheme {
  const CityDistrictTheme({
    required this.name,
    required this.accent,
    required this.surface,
    required this.road,
    required this.park,
    required this.tier,
  });

  final String name;
  final Color accent;
  final Color surface;
  final Color road;
  final Color park;
  final QuestTier tier;
}

/// Six districts — clean low-poly palette (white city + accent pops).
const kCityDistrictThemes = <CityDistrictTheme>[
  CityDistrictTheme(
    name: 'Coin Keeper',
    accent: Color(0xFF28B77F),
    surface: Color(0xFFF7F8FA),
    road: Color(0xFFE8EBF0),
    park: Color(0xFF7BC96F),
    tier: QuestTier.foundation,
  ),
  CityDistrictTheme(
    name: 'Smart Spender',
    accent: Color(0xFF5B8DEF),
    surface: Color(0xFFF7F8FA),
    road: Color(0xFFE8EBF0),
    park: Color(0xFF7BC96F),
    tier: QuestTier.foundation,
  ),
  CityDistrictTheme(
    name: 'Budget Boss',
    accent: Color(0xFFFFD93D),
    surface: Color(0xFFF7F8FA),
    road: Color(0xFFE8EBF0),
    park: Color(0xFF7BC96F),
    tier: QuestTier.intermediate,
  ),
  CityDistrictTheme(
    name: 'Junior Investor',
    accent: Color(0xFF00BEAA),
    surface: Color(0xFFF7F8FA),
    road: Color(0xFFE8EBF0),
    park: Color(0xFF7BC96F),
    tier: QuestTier.intermediate,
  ),
  CityDistrictTheme(
    name: 'Wealth Builder',
    accent: Color(0xFFFA7F46),
    surface: Color(0xFFF7F8FA),
    road: Color(0xFFE8EBF0),
    park: Color(0xFF7BC96F),
    tier: QuestTier.advanced,
  ),
  CityDistrictTheme(
    name: 'Chief Money Officer',
    accent: Color(0xFFFFB018),
    surface: Color(0xFFF7F8FA),
    road: Color(0xFFE8EBF0),
    park: Color(0xFF7BC96F),
    tier: QuestTier.advanced,
  ),
];

const _plotEmojis = <String>[
  '🪙', '🐷', '🛒', '🎮', '🏪', '🏬', '🏷️', '☕', '📋', '💼',
  '🌱', '🫙', '🌳', '🏦', '🏆', '📊', '📝', '🔧', '🏠', '✅',
  '🍋', '💰', '🛍️', '📈', '🏗️', '🧹', '⏰', '🔄', '💝', '🎓',
  '🔭', '☂️', '🚑', '🪜', '🌉', '📢', '⭐', '📖', '↩️', '🛡️',
  '🤝', '👥', '💬', '🏢', '🏟️', '🎯', '🧪', '🌻', '🌰', '🎊',
];

List<CityBuildingDef> _buildCityCatalog() {
  final kinds = CityBuildingKind.values;
  return kCurriculum.asMap().entries.map((entry) {
    final i = entry.key;
    final meta = entry.value;
    return CityBuildingDef(
      lessonId: meta.id,
      kind: kinds[i % kinds.length],
      name: meta.title,
      emoji: _plotEmojis[i % _plotEmojis.length],
      districtIndex: meta.questLevel - 1,
      plotIndex: meta.stageInLevel - 1,
    );
  }).toList();
}

final kCityBuildings = _buildCityCatalog();

CityBuildingDef? cityBuildingForLesson(String lessonId) {
  for (final b in kCityBuildings) {
    if (b.lessonId == lessonId) return b;
  }
  return null;
}

CityBuildingDef cityBuildingForLessonOrFallback(String lessonId) {
  return cityBuildingForLesson(lessonId) ??
      CityBuildingDef(
        lessonId: lessonId,
        kind: CityBuildingKind.firstStand,
        name: 'Skill Tower',
        emoji: '🏙️',
        districtIndex: 0,
        plotIndex: 0,
      );
}

List<CityBuildingDef> buildingsInDistrict(int districtIndex) {
  return kCityBuildings.where((b) => b.districtIndex == districtIndex).toList();
}

class CityPlot {
  const CityPlot({
    required this.building,
    required this.status,
    this.tower,
    this.isHighlighted = false,
  });

  final CityBuildingDef building;
  final CityPlotStatus status;
  final Tower? tower;
  final bool isHighlighted;

  bool get isBuilt => status == CityPlotStatus.built;
  bool get isNext => status == CityPlotStatus.next;
}

class CityProgressSnapshot {
  const CityProgressSnapshot({
    required this.plots,
    required this.builtCount,
    required this.nextPlot,
    required this.districtCompletion,
  });

  final List<CityPlot> plots;
  final int builtCount;
  final CityPlot? nextPlot;
  final List<double> districtCompletion;

  double get overallProgress => builtCount / kTotalStages;
}

CityProgressSnapshot buildCityProgress({
  required List<LessonProgress> lessonProgress,
  required List<Tower> towers,
  UserProfile? profile,
  String? highlightLessonId,
}) {
  final towerByLesson = {for (final t in towers) t.type: t};
  CityPlot? nextPlot;

  final plots = kCityBuildings.map((building) {
    final meta = building.meta;
    if (meta == null) {
      return CityPlot(building: building, status: CityPlotStatus.locked);
    }
    final lessonStatus = LessonProgression.statusFor(meta, lessonProgress, profile);
    final tower = towerByLesson[building.lessonId];

    final CityPlotStatus status;
    if (lessonStatus == LessonStatus.completed || tower != null) {
      status = CityPlotStatus.built;
    } else if (lessonStatus == LessonStatus.inProgress) {
      status = CityPlotStatus.inProgress;
    } else if (lessonStatus == LessonStatus.available) {
      status = CityPlotStatus.next;
      nextPlot ??= CityPlot(building: building, status: status, tower: tower);
    } else {
      status = CityPlotStatus.locked;
    }

    return CityPlot(
      building: building,
      status: status,
      tower: tower,
      isHighlighted: building.lessonId == highlightLessonId,
    );
  }).toList();

  if (nextPlot == null) {
    for (final p in plots) {
      if (p.status == CityPlotStatus.inProgress) {
        nextPlot = p;
        break;
      }
    }
  }

  final builtCount = plots.where((p) => p.isBuilt).length;
  final districtCompletion = List.generate(kQuestLevelCount, (d) {
    final districtPlots = plots.where((p) => p.building.districtIndex == d);
    final built = districtPlots.where((p) => p.isBuilt).length;
    final total = stagesInQuestLevel(d + 1);
    return total > 0 ? built / total : 0.0;
  });

  return CityProgressSnapshot(
    plots: plots,
    builtCount: builtCount,
    nextPlot: nextPlot,
    districtCompletion: districtCompletion,
  );
}

String buildingDisplayName(Tower tower) {
  return cityBuildingForLesson(tower.type)?.name ?? tower.name;
}
