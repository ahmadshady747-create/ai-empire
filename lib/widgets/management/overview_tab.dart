import 'package:flutter/material.dart';

import '../../analytics/company_history.dart';
import '../../analytics/strategic_advisor.dart';
import '../../interactive/decision_cards.dart';
import '../../interactive/hq_pulses.dart';
import '../../interactive/progression_stages.dart';
import '../../interactive/rival_brands.dart';
import '../../live_scene.dart';
import '../../management.dart';
import '../../story/story_engine.dart';
import '../../theme/empire_theme.dart';
import '../../tutorial.dart';
import '../../world_events.dart';
import 'decision_card_widget.dart';
import 'delta_banner.dart';
import 'interactive_hq_bar.dart';
import 'live_ticker.dart';
import 'ui_components.dart';

/// شاشة المقر التفاعلية (الإصدار 4.0 Mega Edition):
/// تجمع شريط الأخبار الحية، القصة والدليل، اللعبة المصغرة لتدريب الشبكة العصبية،
/// نبضات المقر، بطاقة القرار العاجل، والمجسمات ثلاثية الأبعاد الأيزومترية.
class OverviewTab extends StatelessWidget {
  final String companyName;
  final ManagementState state;
  final ProgressionUnlock progression;
  final WeekReport? lastReport;
  final WeekDelta? lastDelta;
  final List<HqPulse> pulses;
  final Set<String> claimedPulseIds;
  final bool miniGameAvailable;
  final bool highVisualEffects;
  final int completedStoryCount;
  final DecisionCardModel? activeDecision;
  final int streakWeeks;
  final int tutorialStep;
  final bool eventSceneDismissed;
  final String? eventNote;
  final void Function(int navIndex, int subIndex) onJump;
  final VoidCallback onPlayMiniGame;
  final VoidCallback onOpenStoryJournal;
  final VoidCallback onOpenGuide;
  final void Function(HqPulse pulse) onClaimPulse;
  final void Function(DecisionOption option) onChooseDecision;
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
    required this.progression,
    required this.lastReport,
    required this.lastDelta,
    required this.pulses,
    required this.claimedPulseIds,
    required this.miniGameAvailable,
    required this.highVisualEffects,
    required this.completedStoryCount,
    required this.activeDecision,
    required this.streakWeeks,
    required this.tutorialStep,
    required this.eventSceneDismissed,
    required this.eventNote,
    required this.onJump,
    required this.onPlayMiniGame,
    required this.onOpenStoryJournal,
    required this.onOpenGuide,
    required this.onClaimPulse,
    required this.onChooseDecision,
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
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: EmpireColors.gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: EmpireColors.gold.withValues(alpha: 0.65),
          width: 1.4,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.school_rounded, color: EmpireColors.gold, size: 19),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tutorialStepTitle(tutorialStep),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: EmpireColors.gold,
                  ),
                ),
              ),
              TextButton(
                onPressed: onSkipAllTutorial,
                child: const Text('تخطي التعليم'),
              ),
            ],
          ),
          Text(
            tutorialStepHint(tutorialStep),
            style: const TextStyle(
              fontSize: 12.5,
              color: EmpireColors.textPrimary,
            ),
          ),
          if (tutorialStep == 1) ...[
            const SizedBox(height: 8),
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
              TextButton(
                onPressed: onSkipTutorialStep,
                child: const Text('تخطي هذه الخطوة'),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildTopAdvisorCard() {
    final adviceList = analyzeStrategy(state);
    if (adviceList.isEmpty) return const SizedBox.shrink();
    final top = adviceList.first;
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: top.color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: top.color.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(top.icon, color: top.color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الخطوة المقترحة: ${top.title}',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: top.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  top.detail,
                  style: const TextStyle(
                    fontSize: 12,
                    color: EmpireColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () => onJump(top.targetNavIndex, top.targetSubIndex),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              textStyle: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            child: Text(top.actionLabel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = state;
    final showWorldEvent = lastReport != null &&
        lastReport!.worldEvent.isNotEmpty &&
        !eventSceneDismissed;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LiveMarketTicker(lastReport: lastReport, week: s.week),
          Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: Row(
              children: [
                EmpireBadge(
                  text: 'المرحلة ${progression.stage}/4 • ${progression.stageName}',
                  color: EmpireColors.indigo,
                ),
                const Spacer(),
                InkWell(
                  onTap: onOpenStoryJournal,
                  borderRadius: BorderRadius.circular(14),
                  child: EmpireBadge(
                    text: 'القصة $completedStoryCount/${storyChapters.length}',
                    color: EmpireColors.gold,
                  ),
                ),
                const SizedBox(width: 6),
                InkWell(
                  onTap: onOpenGuide,
                  borderRadius: BorderRadius.circular(14),
                  child: const EmpireBadge(
                    text: 'الدليل',
                    color: EmpireColors.sky,
                  ),
                ),
              ],
            ),
          ),
          _buildTutorialBanner(),
          if (lastDelta != null) WeeklyDeltaBanner(delta: lastDelta!),
          if (showWorldEvent) ...[
            WorldEventScene(
              eventName: lastReport!.worldEvent,
              eventEffect: brandizeText(
                lastReport!.lines.firstWhere(
                  (l) => l.startsWith('حدث عالمي'),
                  orElse: () => 'حدث عالمي دوري (سيناريو محاكاة، لا تنبؤ).',
                ),
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
            const SizedBox(height: 10),
          ],
          if (!showWorldEvent && activeDecision != null)
            DecisionCardWidget(
              card: activeDecision!,
              onChoose: onChooseDecision,
            ),
          if (eventNote != null)
            EmpireInfoBox(
              text: brandizeText(eventNote!),
              accent: EmpireColors.cyan,
              icon: Icons.bolt_rounded,
            ),
          if (miniGameAvailable && !s.isBankrupt)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ElevatedButton.icon(
                onPressed: onPlayMiniGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: EmpireColors.indigo,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.sports_esports_rounded, color: EmpireColors.gold),
                label: const Text('العب تحدي الشبكة العصبية (10 ثوانٍ لتسريع النموذج ⚡)'),
              ),
            ),
          InteractiveHqBar(
            pulses: pulses,
            claimedIds: claimedPulseIds,
            onClaim: onClaimPulse,
          ),
          CompanyLiveScene(
            computeAvailable: s.computeAvailable,
            computeReserved: s.computeReserved,
            users: s.users,
            modelLevel: s.modelLevel,
            rivalNames: [
              for (final r in s.rivals) resolveRivalBrand(r.name).shortName,
            ],
            rivalLevels: [for (final r in s.rivals) r.modelLevel],
            reputation: s.reputation,
            isBankrupt: s.isBankrupt,
            leadershipVictory: s.leadershipVictory,
            highVisualEffects: highVisualEffects,
          ),
          _buildTopAdvisorCard(),
          if (lastReport != null && lastReport!.lines.isNotEmpty) ...[
            const SizedBox(height: 14),
            const EmpireSectionHeader(
              title: 'ملخص الأسبوع الأخير',
              accent: EmpireColors.indigo,
              icon: Icons.newspaper_rounded,
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: EmpireColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: EmpireColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final line in lastReport!.lines.take(4))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
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
                              brandizeText(line),
                              style: const TextStyle(
                                fontSize: 13,
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
        ],
      ),
    );
  }
}
