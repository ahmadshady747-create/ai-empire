import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_empire/data/stat_meanings.dart';
import 'package:ai_empire/game_engine.dart';
import 'package:ai_empire/screens/game_screen.dart';

void main() {
  test('شرح الإحصاءات يغطي الإحصاءات السبع كلها دون نقص', () {
    final engine = GameEngine()..newLife();
    final labels = engine.stats.asList().map((s) => s.$1).toList();
    expect(statMeanings.keys.toSet(), labels.toSet());
    for (final meaning in statMeanings.values) {
      expect(meaning.meaning, isNotEmpty);
      expect(meaning.effect, isNotEmpty);
    }
    expect(statLevelLabel(80), 'ممتاز');
    expect(statLevelLabel(50), 'جيد');
    expect(statLevelLabel(20), contains('خطر'));
  });

  testWidgets('بطاقة الإحصاءات: عنوان وإرشاد، والضغط على التقنية يفتح شرحها',
      (tester) async {
    final engine = GameEngine()..newLife();
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
    expect(find.text('📊 إحصاءات شركتك'), findsOneWidget);
    expect(find.text('اضغط أي إحصاءة لتعرف معناها وأثرها على شركتك.'),
        findsOneWidget);
    await tester.tap(find.text('التقنية'));
    await tester.pumpAndSettle();
    // شرح التقنية يذكر رؤية الذكاء العام وعتبة 85.
    expect(find.textContaining('رؤية الذكاء العام'), findsOneWidget);
    expect(find.textContaining('85'), findsWidgets);
  });
}
