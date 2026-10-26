import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:ai_empire/management.dart';

void main() {
  test('الأسبوع ينفذ الرواتب والاستدلال وينمو بالمستخدمين', () {
    final s = ManagementState();
    final cashBefore = s.cash;
    final expectedRevenue = s.weeklyRevenue;
    final expectedCost = s.weeklyCost;
    final report = s.advanceWeek(random: Random(7));
    expect(s.week, 2);
    expect(report.revenue, expectedRevenue);
    expect(report.salaries + report.inferenceCost, expectedCost);
    expect(s.cash, cashBefore + expectedRevenue - expectedCost);
    expect(report.cashAfter, s.cash);
    expect(s.users, greaterThan(report.usersBefore));
    expect(report.lines, isNotEmpty);
  });

  test('المدى النقدي يساوي النقد مقسوما على الحرق الأسبوعي', () {
    final s = ManagementState(cash: 10000, users: 10);
    // إيراد 120، تكلفة 3500 + 20 = 3520، صافي -3400.
    expect(s.weeklyNet, -3400);
    expect(s.runwayWeeks, 10000 ~/ 3400);
  });

  test('البحث والتدريب يرفعان مستوى النموذج عند الاكتمال', () {
    final s = ManagementState(researchProgress: 98, trainingProgress: 0);
    s.advanceWeek(random: Random(1));
    // البحث يضيف 6 على الأقل فيتجاوز 100 ويرفع المستوى.
    expect(s.modelLevel, greaterThan(1));
    expect(s.researchProgress, lessThan(100));
  });

  test('حداثة البيانات تتقادم والسمعة والترتيب محسوبان', () {
    final s = ManagementState();
    s.advanceWeek(random: Random(3));
    expect(s.dataFreshness, 78);
    expect(s.rank, greaterThanOrEqualTo(1));
    expect(s.rank, lessThanOrEqualTo(4));
    expect(s.reputation, greaterThanOrEqualTo(0));
    expect(s.reputation, lessThanOrEqualTo(100));
  });

  test('تحركات المنافسين مسجلة ولا تخرج عن قائمة الخياليين', () {
    final s = ManagementState();
    final report = s.advanceWeek(random: Random(42));
    for (final move in report.rivalMoves) {
      expect(
        s.rivals.any((r) => move.contains(r.name)),
        isTrue,
      );
    }
    expect(s.rivals.map((r) => r.name).toSet().length, 3);
  });

  test('الحفظ والاسترجاع يحافظان على حالة الإدارة', () {
    final s = ManagementState(cash: 77777, modelLevel: 3, users: 500);
    final restored = ManagementState.fromJson(s.toJson());
    expect(restored.cash, 77777);
    expect(restored.modelLevel, 3);
    expect(restored.users, 500);
    expect(restored.rivals.length, 3);
  });

  test('الخدمات: بدء وإيقاف وإيراد وتكلفة وحوسبة', () {
    final s = ManagementState();
    expect(s.startService('hosting'), isTrue);
    expect(s.startService('hosting'), isFalse);
    expect(s.servicesRevenue, 900);
    expect(s.servicesCost, 200);
    expect(s.servicesCompute, 30);
    // عميل الاستضافة هو منافس خيالي، لا شركة حقيقية.
    expect(
      s.rivals.any((r) => r.name == s.services.first.clientName),
      isTrue,
    );
    expect(s.stopService('hosting'), isTrue);
    expect(s.services, isEmpty);
  });

  test('تأجير الحوسبة يبطئ التدريب فعلا', () {
    final plain = ManagementState(trainingProgress: 0);
    plain.advanceWeek(random: Random(5));
    final rented = ManagementState(trainingProgress: 0);
    rented.startService('compute_rental');
    rented.advanceWeek(random: Random(5));
    expect(rented.trainingProgress, lessThan(plain.trainingProgress));
  });

  test('استضافة منافس تقوّيه عند تحقق فرصة التقدم', () {
    final s = ManagementState();
    s.startService('hosting');
    final hostedName = s.services.first.clientName;
    final before =
        s.rivals.firstWhere((r) => r.name == hostedName).modelLevel;
    // عشوائية صفرية: كل فرصة تتحقق، فيقوى المنافس المستضاف حتما.
    s.advanceWeek(random: _ZeroRandom());
    final after =
        s.rivals.firstWhere((r) => r.name == hostedName).modelLevel;
    expect(after, greaterThan(before));
  });

  test('الائتمان ينقذ من العجز، ونفاده مع النقد هو الإفلاس', () {
    final saved = ManagementState(cash: 100, users: 0, creditUsed: 0);
    final report = saved.advanceWeek(random: Random(9));
    expect(saved.isBankrupt, isFalse);
    expect(saved.cash, 0);
    expect(report.creditDrawn, greaterThan(0));

    final ruined = ManagementState(
        cash: 100, users: 0, creditUsed: 50000, creditLimit: 50000);
    final bad = ruined.advanceWeek(random: Random(9));
    expect(ruined.isBankrupt, isTrue);
    expect(bad.bankrupt, isTrue);
  });

  test('الحفظ والاسترجاع يحافظان على الخدمات والائتمان', () {
    final s = ManagementState(creditUsed: 4000);
    s.startService('consulting');
    final restored = ManagementState.fromJson(s.toJson());
    expect(restored.creditUsed, 4000);
    expect(restored.services.length, 1);
    expect(restored.services.first.id, 'consulting');
    expect(restored.services.first.bigClient, isTrue);
  });

  test('بدء مشروع بحث يخصم ثمنه ويرفض مشروعا ثانيا أو مكررا', () {
    final s = ManagementState();
    final cashBefore = s.cash;
    expect(s.startResearch('architecture'), isTrue);
    expect(s.cash, cashBefore - 8000);
    expect(s.activeResearch?.id, 'architecture');
    expect(s.startResearch('scaling'), isFalse);
    expect(s.cash, cashBefore - 8000);
  });

  test('بدء مشروع بحث بلا نقد كاف مرفوض', () {
    final s = ManagementState(cash: 100);
    expect(s.startResearch('alignment'), isFalse);
    expect(s.activeResearch, isNull);
  });

  test('مشروع المواءمة يكتمل بعد مدته ويرفع السمعة ولا يتكرر', () {
    final s = ManagementState();
    expect(s.startResearch('alignment'), isTrue);
    WeekReport? last;
    for (var i = 0; i < 4; i++) {
      last = s.advanceWeek(random: Random(11));
    }
    expect(s.activeResearch, isNull);
    expect(s.completedResearch, contains('alignment'));
    expect(last?.researchCompleted, contains('مواءمة'));
    expect(s.startResearch('alignment'), isFalse);
    // السمعة أعلى بعشر نقاط بالضبط من حالة ضابطة بنفس البذرة،
    // لأن تحركات المنافسين قد تخفضها أسبوعيا في الحالتين معا.
    final control = ManagementState();
    for (var i = 0; i < 4; i++) {
      control.advanceWeek(random: Random(11));
    }
    expect(s.reputation, control.reputation + 10);
  });

  test('مشروع المعمارية يسرّع البحث دائما بعد اكتماله', () {
    final s = ManagementState();
    s.startResearch('architecture');
    for (var i = 0; i < 6; i++) {
      s.advanceWeek(random: Random(2));
    }
    expect(s.researchBoost, 2);
    final plain = ManagementState(researchProgress: 0);
    plain.advanceWeek(random: Random(2));
    final boosted = ManagementState(
        researchProgress: 0, researchBoost: 2);
    boosted.advanceWeek(random: Random(2));
    expect(boosted.researchProgress,
        greaterThan(plain.researchProgress));
  });

  test('مشروعا التوسع والوكلاء يقوّيان التدريب ونمو المستخدمين', () {
    final scaled = ManagementState();
    scaled.startResearch('scaling');
    for (var i = 0; i < 5; i++) {
      scaled.advanceWeek(random: Random(4));
    }
    expect(scaled.trainingBoost, 4);

    final agented = ManagementState();
    agented.startResearch('agents');
    for (var i = 0; i < 5; i++) {
      agented.advanceWeek(random: Random(4));
    }
    expect(agented.userGrowthBoost, 5);
  });

  test('الحفظ والاسترجاع يحافظان على مشروع البحث والمكافآت', () {
    final s = ManagementState(researchBoost: 2, trainingBoost: 4);
    s.startResearch('agents');
    s.advanceWeek(random: Random(6));
    final restored = ManagementState.fromJson(s.toJson());
    expect(restored.researchBoost, 2);
    expect(restored.trainingBoost, 4);
    expect(restored.activeResearch?.id, 'agents');
    expect(restored.activeResearch?.weeksDone, 1);
  });

  test('شراء البيانات: ثمن مقدم وكمية وجودة وحداثة بحسب العرض', () {
    final s = ManagementState();
    expect(s.buyData('web'), isTrue);
    expect(s.cash, 150000 - 5000);
    expect(s.dataQuantity, 800 + 500);
    expect(s.dataQuality, 55 - 5);
    expect(s.dataFreshness, 80 + 15);

    final curated = ManagementState();
    expect(curated.buyData('curated'), isTrue);
    expect(curated.dataQuantity, 800 + 150);
    expect(curated.dataQuality, 55 + 10);
    expect(curated.dataFreshness, 80 + 5);

    final poor = ManagementState(cash: 100);
    expect(poor.buyData('specialized'), isFalse);
    expect(poor.cash, 100);
    expect(poor.dataQuantity, 800);
  });

  test('تنظيف البيانات يرفع الجودة ويسقط كمية، وتجديدها يرفع الحداثة فقط', () {
    final s = ManagementState();
    expect(s.cleanData(), isTrue);
    expect(s.cash, 150000 - 3000);
    expect(s.dataQuality, 55 + 15);
    expect(s.dataQuantity, 800 - 50);
    expect(s.refreshData(), isTrue);
    // الحداثة من 80 + 25، مقيدة بالسقف 100.
    expect(s.dataFreshness, 100);
    expect(s.dataQuantity, 750);
    expect(s.dataQuality, 70);

    final full = ManagementState(dataQuality: 100, dataFreshness: 100);
    expect(full.cleanData(), isFalse);
    expect(full.refreshData(), isFalse);
    expect(full.cash, 150000);
  });

  test('جودة بيانات منخفضة تبطئ التدريب، وعالية تسرّعه', () {
    final plain = ManagementState(trainingProgress: 0);
    plain.advanceWeek(random: Random(5));
    final low = ManagementState(trainingProgress: 0, dataQuality: 30);
    low.advanceWeek(random: Random(5));
    expect(low.trainingProgress, lessThan(plain.trainingProgress));
    final high = ManagementState(trainingProgress: 0, dataQuality: 90);
    high.advanceWeek(random: Random(5));
    expect(high.trainingProgress, greaterThan(plain.trainingProgress));
  });

  test('حداثة بيانات منخفضة تبطئ البحث فعلا', () {
    final plain = ManagementState(researchProgress: 0);
    plain.advanceWeek(random: Random(5));
    final stale = ManagementState(researchProgress: 0, dataFreshness: 20);
    stale.advanceWeek(random: Random(5));
    expect(stale.researchProgress, lessThan(plain.researchProgress));
  });

  test('الحفظ والاسترجاع يحافظان على حالة البيانات بعد الشراء والتنظيف', () {
    final s = ManagementState();
    s.buyData('specialized');
    s.cleanData();
    final restored = ManagementState.fromJson(s.toJson());
    expect(restored.dataQuantity, s.dataQuantity);
    expect(restored.dataQuality, s.dataQuality);
    expect(restored.dataFreshness, s.dataFreshness);
    expect(restored.cash, s.cash);
  });

  test('شراء الحوسبة يزيد المتاح بثمن، ويرفض فوق السقف وبلا نقد', () {
    final s = ManagementState();
    expect(s.buyCompute(), isTrue);
    expect(s.computeAvailable, 125);
    expect(s.cash, 150000 - 4000);
    final capped = ManagementState(computeAvailable: 200);
    expect(capped.buyCompute(), isFalse);
    expect(capped.cash, 150000);
    final poor = ManagementState(cash: 3000);
    expect(poor.buyCompute(), isFalse);
    expect(poor.computeAvailable, 100);
  });

  test('حجز الحوسبة ينقل من المتاح إلى المحجوز ويرفض الزائد والصفر', () {
    final s = ManagementState();
    expect(s.reserveCompute(20), isTrue);
    expect(s.computeAvailable, 80);
    expect(s.computeReserved, 40);
    expect(s.reserveCompute(200), isFalse);
    expect(s.reserveCompute(0), isFalse);
    expect(s.reserveCompute(-5), isFalse);
    expect(s.computeAvailable, 80);
    expect(s.computeReserved, 40);
  });

  test('المحجوز 20 فأكثر يسرّع التدريب، والحجز الثقيل 60 يبطئه بالإجهاد', () {
    final reserved = ManagementState(trainingProgress: 0);
    reserved.advanceWeek(random: Random(5));
    expect(reserved.trainingProgress, 12);
    final none = ManagementState(trainingProgress: 0, computeReserved: 0);
    none.advanceWeek(random: Random(5));
    expect(none.trainingProgress, 4);
    final heavy = ManagementState(trainingProgress: 0, computeReserved: 60);
    final report = heavy.advanceWeek(random: Random(5));
    expect(heavy.trainingProgress, 8);
    expect(
        report.lines.any((l) => l.contains('أجهد الموثوقية')), isTrue);
  });

  test('الحفظ والاسترجاع يحافظان على الحوسبة بعد الشراء والحجز', () {
    final s = ManagementState();
    s.buyCompute();
    s.reserveCompute(20);
    final restored = ManagementState.fromJson(s.toJson());
    expect(restored.computeAvailable, s.computeAvailable);
    expect(restored.computeReserved, s.computeReserved);
    expect(restored.cash, s.cash);
  });

  test('بدء وظيفة نموذج يخصم ثمنها ويرفض وظيفة ثانية أو بلا نقد', () {
    final s = ManagementState();
    expect(s.startModelJob('distillation'), isTrue);
    expect(s.cash, 150000 - 6000);
    expect(s.activeModelJob?.id, 'distillation');
    expect(s.startModelJob('new_generation'), isFalse);
    expect(s.cash, 150000 - 6000);
    final poor = ManagementState(cash: 5000);
    expect(poor.startModelJob('distillation'), isFalse);
    expect(poor.activeModelJob, isNull);
    expect(poor.cash, 5000);
  });

  test('التقطير يكتمل بعد مدته ويخفض تكلفة الاستدلال دون رفع المستوى', () {
    final s = ManagementState();
    final control = ManagementState();
    expect(s.startModelJob('distillation'), isTrue);
    for (var i = 0; i < 3; i++) {
      s.advanceWeek(random: _ZeroRandom());
      control.advanceWeek(random: _ZeroRandom());
    }
    expect(s.activeModelJob, isNull);
    expect(s.completedModels, contains('distillation'));
    expect(s.inferenceSaving, 1);
    expect(s.inferencePerUser, 1);
    expect(control.inferencePerUser, 2);
    expect(s.modelLevel, control.modelLevel);
    expect(s.startModelJob('distillation'), isFalse);
  });

  test('الجيل الجديد يكتمل بعد مدته ويرفع المستوى ويصفّر التدريب', () {
    final s = ManagementState(trainingProgress: 80);
    final control = ManagementState(trainingProgress: 80);
    expect(s.startModelJob('new_generation'), isTrue);
    WeekReport? last;
    for (var i = 0; i < 6; i++) {
      last = s.advanceWeek(random: _ZeroRandom());
      control.advanceWeek(random: _ZeroRandom());
    }
    expect(s.activeModelJob, isNull);
    expect(s.completedModels, contains('new_generation'));
    expect(s.modelLevel, control.modelLevel + 1);
    expect(s.trainingProgress, 0);
    expect(control.trainingProgress, 12);
    expect(last!.modelCompleted.contains('جيل جديد'), isTrue);
  });

  test('الاسترجاع يكتمل بعد مدته ويرفع السمعة ونمو المستخدمين مقابل حالة ضابطة', () {
    final s = ManagementState();
    final control = ManagementState();
    expect(s.startModelJob('retrieval'), isTrue);
    for (var i = 0; i < 4; i++) {
      s.advanceWeek(random: _ZeroRandom());
      control.advanceWeek(random: _ZeroRandom());
    }
    expect(s.activeModelJob, isNull);
    expect(s.completedModels, contains('retrieval'));
    expect(s.userGrowthBoost, 3);
    expect(s.reputation, control.reputation + 8);
    expect(s.modelLevel, control.modelLevel);
  });

  test('الحفظ والاسترجاع يحافظان على وظيفة النموذج والتقطير وتوافق مع حالة قديمة', () {
    final s = ManagementState();
    s.startModelJob('retrieval');
    final restored = ManagementState.fromJson(s.toJson());
    expect(restored.activeModelJob?.id, 'retrieval');
    expect(restored.cash, s.cash);
    final d = ManagementState();
    d.startModelJob('distillation');
    for (var i = 0; i < 3; i++) {
      d.advanceWeek(random: _ZeroRandom());
    }
    final restoredDone = ManagementState.fromJson(d.toJson());
    expect(restoredDone.completedModels, contains('distillation'));
    expect(restoredDone.inferenceSaving, 1);
    expect(restoredDone.inferencePerUser, 1);
    final oldJson = d.toJson()
      ..remove('activeModelJob')
      ..remove('completedModels')
      ..remove('inferenceSaving');
    final restoredOld = ManagementState.fromJson(oldJson);
    expect(restoredOld.activeModelJob, isNull);
    expect(restoredOld.completedModels, isEmpty);
    expect(restoredOld.inferenceSaving, 0);
  });
  test('إطلاق المنتج يخصم ثمنه ويرفض المكرر وبلا نقد', () {
    final s = ManagementState();
    expect(s.launchProduct('chatbot'), isTrue);
    expect(s.cash, 150000 - 9000);
    expect(s.launchedProducts, contains('chatbot'));
    expect(s.launchProduct('chatbot'), isFalse);
    expect(s.cash, 150000 - 9000);
    final poor = ManagementState(cash: 1000);
    expect(poor.launchProduct('api'), isFalse);
    expect(poor.cash, 1000);
    expect(poor.launchedProducts, isEmpty);
  });

  test('المنتج يدر إيراده ويكلف صيانته وينمو بالمستخدمين أسبوعا واحدا', () {
    final s = ManagementState();
    final control = ManagementState();
    expect(s.launchProduct('coding'), isTrue);
    final report = s.advanceWeek(random: _ZeroRandom());
    control.advanceWeek(random: _ZeroRandom());
    expect(s.productsRevenue, 800);
    expect(s.productsCost, 400);
    expect(s.productsGrowth, 5);
    expect(report.productRevenue, 800);
    expect(report.productCost, 400);
    expect(s.users, control.users + 5);
    expect(s.cash, control.cash - 13000 + 400);
    expect(report.lines.any((l) => l.contains('المنتجات:')), isTrue);
  });

  test('الواجهة أعلى صافي أسبوعي ومساعد البرمجة أعلى نمو ولا منتج مهيمن', () {
    final apiDef = ManagementState.productCatalog
        .firstWhere((d) => d.id == 'api');
    final codingDef = ManagementState.productCatalog
        .firstWhere((d) => d.id == 'coding');
    final chatDef = ManagementState.productCatalog
        .firstWhere((d) => d.id == 'chatbot');
    expect(apiDef.revenue - apiDef.maintenance, 600);
    expect(chatDef.revenue - chatDef.maintenance, 400);
    expect(codingDef.revenue - codingDef.maintenance, 400);
    expect(codingDef.growth, 5);
    expect(apiDef.growth, 2);
    expect(chatDef.cost, 9000);
    expect(codingDef.cost, 13000);
    final s = ManagementState();
    expect(s.launchProduct('api'), isTrue);
    expect(s.launchProduct('coding'), isTrue);
    expect(s.productsRevenue, 1700);
    expect(s.productsCost, 700);
    expect(s.productsGrowth, 7);
  });

  test('الحفظ والاسترجاع يحافظان على المنتجات وتوافق مع حالة قديمة', () {
    final s = ManagementState();
    s.launchProduct('chatbot');
    final restored = ManagementState.fromJson(s.toJson());
    expect(restored.launchedProducts, contains('chatbot'));
    expect(restored.productsRevenue, 600);
    expect(restored.productsCost, 200);
    expect(restored.cash, s.cash);
    final oldJson = s.toJson()..remove('launchedProducts');
    final restoredOld = ManagementState.fromJson(oldJson);
    expect(restoredOld.launchedProducts, isEmpty);
    expect(restoredOld.productsRevenue, 0);
  });

}

/// عشوائية حتمية للاختبارات: كل فرصة تتحقق، وكل عدد عشوائي صفر.
class _ZeroRandom implements Random {
  @override
  double nextDouble() => 0;

  @override
  int nextInt(int max) => 0;

  @override
  bool nextBool() => false;
}
