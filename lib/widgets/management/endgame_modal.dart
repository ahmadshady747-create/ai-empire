import 'package:flutter/material.dart';

import '../../analytics/company_history.dart';
import '../../goals.dart';
import '../../management.dart';
import '../../theme/empire_theme.dart';

/// نافذة ملخص نهاية الجولة عند بلوغ الفوز بالصدارة أو الإفلاس.
Future<void> showEndgameSummaryDialog({
  required BuildContext context,
  required String companyName,
  required ManagementState state,
  required List<WeekSnapshot> history,
  required VoidCallback onStartNew,
}) {
  final isWin = state.leadershipVictory && !state.isBankrupt;
  final accent = isWin ? EmpireColors.emerald : EmpireColors.coral;
  final peakCash = history.isEmpty
      ? state.cash
      : history.map((h) => h.cash).reduce((a, b) => a > b ? a : b);
  final unlockedAchievements = achievements(
    week: state.week,
    users: state.users,
    cash: state.cash,
    modelLevel: state.modelLevel,
    launchedCount: state.launchedProducts.length,
    completedResearchCount: state.completedResearch.length,
    completedModelCount: state.completedModels.length,
    rank: state.rank,
    reputation: state.reputation,
    leadershipVictory: state.leadershipVictory,
  ).where((a) => a.unlocked).length;

  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: EmpireColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: accent, width: 1.6),
      ),
      title: Row(
        children: [
          Icon(
            isWin ? Icons.emoji_events_rounded : Icons.trending_down_rounded,
            color: accent,
            size: 28,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isWin ? 'انتصار الإمبراطورية!' : 'نهاية الجولة — إفلاس',
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isWin
                ? 'نجحت "$companyName" في تصدر سباق الذكاء الاصطناعي أربعة أسابيع متتالية!'
                : 'استنفدت "$companyName" كامل النقد والائتمان المتاح في الأسبوع ${state.week}.',
            style: const TextStyle(
              fontSize: 13.5,
              color: EmpireColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          _SummaryRow('الأسابيع المنجزة', '${state.week}'),
          _SummaryRow('الترتيب النهائي', '#${state.rank}'),
          _SummaryRow('مستوى النموذج', '${state.modelLevel}'),
          _SummaryRow('المستخدمون', '${state.users}'),
          _SummaryRow('أعلى نقد بلغته', '$peakCash'),
          _SummaryRow('الإنجازات المفتوحة', '$unlockedAchievements / 11'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('متابعة المعاينة'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(dialogContext).pop();
            onStartNew();
          },
          child: const Text('إمبراطورية جديدة'),
        ),
      ],
    ),
  );
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: EmpireColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: EmpireColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
