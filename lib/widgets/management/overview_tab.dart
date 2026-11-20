import 'package:flutter/material.dart';

import '../../analytics/company_history.dart';
import '../../analytics/strategic_advisor.dart';
import '../../live_scene.dart';
import '../../management.dart';
import '../../theme/empire_theme.dart';
import '../../tutorial.dart';
import '../../world_events.dart';
import 'charts_card.dart';
import 'delta_banner.dart';
import 'market_share_card.dart';
import 'ui_components.dart';

/// محور القيادة (نظرة عامة):
/// يجمع التعليم التفاعلي، الفروقات الأسبوعية، المستشار الاستراتيجي،
/// حدث العالم، المشهد الحي، الرسم البياني التاريخي، ترتيب السوق، ونشرة الأخبار.
class OverviewTab extends StatelessWidget {
  final String companyName;
  final ManagementState state;
  final WeekReport? lastReport;
  final WeekDelta? lastDelta;
  final List<WeekSnapshot> history;
  final int streakWeeks;
  final int tutorialStep;
  final bool eventSceneDismissed;
  final String? eventNote;
  final void Function(int navIndex, int subIndex) onJump;
  final VoidCallback onBuyTutorialData;
  final VoidCallback onStartTutorialResearch;
  final VoidCallback onSkipTutorialStep;
  final VoidCallback onSkipAllTutorial;
  final VoidCallback onEventBuyCompute;
  final VoidCallback onEventStartResearch;
  final VoidCallback onEventSaveCash;

  const OverviewTab({
    super.key,
    required this.companyName,
    required this.state,
    required this.lastReport,
    required this.lastDelta,
    required this.history,
    required this.streakWeeks,
    required this.tutorialStep,
    required this.eventSceneDismissed,
    required this.eventNote,
    required this.onJump,
    required this.onBuyTutorialData,
    required this.onStartTutorialResearch,
    required this.onSkipTutorialStep,
    required this.onSkipAllTutorial,
    required this.onEventBuyCompute,
    required this.onEventStartResearch,
    required this.onEventSaveCash,
  });

  Widget _buildTutorialBanner() {
    if (tutorialStep >= 3) return const SizedBox.shrink();
    final s = state;
    final affordableData = ManagementState.dataCatalog
        .where((d) => s.cash >= d.cost)
        .toList();
    final affordableResearch = ManagementState.researchCatalog
        .where(
          (d) =>
              s.activeResearch == null &&
              !s.completedResearch.contains(d.id) &&
              s.cash >= d.cost,
        )
        .toList();

    return Container(
      key: const Key('tutorial-banner'),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: EmpireColors.gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: EmpireColors.gold.withValues(alpha: 0.65),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.school_rounded, color: EmpireColors.gold, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tutorialStepTitle(tutorialStep),
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: EmpireColors.gold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            tutorialStepHint(tutorialStep),
            style: const TextStyle(
              fontSize: 13,
              color: EmpireColors.textPrimary,
            ),
          ),
          if (tutorialStep == 1) ...[
            const SizedBox(height: 10),
            if (affordableData.isNotEmpty)
              OutlinedButton(
                onPressed: onBuyTutorialData,
                child: Text(
                  'اشترِ مجموعة بيانات (${affordableData.first.name} — ${affordableData.first.cost})',
                ),
              ),
            if (affordableResearch.isNotEmpty) ...[
              const SizedBox(height: 6),
              OutlinedButton(
                onPressed: onStartTutorialResearch,
                child: Text(
                  'ابدأ مشروع بحث (${affordableResearch.first.name} — ${affordableResearch.first.cost})',
                ),
              ),
            ],
            if (affordableData.isEmpty && affordableResearch.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'نقدك لا يكفي لأي إجراء الآن — اضغط «تخطي هذه الخطوة» ثم تقدم أسبوعا لتجمع إيرادا.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: EmpireColors.textSecondary,
                  ),
                ),
              ),
            TextButton(
              onPressed: onSkipTutorialStep,
              child: const Text('تخطي هذه الخطوة'),
            ),
          ],
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: onSkipAllTutorial,
              child: const Text('تخطي التعليم'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvisorSection() {
    final adviceList = analyzeStrategy(state);
    if (adviceList.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const EmpireSectionHeader(
          title: 'المستشار الاستراتيجي',
          accent: EmpireColors.gold,
          icon: Icons.tips_and_updates_rounded,
        ),
        for (final item in adviceList)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: item.color.withValues(alpha: 0.45)),
            ),
            child: Row(
              children: [
                Icon(item.icon, color: item.color, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: item.color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.detail,
                        style: const TextStyle(
                          fontSize: 12,
                          color: EmpireColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () =>
                      onJump(item.targetNavIndex, item.targetSubIndex),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    minimumSize: Size.zero,
                  ),
                  child: Text(item.actionLabel),
                ),
              ],
            ),
          ),
        const SizedBox(height: 6),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = state;
    final showWorldEvent = lastReport != null &&
        lastReport!.worldEvent.isNotEmpty &&
        !eventSceneDismissed;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTutorialBanner(),
          if (lastDelta != null) WeeklyDeltaBanner(delta: lastDelta!),
          if (showWorldEvent) ...[
            WorldEventScene(
              eventName: lastReport!.worldEvent,
              eventEffect: lastReport!.lines.firstWhere(
                (l) => l.startsWith('حدث عالمي'),
                orElse: () => 'حدث عالمي دوري (سيناريو محاكاة، لا تنبؤ).',
              ),
              streakWeeks: streakWeeks,
              canBuyCompute: s.cash >= 4000 && s.computeAvailable < 200,
              canStartResearch: s.activeResearch == null &&
                  ManagementState.researchCatalog.any(
                    (d) =>
                        !s.completedResearch.contains(d.id) &&
                        s.cash >= d.cost,
                  ),
              onBuyCompute: onEventBuyCompute,
              onStartResearch: onEventStartResearch,
              onSaveCash: onEventSaveCash,
            ),
            const SizedBox(height: 12),
          ],
          if (eventNote != null)
            EmpireInfoBox(
              text: eventNote!,
              accent: EmpireColors.cyan,
              icon: Icons.bolt_rounded,
            ),
          CompanyLiveScene(
            computeAvailable: s.computeAvailable,
            computeReserved: s.computeReserved,
            users: s.users,
            modelLevel: s.modelLevel,
            rivalNames: [for (final r in s.rivals) r.name],
            rivalLevels: [for (final r in s.rivals) r.modelLevel],
            reputation: s.reputation,
            isBankrupt: s.isBankrupt,
            leadershipVictory: s.leadershipVictory,
          ),
          const SizedBox(height: 14),
          _buildAdvisorSection(),
          EmpireTrendChartCard(history: history),
          MarketLeaderboardCard(companyName: companyName, state: s),
          const EmpireSectionHeader(
            title: 'نبض الشركة الأسبوعي',
            accent: EmpireColors.cyan,
            icon: Icons.analytics_rounded,
          ),
          EmpireMetricGrid(
            items: [
              EmpireMetricItem(
                'السمعة',
                '${s.reputation} / 100',
                accent: EmpireColors.sky,
              ),
              EmpireMetricItem(
                'أسابيع الصدارة المتتالية',
                '${s.leadershipWeeks}',
                accent: EmpireColors.gold,
              ),
              EmpireMetricItem(
                'الإيراد الأسبوعي',
                '${s.weeklyRevenue}',
                accent: EmpireColors.emerald,
              ),
              EmpireMetricItem(
                'التكلفة الأسبوعية',
                '${s.weeklyCost}',
                accent: EmpireColors.amber,
              ),
              EmpireMetricItem(
                'صافي الأسبوع',
                '${s.weeklyNet}',
                accent: s.weeklyNet >= 0
                    ? EmpireColors.emerald
                    : EmpireColors.coral,
              ),
            ],
          ),
          if (s.lastWorldEvent.isNotEmpty)
            EmpireInfoBox(
              text:
                  'آخر حدث عالمي: ${s.lastWorldEvent} — سيناريو محاكاة مستوحى من اتجاهات عامة، ليس بيانات رسمية ولا تنبؤات.',
              accent: EmpireColors.sky,
              icon: Icons.public_rounded,
            ),
          const EmpireSectionHeader(
            title: 'أخبار الأسبوع الأخير',
            accent: EmpireColors.indigo,
            icon: Icons.newspaper_rounded,
          ),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: EmpireColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: EmpireColors.border),
            ),
            child: lastReport == null
                ? const Text(
                    'لم يمر أسبوع بعد. اضغط "تقدم أسبوعا" لترى أول تقرير.',
                    style: TextStyle(color: EmpireColors.textSecondary),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final line in lastReport!.lines)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 6),
                                child: Icon(
                                  Icons.circle,
                                  size: 6,
                                  color: EmpireColors.cyan,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  line,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    color: EmpireColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
