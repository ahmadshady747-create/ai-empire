import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../interactive/rival_brands.dart';
import '../../management.dart';
import '../../theme/empire_theme.dart';

/// لوحة ترتيب السوق ومقارنة قوة النماذج بأسماء وشعارات الشركات شبه الحقيقية.
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
    final entries = <({
      String name,
      int level,
      bool isPlayer,
      String sub,
      IconData icon,
      Color color,
    })>[
      (
        name: companyName,
        level: state.modelLevel,
        isPlayer: true,
        sub: 'شركتك',
        icon: Icons.hub_rounded,
        color: EmpireColors.cyan,
      ),
      for (final r in state.rivals)
        (() {
          final b = resolveRivalBrand(r.name);
          return (
            name: b.shortName,
            level: r.modelLevel,
            isPlayer: false,
            sub: '${b.headquarters} • ${r.strategy}',
            icon: b.icon,
            color: b.color,
          );
        })(),
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
        borderRadius: BorderRadius.circular(18),
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
                'ترتيب سباق الذكاء العالمي',
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
              sub: entries[i].sub,
              level: entries[i].level,
              fraction: (entries[i].level / maxLevel).clamp(0.12, 1.0),
              isPlayer: entries[i].isPlayer,
              icon: entries[i].icon,
              color: entries[i].color,
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
  final String sub;
  final int level;
  final double fraction;
  final bool isPlayer;
  final IconData icon;
  final Color color;

  const _LeaderRow({
    required this.position,
    required this.name,
    required this.sub,
    required this.level,
    required this.fraction,
    required this.isPlayer,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isPlayer
            ? EmpireColors.cyan.withValues(alpha: 0.11)
            : EmpireColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPlayer
              ? EmpireColors.cyan.withValues(alpha: 0.6)
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
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: position == 1
                      ? EmpireColors.gold
                      : EmpireColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Icon(icon, size: 17, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: isPlayer ? FontWeight.w800 : FontWeight.w700,
                        color: EmpireColors.textPrimary,
                      ),
                    ),
                    Text(
                      sub,
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: EmpireColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'مستوى $level',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: fraction,
              color: color,
              backgroundColor: EmpireColors.bg,
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }
}
