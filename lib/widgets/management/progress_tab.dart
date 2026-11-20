import 'package:flutter/material.dart';

import '../../goals.dart';
import '../../management.dart';
import '../../theme/empire_theme.dart';
import 'ui_components.dart';

/// محور الإنجاز: يضم لوحة الأهداف والمكافآت ومكتبة المفاهيم.
class ProgressTab extends StatefulWidget {
  final ManagementState state;
  final int streakWeeks;

  const ProgressTab({
    super.key,
    required this.state,
    required this.streakWeeks,
  });

  @override
  State<ProgressTab> createState() => _ProgressTabState();
}

class _ProgressTabState extends State<ProgressTab> {
  int _subIndex = 0;

  static const _subTabs = ['الأهداف والمكافآت', 'مكتبة المفاهيم'];

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EmpireSubTabBar(
            labels: _subTabs,
            selectedIndex: _subIndex,
            onChanged: (i) => setState(() => _subIndex = i),
          ),
          if (_subIndex == 0) ...[
            const EmpireSectionHeader(
              title: 'الأهداف والمكافآت',
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
              streakWeeks: widget.streakWeeks,
            ),
          ] else ...[
            const EmpireSectionHeader(
              title: 'مكتبة المفاهيم',
              accent: EmpireColors.sky,
              icon: Icons.menu_book_rounded,
            ),
            const EmpireInfoBox(
              text:
                  'شرح عربي واضح لكل نظام إداري: ما يفعله، وما ثمنه في الأنظمة الأخرى، ولماذا لا توجد استراتيجية واحدة تفوز دائما.',
              accent: EmpireColors.sky,
            ),
            for (final concept in managementConcepts)
              EmpireActionCard(
                title: concept.title,
                description: concept.body,
              ),
          ],
        ],
      ),
    );
  }
}
