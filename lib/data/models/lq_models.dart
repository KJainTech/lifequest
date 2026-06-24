// LifeQuest data models — mirrors packages/types Firestore shapes.

class BusinessIQ {
  const BusinessIQ({
    required this.profit,
    required this.decision,
    required this.resilience,
  });

  final int profit;
  final int decision;
  final int resilience;

  factory BusinessIQ.fromMap(Map<String, dynamic> map) => BusinessIQ(
        profit: (map['profit'] as num?)?.toInt() ?? 0,
        decision: (map['decision'] as num?)?.toInt() ?? 0,
        resilience: (map['resilience'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'profit': profit,
        'decision': decision,
        'resilience': resilience,
      };
}

class Streak {
  const Streak({required this.count, this.lastActive});

  final int count;
  final String? lastActive;

  factory Streak.fromMap(Map<String, dynamic> map) => Streak(
        count: (map['count'] as num?)?.toInt() ?? 0,
        lastActive: map['lastActive'] as String?,
      );
}

class UserStats {
  const UserStats({
    required this.xp,
    required this.level,
    required this.coins,
    required this.lqScore,
    required this.businessIQ,
    required this.streak,
    this.conceptSkills = const {},
    this.updatedAt,
  });

  final int xp;
  final int level;
  final int coins;
  final int lqScore;
  final BusinessIQ businessIQ;
  final Streak streak;
  final Map<String, int> conceptSkills;
  final String? updatedAt;

  static const empty = UserStats(
    xp: 0,
    level: 1,
    coins: 0,
    lqScore: 0,
    businessIQ: BusinessIQ(profit: 0, decision: 0, resilience: 0),
    streak: Streak(count: 0),
    conceptSkills: {},
  );

  factory UserStats.fromMap(Map<String, dynamic> map) {
    final rawSkills = map['conceptSkills'] as Map<String, dynamic>? ?? {};
    return UserStats(
        xp: (map['xp'] as num?)?.toInt() ?? 0,
        level: (map['level'] as num?)?.toInt() ?? 1,
        coins: (map['coins'] as num?)?.toInt() ?? 0,
        lqScore: (map['lqScore'] as num?)?.toInt() ?? 0,
        businessIQ: BusinessIQ.fromMap(
          map['businessIQ'] as Map<String, dynamic>? ?? {},
        ),
        streak: Streak.fromMap(map['streak'] as Map<String, dynamic>? ?? {}),
        conceptSkills: rawSkills.map(
          (k, v) => MapEntry(k, (v as num).toInt()),
        ),
        updatedAt: map['updatedAt'] as String?,
      );
  }
}

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.role,
    required this.displayName,
    this.ageBand,
    this.guide,
    this.proficiencyLevel = 1,
    this.locale = 'en',
    this.region = 'AE',
    this.onboardingComplete = false,
    this.age,
  });

  final String uid;
  final String role;
  final String displayName;
  final String? ageBand;
  final String? guide;
  final int proficiencyLevel;
  final String locale;
  final String region;
  final bool onboardingComplete;
  final int? age;

  factory UserProfile.fromMap(String uid, Map<String, dynamic> map) =>
      UserProfile(
        uid: uid,
        role: map['role'] as String? ?? 'child',
        displayName: map['displayName'] as String? ?? 'Player',
        ageBand: map['ageBand'] as String?,
        guide: map['guide'] as String?,
        proficiencyLevel: (map['proficiencyLevel'] as num?)?.toInt() ?? 1,
        locale: map['locale'] as String? ?? 'en',
        region: map['region'] as String? ?? 'AE',
        onboardingComplete: map['onboardingComplete'] as bool? ?? false,
        age: (map['age'] as num?)?.toInt(),
      );

  Map<String, dynamic> toMap() => {
        'role': role,
        'displayName': displayName,
        if (ageBand != null) 'ageBand': ageBand,
        if (guide != null) 'guide': guide,
        'proficiencyLevel': proficiencyLevel,
        'locale': locale,
        'region': region,
        'onboardingComplete': onboardingComplete,
        if (age != null) 'age': age,
        'createdAt': DateTime.now().toUtc().toIso8601String(),
      };
}

enum LessonStatus { locked, available, inProgress, completed }

class LessonProgress {
  const LessonProgress({
    required this.lessonId,
    required this.status,
    this.quizScore,
    this.stars,
    this.completedAt,
  });

  final String lessonId;
  final LessonStatus status;
  final int? quizScore;
  final int? stars;
  final String? completedAt;

  factory LessonProgress.fromMap(String lessonId, Map<String, dynamic> map) {
    final statusStr = map['status'] as String? ?? 'locked';
    return LessonProgress(
      lessonId: lessonId,
      status: switch (statusStr) {
        'available' => LessonStatus.available,
        'in_progress' => LessonStatus.inProgress,
        'completed' => LessonStatus.completed,
        _ => LessonStatus.locked,
      },
      quizScore: (map['quizScore'] as num?)?.toInt(),
      stars: (map['stars'] as num?)?.toInt(),
      completedAt: map['completedAt'] as String?,
    );
  }
}

class Tower {
  const Tower({
    required this.id,
    required this.type,
    required this.name,
    required this.builtAt,
  });

  final String id;
  final String type;
  final String name;
  final String builtAt;

  factory Tower.fromMap(Map<String, dynamic> map) => Tower(
        id: map['id'] as String? ?? '',
        type: map['type'] as String? ?? '',
        name: map['name'] as String? ?? '',
        builtAt: map['builtAt'] as String? ?? '',
      );
}

class LessonCompletionResult {
  const LessonCompletionResult({
    required this.xp,
    required this.coins,
    required this.lqScore,
    required this.level,
    required this.stars,
    this.badgeUnlocked,
    this.towerName,
    this.idempotent = false,
  });

  final int xp;
  final int coins;
  final int lqScore;
  final int level;
  final int stars;
  final String? badgeUnlocked;
  final String? towerName;
  final bool idempotent;

  factory LessonCompletionResult.fromMap(Map<String, dynamic> map) {
    final tower = map['tower'] as Map<String, dynamic>?;
    return LessonCompletionResult(
      xp: (map['xp'] as num?)?.toInt() ?? 0,
      coins: (map['coins'] as num?)?.toInt() ?? 0,
      lqScore: (map['lqScore'] as num?)?.toInt() ?? 0,
      level: (map['level'] as num?)?.toInt() ?? 1,
      stars: (map['stars'] as num?)?.toInt() ?? 0,
      badgeUnlocked: map['badgeUnlocked'] as String?,
      towerName: tower?['name'] as String?,
      idempotent: map['idempotent'] as bool? ?? false,
    );
  }
}

class QuizSubmitResult {
  const QuizSubmitResult({
    required this.score,
    required this.maxScore,
    required this.xpPreview,
    required this.coinsPreview,
    required this.allCorrect,
  });

  final int score;
  final int maxScore;
  final int xpPreview;
  final int coinsPreview;
  final bool allCorrect;

  factory QuizSubmitResult.fromMap(Map<String, dynamic> map) =>
      QuizSubmitResult(
        score: (map['score'] as num?)?.toInt() ?? 0,
        maxScore: (map['maxScore'] as num?)?.toInt() ?? 5,
        xpPreview: (map['xpPreview'] as num?)?.toInt() ?? 0,
        coinsPreview: (map['coinsPreview'] as num?)?.toInt() ?? 0,
        allCorrect: map['allCorrect'] as bool? ?? false,
      );
}
