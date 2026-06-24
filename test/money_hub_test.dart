import 'package:flutter_test/flutter_test.dart';

import 'package:lifequest/features/money/money_hub_snapshot.dart';
import 'package:lifequest/data/models/lq_models.dart';

void main() {
  test('MoneyHubSnapshot computes savings split from coins', () {
    final snap = MoneyHubSnapshot.from(
      stats: const UserStats(
        xp: 100,
        level: 2,
        coins: 100,
        lqScore: 55,
        businessIQ: BusinessIQ(profit: 10, decision: 20, resilience: 15),
        streak: Streak(count: 3),
      ),
      lessons: const [],
      profile: null,
      badgeCount: 1,
      cityBuildings: 4,
    );
    expect(snap.savingsJar, 35);
    expect(snap.availableCoins, 65);
    expect(snap.badgeCount, 1);
  });
}
