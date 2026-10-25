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
