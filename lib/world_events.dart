import 'package:flutter/material.dart';

import 'theme/empire_theme.dart';

/// مشهد حدث العالم التفاعلي: بطاقة طوارئ/حدث عالمي داكنة
/// تعرض القرارات الإدارية الثلاثة بوضوح وبأثر فوري على أرقام الشركة.
class WorldEventScene extends StatelessWidget {
  final String eventName;
  final String eventEffect;
  final int streakWeeks;
  final bool canBuyCompute;
  final bool canStartResearch;
  final VoidCallback onBuyCompute;
  final VoidCallback onStartResearch;
  final VoidCallback onSaveCash;

  const WorldEventScene({
    super.key,
    required this.eventName,
    required this.eventEffect,
    required this.streakWeeks,
    required this.canBuyCompute,
    required this.canStartResearch,
    required this.onBuyCompute,
    required this.onStartResearch,
    required this.onSaveCash,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('world-event-scene'),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            EmpireColors.sky.withOpacity(0.18),
            EmpireColors.surface,
          ],
        ),
        border: Border.all(
          color: EmpireColors.sky.withOpacity(0.65),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: EmpireColors.sky.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.public_rounded,
                    size: 22,
                    color: EmpireColors.sky,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'مشهد حدث العالم',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: EmpireColors.sky,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: EmpireColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: EmpireColors.border),
                  ),
                  child: Text(
                    'سلسلة أسابيعك دون إفلاس: $streakWeeks',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: EmpireColors.gold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              eventName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: EmpireColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              eventEffect,
              style: const TextStyle(
                fontSize: 13.5,
                color: EmpireColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'كيف ترد إداريا؟ اختر إجراء واحدا — أثره يظهر فورا في أرقامك:',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: EmpireColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: canBuyCompute ? onBuyCompute : null,
              icon: const Icon(Icons.memory_rounded, size: 18),
              label: Text(
                canBuyCompute
                    ? 'استثمر في الحوسبة: شراء 25 وحدة (4000)'
                    : 'شراء الحوسبة غير متاح الآن',
              ),
            ),
            const SizedBox(height: 6),
            OutlinedButton.icon(
              onPressed: canStartResearch ? onStartResearch : null,
              icon: const Icon(Icons.science_rounded, size: 18),
              label: Text(
                canStartResearch
                    ? 'ركّز على البحث: ابدأ أول مشروع بحث بمقدورك'
                    : 'بدء البحث غير متاح الآن',
              ),
            ),
            const SizedBox(height: 6),
            OutlinedButton.icon(
              onPressed: onSaveCash,
              icon: const Icon(Icons.savings_rounded, size: 18),
              label: const Text('ادّخر النقد: لا إجراء الآن'),
            ),
          ],
        ),
      ),
    );
  }
}
