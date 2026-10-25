import 'package:flutter_test/flutter_test.dart';
import 'package:ai_empire/data/training_events.dart';
import 'package:ai_empire/game_engine.dart';
import 'package:ai_empire/models.dart';

void main() {
  test('رحلة كاملة تنتهي بنهاية وسجل غير فارغ', () {
    final engine = GameEngine()..newLife();

    expect(engine.person.fullName.isNotEmpty, isTrue);
    expect(engine.currentEvent, isNotNull);
    expect(engine.age, 22);

    // العب دائما بالخيار الأول غير القاتل، حتى الموت.
    var steps = 0;
    while (!engine.isDead && steps < 200) {
      final event = engine.currentEvent!;
      final choice = event.choices.firstWhere(
        (c) => c.deathCause == null,
        orElse: () => event.choices.first,
      );
      final ageBefore = engine.age;
      engine.applyChoice(choice);
      if (!engine.isDead) {
        expect(engine.age, greaterThan(ageBefore));
        engine.nextEvent();
        expect(engine.currentEvent, isNotNull);
      }
      steps++;
    }

    expect(engine.isDead, isTrue);
    expect(engine.deathCause, isNotNull);
    expect(engine.log, isNotEmpty);
    expect(engine.storyText(), contains(engine.person.fullName));
    // لا يتكرر حدث مكتوب في الحياة الواحدة (الأحداث العامة مستثناة).
    final ids = engine.usedEvents.toList();
    expect(ids.length, ids.toSet().length);
  });

  test('الحفظ والاستئناف يعيدان نفس الرحلة', () {
    final engine = GameEngine()..newLife();
    final event = engine.currentEvent!;
    final choice = event.choices.firstWhere(
      (c) => c.deathCause == null,
      orElse: () => event.choices.first,
    );
    engine.applyChoice(choice);
    engine.nextEvent();
    final json = engine.toJson();
    final restored = GameEngine.fromJson(json);
    expect(restored.person.fullName, engine.person.fullName);
    expect(restored.age, engine.age);
    expect(restored.balance, engine.balance);
    expect(restored.log.length, engine.log.length);
    expect(restored.currentEvent, isNotNull);
    expect(restored.lifeScore, greaterThan(0));
  });

  test('الهوك يفرض ليلة العرض ثم صباح العرض بثلاثة خيارات لكل فصل', () {
    final engine = GameEngine()..newLife();
    expect(engine.currentEvent!.id, 'hook_ai_open');
    expect(engine.currentEvent!.choices.length, 3);
    // كل خيار في الفصل الأول له ثمن مرئي: أثر أو رصيد أو حوسبة أو سمة.
    for (final choice in engine.currentEvent!.choices) {
      expect(
        !choice.effect.isEmpty ||
            choice.cash != 0 ||
            choice.compute != 0 ||
            choice.addTraits.isNotEmpty,
        isTrue,
      );
      expect(choice.nextId, 'hook_ai_2');
    }
    // العبور بالخيار الأول: الفصل الثاني يفرض نفسه فورا.
    final first = engine.currentEvent!.choices.first;
    engine.applyChoice(first);
    engine.nextEvent();
    expect(engine.currentEvent!.id, 'hook_ai_2');
    expect(engine.currentEvent!.choices.length, 3);
    // كل نتيجة في الفصل الثاني تنتهي بالخيط المفتوح نفسه: البطاقة بلا اسم.
    for (final choice in engine.currentEvent!.choices) {
      expect(choice.outcome, contains('بطاقة بلا اسم'));
      expect(choice.nextId, isNull);
    }
    // بعد الفصل الثاني تأتي سنة تدبير، لأن خياره بلا فصل تال.
    engine.applyChoice(engine.currentEvent!.choices.first);
    engine.nextEvent();
    expect(engine.currentEvent!.id.startsWith('yearly_'), isTrue);
  });

  test('القصة المتسلسلة تفرض فصلها التالي والحدث المصيري يتبعه سنة تدبير', () {
    final engine = GameEngine()..newLife();
    engine.pendingNextId = 'series_b';
    final arc = engine.pickNextEvent();
    expect(arc.id, 'series_b');

    // العبور من الافتتاح أولا: الهوك صار أول حدث، فلا يفترض
    // أن أول حدث عشوائي. بعد فصلَي الافتتاح تأتي سنة تدبير.
    final engine2 = GameEngine()..newLife();
    expect(engine2.currentEvent!.id, 'hook_ai_open');
    engine2.applyChoice(engine2.currentEvent!.choices.first);
    engine2.nextEvent();
    expect(engine2.currentEvent!.id, 'hook_ai_2');
    final hookChoice = engine2.currentEvent!.choices.firstWhere(
      (c) => c.deathCause == null && c.nextId == null,
      orElse: () => engine2.currentEvent!.choices.first,
    );
    engine2.applyChoice(hookChoice);
    if (!engine2.isDead) {
      engine2.nextEvent();
      expect(engine2.currentEvent!.id.startsWith('yearly_'), isTrue);
    }
  });

  test('نظام التدريب: حوسبة مخزنة ومستوى نموذج بسقف 5 وحفظ', () {
    final engine = GameEngine()..newLife();
    expect(engine.modelLevel, 0);
    expect(engine.compute, 0);

    // جمع حوسبة دون تدريب.
    engine.applyChoice(const EventChoice(
        text: 'x', outcome: 'x', compute: 25, ageJump: 0));
    expect(engine.compute, 25);

    // جولة تدريب مع مخزون 20+: تستهلك 20 وتمنح مستوى إضافيا.
    engine.applyChoice(const EventChoice(
        text: 'x', outcome: 'x', trainLevels: 1, ageJump: 0));
    expect(engine.modelLevel, 2);
    expect(engine.compute, 5);

    // جولة تدريب دون مخزون كاف: مستوى واحد فقط.
    engine.applyChoice(const EventChoice(
        text: 'x', outcome: 'x', trainLevels: 1, ageJump: 0));
    expect(engine.modelLevel, 3);

    // السقف 5 لا يُتجاوز مهما تكرر التدريب.
    for (var i = 0; i < 10; i++) {
      engine.applyChoice(const EventChoice(
          text: 'x', outcome: 'x', trainLevels: 1, ageJump: 0));
    }
    expect(engine.modelLevel, 5);
    expect(engine.achievements, contains('frontier'));

    // الحفظ والاستئناف يحفظان مستوى النموذج والحوسبة.
    final restored = GameEngine.fromJson(engine.toJson());
    expect(restored.modelLevel, 5);
    expect(restored.compute, engine.compute);

    // حدث التسريب يشترط سمة ديون البيانات، وحدث التدريب الأول يناسب
    // من لا يملكها (الفئة العمرية 24-50).
    final leakEvent =
        trainingEvents.firstWhere((e) => e.id == 'train_leak');
    expect(leakEvent.fits(30, {'datadebt'}, {}), isTrue);
    expect(leakEvent.fits(30, {}, {}), isFalse);
    final firstEvent =
        trainingEvents.firstWhere((e) => e.id == 'train_first');
    expect(firstEvent.fits(30, {}, {}), isTrue);
    expect(firstEvent.choices.length, 3);
  });

  test('عدة شركات مختلفة على الأقل في الأسماء أو الدول', () {
    final seen = <String>{};
    for (var i = 0; i < 20; i++) {
      final engine = GameEngine()..newLife();
      seen.add('${engine.person.fullName}-${engine.person.country}');
    }
    expect(seen.length, greaterThan(1));
  });
}
