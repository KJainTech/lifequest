/// Activity types for the gameplay engine (Creative DevPlan Phase 3).
enum StageActivityKind { mcq, dragDrop, slider, cardSort, scenario, simulator }

/// Bespoke simulators flagged as review “best screens”.
enum StageSimulatorId { creditScore, crashExperiment }

class StageActivity {
  const StageActivity({
    required this.kind,
    required this.prompt,
    this.options = const [],
    this.correctIndex = 0,
    this.dragItems = const [],
    this.dragTargetA = 'Needs',
    this.dragTargetB = 'Wants',
    this.dragCorrectBucket = const {},
    this.sliderMin = 0,
    this.sliderMax = 100,
    this.sliderCorrect = 50,
    this.sliderUnit = 'AED',
    this.sceneText,
    this.explanation = '',
  });

  final StageActivityKind kind;
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final List<String> dragItems;
  final String dragTargetA;
  final String dragTargetB;
  /// item label → 'A' or 'B'
  final Map<String, String> dragCorrectBucket;
  final int sliderMin;
  final int sliderMax;
  final int sliderCorrect;
  final String sliderUnit;
  final String? sceneText;
  final String explanation;
}

class StageIntroCopy {
  const StageIntroCopy({
    required this.penny,
    required this.finBot,
    required this.atlas,
    this.hook,
  });

  final String penny;
  final String finBot;
  final String atlas;
  final String? hook;
}
