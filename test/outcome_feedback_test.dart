import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_empire/game_engine.dart';
import 'package:ai_empire/screens/game_screen.dart';

void main() {
  test('التقريب: +10 تقنية عند 98 تعني فعليا +2 إلى 100 في الملخص', () {
    final engine = GameEngine()..newLife();
    engine.stats.tech = 98;
    final choice = engine.currentEvent!.choices[1];
    engine.applyChoice(choice);
    final summary = engine.lastOutcome!;
    final tech = summary.statChanges.firstWhere((c) => c.label == 'التقنية');
    expect(tech.delta, 2);
    expect(tech.newValue, 100);
  });

  test('تفصيل الرصيد والحوسبة: رصيد = قبل -2000 من القرار + دخل ومصاريف × سنة، وحوسبة +30',
      () {
    final engine = GameEngine()..newLife();
    final balanceBefore = engine.balance;
    final choice = engine.currentEvent!.choices[1];
    engine.applyChoice(choice);
    final summary = engine.lastOutcome!;
    expect(summary.cashDelta, -2000);
    expect(summary.years, 1);
    expect(summary.yearlyDelta, lessThan(0));
    expect(summary.balanceAfter,
        balanceBefore + summary.cashDelta + summary.yearlyDelta * 1);
    expect(summary.computeBefore, 0);
    expect(summary.computeAfter, 30);
    expect(summary.modelLevelAfter, summary.modelLevelBefore);
  });

  test('سمات وإنجازات جديدة: خيار الزقاق الأول يمنح سمة ديون بيانات، وبلوغ تقنية 90 يفتح إنجازا',
      () {
    final engine = GameEngine()..newLife();
    engine.stats.tech = 85;
    final choice = engine.currentEvent!.choices[0];
    engine.applyChoice(choice);
    final summary = engine.lastOutcome!;
    expect(summary.traitsAdded, contains('datadebt'));
    expect(summary.newAchievements, contains('techy'));
  });

  testWidgets('بطاقة النتيجة تعرض التغيّر الفعلي: تقنية وبحث ومال، وتفصيل رصيد وحوسبة',
      (tester) async {
    final engine = GameEngine()..newLife();
    engine.stats.tech = 80;
    engine.stats.research = 50;
    engine.stats.money = 50;
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('ar'),
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: GameScreen(
          engine: engine,
          onNewLife: () {},
          onFinish: () {},
        ),
      ),
    ));
    await tester.ensureVisible(find.text('ابدأ رحلة الشركة 🚀'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ابدأ رحلة الشركة 🚀'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
        find.text('أستأجر حوسبة طارئة وأعيد التدريب الليلة'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('أستأجر حوسبة طارئة وأعيد التدريب الليلة'));
    await tester.pumpAndSettle();
    expect(find.text('ما تغيّر في إحصاءاتك:'), findsOneWidget);
    expect(find.textContaining('التقنية: +10 → 90'), findsOneWidget);
    expect(find.textContaining('البحث: +4 → 54'), findsOneWidget);
    expect(find.textContaining('المال: -6 → 44'), findsOneWidget);
    expect(find.textContaining('-2,000 من القرار'), findsOneWidget);
    expect(find.textContaining('دخل ومصاريف × 1 سنة'), findsOneWidget);
    expect(find.textContaining('الحوسبة: 30 (+30)'), findsOneWidget);
  });
}
