import 'package:flutter/material.dart';

import 'game_feel.dart';

/// المرحلة 3 — أهداف ومكافآت مشتقة من أرقام الإدارة نفسها فقط.
/// لا يضيف هذا الملف أي رقم إدارة جديد ولا يغيّر توازنا:
/// التحديات عتبات على الأرقام الحقيقية وتتجدد كل 4 أسابيع
/// (كتلة أسبوعية)، والإنجازات تُفتح عند بلوغ عتبات حقيقية،
/// والمستوى مجموع نقاط من المستوى والمنتجات والمشاريع المنجزة.
/// لحظتا الفوز والخسارة هما حالتا الإدارة القائمتان أصلا:
/// الصدارة (leadershipVictory) والإفلاس (isBankrupt)، وهنا
/// تظهران بعرض بصري واضح لا بسطر تقرير فقط.
class GoalItem {
  final String title;
  final int current;
  final int target;
  final bool unlocked;

  const GoalItem({
    required this.title,
    required this.current,
    required this.target,
    required this.unlocked,
  });

  double get progress =>
      target <= 0 ? 0 : (current / target).clamp(0.0, 1.0);
  bool get done => current >= target;
}

int weekBlock(int week) => (week - 1) ~/ 4;

List<GoalItem> weeklyChallenges({
  required int week,
  required int users,
  required int modelLevel,
  required int launchedCount,
}) {
  final block = weekBlock(week);
  return [
    GoalItem(
      title: 'تحدي الأسبوع: المستخدمون',
      current: users,
      target: 200 * (block + 1),
      unlocked: users >= 200 * (block + 1),
    ),
    GoalItem(
      title: 'تحدي الأسبوع: مستوى النموذج',
      current: modelLevel,
      target: (1 + block).clamp(1, 5),
      unlocked: modelLevel >= (1 + block).clamp(1, 5),
    ),
    GoalItem(
      title: 'تحدي الأسبوع: منتجات مطلقة',
      current: launchedCount,
      target: (block + 1).clamp(1, 8),
      unlocked: launchedCount >= (block + 1).clamp(1, 8),
    ),
  ];
}

List<GoalItem> monthlyChallenges({
  required int week,
  required int rank,
  required int reputation,
  required int completedResearchCount,
}) {
  final block = weekBlock(week);
  return [
    GoalItem(
      title: 'تحدي الشهر: بلغ ترتيبا متقدما',
      current: rank <= 0 ? 0 : (5 - rank).clamp(0, 4),
      target: 2,
      unlocked: rank <= 3 && rank > 0,
    ),
    GoalItem(
      title: 'تحدي الشهر: السمعة',
      current: reputation,
      target: 60,
      unlocked: reputation >= 60,
    ),
    GoalItem(
      title: 'تحدي الشهر: مشاريع بحث منجزة',
      current: completedResearchCount,
      target: (block + 1).clamp(1, 8),
      unlocked: completedResearchCount >= (block + 1).clamp(1, 8),
    ),
  ];
}

List<GoalItem> achievements({
  required int week,
  required int users,
  required int cash,
  required int modelLevel,
  required int launchedCount,
  required int completedResearchCount,
  required int completedModelCount,
  required int rank,
  required int reputation,
  required bool leadershipVictory,
}) {
  return [
    GoalItem(
        title: 'أول منتج مطلق',
        current: launchedCount,
        target: 1,
        unlocked: launchedCount >= 1),
    GoalItem(
        title: 'أول بحث منجز',
        current: completedResearchCount,
        target: 1,
        unlocked: completedResearchCount >= 1),
    GoalItem(
        title: 'أول وظيفة نموذج منجزة',
        current: completedModelCount,
        target: 1,
        unlocked: completedModelCount >= 1),
    GoalItem(
        title: 'ألف مستخدم',
        current: users,
        target: 1000,
        unlocked: users >= 1000),
    GoalItem(
        title: 'خمسة آلاف مستخدم',
        current: users,
        target: 5000,
        unlocked: users >= 5000),
    GoalItem(
        title: 'ضمن الثلاثة الأوائل',
        current: rank > 0 ? (4 - rank).clamp(0, 3) : 0,
        target: 1,
        unlocked: rank >= 1 && rank <= 3),
    GoalItem(
        title: 'عشرة أسابيع دون إفلاس',
        current: week,
        target: 10,
        unlocked: week >= 10),
    GoalItem(
        title: 'نقد ربع مليون',
        current: cash,
        target: 250000,
        unlocked: cash >= 250000),
    GoalItem(
        title: 'سمعة 80',
        current: reputation,
        target: 80,
        unlocked: reputation >= 80),
    GoalItem(
        title: 'نموذج مستوى 5',
        current: modelLevel,
        target: 5,
        unlocked: modelLevel >= 5),
    GoalItem(
        title: 'فوز الصدارة',
        current: leadershipVictory ? 1 : 0,
        target: 1,
        unlocked: leadershipVictory),
  ];
}

int levelPoints({
  required int modelLevel,
  required int launchedCount,
  required int completedResearchCount,
  required int completedModelCount,
}) =>
    modelLevel * 3 +
    launchedCount * 2 +
    completedResearchCount +
    completedModelCount;

int levelFromPoints(int points) => 1 + points ~/ 5;

double levelProgress(int points) => (points % 5) / 5;

/// لوحة الأهداف: مستوى وترتيب مرئي، وتحديات أسبوعية وشهرية،
/// وإنجازات، وشريط فوز/خسارة واضح عند تحقق أي منهما.
class GoalsPanel extends StatelessWidget {
  final int week;
  final int users;
  final int cash;
  final int modelLevel;
  final int launchedCount;
  final int completedResearchCount;
  final int completedModelCount;
  final int rank;
  final int reputation;
  final bool isBankrupt;
  final bool leadershipVictory;
  final int streakWeeks;

  const GoalsPanel({
    super.key,
    required this.week,
    required this.users,
    required this.cash,
    required this.modelLevel,
    required this.launchedCount,
    required this.completedResearchCount,
    required this.completedModelCount,
    required this.rank,
    required this.reputation,
    required this.isBankrupt,
    required this.leadershipVictory,
    required this.streakWeeks,
  });

  @override
  Widget build(BuildContext context) {
    final points = levelPoints(
      modelLevel: modelLevel,
      launchedCount: launchedCount,
      completedResearchCount: completedResearchCount,
      completedModelCount: completedModelCount,
    );
    final level = levelFromPoints(points);
    final weekly = weeklyChallenges(
        week: week,
        users: users,
        modelLevel: modelLevel,
        launchedCount: launchedCount);
    final monthly = monthlyChallenges(
        week: week,
        rank: rank,
        reputation: reputation,
        completedResearchCount: completedResearchCount);
    final all = achievements(
      week: week,
      users: users,
      cash: cash,
      modelLevel: modelLevel,
      launchedCount: launchedCount,
      completedResearchCount: completedResearchCount,
      completedModelCount: completedModelCount,
      rank: rank,
      reputation: reputation,
      leadershipVictory: leadershipVictory,
    );
    final unlockedCount = all.where((g) => g.unlocked).length;
    return Column(
      key: const Key('goals-panel'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (leadershipVictory)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green, width: 2),
            ),
            child: const Text(
              'لحظة فوز: أنت في الصدارة! بلغت الترتيب الأول أربعة أسابيع متتالية بإدارتك.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),
          ),
        if (isBankrupt)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red, width: 2),
            ),
            child: const Text(
              'لحظة خسارة: الشركة مفلسة. نفد النقد ونفد الائتمان — البقاء كان الشرط الأول.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red),
            ),
          ),
        if (leadershipVictory || isBankrupt) const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('مستواك: $level — الترتيب #$rank — سلسلة أسابيع: $streakWeeks',
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                AnimatedBar(
                  label: 'تقدمك نحو المستوى ${level + 1}',
                  fraction: levelProgress(points),
                  color: Colors.amber.shade700,
                ),
                Text('إنجازات مفتوحة: $unlockedCount من ${all.length}',
                    style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text('تحديات الأسبوع (تتجدد كل 4 أسابيع)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        for (final g in weekly) _GoalRow(goal: g),
        const SizedBox(height: 12),
        const Text('تحديات الشهر',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        for (final g in monthly) _GoalRow(goal: g),
        const SizedBox(height: 12),
        const Text('الإنجازات',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        for (final g in all) _GoalRow(goal: g),
      ],
    );
  }
}

class _GoalRow extends StatelessWidget {
  final GoalItem goal;

  const _GoalRow({required this.goal});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: goal.unlocked ? Colors.green.shade50 : null,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  goal.unlocked ? Icons.emoji_events : Icons.lock_outline,
                  color: goal.unlocked ? Colors.amber.shade800 : Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(goal.title,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold)),
                ),
                Text('${goal.current} / ${goal.target}',
                    style: const TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 4),
            AnimatedBar(
              label: goal.unlocked ? 'مكتمل' : 'التقدم',
              fraction: goal.progress,
              color: goal.unlocked ? Colors.green : Colors.teal,
            ),
          ],
        ),
      ),
    );
  }
}
