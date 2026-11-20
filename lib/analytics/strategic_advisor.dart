import 'package:flutter/material.dart';

import '../management.dart';
import '../theme/empire_theme.dart';

enum AdviceSeverity { critical, warning, opportunity }

class StrategicAdvice {
  final String title;
  final String detail;
  final String actionLabel;
  final int targetNavIndex;
  final int targetSubIndex;
  final AdviceSeverity severity;

  const StrategicAdvice({
    required this.title,
    required this.detail,
    required this.actionLabel,
    required this.targetNavIndex,
    required this.targetSubIndex,
    required this.severity,
  });

  Color get color {
    switch (severity) {
      case AdviceSeverity.critical:
        return EmpireColors.coral;
      case AdviceSeverity.warning:
        return EmpireColors.amber;
      case AdviceSeverity.opportunity:
        return EmpireColors.cyan;
    }
  }

  IconData get icon {
    switch (severity) {
      case AdviceSeverity.critical:
        return Icons.warning_amber_rounded;
      case AdviceSeverity.warning:
        return Icons.bolt_rounded;
      case AdviceSeverity.opportunity:
        return Icons.lightbulb_outline_rounded;
    }
  }
}

/// مستشار استراتيجي ذكي يحلل حالة الشركة الحالية ويقدم
/// توصيات مرتبة حسب الأولوية مع أزرار انتقال مباشر للقرار المناسب.
List<StrategicAdvice> analyzeStrategy(ManagementState s) {
  final items = <StrategicAdvice>[];

  if (s.isBankrupt) {
    return items;
  }

  if (s.runwayWeeks < 4 && s.weeklyNet < 0) {
    items.add(
      const StrategicAdvice(
        title: 'خطر نفاد السيولة قريبا',
        detail:
            'المدى النقدي أقل من 4 أسابيع. أطلق منتجاً، فعّل خدمة، أو اسحب من الائتمان قبل الإفلاس.',
        actionLabel: 'المالية',
        targetNavIndex: 3,
        targetSubIndex: 0,
        severity: AdviceSeverity.critical,
      ),
    );
  }

  if (s.computeReserved >= 60 && s.maintenanceWeeks == 0) {
    items.add(
      const StrategicAdvice(
        title: 'إجهاد حراري في الخوادم',
        detail:
            'حجزت 60+ وحدة حوسبة دون عقد صيانة وتبريد، ما يبطئ تدريبك 4 نقاط كل أسبوع.',
        actionLabel: 'الحوسبة',
        targetNavIndex: 1,
        targetSubIndex: 3,
        severity: AdviceSeverity.critical,
      ),
    );
  }

  if (s.dataQuality < 40) {
    items.add(
      const StrategicAdvice(
        title: 'جودة البيانات تبطئ التدريب',
        detail: 'جودة بياناتك تحت 40. نظّف البيانات أو اشترِ مجموعة عالية الجودة.',
        actionLabel: 'البيانات',
        targetNavIndex: 1,
        targetSubIndex: 2,
        severity: AdviceSeverity.warning,
      ),
    );
  }

  if (s.dataFreshness < 50) {
    items.add(
      const StrategicAdvice(
        title: 'البيانات تتقادم وتبطئ البحث',
        detail: 'حداثة البيانات تحت 50. جدّد البيانات للحفاظ على سرعة البحث.',
        actionLabel: 'البيانات',
        targetNavIndex: 1,
        targetSubIndex: 2,
        severity: AdviceSeverity.warning,
      ),
    );
  }

  if (s.computeAvailable < 20) {
    items.add(
      const StrategicAdvice(
        title: 'الحوسبة المتاحة منخفضة جدا',
        detail: 'توسيع الحوسبة يحمي خدماتك ويسمح بتسريع تدريب نموذجك.',
        actionLabel: 'الحوسبة',
        targetNavIndex: 1,
        targetSubIndex: 3,
        severity: AdviceSeverity.warning,
      ),
    );
  }

  if (s.launchedProducts.isEmpty && s.cash >= 10000) {
    items.add(
      const StrategicAdvice(
        title: 'لا يوجد منتج في السوق بعد',
        detail: 'أطلق أول منتج لتبدأ بجذب المستخدمين وتوليد إيراد أسبوعي مستقر.',
        actionLabel: 'المنتجات',
        targetNavIndex: 2,
        targetSubIndex: 0,
        severity: AdviceSeverity.opportunity,
      ),
    );
  }

  if (s.activeResearch == null &&
      ManagementState.researchCatalog.any(
        (r) => !s.completedResearch.contains(r.id) && s.cash >= r.cost,
      )) {
    items.add(
      const StrategicAdvice(
        title: 'مختبر البحث خامل حاليا',
        detail: 'لديك سيولة كافية لبدء مشروع بحثي يمنحك مكافأة دائمة.',
        actionLabel: 'البحث',
        targetNavIndex: 1,
        targetSubIndex: 1,
        severity: AdviceSeverity.opportunity,
      ),
    );
  }

  if (s.activeModelJob == null &&
      ManagementState.modelCatalog.any(
        (m) => !s.completedModels.contains(m.id) && s.cash >= m.cost,
      )) {
    items.add(
      const StrategicAdvice(
        title: 'فريق النماذج جاهز لمهمة جديدة',
        detail: 'يمكنك إطلاق وظيفة نموذج جديدة لرفع المستوى أو خفض الاستدلال.',
        actionLabel: 'النماذج',
        targetNavIndex: 1,
        targetSubIndex: 0,
        severity: AdviceSeverity.opportunity,
      ),
    );
  }

  if (s.rank > 1 &&
      s.cash >= ManagementState.poachCost &&
      s.rivals.any(
        (r) => r.modelLevel > 1 && !s.poachedRivals.contains(r.name),
      )) {
    items.add(
      const StrategicAdvice(
        title: 'فرصة استقطاب خبير من منافس',
        detail: 'يمكنك إضعاف منافس متقدم وتسريع تدريبك نقطتين دائما.',
        actionLabel: 'المنافسون',
        targetNavIndex: 2,
        targetSubIndex: 2,
        severity: AdviceSeverity.opportunity,
      ),
    );
  }

  return items.take(3).toList();
}
