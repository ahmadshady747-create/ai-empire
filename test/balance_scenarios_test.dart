import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:ai_empire/management.dart';

void main() {
  test('المرحلة 2: لا منتج يهيمن على محوري الصافي والنمو معا', () {
    const products = ManagementState.productCatalog;
    final maxNet = products
        .map((p) => p.revenue - p.maintenance)
        .reduce((a, b) => a > b ? a : b);
    final maxGrowth =
        products.map((p) => p.growth).reduce((a, b) => a > b ? a : b);
    for (final p in products) {
      final net = p.revenue - p.maintenance;
      expect(net == maxNet && p.growth == maxGrowth, isFalse,
          reason: 'المنتج ${p.name} يجمع أعلى صافي وأعلى نمو معا');
    }
    final maxNetProduct =
        products.firstWhere((p) => p.revenue - p.maintenance == maxNet);
    final maxGrowthProduct =
        products.firstWhere((p) => p.growth == maxGrowth);
    expect(maxNetProduct.growth < maxGrowth, isTrue);
    expect(maxGrowthProduct.revenue - maxGrowthProduct.maintenance < maxNet,
        isTrue);
  });

  test('المرحلة 2: أعلى خدمة صافي ليست مجانية: فريق أو حوسبة أو عميل كبير',
      () {
    const services = ManagementState.serviceCatalog;
    final maxNet = services
        .map((s) => s.revenue - s.cost)
        .reduce((a, b) => a > b ? a : b);
    for (final s in services) {
      if (s.revenue - s.cost == maxNet) {
        expect(s.team || s.compute > 0 || s.big, isTrue,
            reason: 'الخدمة ${s.name} أعلى صافي بلا ثمن متشابك');
      }
    }
  });

  test('المرحلة 2: أرخص وأسرع بحث ليس دفعة أسبوعية دائمة', () {
    const research = ManagementState.researchCatalog;
    final minCost =
        research.map((r) => r.cost).reduce((a, b) => a < b ? a : b);
    final minWeeks =
        research.map((r) => r.weeks).reduce((a, b) => a < b ? a : b);
    for (final r in research) {
      expect(
          r.cost == minCost && r.weeks == minWeeks && r.effect.contains('دائما'),
          isFalse,
          reason: 'البحث ${r.name} أرخص وأسرع ودائم معا');
    }
  });

  test('المرحلة 2: سيناريو إفلاس — نقد نافد وائتمان مستنفد معا', () {
    final state = ManagementState(cash: 100, creditUsed: 50000);
    final report = state.advanceWeek(random: Random(7));
    expect(report.creditDrawn, 0);
    expect(state.isBankrupt, isTrue);
    expect(report.lines.any((l) => l.contains('مفلسة')), isTrue);
  });

  test('المرحلة 2: سيناريو إنقاذ — الائتمان المتاح يمنع الإفلاس عند نفاد النقد',
      () {
    final state = ManagementState(cash: 100, creditUsed: 0);
    final report = state.advanceWeek(random: Random(7));
    expect(report.creditDrawn, greaterThan(0));
    expect(state.isBankrupt, isFalse);
  });

  test('المرحلة 2: سيناريو فوز — أربعة أسابيع متتالية في الصدارة', () {
    final state = ManagementState(
      modelLevel: 5,
      rivals: [
        Rival(name: 'منافس أ', modelLevel: 1),
        Rival(name: 'منافس ب', modelLevel: 1),
        Rival(name: 'منافس ج', modelLevel: 1),
      ],
    );
    for (var i = 0; i < 3; i++) {
      state.advanceWeek(random: Random(42));
    }
    expect(state.leadershipVictory, isFalse);
    state.advanceWeek(random: Random(42));
    expect(state.leadershipWeeks, greaterThanOrEqualTo(4));
    expect(state.leadershipVictory, isTrue);
  });
}
