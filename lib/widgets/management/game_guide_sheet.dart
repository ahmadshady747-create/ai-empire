import 'package:flutter/material.dart';

import '../../management.dart';
import '../../theme/empire_theme.dart';

/// دليل القائد المصوّر وموسوعة الشرح التفاعلي (الإصدار 4.0):
/// يشرح كل آليات اللعب بوضوح وببطاقات ملونة بدلاً من الفقرات المزدحمة.
Future<void> showGameGuideSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: EmpireColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (sheetContext) => SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        maxChildSize: 0.94,
        builder: (_, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: EmpireColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const Row(
              children: [
                Icon(Icons.menu_book_rounded, color: EmpireColors.cyan),
                SizedBox(width: 8),
                Text(
                  'دليل القائد — كيف تبني إمبراطوريتك؟',
                  style: TextStyle(
                    fontSize: 17.5,
                    fontWeight: FontWeight.w900,
                    color: EmpireColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const _GuideCard(
              icon: Icons.emoji_events_rounded,
              color: EmpireColors.gold,
              title: 'كيف تفوز؟',
              body:
                  'تصدّر الترتيب #1 فوق OpenMind وAnthroCore وDeepVortex لمدة 4 أسابيع متتالية عبر تطوير مستوى نموذجك الرئيسي باستمرار.',
            ),
            const _GuideCard(
              icon: Icons.warning_amber_rounded,
              color: EmpireColors.coral,
              title: 'كيف تتجنب الإفلاس؟',
              body:
                  'أطلق منتجاً مبكراً ليغطي رواتبك الأسبوعية. إذا نفد النقد والائتمان معاً تُفلس الشركة. راقب «المدى النقدي» في الشريط العلوي دائماً.',
            ),
            const _GuideCard(
              icon: Icons.bolt_rounded,
              color: EmpireColors.cyan,
              title: 'التفاعل الأسبوعي واللعبة المصغّرة',
              body:
                  'كل أسبوع تظهر لك «جلسة تدريب الشبكة العصبية» و«نبضات المقر» القابلة للنقر، وكل أسبوعين تظهر بطاقة قرار عاجل وفصول قصة تمنحك قفزات قوية.',
            ),
            const _GuideCard(
              icon: Icons.memory_rounded,
              color: EmpireColors.indigo,
              title: 'معادلة البيانات والحوسبة',
              body:
                  'جودة البيانات فوق 80 تسرّع التدريب وتحت 40 تبطئه. حجز 20–40 وحدة حوسبة يسرّع التدريب، لكن 60+ وحدة دون عقد صيانة يجهد الخوادم.',
            ),
            const SizedBox(height: 12),
            const Text(
              'موسوعة الأنظمة التفصيلية',
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                color: EmpireColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            for (final concept in managementConcepts)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: EmpireColors.bg,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: EmpireColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      concept.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: EmpireColors.cyan,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      concept.body,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: EmpireColors.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

class _GuideCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String body;

  const _GuideCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: EmpireColors.textPrimary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
