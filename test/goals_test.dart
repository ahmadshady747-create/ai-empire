import 'package:ai_empire/goals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('التحديات الأسبوعية تتجدد مع كتلة الأسابيع', () {
    expect(weekBlock(1), 0);
    expect(weekBlock(4), 0);
    expect(weekBlock(5), 1);
    final early = weeklyChallenges(
        week: 1, users: 120, modelLevel: 1, launchedCount: 0);
    expect(early.first.target, 200);
    final later = weeklyChallenges(
        week: 9, users: 120, modelLevel: 1, launchedCount: 0);
    expect(later.first.target, 600);
  });

  test('الإنجازات والمستوى مشتقان من الأرقام فقط', () {
    final all = achievements(
      week: 12,
      users: 1500,
      cash: 300000,
      modelLevel: 3,
      launchedCount: 2,
      completedResearchCount: 1,
      completedModelCount: 0,
      rank: 2,
      reputation: 85,
      leadershipVictory: false,
    );
    expect(all.where((g) => g.unlocked).length, greaterThan(5));
    expect(all.firstWhere((g) => g.title == 'أول وظيفة نموذج منجزة')
        .unlocked, isFalse);
    final points = levelPoints(
        modelLevel: 3,
        launchedCount: 2,
        completedResearchCount: 1,
        completedModelCount: 0);
    expect(points, 14);
    expect(levelFromPoints(points), 3);
  });

  testWidgets('لوحة الأهداف تعرض الفوز عند الصدارة',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: SingleChildScrollView(
              child: GoalsPanel(
                week: 20,
                users: 2000,
                cash: 200000,
                modelLevel: 3,
                launchedCount: 2,
                completedResearchCount: 1,
                completedModelCount: 1,
                rank: 1,
                reputation: 70,
                isBankrupt: false,
                leadershipVictory: true,
                streakWeeks: 5,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('لحظة فوز'), findsOneWidget);
    expect(find.byKey(const Key('goals-panel')), findsOneWidget);
  });
}
