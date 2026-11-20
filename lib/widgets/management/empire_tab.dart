import 'package:flutter/material.dart';

import '../../analytics/company_history.dart';
import '../../goals.dart';
import '../../interactive/progression_stages.dart';
import '../../management.dart';
import '../../theme/empire_theme.dart';
import 'charts_card.dart';
import 'market_share_card.dart';
import 'ui_components.dart';

/// محور الإمبراطورية الموحّد (الإصدار 3.0):
/// يجمع الأداء (الرسوم البيانية والصدارة)، المالية، الفريق، والأهداف/المفاهيم في تبويب واحد واضح.
class EmpireTab extends StatelessWidget {
  final String companyName;
  final ManagementState state;
  final ProgressionUnlock progression;
  final List<WeekSnapshot> history;
  final int streakWeeks;
  final int subIndex;
  final ValueChanged<int> onSubChanged;
  final VoidCallback onUnlockAll;
  final void Function(VoidCallback action) onMutate;

  const EmpireTab({
    super.key,
    required this.companyName,
    required this.state,
    required this.progression,
    required this.history,
    required this.streakWeeks,
    required this.subIndex,
    required this.onSubChanged,
    required this.onUnlockAll,
    required this.onMutate,
  });

  static const _subTabs = ['الأداء', 'المالية', 'الفريق', 'الأهداف'];

  @override
  Widget build(BuildContext context) {
    final locked = <int>{
      if (!progression.teamUnlocked) 2,
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EmpireSubTabBar(
            labels: _subTabs,
            selectedIndex: subIndex,
            onChanged: onSubChanged,
            lockedIndices: locked,
          ),
          if (subIndex == 0) _buildPerformance(),
          if (subIndex == 1) _buildFinance(),
          if (subIndex == 2)
            progression.teamUnlocked
                ? _buildTeam()
                : EmpireLockedPanel(
                    title: 'توظيف الفريق المتخصص',
                    unlockHint:
                        'يُفتح في المرحلة 3 (الأسبوع 4 أو مستوى نموذج 2) لتعيين الخبراء.',
                    onUnlockAll: onUnlockAll,
                  ),
          if (subIndex == 3) _buildGoals(),
        ],
      ),
    );
  }

  Widget _buildPerformance() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EmpireTrendChartCard(history: history),
        MarketLeaderboardCard(companyName: companyName, state: state),
      ],
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
          helpText:
              'الاقتراض يمنحك سيولة فورية مقابل فائدة 2% أسبوعياً، والسداد يخفض الفائدة. الرواتب تُخصم كل أسبوع.',
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
            EmpireMetricItem('إجمالي التكلفة', '${s.weeklyCost}'),
            EmpireMetricItem(
              'الائتمان المستخدم',
              '${s.creditUsed} / ${s.creditLimit}',
              accent: s.creditUsed > 0 ? EmpireColors.amber : null,
            ),
            EmpireMetricItem(
              'الفائدة الأسبوعية',
              '${s.creditInterest}',
              accent: s.creditInterest > 0 ? EmpireColors.coral : null,
            ),
          ],
        ),
        EmpireActionCard(
          title: 'إدارة خط الائتمان',
          footer: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: s.creditRemaining >= 10000
                      ? () => onMutate(s.takeLoan)
                      : null,
                  child: const Text('اقتراض 10000'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: (s.cash >= 5000 && s.creditUsed >= 5000)
                      ? () => onMutate(() => s.repayCredit(5000))
                      : null,
                  child: const Text('سداد 5000'),
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
          title: 'الفريق المتخصص',
          accent: EmpireColors.indigo,
          icon: Icons.badge_rounded,
          helpText:
              'كل دور يُعين مرة واحدة فقط بمكافأة دائمة وراتب أسبوعي مستمر.',
        ),
        EmpireMetricGrid(
          items: [
            EmpireMetricItem(
              'رواتب الفريق',
              '${s.staffSalaries}/أسبوع',
              accent: EmpireColors.amber,
            ),
            EmpireMetricItem(
              'مكافأة البحث',
              '+${s.researchBoost}',
              accent: EmpireColors.cyan,
            ),
            EmpireMetricItem(
              'مكافأة النمو',
              '+${s.userGrowthBoost}',
              accent: EmpireColors.sky,
            ),
          ],
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
                  'الراتب: ${def.salary}/أسبوع',
                  def.effect,
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

  Widget _buildGoals() {
    final s = state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const EmpireSectionHeader(
          title: 'الأهداف والإنجازات',
          accent: EmpireColors.gold,
          icon: Icons.emoji_events_rounded,
        ),
        GoalsPanel(
          week: s.week,
          users: s.users,
          cash: s.cash,
          modelLevel: s.modelLevel,
          launchedCount: s.launchedProducts.length,
          completedResearchCount: s.completedResearch.length,
          completedModelCount: s.completedModels.length,
          rank: s.rank,
          reputation: s.reputation,
          isBankrupt: s.isBankrupt,
          leadershipVictory: s.leadershipVictory,
          streakWeeks: streakWeeks,
        ),
      ],
    );
  }
}
