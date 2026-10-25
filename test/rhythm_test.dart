import 'package:flutter_test/flutter_test.dart';
import 'package:ai_empire/data/yearly_events.dart';
import 'package:ai_empire/game_engine.dart';

/// البند 6 (إيقاع متكامل)، الجولة الأولى: سنوات التدبير لا تتكرر
/// حرفيا، والأنظمة القديمة تبقى مؤثرة في المرحلة المتأخرة.
void main() {
  test('إطارات سنوات التدبير تدور ولا تتكرر في كل مرحلة', () {
    for (final age in [25, 40, 60]) {
      final stories = [
        yearlyEventForAge(age, cycle: 0).story,
        yearlyEventForAge(age, cycle: 1).story,
        yearlyEventForAge(age, cycle: 2).story,
      ];
      expect(stories.toSet().length, 3,
          reason: 'سنة التدبير بعمر $age تتكرر حرفيا عبر الدورات');
      // الدورة الرابعة تعود إلى الإطار الأول: دوران لا توليد لا نهائي.
      expect(yearlyEventForAge(age, cycle: 3).story, stories[0]);
    }
  });

  test('الخيارات نفسها عبر الإطارات: الدوران سردي لا يغيّر التوازن', () {
    for (final age in [25, 40]) {
      final first =
          yearlyEventForAge(age, cycle: 0).choices.map((c) => c.text).toList();
      final second =
          yearlyEventForAge(age, cycle: 1).choices.map((c) => c.text).toList();
      expect(second, first);
    }
  });

  test('المرحلة المتأخرة فيها خيار إرث، وأثره يكبر مع مستوى النموذج', () {
    final poor = yearlyEventForAge(60, modelLevel: 0, achievementCount: 0);
    final rich = yearlyEventForAge(60, modelLevel: 5, achievementCount: 6);
    expect(poor.choices.length, 4);
    final legacyPoor = poor.choices.last;
    final legacyRich = rich.choices.last;
    expect(legacyPoor.text, contains('إرثي'));
    expect(legacyRich.effect.reputation, greaterThan(legacyPoor.effect.reputation));
    expect(legacyRich.cash, greaterThan(legacyPoor.cash));
    expect(legacyRich.effect.money, greaterThan(legacyPoor.effect.money));
  });

  test('المحرك يحصي سنوات التدبير ويحفظ العدد مع الاستئناف', () {
    final engine = GameEngine()..newLife();
    // الافتتاح فصلان، وبعدهما تأتي سنة التدبير الأولى.
    engine.applyChoice(engine.currentEvent!.choices.first);
    engine.nextEvent();
    expect(engine.currentEvent!.id, 'hook_ai_2');
    engine.applyChoice(engine.currentEvent!.choices.first);
    engine.nextEvent();
    expect(engine.currentEvent!.id.startsWith('yearly_'), isTrue);
    expect(engine.yearlyCount, 1);
    final firstStory = engine.currentEvent!.story;
    // سنة تدبير ثانية بإطار مختلف.
    engine.yearlyTurn = true;
    engine.nextEvent();
    expect(engine.currentEvent!.id.startsWith('yearly_'), isTrue);
    expect(engine.yearlyCount, 2);
    expect(engine.currentEvent!.story, isNot(firstStory));
    // الاستئناف يحفظ العدد ويعيد نص السنة الحالية نفسه.
    final restored = GameEngine.fromJson(engine.toJson());
    expect(restored.yearlyCount, 2);
    expect(restored.currentEvent!.story, engine.currentEvent!.story);
  });
}
