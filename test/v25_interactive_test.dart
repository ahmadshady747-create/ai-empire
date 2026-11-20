import 'package:ai_empire/interactive/decision_cards.dart';
import 'package:ai_empire/interactive/hq_pulses.dart';
import 'package:ai_empire/interactive/progression_stages.dart';
import 'package:ai_empire/management.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('نبضات المقر تولّد فرصتين مختلفتين كل أسبوع وتؤثر فعلياً في الحالة', () {
    final s = ManagementState();
    final pulses = generateWeeklyPulses(1, s);
    expect(pulses.length, 2);
    expect(pulses[0].id, isNot(pulses[1].id));

    final beforeCash = s.cash;
    final beforeUsers = s.users;
    final beforeTrain = s.trainingProgress;
    final beforeResearch = s.researchProgress;
    final beforeFresh = s.dataFreshness;

    pulses.first.apply(s);
    final changed = s.cash != beforeCash ||
        s.users != beforeUsers ||
        s.trainingProgress != beforeTrain ||
        s.researchProgress != beforeResearch ||
        s.dataFreshness != beforeFresh;
    expect(changed, isTrue);
  });

  test('بطاقات القرار تظهر كل أسبوعين وتطبق أثرها عند الاختيار', () {
    expect(pickDecisionForWeek(1), isNull);
    final card = pickDecisionForWeek(2);
    expect(card, isNotNull);
    final s = ManagementState();
    final beforeUsers = s.users;
    final beforeRep = s.reputation;
    card!.optionB.apply(s);
    expect(s.users != beforeUsers || s.reputation != beforeRep, isTrue);
  });

  test('الفتح التدريجي يبدأ بالمرحلة 1 ويفتح الكل عند التقدم أو التجاوز', () {
    final early = ProgressionUnlock.fromState(
      ManagementState(week: 1),
      unlockAllOverride: false,
    );
    expect(early.stage, 1);
    expect(early.computeUnlocked, isFalse);
    expect(early.rivalsUnlocked, isFalse);

    final unlocked = ProgressionUnlock.fromState(
      ManagementState(week: 1),
      unlockAllOverride: true,
    );
    expect(unlocked.stage, 4);
    expect(unlocked.computeUnlocked, isTrue);
    expect(unlocked.rivalsUnlocked, isTrue);
    expect(unlocked.teamUnlocked, isTrue);
  });
}
