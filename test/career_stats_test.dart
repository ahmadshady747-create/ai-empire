import 'package:ai_empire/analytics/career_stats.dart';
import 'package:ai_empire/management.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CareerStats يسجل أفضل الأرقام والانتصارات ويحفظها عبر JSON', () {
    const initial = CareerStats();
    final progressed = initial.recordProgress(
      ManagementState(week: 12, cash: 320000, users: 4200, modelLevel: 4),
    );
    final won = progressed.recordOutcome(victory: true, bankrupt: false);
    final nextRun = won.recordNewRun();

    final restored = CareerStats.fromJson(nextRun.toJson());
    expect(restored.runsPlayed, 2);
    expect(restored.victories, 1);
    expect(restored.bankruptcies, 0);
    expect(restored.highestCash, 320000);
    expect(restored.highestUsers, 4200);
    expect(restored.highestModelLevel, 4);
    expect(restored.longestRunWeeks, 12);
  });
}
