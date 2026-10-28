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

  test('الاقتراض الصريح يضيف نقدا ويستخدم ائتمانا ويرفض فوق المتبقي',
      () {
    final s = ManagementState();
    expect(s.takeLoan(), isTrue);
    expect(s.cash, 160000);
    expect(s.creditUsed, 10000);
    expect(s.creditInterest, 200);
    s.creditUsed = 45000;
    expect(s.takeLoan(), isFalse);
    expect(s.cash, 160000);
    expect(s.creditUsed, 45000);
  });

  test('السداد الصريح يخفض المستخدم والفائدة ويرفض المخالف', () {
    final s = ManagementState();
    s.takeLoan();
    expect(s.repayCredit(5000), isTrue);
    expect(s.cash, 155000);
    expect(s.creditUsed, 5000);
    expect(s.creditInterest, 100);
    expect(s.repayCredit(0), isFalse);
    expect(s.repayCredit(-100), isFalse);
    expect(s.repayCredit(6000), isFalse);
    expect(s.cash, 155000);
    expect(s.creditUsed, 5000);
    final poor = ManagementState()..cash = 1000;
    poor.creditUsed = 5000;
    expect(poor.repayCredit(5000), isFalse);
    expect(poor.cash, 1000);
    expect(poor.creditUsed, 5000);
  });

  test('السداد يخفض فائدة الأسبوع التالي مقابل حالة ضابطة', () {
    final paid = ManagementState();
    paid.takeLoan();
    paid.repayCredit(5000);
    final unpaid = ManagementState();
    unpaid.takeLoan();
    final paidReport = paid.advanceWeek(random: _ZeroRandom());
    final unpaidReport = unpaid.advanceWeek(random: _ZeroRandom());
    expect(paidReport.creditInterest, 100);
    expect(unpaidReport.creditInterest, 200);
    expect(paidReport.creditInterest, lessThan(unpaidReport.creditInterest));
  });

  test('الحفظ والاسترجاع يحافظان على الائتمان بعد اقتراض وسداد', () {
    final s = ManagementState();
    s.takeLoan();
    s.repayCredit(5000);
    final restored = ManagementState.fromJson(s.toJson());
    expect(restored.creditUsed, 5000);
    expect(restored.cash, s.cash);
    expect(restored.creditRemaining, 45000);
  });

  test('استقطاب خبير يخفض المنافس ويرفع تسريع التدريب بثمن مقدم', () {
    final s = ManagementState();
    expect(s.rivals[1].name, 'نورال للأنظمة');
    expect(s.rivals[1].strategy, 'جودة');
    expect(s.poachRival('نورال للأنظمة'), isTrue);
    expect(s.cash, 141000);
    expect(s.rivals[1].modelLevel, 1);
    expect(s.trainingBoost, 2);
    expect(s.poachedRivals, ['نورال للأنظمة']);
  });

  test('الاستقطاب يرفض المستوى 1 والمكرر وبلا نقد وبلا خصم', () {
    final s = ManagementState();
    expect(s.poachRival('مدار للذكاء'), isFalse);
    expect(s.poachRival('نورال للأنظمة'), isTrue);
    expect(s.poachRival('نورال للأنظمة'), isFalse);
    expect(s.cash, 141000);
    expect(s.rivals[1].modelLevel, 1);
    final poor = ManagementState()..cash = 8000;
    expect(poor.poachRival('نورال للأنظمة'), isFalse);
    expect(poor.cash, 8000);
    expect(poor.rivals[1].modelLevel, 2);
    expect(s.poachRival('منافس غير موجود'), isFalse);
  });

  test('الاستقطاب يسرّع التدريب في الأسبوع التالي مقابل حالة ضابطة', () {
    final poached = ManagementState();
    poached.poachRival('نورال للأنظمة');
    final control = ManagementState();
    final poachedReport =
        poached.advanceWeek(random: _ZeroRandom());
    final controlReport =
        control.advanceWeek(random: _ZeroRandom());
    expect(poachedReport.trainingAfter,
        greaterThan(controlReport.trainingAfter));
  });

  test('الحفظ والاسترجاع يحافظان على الاستقطاب وتوافق مع حالة قديمة', () {
    final s = ManagementState();
    s.poachRival('نورال للأنظمة');
    final restored = ManagementState.fromJson(s.toJson());
    expect(restored.poachedRivals, ['نورال للأنظمة']);
    expect(restored.rivals[1].modelLevel, 1);
    expect(restored.trainingBoost, 2);
    expect(restored.rivals[1].strategy, 'جودة');
    final old = ManagementState.fromJson({
      'cash': 150000,
      'rivals': [
        {'name': 'مدار للذكاء', 'modelLevel': 1},
        {'name': 'نورال للأنظمة', 'modelLevel': 2},
      ],
    });
    expect(old.poachedRivals, isEmpty);
    expect(old.rivals[1].strategy, 'سرعة');
  });

  test('تعيين باحث يخصم ثمنه ويرفع تسريع البحث ويرفض المكرر وبلا نقد', () {
    final s = ManagementState();
    expect(s.hireStaff('research_lead'), isTrue);
    expect(s.cash, 150000 - 7000);
    expect(s.researchBoost, 2);
    expect(s.staffSalaries, 800);
    expect(s.hireStaff('research_lead'), isFalse);
    expect(s.cash, 150000 - 7000);
    final poor = ManagementState()..cash = 1000;
    expect(poor.hireStaff('research_lead'), isFalse);
    expect(poor.cash, 1000);
    expect(poor.hiredStaff, isEmpty);
  });

  test('تعيين مهندس بنية يضيف حوسبة ومدير منتجات يرفع نمو المستخدمين', () {
    final s = ManagementState();
    expect(s.hireStaff('infra_engineer'), isTrue);
    expect(s.computeAvailable, 125);
    expect(s.hireStaff('product_manager'), isTrue);
    expect(s.userGrowthBoost, 2);
    expect(s.staffSalaries, 700 + 600);
    expect(s.cash, 150000 - 6000 - 5000);
  });

  test('راتب الفريق يُخصم في الأسبوع التالي مقابل حالة ضابطة', () {
    final hired = ManagementState()..hireStaff('research_lead');
    hired.cash = 150000; // معادلة الثمن المقدم لعزل أثر الراتب وحده.
    final control = ManagementState();
    final hiredReport = hired.advanceWeek(random: _ZeroRandom());
    final controlReport = control.advanceWeek(random: _ZeroRandom());
    expect(hiredReport.cashAfter, controlReport.cashAfter - 800);
    expect(hiredReport.researchAfter, controlReport.researchAfter + 2);
    expect(hiredReport.lines.any((l) => l.contains('رواتب فريقك المتخصص: 800')), isTrue);
  });

  test('الحفظ والاسترجاع يحافظان على الفريق وتوافق مع حالة قديمة', () {
    final s = ManagementState()
      ..hireStaff('research_lead')
      ..hireStaff('infra_engineer');
    final restored = ManagementState.fromJson(s.toJson());
    expect(restored.hiredStaff, ['research_lead', 'infra_engineer']);
    expect(restored.researchBoost, 2);
    expect(restored.computeAvailable, 125);
    expect(restored.staffSalaries, 1500);
    final old = ManagementState.fromJson({'cash': 150000});
    expect(old.hiredStaff, isEmpty);
    expect(old.staffSalaries, 0);
    expect(old.hireStaff('product_manager'), isTrue);
  });

  test('شراء عقد صيانة يخصم ثمنه ويرفض التكديس وبلا نقد', () {
    final s = ManagementState();
    expect(s.buyMaintenance(), isTrue);
    expect(s.cash, 150000 - 5000);
    expect(s.maintenanceWeeks, 4);
    expect(s.buyMaintenance(), isFalse);
    expect(s.cash, 150000 - 5000);
    final poor = ManagementState()..cash = 4000;
    expect(poor.buyMaintenance(), isFalse);
    expect(poor.cash, 4000);
    expect(poor.maintenanceWeeks, 0);
  });

  test('عقد الصيانة يلغي إجهاد الحجز الثقيل مقابل حالة ضابطة', () {
    final withContract =
        ManagementState(trainingProgress: 0, computeReserved: 60)
          ..buyMaintenance();
    final report = withContract.advanceWeek(random: Random(5));
    expect(withContract.trainingProgress, 12);
    expect(withContract.maintenanceWeeks, 3);
    expect(
        report.lines
            .any((l) => l.contains('عقد الصيانة والتبريد امتص')),
        isTrue);
    final control = ManagementState(trainingProgress: 0, computeReserved: 60);
    control.advanceWeek(random: Random(5));
    expect(control.trainingProgress, 8);
  });

  test('انتهاء العقد بعد أربعة أسابيع يعود بالإجهاد', () {
    final s = ManagementState(trainingProgress: 0)..buyMaintenance();
    for (var i = 0; i < 4; i++) {
      s.advanceWeek(random: Random(5));
    }
    expect(s.maintenanceWeeks, 0);
    final before = s.trainingProgress;
    s.computeReserved = 60;
    final report = s.advanceWeek(random: Random(5));
    expect(s.trainingProgress, before + 8);
    expect(report.lines.any((l) => l.contains('أجهد الموثوقية')), isTrue);
  });

  test('الحفظ والاسترجاع يحافظان على عقد الصيانة وتوافق مع حالة قديمة',
      () {
    final s = ManagementState()..buyMaintenance();
    final restored = ManagementState.fromJson(s.toJson());
    expect(restored.maintenanceWeeks, 4);
    expect(restored.cash, 150000 - 5000);
    final old = ManagementState.fromJson({'cash': 150000});
    expect(old.maintenanceWeeks, 0);
    expect(old.buyMaintenance(), isTrue);
  });

  test('مكتبة المفاهيم تغطي كل الأنظمة بشرح غير فارغ وبلا تكرار', () {
    final titles = managementConcepts.map((c) => c.title).toList();
    expect(titles, containsAll([
      'البحث',
      'البيانات',
      'الحوسبة',
      'النماذج',
      'المنتجات',
      'الخدمات',
      'المنافسون',
      'الفريق',
      'المالية',
      'البقاء أولا',
    ]));
    expect(titles.toSet().length, titles.length);
    for (final concept in managementConcepts) {
      expect(concept.body.length, greaterThan(40));
    }
    final survival = managementConcepts.last;
    expect(survival.title, 'البقاء أولا');
    expect(survival.body.contains('الإفلاس'), isTrue);
  });

  test('التسعير المميز يرفع إيراد المنتجات 30% ويخفض نموها نقطتين', () {
    final s = ManagementState();
    expect(s.launchProduct('chatbot'), isTrue);
    expect(s.effectiveProductsRevenue, 600);
    expect(s.effectiveProductsGrowth, 3);
    s.setPremiumPricing(true);
    expect(s.effectiveProductsRevenue, 780);
    expect(s.effectiveProductsGrowth, 1);
    s.setPremiumPricing(false);
    expect(s.effectiveProductsRevenue, 600);
    expect(s.effectiveProductsGrowth, 3);
  });

  test('التسعير المميز أسبوعا واحدا: إيراد أعلى ونمو أبطأ بنقطتين', () {
    final s = ManagementState();
    final control = ManagementState();
    expect(s.launchProduct('chatbot'), isTrue);
    expect(control.launchProduct('chatbot'), isTrue);
    s.setPremiumPricing(true);
    final report = s.advanceWeek(random: _ZeroRandom());
    final controlReport = control.advanceWeek(random: _ZeroRandom());
    expect(report.productRevenue, 780);
    expect(controlReport.productRevenue, 600);
    expect(report.usersAfter, controlReport.usersAfter - 2);
    expect(report.cashAfter, controlReport.cashAfter + 180);
    expect(report.lines.join(' ').contains('التسعير المميز'), isTrue);
  });

  test('حفظ واسترجاع التسعير المميز', () {
    final s = ManagementState();
    expect(s.launchProduct('chatbot'), isTrue);
    s.setPremiumPricing(true);
    final restored = ManagementState.fromJson(s.toJson());
    expect(restored.premiumPricing, isTrue);
    expect(restored.effectiveProductsRevenue, 780);
    expect(restored.effectiveProductsGrowth, 1);
  });

  test('توافق مع حالة قديمة بلا حقل التسعير المميز', () {
    final s = ManagementState();
    expect(s.launchProduct('chatbot'), isTrue);
    final oldJson = s.toJson()..remove('premiumPricing');
    final restoredOld = ManagementState.fromJson(oldJson);
    expect(restoredOld.premiumPricing, isFalse);
    expect(restoredOld.effectiveProductsRevenue, 600);
  });

  test('لا حدث عالمي في الأسابيع السبعة الأولى', () {
    final s = ManagementState();
    WeekReport? last;
    for (var i = 0; i < 7; i++) {
      last = s.advanceWeek(random: _ZeroRandom());
    }
    expect(s.lastWorldEvent, '');
    expect(last?.worldEvent, '');
    expect(s.week, 8);
  });

  test('الأسبوع الثامن يطلق أزمة إمداد رقائق وتنقص الحوسبة 20', () {
    final s = ManagementState();
    WeekReport? last;
    for (var i = 0; i < 8; i++) {
      last = s.advanceWeek(random: _ZeroRandom());
    }
    expect(last?.worldEvent, 'أزمة إمداد رقائق');
    expect(s.lastWorldEvent, 'أزمة إمداد رقائق');
    expect(
        last?.lines.any((l) => l.contains('حدث عالمي')), isTrue);
    // الحوسبة: 100 + 8 تجديدات × 10، ناقص 20 من الأزمة.
    expect(s.computeAvailable, 160);
  });

  test('الدورة تدور: طفرة وكلاء في 16 وتشديد في 24 ثم أزمة من جديد في 32', () {
    final s = ManagementState();
    for (var i = 0; i < 15; i++) {
      s.advanceWeek(random: _ZeroRandom());
    }
    final usersBefore = s.users;
    final levelBefore = s.modelLevel;
    final repBefore = s.reputation;
    final boostBefore =
        s.userGrowthBoost + s.effectiveProductsGrowth;
    final surgeReport = s.advanceWeek(random: _ZeroRandom());
    expect(surgeReport.worldEvent, 'طفرة طلب على الوكلاء');
    expect(s.lastWorldEvent, 'طفرة طلب على الوكلاء');
    var expectedDelta =
        4 + levelBefore * 2 + repBefore ~/ 25 + boostBefore + 10;
    if (repBefore < 30) expectedDelta -= 6;
    expect(s.users, usersBefore + expectedDelta);
    for (var i = 0; i < 8; i++) {
      s.advanceWeek(random: _ZeroRandom());
    }
    expect(s.lastWorldEvent, 'تشديد تنظيمي مؤقت');
    for (var i = 0; i < 8; i++) {
      s.advanceWeek(random: _ZeroRandom());
    }
    expect(s.lastWorldEvent, 'أزمة إمداد رقائق');
  });

  test('حفظ واسترجاع آخر حدث عالمي وتوافق مع حالة قديمة', () {
    final s = ManagementState();
    for (var i = 0; i < 8; i++) {
      s.advanceWeek(random: _ZeroRandom());
    }
    final restored = ManagementState.fromJson(s.toJson());
    expect(restored.lastWorldEvent, 'أزمة إمداد رقائق');
    final oldJson = s.toJson()..remove('lastWorldEvent');
    final restoredOld = ManagementState.fromJson(oldJson);
    expect(restoredOld.lastWorldEvent, '');
  });

  test('خدمة دعم النماذج المفتوحة: بدء ورفض مكرر وأثمانها', () {
    final s = ManagementState();
    expect(s.startService('open_model_support'), isTrue);
    expect(s.startService('open_model_support'), isFalse);
    expect(s.services.length, 1);
    expect(s.servicesRevenue, 1000);
    expect(s.servicesCost, 350);
    expect(s.servicesCompute, 20);
    expect(s.teamServiceCount, 1);
    expect(s.stopService('open_model_support'), isTrue);
    expect(s.services, isEmpty);
    expect(s.stopService('open_model_support'), isFalse);
  });

  test('خدمة النماذج المفتوحة تبطئ البحث وتأكل الحوسبة أسبوعيا', () {
    final control = ManagementState();
    final open = ManagementState();
    open.startService('open_model_support');
    final controlReport =
        control.advanceWeek(random: _NeverRandom());
    final openReport = open.advanceWeek(random: _NeverRandom());
    expect(openReport.servicesRevenue, 1000);
    expect(openReport.servicesCost, 350);
    expect(open.researchProgress, control.researchProgress - 3);
    expect(open.computeAvailable, 90);
    expect(control.computeAvailable, 110);
    expect(open.services.length, 1);
    expect(controlReport.servicesRevenue, 0);
  });

  test('حفظ واسترجاع خدمة النماذج المفتوحة', () {
    final s = ManagementState();
    s.startService('open_model_support');
    final restored = ManagementState.fromJson(s.toJson());
    expect(restored.services.length, 1);
    expect(restored.services.first.id, 'open_model_support');
    expect(restored.servicesRevenue, 1000);
    expect(restored.servicesCompute, 20);
    expect(restored.teamServiceCount, 1);
  });

  test('تعيين خبير بيانات يخصم ثمنه ويرفع الجودة ويرفض المكرر وبلا نقد', () {
    final s = ManagementState();
    expect(s.hireStaff('data_lead'), isTrue);
    expect(s.cash, 150000 - 6500);
    expect(s.dataQuality, 70);
    expect(s.staffSalaries, 750);
    expect(s.hireStaff('data_lead'), isFalse);
    expect(s.cash, 150000 - 6500);
    expect(s.dataQuality, 70);
    final poor = ManagementState()..cash = 1000;
    expect(poor.hireStaff('data_lead'), isFalse);
    expect(poor.cash, 1000);
    expect(poor.dataQuality, 55);
  });

  test('خبير البيانات لا يرفع الجودة فوق 100', () {
    final s = ManagementState()..dataQuality = 95;
    expect(s.hireStaff('data_lead'), isTrue);
    expect(s.dataQuality, 100);
  });

  test('خبير البيانات يسرّع التدريب عند عبور عتبة الجودة 80 مقابل ضابطة', () {
    final hired = ManagementState()..dataQuality = 70;
    expect(hired.hireStaff('data_lead'), isTrue);
    expect(hired.dataQuality, 85);
    final control = ManagementState()..dataQuality = 70;
    final hiredReport = hired.advanceWeek(random: _ZeroRandom());
    final controlReport = control.advanceWeek(random: _ZeroRandom());
    expect(hiredReport.trainingAfter, controlReport.trainingAfter + 2);
  });

  test('الحفظ والاسترجاع يحافظان على خبير البيانات وتوافق مع حالة قديمة', () {
    final s = ManagementState()..hireStaff('data_lead');
    final restored = ManagementState.fromJson(s.toJson());
    expect(restored.hiredStaff, ['data_lead']);
    expect(restored.dataQuality, 70);
    expect(restored.staffSalaries, 750);
    final old = ManagementState.fromJson({'cash': 150000});
    expect(old.hireStaff('data_lead'), isTrue);
    expect(old.dataQuality, 70);
  });

  test('منصة الوكلاء تطلق بثمنها وتدر إيرادها وتكلف صيانتها أسبوعا', () {
    final s = ManagementState();
    final control = ManagementState();
    expect(s.launchProduct('agents'), isTrue);
    expect(s.cash, 150000 - 15000);
    expect(s.launchProduct('agents'), isFalse);
    expect(s.cash, 150000 - 15000);
    final poor = ManagementState(cash: 1000);
    expect(poor.launchProduct('agents'), isFalse);
    expect(poor.cash, 1000);
    final report = s.advanceWeek(random: _ZeroRandom());
    control.advanceWeek(random: _ZeroRandom());
    expect(s.productsRevenue, 1000);
    expect(s.productsCost, 450);
    expect(s.productsGrowth, 4);
    expect(report.productRevenue, 1000);
    expect(report.productCost, 450);
    expect(s.users, control.users + 4);
    expect(s.cash, control.cash - 15000 + 550);
    expect(report.lines.any((l) => l.contains('المنتجات:')), isTrue);
  });

  test('منصة الوكلاء في الوسط: لا أعلى صافي ولا أعلى نمو ولا أرخص ثمن', () {
    final agentsDef = ManagementState.productCatalog
        .firstWhere((d) => d.id == 'agents');
    final apiDef = ManagementState.productCatalog
        .firstWhere((d) => d.id == 'api');
    final codingDef = ManagementState.productCatalog
        .firstWhere((d) => d.id == 'coding');
    expect(agentsDef.cost, 15000);
    expect(agentsDef.revenue - agentsDef.maintenance, 550);
    expect(apiDef.revenue - apiDef.maintenance, 600);
    expect(codingDef.growth, 5);
    expect(agentsDef.growth, 4);
    expect(agentsDef.cost, greaterThan(codingDef.cost));
  });

  test('الحفظ والاسترجاع يحافظان على منصة الوكلاء', () {
    final s = ManagementState();
    s.launchProduct('agents');
    final restored = ManagementState.fromJson(s.toJson());
    expect(restored.launchedProducts, contains('agents'));
    expect(restored.productsRevenue, 1000);
    expect(restored.productsCost, 450);
    expect(restored.cash, s.cash);
  });

  test('تحليل الوثائق يطلق بثمنه ويدر إيراده ويكلف صيانته أسبوعا', () {
    final s = ManagementState();
    final control = ManagementState();
    expect(s.launchProduct('docs'), isTrue);
    expect(s.cash, 150000 - 12000);
    expect(s.launchProduct('docs'), isFalse);
    expect(s.cash, 150000 - 12000);
    final poor = ManagementState(cash: 1000);
    expect(poor.launchProduct('docs'), isFalse);
    expect(poor.cash, 1000);
    final report = s.advanceWeek(random: _ZeroRandom());
    control.advanceWeek(random: _ZeroRandom());
    expect(s.productsRevenue, 850);
    expect(s.productsCost, 400);
    expect(s.productsGrowth, 3);
    expect(report.productRevenue, 850);
    expect(report.productCost, 400);
    expect(s.users, control.users + 3);
    expect(s.cash, control.cash - 12000 + 450);
    expect(report.lines.any((l) => l.contains('المنتجات:')), isTrue);
  });

  test('تحليل الوثائق في الوسط: لا أعلى صافي ولا أعلى نمو ولا أرخص ثمن', () {
    final docsDef = ManagementState.productCatalog
        .firstWhere((d) => d.id == 'docs');
    final apiDef = ManagementState.productCatalog
        .firstWhere((d) => d.id == 'api');
    final codingDef = ManagementState.productCatalog
        .firstWhere((d) => d.id == 'coding');
    expect(docsDef.cost, 12000);
    expect(docsDef.revenue - docsDef.maintenance, 450);
    expect(apiDef.revenue - apiDef.maintenance, 600);
    expect(codingDef.growth, 5);
    expect(docsDef.growth, 3);
    expect(docsDef.cost, greaterThan(apiDef.cost));
    expect(docsDef.cost, lessThan(codingDef.cost));
  });

  test('الحفظ والاسترجاع يحافظان على تحليل الوثائق', () {
    final s = ManagementState();
    s.launchProduct('docs');
    final restored = ManagementState.fromJson(s.toJson());
    expect(restored.launchedProducts, contains('docs'));
    expect(restored.productsRevenue, 850);
    expect(restored.productsCost, 400);
    expect(restored.cash, s.cash);
  });

  test('تعيين خبير مواءمة يخصم ثمنه ويرفع السمعة ويرفض المكرر وبلا نقد', () {
    final s = ManagementState();
    expect(s.hireStaff('safety_lead'), isTrue);
    expect(s.cash, 150000 - 8000);
    expect(s.reputation, 60);
    expect(s.staffSalaries, 900);
    expect(s.hireStaff('safety_lead'), isFalse);
    expect(s.cash, 150000 - 8000);
    expect(s.reputation, 60);
    final poor = ManagementState()..cash = 1000;
    expect(poor.hireStaff('safety_lead'), isFalse);
    expect(poor.cash, 1000);
    expect(poor.reputation, 50);
  });

  test('خبير المواءمة لا يرفع السمعة فوق 100 وراتبه يُخصم في الأسبوع التالي', () {
    final s = ManagementState()..reputation = 95;
    expect(s.hireStaff('safety_lead'), isTrue);
    expect(s.reputation, 100);
    final hired = ManagementState()..hireStaff('safety_lead');
    final control = ManagementState();
    final hiredReport = hired.advanceWeek(random: _ZeroRandom());
    final controlReport = control.advanceWeek(random: _ZeroRandom());
    expect(hiredReport.cashAfter, controlReport.cashAfter - 8000 - 900);
  });

  test('الحفظ والاسترجاع يحافظان على خبير المواءمة وتوافق مع حالة قديمة', () {
    final s = ManagementState()..hireStaff('safety_lead');
    final restored = ManagementState.fromJson(s.toJson());
    expect(restored.hiredStaff, ['safety_lead']);
    expect(restored.reputation, 60);
    expect(restored.staffSalaries, 900);
    final old = ManagementState.fromJson({'cash': 150000});
    expect(old.hireStaff('safety_lead'), isTrue);
    expect(old.reputation, 60);
  });

  test('الصدارة أربعة أسابيع متتالية تحقق فوزا إداريا، لا أسبوع واحد', () {
    final s = ManagementState(
      modelLevel: 5,
      rivals: [
        Rival(name: 'مدار للذكاء', modelLevel: 1, strategy: 'سرعة'),
        Rival(name: 'نورال للأنظمة', modelLevel: 1, strategy: 'جودة'),
        Rival(name: 'قمة الحوسبة', modelLevel: 1, strategy: 'سعر'),
      ],
    );
    for (var i = 0; i < 3; i++) {
      final report = s.advanceWeek(random: _NeverRandom());
      expect(s.rank, 1);
      expect(s.leadershipWeeks, i + 1);
      expect(s.leadershipVictory, isFalse);
      expect(report.lines.any((l) => l.contains('في الصدارة')), isTrue);
    }
    final fourth = s.advanceWeek(random: _NeverRandom());
    expect(s.leadershipWeeks, 4);
    expect(s.leadershipVictory, isTrue);
    expect(
        fourth.lines.any((l) => l.contains('أربعة أسابيع متتالية')), isTrue);
  });

  test('التراجع عن الصدارة يصفّر سلسلتها لكنه لا يلغي فوزا تحقق', () {
    final s = ManagementState(
      modelLevel: 5,
      rivals: [
        Rival(name: 'مدار للذكاء', modelLevel: 1, strategy: 'سرعة'),
        Rival(name: 'نورال للأنظمة', modelLevel: 1, strategy: 'جودة'),
        Rival(name: 'قمة الحوسبة', modelLevel: 1, strategy: 'سعر'),
      ],
    );
    for (var i = 0; i < 4; i++) {
      s.advanceWeek(random: _NeverRandom());
    }
    expect(s.leadershipVictory, isTrue);
    s.rivals.first.modelLevel = 99;
    s.advanceWeek(random: _NeverRandom());
    expect(s.rank, greaterThan(1));
    expect(s.leadershipWeeks, 0);
    expect(s.leadershipVictory, isTrue);
  });

  test('الحفظ والاسترجاع يحافظان على سلسلة الصدارة والفوز وتوافق مع حالة قديمة', () {
    final s = ManagementState(
      modelLevel: 5,
      rivals: [
        Rival(name: 'مدار للذكاء', modelLevel: 1, strategy: 'سرعة'),
        Rival(name: 'نورال للأنظمة', modelLevel: 1, strategy: 'جودة'),
        Rival(name: 'قمة الحوسبة', modelLevel: 1, strategy: 'سعر'),
      ],
    );
    s.advanceWeek(random: _NeverRandom());
    final restored = ManagementState.fromJson(s.toJson());
    expect(restored.leadershipWeeks, 1);
    expect(restored.leadershipVictory, isFalse);
    expect(restored.rank, 1);
    final old = ManagementState.fromJson({'cash': 150000});
    expect(old.leadershipWeeks, 0);
    expect(old.leadershipVictory, isFalse);
  });

  test('بدء مشروع كفاءة الحوسبة يخصم ثمنه ويرفض مشروعا ثانيا أو بلا نقد', () {
    final s = ManagementState();
    final cashBefore = s.cash;
    expect(s.startResearch('compute_efficiency'), isTrue);
    expect(s.cash, cashBefore - 7000);
    expect(s.activeResearch?.id, 'compute_efficiency');
    expect(s.startResearch('architecture'), isFalse);
    expect(s.cash, cashBefore - 7000);
    final poor = ManagementState(cash: 100);
    expect(poor.startResearch('compute_efficiency'), isFalse);
    expect(poor.activeResearch, isNull);
  });

  test('مشروع كفاءة الحوسبة يكتمل بعد 5 أسابيع ويزيد الحوسبة 20', () {
    final s = ManagementState();
    expect(s.startResearch('compute_efficiency'), isTrue);
    WeekReport? last;
    for (var i = 0; i < 5; i++) {
      last = s.advanceWeek(random: _ZeroRandom());
    }
    expect(s.activeResearch, isNull);
    expect(s.completedResearch, contains('compute_efficiency'));
    expect(last?.researchCompleted, contains('كفاءة'));
    expect(s.startResearch('compute_efficiency'), isFalse);
    // الحوسبة المتاحة: تجديد 10 أسبوعيا من 100 إلى 150 بعد
    // خمسة أسابيع، ثم +20 عند الاكتمال = 170، مقابل 150
    // لحالة ضابطة بنفس العشوائية الصفرية.
    final control = ManagementState();
    for (var i = 0; i < 5; i++) {
      control.advanceWeek(random: _ZeroRandom());
    }
    expect(control.computeAvailable, 150);
    expect(s.computeAvailable, 170);
  });

  test('أثر كفاءة الحوسبة لا يرفع المتاح فوق سقف 200', () {
    final s = ManagementState(computeAvailable: 195);
    expect(s.startResearch('compute_efficiency'), isTrue);
    for (var i = 0; i < 5; i++) {
      s.advanceWeek(random: _ZeroRandom());
    }
    expect(s.completedResearch, contains('compute_efficiency'));
    expect(s.computeAvailable, 200);
  });

  test('الحفظ والاسترجاع يحافظان على مشروع كفاءة الحوسبة', () {
    final s = ManagementState();
    s.startResearch('compute_efficiency');
    s.advanceWeek(random: _ZeroRandom());
    final restored = ManagementState.fromJson(s.toJson());
    expect(restored.activeResearch?.id, 'compute_efficiency');
    expect(restored.activeResearch?.weeksDone, 1);
    final old = ManagementState.fromJson({'cash': 150000});
    expect(old.startResearch('compute_efficiency'), isTrue);
  });

  test('بدء مشروع بيانات تركيبية يخصم ثمنه ويرفض مشروعا ثانيا أو بلا نقد', () {
    final s = ManagementState();
    final cashBefore = s.cash;
    expect(s.startResearch('synthetic_data'), isTrue);
    expect(s.cash, cashBefore - 6500);
    expect(s.activeResearch?.id, 'synthetic_data');
    expect(s.startResearch('architecture'), isFalse);
    expect(s.cash, cashBefore - 6500);
    final poor = ManagementState(cash: 100);
    expect(poor.startResearch('synthetic_data'), isFalse);
    expect(poor.activeResearch, isNull);
  });

  test('مشروع بيانات تركيبية يكتمل بعد 5 أسابيع ويزيد الكمية 300 دون جودة', () {
    final s = ManagementState();
    expect(s.startResearch('synthetic_data'), isTrue);
    WeekReport? last;
    for (var i = 0; i < 5; i++) {
      last = s.advanceWeek(random: _ZeroRandom());
    }
    expect(s.activeResearch, isNull);
    expect(s.completedResearch, contains('synthetic_data'));
    expect(last?.researchCompleted, contains('تركيبية'));
    expect(s.startResearch('synthetic_data'), isFalse);
    final control = ManagementState();
    for (var i = 0; i < 5; i++) {
      control.advanceWeek(random: _ZeroRandom());
    }
    expect(control.dataQuantity, 800);
    expect(control.dataQuality, s.dataQuality);
    expect(s.dataQuantity, 1100);
  });

  test('الحفظ والاسترجاع يحافظان على مشروع بيانات تركيبية', () {
    final s = ManagementState();
    s.startResearch('synthetic_data');
    s.advanceWeek(random: _ZeroRandom());
    final restored = ManagementState.fromJson(s.toJson());
    expect(restored.activeResearch?.id, 'synthetic_data');
    expect(restored.activeResearch?.weeksDone, 1);
    final old = ManagementState.fromJson({'cash': 150000});
    expect(old.startResearch('synthetic_data'), isTrue);
  });

  test('بدء خدمة التقييم وإيقافها وأثمانها', () {
    final s = ManagementState();
    expect(s.startService('model_evaluation'), isTrue);
    expect(s.startService('model_evaluation'), isFalse);
    expect(s.servicesRevenue, 950);
    expect(s.servicesCost, 300);
    expect(s.servicesCompute, 0);
    expect(s.teamServiceCount, 1);
    expect(s.stopService('model_evaluation'), isTrue);
    expect(s.servicesRevenue, 0);
    expect(s.teamServiceCount, 0);
  });

  test('أسبوع بخدمة التقييم يبطئ البحث 3 ويسجل إيرادها وتكلفتها', () {
    final s = ManagementState();
    s.startService('model_evaluation');
    final report = s.advanceWeek(random: _NeverRandom());
    expect(report.servicesRevenue, 950);
    expect(report.servicesCost, 300);
    expect(s.researchProgress, 3);
    final control = ManagementState();
    control.advanceWeek(random: _NeverRandom());
    expect(control.researchProgress, 6);
  });

  test('الحفظ والاسترجاع يحافظان على خدمة التقييم', () {
    final s = ManagementState();
    s.startService('model_evaluation');
    s.advanceWeek(random: _NeverRandom());
    final restored = ManagementState.fromJson(s.toJson());
    expect(restored.services.map((e) => e.id), contains('model_evaluation'));
    expect(restored.servicesRevenue, 950);
    final old = ManagementState.fromJson({'cash': 150000});
    expect(old.startService('model_evaluation'), isTrue);
  });

  test('خدمة وكلاء خدمة العملاء: بدء وإيقاف وأثمان 1000/400/10/فريق', () {
    final s = ManagementState();
    expect(s.startService('support_agents'), isTrue);
    expect(s.startService('support_agents'), isFalse);
    final started = s.services.singleWhere((e) => e.id == 'support_agents');
    expect(started.weeklyRevenue, 1000);
    expect(started.weeklyCost, 400);
    expect(started.computeUsed, 10);
    expect(started.teamLoad, isTrue);
    expect(started.bigClient, isFalse);
    expect(s.stopService('support_agents'), isTrue);
    expect(s.stopService('support_agents'), isFalse);
  });

  test('أسبوع خدمة الوكلاء مقابل ضابطة: بحث أبطأ بثلاث وتقرير 1000/400', () {
    final s = ManagementState();
    s.startService('support_agents');
    final report = s.advanceWeek(random: _NeverRandom());
    final control = ManagementState();
    control.advanceWeek(random: _NeverRandom());
    expect(s.researchProgress, 3);
    expect(control.researchProgress, 6);
    expect(report.servicesRevenue, 1000);
    expect(report.servicesCost, 400);
  });

  test('الحفظ والاسترجاع يحافظان على خدمة الوكلاء', () {
    final s = ManagementState();
    s.startService('support_agents');
    s.advanceWeek(random: _NeverRandom());
    final restored = ManagementState.fromJson(s.toJson());
    expect(restored.services.map((e) => e.id), contains('support_agents'));
    expect(restored.servicesRevenue, 1000);
    final old = ManagementState.fromJson({'cash': 150000});
    expect(old.startService('support_agents'), isTrue);
  });

  test('خدمة تدقيق الأمان والمواءمة: بدء وإيقاف وأثمان 1150/500/15/فريق', () {
    final s = ManagementState();
    expect(s.startService('safety_audit'), isTrue);
    expect(s.startService('safety_audit'), isFalse);
    final started = s.services.singleWhere((e) => e.id == 'safety_audit');
    expect(started.weeklyRevenue, 1150);
    expect(started.weeklyCost, 500);
    expect(started.computeUsed, 15);
    expect(started.teamLoad, isTrue);
    expect(started.bigClient, isFalse);
    expect(s.stopService('safety_audit'), isTrue);
    expect(s.stopService('safety_audit'), isFalse);
  });

  test('أسبوع خدمة التدقيق مقابل ضابطة: بحث أبطأ بثلاث وتقرير 1150/500', () {
    final s = ManagementState();
    s.startService('safety_audit');
    final report = s.advanceWeek(random: _NeverRandom());
    final control = ManagementState();
    control.advanceWeek(random: _NeverRandom());
    expect(s.researchProgress, 3);
    expect(control.researchProgress, 6);
    expect(report.servicesRevenue, 1150);
    expect(report.servicesCost, 500);
  });

  test('الحفظ والاسترجاع يحافظان على خدمة التدقيق', () {
    final s = ManagementState();
    s.startService('safety_audit');
    s.advanceWeek(random: _NeverRandom());
    final restored = ManagementState.fromJson(s.toJson());
    expect(restored.services.map((e) => e.id), contains('safety_audit'));
    expect(restored.servicesRevenue, 1150);
    final old = ManagementState.fromJson({'cash': 150000});
    expect(old.startService('safety_audit'), isTrue);
  });

  test('بدء مشروع فهم متعدد الوسائط يخصم ثمنه ويرفض مشروعا ثانيا أو بلا نقد', () {
    final s = ManagementState();
    final cashBefore = s.cash;
    expect(s.startResearch('multimodal'), isTrue);
    expect(s.cash, cashBefore - 7500);
    expect(s.activeResearch?.id, 'multimodal');
    expect(s.startResearch('architecture'), isFalse);
    expect(s.cash, cashBefore - 7500);
    final poor = ManagementState(cash: 100);
    expect(poor.startResearch('multimodal'), isFalse);
    expect(poor.activeResearch, isNull);
  });

  test('مشروع فهم متعدد الوسائط يكتمل بعد 6 أسابيع: سمعة +5 ونمو +2', () {
    final s = ManagementState();
    expect(s.startResearch('multimodal'), isTrue);
    WeekReport? last;
    for (var i = 0; i < 6; i++) {
      last = s.advanceWeek(random: _NeverRandom());
    }
    expect(s.activeResearch, isNull);
    expect(s.completedResearch, contains('multimodal'));
    expect(last?.researchCompleted, contains('متعدد الوسائط'));
    expect(s.startResearch('multimodal'), isFalse);
    final control = ManagementState();
    for (var i = 0; i < 6; i++) {
      control.advanceWeek(random: _NeverRandom());
    }
    expect(s.reputation, control.reputation + 5);
    expect(s.userGrowthBoost, control.userGrowthBoost + 2);
  });

  test('إطلاق تلخيص الاجتماعات يخصم ثمنه ويرفض المكرر وبلا نقد', () {
    final s = ManagementState();
    expect(s.launchProduct('meetings'), isTrue);
    expect(s.cash, 150000 - 14000);
    expect(s.launchedProducts, contains('meetings'));
    expect(s.launchProduct('meetings'), isFalse);
    expect(s.cash, 150000 - 14000);
    final poor = ManagementState(cash: 1000);
    expect(poor.launchProduct('meetings'), isFalse);
    expect(poor.cash, 1000);
    expect(poor.launchedProducts, isEmpty);
  });

  test('تلخيص الاجتماعات يدر إيراده ويكلف صيانته وينمو بالمستخدمين', () {
    final s = ManagementState();
    final control = ManagementState();
    expect(s.launchProduct('meetings'), isTrue);
    final report = s.advanceWeek(random: _ZeroRandom());
    control.advanceWeek(random: _ZeroRandom());
    expect(s.productsRevenue, 950);
    expect(s.productsCost, 500);
    expect(s.productsGrowth, 4);
    expect(report.productRevenue, 950);
    expect(report.productCost, 500);
    expect(s.users, control.users + 4);
    expect(s.cash, control.cash - 14000 + 450);
    expect(report.lines.any((l) => l.contains('المنتجات:')), isTrue);
  });

  test('تلخيص الاجتماعات صافي متوسط بلا هيمنة وحفظه واسترجاعه', () {
    final meetingsDef = ManagementState.productCatalog
        .firstWhere((d) => d.id == 'meetings');
    final apiDef = ManagementState.productCatalog
        .firstWhere((d) => d.id == 'api');
    final agentsDef = ManagementState.productCatalog
        .firstWhere((d) => d.id == 'agents');
    expect(meetingsDef.revenue - meetingsDef.maintenance, 450);
    expect(meetingsDef.revenue - meetingsDef.maintenance,
        lessThan(apiDef.revenue - apiDef.maintenance));
    expect(meetingsDef.growth, agentsDef.growth);
    expect(meetingsDef.revenue - meetingsDef.maintenance,
        lessThan(agentsDef.revenue - agentsDef.maintenance));
    final s = ManagementState();
    s.launchProduct('meetings');
    final restored = ManagementState.fromJson(s.toJson());
    expect(restored.launchedProducts, contains('meetings'));
    expect(restored.productsRevenue, 950);
    expect(restored.productsCost, 500);
    final oldJson = s.toJson()..remove('launchedProducts');
    final restoredOld = ManagementState.fromJson(oldJson);
    expect(restoredOld.launchedProducts, isEmpty);
  });

  test('الحفظ والاسترجاع يحافظان على مشروع فهم متعدد الوسائط', () {
    final s = ManagementState();
    s.startResearch('multimodal');
    s.advanceWeek(random: _NeverRandom());
    final restored = ManagementState.fromJson(s.toJson());
    expect(restored.activeResearch?.id, 'multimodal');
    expect(restored.activeResearch?.weeksDone, 1);
    final old = ManagementState.fromJson({'cash': 150000});
    expect(old.startResearch('multimodal'), isTrue);
  });

  test('بدء مشروع ذاكرة وكلاء طويلة يخصم ثمنه ويرفض مشروعا ثانيا أو بلا نقد', () {
    final s = ManagementState();
    final cashBefore = s.cash;
    expect(s.startResearch('agent_memory'), isTrue);
    expect(s.cash, cashBefore - 6500);
    expect(s.activeResearch?.id, 'agent_memory');
    expect(s.startResearch('architecture'), isFalse);
    expect(s.cash, cashBefore - 6500);
    final poor = ManagementState(cash: 100);
    expect(poor.startResearch('agent_memory'), isFalse);
    expect(poor.activeResearch, isNull);
  });

  test('مشروع ذاكرة وكلاء طويلة يكتمل بعد 5 أسابيع: سمعة +3 ونمو +2', () {
    final s = ManagementState();
    expect(s.startResearch('agent_memory'), isTrue);
    WeekReport? last;
    for (var i = 0; i < 5; i++) {
      last = s.advanceWeek(random: _NeverRandom());
    }
    expect(s.activeResearch, isNull);
    expect(s.completedResearch, contains('agent_memory'));
    expect(last?.researchCompleted, contains('ذاكرة'));
    expect(s.startResearch('agent_memory'), isFalse);
    final control = ManagementState();
    for (var i = 0; i < 5; i++) {
      control.advanceWeek(random: _NeverRandom());
    }
    expect(s.reputation, control.reputation + 3);
    expect(s.userGrowthBoost, control.userGrowthBoost + 2);
  });

  test('الحفظ والاسترجاع يحافظان على مشروع ذاكرة وكلاء طويلة', () {
    final s = ManagementState();
    s.startResearch('agent_memory');
    s.advanceWeek(random: _NeverRandom());
    final restored = ManagementState.fromJson(s.toJson());
    expect(restored.activeResearch?.id, 'agent_memory');
    expect(restored.activeResearch?.weeksDone, 1);
    final old = ManagementState.fromJson({'cash': 150000});
    expect(old.startResearch('agent_memory'), isTrue);
  });

  test('إطلاق مساعد الأبحاث يخصم ثمنه ويرفض المكرر وبلا نقد', () {
    final s = ManagementState();
    expect(s.launchProduct('research_assistant'), isTrue);
    expect(s.cash, 150000 - 13500);
    expect(s.launchedProducts, contains('research_assistant'));
    expect(s.launchProduct('research_assistant'), isFalse);
    expect(s.cash, 150000 - 13500);
    final poor = ManagementState(cash: 1000);
    expect(poor.launchProduct('research_assistant'), isFalse);
    expect(poor.cash, 1000);
    expect(poor.launchedProducts, isEmpty);
  });

  test('مساعد الأبحاث يدر إيراده ويكلف صيانته وينمو بالمستخدمين', () {
    final s = ManagementState();
    final control = ManagementState();
    expect(s.launchProduct('research_assistant'), isTrue);
    final report = s.advanceWeek(random: _ZeroRandom());
    control.advanceWeek(random: _ZeroRandom());
    expect(s.productsRevenue, 950);
    expect(s.productsCost, 450);
    expect(s.productsGrowth, 3);
    expect(report.productRevenue, 950);
    expect(report.productCost, 450);
    expect(s.users, control.users + 3);
    expect(s.cash, control.cash - 13500 + 500);
    expect(report.lines.any((l) => l.contains('المنتجات:')), isTrue);
  });

  test('مساعد الأبحاث صافي متوسط بلا هيمنة وحفظه واسترجاعه', () {
    final researchDef = ManagementState.productCatalog
        .firstWhere((d) => d.id == 'research_assistant');
    final apiDef = ManagementState.productCatalog
        .firstWhere((d) => d.id == 'api');
    final agentsDef = ManagementState.productCatalog
        .firstWhere((d) => d.id == 'agents');
    final codingDef = ManagementState.productCatalog
        .firstWhere((d) => d.id == 'coding');
    expect(researchDef.revenue - researchDef.maintenance, 500);
    expect(researchDef.revenue - researchDef.maintenance,
        lessThan(apiDef.revenue - apiDef.maintenance));
    expect(researchDef.revenue - researchDef.maintenance,
        lessThan(agentsDef.revenue - agentsDef.maintenance));
    expect(researchDef.growth, lessThan(codingDef.growth));
    final s = ManagementState();
    s.launchProduct('research_assistant');
    final restored = ManagementState.fromJson(s.toJson());
    expect(restored.launchedProducts, contains('research_assistant'));
    expect(restored.productsRevenue, 950);
    expect(restored.productsCost, 450);
    final oldJson = s.toJson()..remove('launchedProducts');
    final restoredOld = ManagementState.fromJson(oldJson);
    expect(restoredOld.launchedProducts, isEmpty);
  });

  test('بدء التدريب الموزّع يخصم ثمنه ويرفض مشروعا ثانيا أو مكررا أو بلا نقد', () {
    final s = ManagementState();
    final cashBefore = s.cash;
    expect(s.startResearch('distributed_training'), isTrue);
    expect(s.cash, cashBefore - 8500);
    expect(s.activeResearch?.id, 'distributed_training');
    expect(s.startResearch('scaling'), isFalse);
    expect(s.cash, cashBefore - 8500);
    final poor = ManagementState(cash: 100);
    expect(poor.startResearch('distributed_training'), isFalse);
    expect(poor.activeResearch, isNull);
  });

  test('التدريب الموزّع يكتمل بعد 5 أسابيع ويرفع البحث نقطة والتدريب نقطتين', () {
    final s = ManagementState();
    expect(s.startResearch('distributed_training'), isTrue);
    WeekReport? last;
    for (var i = 0; i < 5; i++) {
      last = s.advanceWeek(random: Random(11));
    }
    expect(s.activeResearch, isNull);
    expect(s.completedResearch, contains('distributed_training'));
    expect(last?.researchCompleted, contains('تدريب موزّع'));
    expect(s.researchBoost, 1);
    expect(s.trainingBoost, 2);
    expect(s.startResearch('distributed_training'), isFalse);
  });

  test('التدريب الموزّع أضعف من قائدي المحورين فلا يهيمن على أي منهما', () {
    final def = ManagementState.researchCatalog
        .firstWhere((d) => d.id == 'distributed_training');
    final archDef = ManagementState.researchCatalog
        .firstWhere((d) => d.id == 'architecture');
    final scalingDef = ManagementState.researchCatalog
        .firstWhere((d) => d.id == 'scaling');
    expect(def.cost, greaterThan(archDef.cost));
    expect(def.cost, greaterThan(scalingDef.cost));
    final s = ManagementState();
    s.startResearch('distributed_training');
    for (var i = 0; i < 5; i++) {
      s.advanceWeek(random: Random(11));
    }
    expect(s.researchBoost, lessThan(2));
    expect(s.trainingBoost, lessThan(4));
  });

  test('الحفظ والاسترجاع يحافظان على التدريب الموزّع النشط ومكافأتيه', () {
    final s = ManagementState();
    s.startResearch('distributed_training');
    s.advanceWeek(random: Random(6));
    final restored = ManagementState.fromJson(s.toJson());
    expect(restored.activeResearch?.id, 'distributed_training');
    expect(restored.activeResearch?.weeksDone, 1);
    for (var i = 0; i < 4; i++) {
      restored.advanceWeek(random: Random(6));
    }
    expect(restored.researchBoost, 1);
    expect(restored.trainingBoost, 2);
  });

  test('إطلاق الترجمة الفورية يخصم ثمنها ويرفض المكرر وبلا نقد', () {
    final s = ManagementState();
    expect(s.launchProduct('live_translation'), isTrue);
    expect(s.cash, 150000 - 14500);
    expect(s.launchedProducts, contains('live_translation'));
    expect(s.launchProduct('live_translation'), isFalse);
    expect(s.cash, 150000 - 14500);
    final poor = ManagementState(cash: 1000);
    expect(poor.launchProduct('live_translation'), isFalse);
    expect(poor.cash, 1000);
    expect(poor.launchedProducts, isEmpty);
  });

  test('الترجمة الفورية تدر إيرادها وتكلف صيانتها وتنمو بالمستخدمين', () {
    final s = ManagementState();
    final control = ManagementState();
    expect(s.launchProduct('live_translation'), isTrue);
    final report = s.advanceWeek(random: _ZeroRandom());
    control.advanceWeek(random: _ZeroRandom());
    expect(s.productsRevenue, 900);
    expect(s.productsCost, 500);
    expect(s.productsGrowth, 4);
    expect(report.productRevenue, 900);
    expect(report.productCost, 500);
    expect(s.users, control.users + 4);
    expect(s.cash, control.cash - 14500 + 400);
    expect(report.lines.any((l) => l.contains('المنتجات:')), isTrue);
  });

  test('الترجمة الفورية صافي أدنى من المنصة بلا هيمنة وحفظها واسترجاعها',
      () {
    final def = ManagementState.productCatalog
        .firstWhere((d) => d.id == 'live_translation');
    final apiDef =
        ManagementState.productCatalog.firstWhere((d) => d.id == 'api');
    final agentsDef =
        ManagementState.productCatalog.firstWhere((d) => d.id == 'agents');
    expect(def.revenue - def.maintenance, 400);
    expect(def.revenue - def.maintenance,
        lessThan(agentsDef.revenue - agentsDef.maintenance));
    expect(def.growth, agentsDef.growth);
    expect(def.revenue - def.maintenance,
        lessThan(apiDef.revenue - apiDef.maintenance));
    final s = ManagementState();
    s.launchProduct('live_translation');
    final restored = ManagementState.fromJson(s.toJson());
    expect(restored.launchedProducts, contains('live_translation'));
    expect(restored.productsRevenue, 900);
    expect(restored.productsCost, 500);
    final oldJson = s.toJson()..remove('launchedProducts');
    final restoredOld = ManagementState.fromJson(oldJson);
    expect(restoredOld.launchedProducts, isEmpty);
  });

  test('بدء التقييم المستمر يخصم ثمنه ويرفض مشروعا ثانيا أو بلا نقد', () {
    final s = ManagementState();
    expect(s.startResearch('capability_evaluation'), isTrue);
    expect(s.cash, 150000 - 7200);
    expect(s.activeResearch?.id, 'capability_evaluation');
    expect(s.startResearch('architecture'), isFalse);
    expect(s.cash, 150000 - 7200);
    final poor = ManagementState(cash: 1000);
    expect(poor.startResearch('capability_evaluation'), isFalse);
    expect(poor.cash, 1000);
    expect(poor.activeResearch, isNull);
  });

  test('التقييم المستمر يكتمل بعد 6 أسابيع بسمعة +4 وبيانات +150 ولا يتكرر',
      () {
    final s = ManagementState();
    expect(s.startResearch('capability_evaluation'), isTrue);
    WeekReport? last;
    for (var i = 0; i < 6; i++) {
      last = s.advanceWeek(random: Random(11));
    }
    expect(s.activeResearch, isNull);
    expect(s.completedResearch, contains('capability_evaluation'));
    expect(last?.researchCompleted, contains('تقييم قدرات مستمر'));
    expect(s.startResearch('capability_evaluation'), isFalse);
    // السمعة والبيانات أعلى من حالة ضابطة بنفس البذرة بمقدار
    // المكافأتين فقط، لأن تحركات المنافسين قد تخفض السمعة في الحالتين معا.
    final control = ManagementState();
    for (var i = 0; i < 6; i++) {
      control.advanceWeek(random: Random(11));
    }
    expect(s.reputation, control.reputation + 4);
    expect(s.dataQuantity, control.dataQuantity + 150);
  });

  test('التقييم المستمر أضعف من المتخصصين في السمعة والبيانات فلا يهيمن',
      () {
    final def = ManagementState.researchCatalog
        .firstWhere((d) => d.id == 'capability_evaluation');
    final alignmentDef = ManagementState.researchCatalog
        .firstWhere((d) => d.id == 'alignment');
    final syntheticDef = ManagementState.researchCatalog
        .firstWhere((d) => d.id == 'synthetic_data');
    expect(def.cost, greaterThan(alignmentDef.cost));
    expect(def.cost, greaterThan(syntheticDef.cost));
    final s = ManagementState();
    s.startResearch('capability_evaluation');
    for (var i = 0; i < 6; i++) {
      s.advanceWeek(random: Random(11));
    }
    final control = ManagementState();
    for (var i = 0; i < 6; i++) {
      control.advanceWeek(random: Random(11));
    }
    expect(s.reputation, control.reputation + 4);
    expect(s.reputation, lessThan(control.reputation + 10));
    expect(s.dataQuantity, control.dataQuantity + 150);
    expect(s.dataQuantity, lessThan(control.dataQuantity + 300));
  });

  test('الحفظ والاسترجاع يحافظان على التقييم المستمر النشط ومكافأتيه', () {
    final s = ManagementState();
    s.startResearch('capability_evaluation');
    s.advanceWeek(random: Random(6));
    final restored = ManagementState.fromJson(s.toJson());
    expect(restored.activeResearch?.id, 'capability_evaluation');
    expect(restored.activeResearch?.weeksDone, 1);
    for (var i = 0; i < 5; i++) {
      restored.advanceWeek(random: Random(6));
    }
    final control = ManagementState();
    for (var i = 0; i < 6; i++) {
      control.advanceWeek(random: Random(6));
    }
    expect(restored.reputation, control.reputation + 4);
    expect(restored.dataQuantity, control.dataQuantity + 150);
  });

}

/// عشوائية حتمية للاختبارات: لا فرصة تتحقق أبدا، وكل عدد صفر.
class _NeverRandom implements Random {
  @override
  double nextDouble() => 1;

  @override
  int nextInt(int max) => 0;

  @override
  bool nextBool() => false;
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
