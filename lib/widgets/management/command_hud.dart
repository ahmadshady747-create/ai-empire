import 'package:flutter/material.dart';

import '../../game_feel.dart';
import '../../management.dart';
import '../../theme/empire_theme.dart';

/// شريط الموارد العلوي النحيف (Elite Slim HUD):
/// يعرض أهم مؤشرات الشركة في مساحة مضغوطة وأنيقة تترك 80% من الشاشة للعب.
class CommandHud extends StatelessWidget {
  final ManagementState state;
  final String? saveStatus;
  final void Function(int navIndex, int subIndex) onJump;

  const CommandHud({
    super.key,
    required this.state,
    required this.saveStatus,
    required this.onJump,
  });

  @override
  Widget build(BuildContext context) {
    final s = state;
    final runway =
        s.runwayWeeks >= 999 ? 'مستدام' : '${s.runwayWeeks} أسبوع';

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 2, 12, 6),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: EmpireColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: s.isBankrupt
              ? EmpireColors.coral
              : s.leadershipVictory
                  ? EmpireColors.emerald
                  : EmpireColors.border,
          width: (s.isBankrupt || s.leadershipVictory) ? 1.4 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _Pill(
                icon: Icons.calendar_today_rounded,
                color: EmpireColors.cyan,
                child: AnimatedCountText(
                  prefix: 'الأسبوع ',
                  value: s.week,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: EmpireColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: () => onJump(2, 2),
                borderRadius: BorderRadius.circular(10),
                child: _Pill(
                  icon: Icons.workspace_premium_rounded,
                  color: EmpireColors.gold,
                  child: AnimatedCountText(
                    prefix: 'الترتيب #',
                    value: s.rank,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: EmpireColors.gold,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () => onJump(3, 1),
                borderRadius: BorderRadius.circular(10),
                child: Text(
                  'المدى: $runway',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: s.runwayWeeks < 4
                        ? EmpireColors.coral
                        : EmpireColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  icon: Icons.account_balance_wallet_rounded,
                  color: s.cash < 15000
                      ? EmpireColors.coral
                      : EmpireColors.emerald,
                  onTap: () => onJump(3, 1),
                  child: AnimatedCountText(
                    prefix: 'النقد: ',
                    value: s.cash,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: s.cash < 15000
                          ? EmpireColors.coral
                          : EmpireColors.emerald,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _MiniStat(
                  icon: Icons.auto_awesome_rounded,
                  color: EmpireColors.indigo,
                  onTap: () => onJump(1, 0),
                  child: AnimatedCountText(
                    prefix: 'النموذج: مستوى ',
                    value: s.modelLevel,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: EmpireColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _MiniStat(
                  icon: Icons.people_alt_rounded,
                  color: EmpireColors.sky,
                  onTap: () => onJump(2, 0),
                  child: AnimatedCountText(
                    prefix: 'المستخدمون: ',
                    value: s.users,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: EmpireColors.sky,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: AnimatedBar(
                  label: 'تقدم التدريب',
                  fraction: s.trainingProgress / 100,
                  color: EmpireColors.cyan,
                  compact: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AnimatedBar(
                  label: 'تقدم البحث',
                  fraction: s.researchProgress / 100,
                  color: EmpireColors.indigo,
                  compact: true,
                ),
              ),
            ],
          ),
          if (saveStatus != null)
            Text(
              saveStatus!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: EmpireColors.emerald,
              ),
            ),
          if (s.isBankrupt)
            const Padding(
              padding: EdgeInsets.only(top: 3),
              child: Text(
                'الشركة مفلسة: نفد النقد ونفد الائتمان. البقاء كان الشرط الأول.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: EmpireColors.coral,
                ),
              ),
            ),
          if (s.leadershipVictory)
            const Padding(
              padding: EdgeInsets.only(top: 3),
              child: Text(
                'فوز بالصدارة: بلغت الترتيب الأول أربعة أسابيع متتالية بإدارتك.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: EmpireColors.emerald,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Widget child;

  const _Pill({
    required this.icon,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          child,
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final Widget child;

  const _MiniStat({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
        decoration: BoxDecoration(
          color: EmpireColors.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: EmpireColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
