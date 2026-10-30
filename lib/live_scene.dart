import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'game_feel.dart';

/// المرحلة 2 — المشهد الحي للشركة: مرسوم بأدوات Flutter الأصلية
/// فقط، دون أي أصول خارجية، وكل عنصر فيه يعكس رقما حقيقيا من
/// إدارة الشركة نفسها، لا زخرفة منفصلة عن الأرقام:
/// - ارتفاع مبنى شركتك يتناسب مع مستوى نموذجك.
/// - ارتفاع مباني المنافسين يتناسب مع مستوياتهم الحقيقية.
/// - عدد النقاط المضيئة يتناسب مع عدد مستخدميك الحقيقي.
/// - لون مؤشر الحوسبة يعكس الحوسبة المتاحة فعلا، والأحمر عند
///   نفاده أو عند الإفلاس، والأخضر عند الصدارة.
double computeFraction(int available) =>
    (available / 200).clamp(0.0, 1.0);

double usersFraction(int users) =>
    (math.sqrt(users / 10000)).clamp(0.0, 1.0);

double levelFraction(int level) => (level / 10).clamp(0.0, 1.0);

int userDots(int users) => (users ~/ 100).clamp(0, 24);

class CompanyLiveScene extends StatelessWidget {
  final int computeAvailable;
  final int computeReserved;
  final int users;
  final int modelLevel;
  final List<String> rivalNames;
  final List<int> rivalLevels;
  final int reputation;
  final bool isBankrupt;
  final bool leadershipVictory;

  const CompanyLiveScene({
    super.key,
    required this.computeAvailable,
    required this.computeReserved,
    required this.users,
    required this.modelLevel,
    required this.rivalNames,
    required this.rivalLevels,
    required this.reputation,
    required this.isBankrupt,
    required this.leadershipVictory,
  });

  @override
  Widget build(BuildContext context) {
    final computeColor = isBankrupt
        ? Colors.red
        : computeAvailable < 20
            ? Colors.orange
            : leadershipVictory
                ? Colors.green
                : Colors.teal;
    final dots = userDots(users);
    return Card(
      key: const Key('live-scene'),
      color: isBankrupt
          ? Colors.red.shade50
          : leadershipVictory
              ? Colors.green.shade50
              : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('مشهد الشركة الحي',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                Text(
                  isBankrupt
                      ? 'الشركة متعثرة'
                      : leadershipVictory
                          ? 'أنت في الصدارة'
                          : 'السمعة $reputation / 100',
                  style: TextStyle(
                      color: computeColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _Building(
                  label: 'شركتك',
                  level: modelLevel,
                  highlight: true,
                  color: computeColor,
                ),
                for (var i = 0; i < rivalNames.length; i++)
                  _Building(
                    label: rivalNames[i],
                    level: i < rivalLevels.length ? rivalLevels[i] : 1,
                    highlight: false,
                    color: Colors.grey,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.memory, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: AnimatedBar(
                    label: 'الحوسبة المتاحة ($computeAvailable، محجوز $computeReserved)',
                    fraction: computeFraction(computeAvailable),
                    color: computeColor,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.people, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'المستخدمون: $users — كل نقطة مضيئة تمثل 100 مستخدم حقيقي',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                for (var i = 0; i < dots; i++)
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.3, end: 1),
                    duration: Duration(milliseconds: 400 + (i % 5) * 150),
                    builder: (context, value, _) => Opacity(
                      opacity: value,
                      child: const Icon(Icons.circle,
                          size: 10, color: Colors.teal),
                    ),
                  ),
                if (dots == 0)
                  const Text('لا نقاط بعد — أطلق منتجا ليأتي المستخدمون',
                      style: TextStyle(fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Building extends StatelessWidget {
  final String label;
  final int level;
  final bool highlight;
  final Color color;

  const _Building({
    required this.label,
    required this.level,
    required this.highlight,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final height = 24 + levelFraction(level) * 72;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('مستوى $level',
            style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 2),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 24, end: height),
          duration: const Duration(milliseconds: 700),
          builder: (context, value, _) => Container(
            width: highlight ? 44 : 36,
            height: value,
            decoration: BoxDecoration(
              color: highlight ? color : Colors.grey.shade400,
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4)),
              border: highlight
                  ? Border.all(color: color, width: 2)
                  : null,
            ),
            child: const Icon(Icons.business,
                size: 18, color: Colors.white),
          ),
        ),
        const SizedBox(height: 2),
        SizedBox(
          width: 64,
          child: Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
