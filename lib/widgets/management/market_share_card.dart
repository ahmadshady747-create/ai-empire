import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../management.dart';
import '../../theme/empire_theme.dart';

/// لوحة ترتيب السوق ومقارنة قوة النماذج بين شركتك وجميع المنافسين.
class MarketLeaderboardCard extends StatelessWidget {
  final String companyName;
  final ManagementState state;

  const MarketLeaderboardCard({
    super.key,
    required this.companyName,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final entries = <({String name, int level, bool isPlayer, String tag})>[
      (
        name: companyName,
        level: state.modelLevel,
        isPlayer: true,
        tag: 'شركتك',
      ),
      for (final r in state.rivals)
        (
          name: r.name,
          level: r.modelLevel,
          isPlayer: false,
          tag: r.strategy,
        ),
    ];

    entries.sort((a, b) {
      final cmp = b.level.compareTo(a.level);
      if (cmp != 0) return cmp;
      if (a.isPlayer) return -1;
      if (b.isPlayer) return 1;
      return 0;
    });

    final maxLevel = math.max(
      1,
      entries.map((e) => e.level).reduce(math.max),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: EmpireColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: EmpireColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.leaderboard_rounded, color: EmpireColors.gold, size: 19),
              SizedBox(width: 8),
              Text(
                'ترتيب سباق النماذج العالمي',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: EmpireColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < entries.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _LeaderRow(
              position: i + 1,
              name: entries[i].name,
              level: entries[i].level,
              fraction: (entries[i].level / maxLevel).clamp(0.1, 1.0),
              isPlayer: entries[i].isPlayer,
              tag: entries[i].tag,
            ),
          ],
        ],
      ),
    );
  }
}

class _LeaderRow extends StatelessWidget {
  final int position;
  final String name;
  final int level;
  final double fraction;
  final bool isPlayer;
  final String tag;

  const _LeaderRow({
    required this.position,
    required this.name,
    required this.level,
    required this.fraction,
    required this.isPlayer,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    final accent = isPlayer
        ? EmpireColors.cyan
        : position == 1
            ? EmpireColors.gold
            : EmpireColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isPlayer
            ? EmpireColors.cyan.withValues(alpha: 0.1)
            : EmpireColors.surfaceElevated,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: isPlayer
              ? EmpireColors.cyan.withValues(alpha: 0.55)
              : EmpireColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                position == 1 ? '👑 #1' : '#$position',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: position == 1
                      ? EmpireColors.gold
                      : EmpireColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: isPlayer ? FontWeight.w800 : FontWeight.w600,
                    color: EmpireColors.textPrimary,
                  ),
                ),
              ),
              Text(
                'مستوى $level',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: fraction,
              color: accent,
              backgroundColor: EmpireColors.bg,
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }
}
