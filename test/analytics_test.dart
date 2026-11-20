import 'package:ai_empire/analytics/company_history.dart';
import 'package:ai_empire/analytics/strategic_advisor.dart';
import 'package:ai_empire/management.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('WeekSnapshot يحفظ ويسترجع القيم بدقة عبر JSON', () {
    final s = ManagementState(week: 6, cash: 88000, users: 1200, modelLevel: 3);
    final snap = WeekSnapshot.fromState(s);
    final restored = WeekSnapshot.fromJson(snap.toJson());
    expect(restored.week, 6);
    expect(restored.cash, 88000);
    expect(restored.users, 1200);
    expect(restored.modelLevel, 3);
  });

  test('WeekDelta يحسب فروقات النقد والمستخدمين والترتيب بدقة', () {
    const prev = WeekSnapshot(
      week: 1,
      cash: 100000,
      users: 100,
      weeklyRevenue: 5000,
      weeklyCost: 4000,
      weeklyNet: 1000,
      modelLevel: 1,
      rank: 4,
      reputation: 50,
      computeAvailable: 60,
    );
    const curr = WeekSnapshot(
      week: 2,
      cash: 112000,
      users: 350,
      weeklyRevenue: 9000,
      weeklyCost: 4500,
      weeklyNet: 4500,
      modelLevel: 2,
      rank: 2,
      reputation: 58,
      computeAvailable: 80,
    );
    final delta = WeekDelta.between(prev, curr);
    expect(delta.cashDelta, 12000);
    expect(delta.usersDelta, 250);
    expect(delta.rankDelta, 2);
    expect(delta.modelDelta, 1);
    expect(delta.reputationDelta, 8);
  });

  test('المستشار الاستراتيجي يكتشف نقص السيولة وجودة البيانات المنخفضة', () {
    final risky = ManagementState(
      cash: 5000,
      dataQuality: 30,
      computeAvailable: 10,
    );
    final advice = analyzeStrategy(risky);
    expect(advice.isNotEmpty, isTrue);
    expect(
      advice.any((a) => a.severity == AdviceSeverity.critical ||
          a.severity == AdviceSeverity.warning),
      isTrue,
    );
  });
}
