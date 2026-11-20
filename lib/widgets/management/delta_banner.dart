import 'package:flutter/material.dart';

import '../../analytics/company_history.dart';
import '../../theme/empire_theme.dart';

/// شريط الفروقات الأسبوعية: يوضح فوراً ما ربحه أو خسره اللاعب في آخر أسبوع.
class WeeklyDeltaBanner extends StatelessWidget {
  final WeekDelta delta;

  const WeeklyDeltaBanner({super.key, required this.delta});

  String _signed(int v) => v > 0 ? '+$v' : '$v';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: EmpireColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: EmpireColors.border),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        alignment: WrapAlignment.spaceEvenly,
        children: [
          _DeltaPill(
            label: 'النقد',
            value: _signed(delta.cashDelta),
            color: delta.cashDelta >= 0
                ? EmpireColors.emerald
                : EmpireColors.coral,
          ),
          _DeltaPill(
            label: 'المستخدمون',
            value: _signed(delta.usersDelta),
            color: delta.usersDelta >= 0
                ? EmpireColors.sky
                : EmpireColors.coral,
          ),
          if (delta.reputationDelta != 0)
            _DeltaPill(
              label: 'السمعة',
              value: _signed(delta.reputationDelta),
              color: delta.reputationDelta > 0
                  ? EmpireColors.gold
                  : EmpireColors.amber,
            ),
          if (delta.rankDelta != 0)
            _DeltaPill(
              label: 'الترتيب',
              value: delta.rankDelta > 0
                  ? '▲ ${delta.rankDelta}'
                  : '▼ ${delta.rankDelta.abs()}',
              color: delta.rankDelta > 0
                  ? EmpireColors.emerald
                  : EmpireColors.coral,
            ),
          if (delta.modelDelta > 0)
            _DeltaPill(
              label: 'النموذج',
              value: '★ +${delta.modelDelta}',
              color: EmpireColors.indigo,
            ),
        ],
      ),
    );
  }
}

class _DeltaPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _DeltaPill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 11.5,
              color: EmpireColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
