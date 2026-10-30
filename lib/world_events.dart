import 'package:flutter/material.dart';

/// المرحلة 5 — مشهد حدث العالم التفاعلي: يظهر بعد الأسبوع
/// الذي وقع فيه حدث عالمي (كل 8 أسابيع، يدور بين ثلاثة
/// سيناريوهات)، لا كسطر أخبار فقط، بل كمشهد بقرار إداري.
/// القرارات الثلاثة كلها إجراءات إدارة قائمة أصلا، لا خيارات
/// سردية تحسم اللعب: شراء حوسبة، أو بدء بحث، أو ادخار النقد
/// بعدم الإنفاق. أثر القرار يظهر فورا في أرقام الإدارة
/// والمشهد الحي، ويُعرض ملخصه في ملاحظة القرار التي يعيدها
/// الأب. سلسلة الأسابيع المعروضة هنا هي سلسلة الإدارة نفسها
/// من لوحة الأهداف، فالاستمرارية مرئية في المشهد نفسه.
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
    return Card(
      key: const Key('world-event-scene'),
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.blue, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Icon(Icons.public, size: 28, color: Colors.blue),
                SizedBox(width: 8),
                Expanded(
                  child: Text('مشهد حدث العالم',
                      style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold)),
                ),
                Icon(Icons.factory, size: 28, color: Colors.blueGrey),
              ],
            ),
            const SizedBox(height: 6),
            Text(eventName,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            Text(eventEffect),
            Text('سلسلة أسابيعك دون إفلاس: $streakWeeks',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
                'كيف ترد إداريا؟ اختر إجراء واحدا — أثره يظهر فورا في أرقامك:'),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: canBuyCompute ? onBuyCompute : null,
              child: Text(canBuyCompute
                  ? 'استثمر في الحوسبة: شراء 25 وحدة (4000)'
                  : 'شراء الحوسبة غير متاح الآن'),
            ),
            OutlinedButton(
              onPressed: canStartResearch ? onStartResearch : null,
              child: Text(canStartResearch
                  ? 'ركّز على البحث: ابدأ أول مشروع بحث بمقدورك'
                  : 'بدء البحث غير متاح الآن'),
            ),
            OutlinedButton(
              onPressed: onSaveCash,
              child: const Text('ادّخر النقد: لا إجراء الآن'),
            ),
          ],
        ),
      ),
    );
  }
}
