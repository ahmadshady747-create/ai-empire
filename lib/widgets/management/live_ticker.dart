import 'package:flutter/material.dart';

import '../../interactive/rival_brands.dart';
import '../../management.dart';
import '../../theme/empire_theme.dart';

/// شريط الأخبار الحية (Live Market Ticker) في أعلى شاشة المقر.
class LiveMarketTicker extends StatelessWidget {
  final WeekReport? lastReport;
  final int week;

  const LiveMarketTicker({
    super.key,
    required this.lastReport,
    required this.week,
  });

  @override
  Widget build(BuildContext context) {
    final headline = lastReport != null && lastReport!.lines.isNotEmpty
        ? brandizeText(lastReport!.lines.first)
        : 'موجز السوق (الأسبوع $week): OpenMind وAnthroCore وDeepVortex تستعد للسباق — ابدأ أولى خطواتك!';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: EmpireColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: EmpireColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: EmpireColors.coral.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'مباشر',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
                color: EmpireColors.coral,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              headline,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: EmpireColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
