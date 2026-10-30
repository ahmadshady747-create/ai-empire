import 'package:ai_empire/live_scene.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('نسب المشهد الحي مشتقة من الأرقام الحقيقية فقط', () {
    expect(computeFraction(0), 0);
    expect(computeFraction(200), 1);
    expect(computeFraction(100), 0.5);
    expect(userDots(0), 0);
    expect(userDots(120), 1);
    expect(userDots(99999), 24);
    expect(levelFraction(1), 0.1);
    expect(levelFraction(10), 1);
  });

  testWidgets('مشهد الشركة يعرض المنافسين والمستخدمين',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: SingleChildScrollView(
              child: CompanyLiveScene(
                computeAvailable: 100,
                computeReserved: 20,
                users: 250,
                modelLevel: 2,
                rivalNames: ['مدار للذكاء'],
                rivalLevels: [1],
                reputation: 50,
                isBankrupt: false,
                leadershipVictory: false,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('مشهد الشركة الحي'), findsOneWidget);
    expect(find.text('مدار للذكاء'), findsOneWidget);
    expect(find.textContaining('المستخدمون: 250'), findsOneWidget);
    expect(find.byKey(const Key('live-scene')), findsOneWidget);
  });
}
