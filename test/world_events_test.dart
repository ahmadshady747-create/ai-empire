import 'package:ai_empire/world_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('مشهد حدث العالم يعرض الحدث ويستدعي القرار',
      (tester) async {
    var decided = '';
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: SingleChildScrollView(
              child: WorldEventScene(
                eventName: 'أزمة إمداد رقائق',
                eventEffect: 'حوسبتك المتاحة تنقص 20 وحدة هذا الأسبوع.',
                streakWeeks: 4,
                canBuyCompute: true,
                canStartResearch: true,
                onBuyCompute: () => decided = 'compute',
                onStartResearch: () => decided = 'research',
                onSaveCash: () => decided = 'save',
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('مشهد حدث العالم'), findsOneWidget);
    expect(find.text('أزمة إمداد رقائق'), findsOneWidget);
    expect(find.textContaining('سلسلة أسابيعك'), findsOneWidget);
    expect(find.byKey(const Key('world-event-scene')), findsOneWidget);
    await tester.tap(find.textContaining('استثمر في الحوسبة'));
    await tester.pump();
    expect(decided, 'compute');
    await tester.tap(find.textContaining('ادّخر النقد'));
    await tester.pump();
    expect(decided, 'save');
  });
}
