import 'package:flutter_test/flutter_test.dart';
import 'package:ai_empire/data/arcs.dart';
import 'package:ai_empire/data/events.dart';
import 'package:ai_empire/data/hook.dart';
import 'package:ai_empire/data/training_events.dart';
import 'package:ai_empire/data/world_events.dart';
import 'package:ai_empire/data/yearly_events.dart';
import 'package:ai_empire/models.dart';

/// تدقيق البند 5 (ديناميكية بلا خيارات ميتة):
/// كل خيار في كل حدث يجب أن يغيّر شيئا مرئيا واحدا على الأقل
/// يخصّ الخيار نفسه — إحصاءة، أو رصيد مباشر، أو حوسبة، أو جولة
/// تدريب، أو وظيفة، أو رؤية، أو سمة، أو فصل لاحق، أو موت —
/// لا أن يعتمد على الدخل والمصاريف السنوية العامة التي تطال كل
/// الخيارات بالتساوي. خيار بلا أيّ من هذه هو خيار ميت: يقرأه
/// اللاعب ولا يرى له أثرا، فيتعلّم أن الاختيار لا يهمّ.
bool choiceIsVisible(EventChoice choice) {
  return !choice.effect.isEmpty ||
      choice.cash != 0 ||
      choice.compute != 0 ||
      choice.trainLevels > 0 ||
      choice.job != null ||
      choice.ambition != null ||
      choice.addTraits.isNotEmpty ||
      choice.removeTraits.isNotEmpty ||
      choice.nextId != null ||
      choice.deathCause != null;
}

List<LifeEvent> allPools() => [
      ...allEvents,
      ...laterEvents,
      ...trainingEvents,
      ...worldEvents,
      ...arcStarters,
      ...arcChapters,
      ...hookEvents,
      ...hookChapters,
      yearlyEventForAge(25),
      yearlyEventForAge(40),
      yearlyEventForAge(60),
      genericEvent(25),
      genericEvent(40),
      genericEvent(60),
    ];

List<int> _dominanceVector(EventChoice c) => [
      c.effect.tech,
      c.effect.morale,
      c.effect.research,
      c.effect.money,
      c.effect.social,
      c.effect.skill,
      c.effect.reputation,
      c.cash ~/ 10000,
      c.compute,
      c.trainLevels * 10,
    ];

void main() {
  test('لا خيار ميت: كل خيار يغيّر شيئا مرئيا يخصّه', () {
    final dead = <String>[];
    for (final event in allPools()) {
      for (final choice in event.choices) {
        if (!choiceIsVisible(choice)) {
          dead.add('${event.id} :: ${choice.text}');
        }
      }
    }
    expect(dead, isEmpty,
        reason: 'خيارات ميتة بلا أثر مرئي:\n${dead.join('\n')}');
  });

  test('كل حدث له خياران على الأقل، فالقرار بلا بديل ليس قرارا', () {
    final thin = <String>[];
    for (final event in allPools()) {
      if (event.choices.length < 2) thin.add(event.id);
    }
    expect(thin, isEmpty, reason: 'أحداث بخيار واحد: $thin');
  });

  test('لا خيار مهيمن عليه كليا: كل خيار يتفوق على أشقائه في شيء واحد على الأقل', () {
    final dominated = <String>[];
    for (final event in allPools()) {
      final choices = event.choices;
      for (var i = 0; i < choices.length; i++) {
        for (var j = 0; j < choices.length; j++) {
          if (i == j) continue;
          final a = choices[i];
          final b = choices[j];
          if (a.deathCause != null || b.deathCause != null) continue;
          final aQual = {...a.addTraits, ...a.removeTraits};
          final bQual = {...b.addTraits, ...b.removeTraits};
          if (!bQual.containsAll(aQual)) continue;
          if (a.nextId != null && b.nextId != a.nextId) continue;
          if (a.job != null && b.job != a.job) continue;
          if (a.ambition != null && b.ambition != a.ambition) continue;
          final va = _dominanceVector(a);
          final vb = _dominanceVector(b);
          var allGe = true;
          var anyGt = false;
          for (var k = 0; k < va.length; k++) {
            if (vb[k] < va[k]) allGe = false;
            if (vb[k] > va[k]) anyGt = true;
          }
          if (allGe && anyGt) {
            dominated.add('${event.id} :: "${a.text}" مهيمن عليه من "${b.text}"');
          }
        }
      }
    }
    expect(dominated, isEmpty,
        reason: 'خيارات لا سبب لاختيارها أبدا:\n${dominated.join('\n')}');
  });

  test('لا حدث مكرر الهوية يخفي خيارات عن اللاعب', () {
    final ids = allPools().map((e) => e.id).toList();
    final duplicates = ids
        .where((id) => ids.where((other) => other == id).length > 1)
        .toSet();
    expect(duplicates, isEmpty, reason: 'هويات مكررة: $duplicates');
  });
}
