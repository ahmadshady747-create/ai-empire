import 'package:flutter/material.dart';

import '../../management.dart';
import '../../theme/empire_theme.dart';
import 'ui_components.dart';

/// محور الشركة: يضم المالية والائتمان والفريق المتخصص مع تحكم مباشر بالتبويب الفرعي.
class CompanyTab extends StatelessWidget {
  final ManagementState state;
  final int subIndex;
  final ValueChanged<int> onSubChanged;
  final void Function(VoidCallback action) onMutate;

  const CompanyTab({
    super.key,
    required this.state,
    required this.subIndex,
    required this.onSubChanged,
    required this.onMutate,
  });

  static const _subTabs = ['المالية والائتمان', 'الفريق'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EmpireSubTabBar(
            labels: _subTabs,
            selectedIndex: subIndex,
            onChanged: onSubChanged,
          ),
          if (subIndex == 0) _buildFinance(),
          if (subIndex == 1) _buildTeam(),
        ],
      ),
    );
  }

  Widget _buildFinance() {
    final s = state;
    final runway =
        s.runwayWeeks >= 999 ? 'مستدام' : '${s.runwayWeeks} أسبوع';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const EmpireSectionHeader(
          title: 'المالية والائتمان',
          accent: EmpireColors.emerald,
          icon: Icons.account_balance_rounded,
        ),
        EmpireMetricGrid(
          items: [
            EmpireMetricItem(
              'النقد',
              '${s.cash}',
              accent: s.cash < 15000
                  ? EmpireColors.coral
                  : EmpireColors.emerald,
            ),
            EmpireMetricItem('المدى النقدي', runway),
            EmpireMetricItem(
              'إيراد الأسبوع',
              '${s.weeklyRevenue}',
              accent: EmpireColors.emerald,
            ),
            EmpireMetricItem('رواتب الأسبوع', '${s.weeklySalaries}'),
            EmpireMetricItem('رواتب الفريق المتخصص', '${s.staffSalaries}'),
            EmpireMetricItem('تكلفة الاستدلال', '${s.weeklyInferenceCost}'),
            EmpireMetricItem(
              'الائتمان المستخدم',
              '${s.creditUsed}',
              accent: s.creditUsed > 0 ? EmpireColors.amber : null,
            ),
            EmpireMetricItem('الائتمان المتبقي', '${s.creditRemaining}'),
            EmpireMetricItem(
              'فائدة الائتمان الأسبوعية',
              '${s.creditInterest}',
              accent: s.creditInterest > 0 ? EmpireColors.coral : null,
            ),
          ],
        ),
        const EmpireInfoBox(
          text:
              'الاقتراض يسحب من الائتمان إلى النقد الآن لكنه يرفع الفائدة 2% أسبوعيا على المستخدم؛ والسداد يخفضها. رواتب فريقك المتخصص تُخصم كل أسبوع مع الرواتب.',
          accent: EmpireColors.emerald,
        ),
        EmpireActionCard(
          title: 'إدارة خط الائتمان',
          description: 'توازن بين السيولة الفورية وتكلفة الفائدة الأسبوعية.',
          footer: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: s.creditRemaining >= 10000
                      ? () => onMutate(s.takeLoan)
                      : null,
                  child: const Text('اقتراض 10000 من الائتمان'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: (s.cash >= 5000 && s.creditUsed >= 5000)
                      ? () => onMutate(() => s.repayCredit(5000))
                      : null,
                  child: const Text('سداد 5000 من الائتمان'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTeam() {
    final s = state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const EmpireSectionHeader(
          title: 'الفريق — توظيف متخصصين',
          accent: EmpireColors.indigo,
          icon: Icons.badge_rounded,
        ),
        EmpireMetricGrid(
          items: [
            EmpireMetricItem(
              'رواتب الفريق الأسبوعية',
              '${s.staffSalaries}',
              accent: EmpireColors.amber,
            ),
            EmpireMetricItem(
              'مكافأة البحث الدائمة',
              '+${s.researchBoost}',
              accent: EmpireColors.cyan,
            ),
            EmpireMetricItem(
              'مكافأة نمو المستخدمين',
              '+${s.userGrowthBoost}',
              accent: EmpireColors.sky,
            ),
          ],
        ),
        const EmpireInfoBox(
          text:
              'كل دور يُعين مرة واحدة فقط: الثمن يُدفع مقدما والتأثير دائم، لكن الراتب يُخصم كل أسبوع بعد التعيين.',
          accent: EmpireColors.indigo,
        ),
        for (final def in ManagementState.staffCatalog)
          Builder(
            builder: (_) {
              final hired = s.hiredStaff.contains(def.id);
              final canAfford = s.cash >= def.cost;
              return EmpireActionCard(
                title: def.name,
                description: def.description,
                stats: [
                  'التعيين: ${def.cost}',
                  'راتب أسبوعي: ${def.salary}',
                  'الأثر: ${def.effect}',
                ],
                badgeText: hired ? 'معيّن ✓' : null,
                badgeColor: hired ? EmpireColors.emerald : null,
                footer: !hired
                    ? OutlinedButton(
                        onPressed: canAfford
                            ? () => onMutate(() => s.hireStaff(def.id))
                            : null,
                        child: Text(canAfford ? 'تعيين' : 'نقد غير كاف'),
                      )
                    : null,
              );
            },
          ),
      ],
    );
  }
}
