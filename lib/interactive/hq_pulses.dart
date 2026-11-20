import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../management.dart';
import '../theme/empire_theme.dart';

/// فرص وأحداث لمس سريعة تظهر داخل المقر التفاعلي كل أسبوع
/// ليحصل اللاعب على تفاعل فوري ومكافآت ملموسة بين الأسابيع.
class HqPulse {
  final String id;
  final String title;
  final String rewardLabel;
  final IconData icon;
  final Color color;
  final void Function(ManagementState state) apply;

  const HqPulse({
    required this.id,
    required this.title,
    required this.rewardLabel,
    required this.icon,
    required this.color,
    required this.apply,
  });
}

List<HqPulse> generateWeeklyPulses(int week, ManagementState state) {
  final pool = <HqPulse>[
    HqPulse(
      id: 'cool_server_$week',
      title: 'تبريد خادم ساخن',
      rewardLabel: '+5 تدريب',
      icon: Icons.ac_unit_rounded,
      color: EmpireColors.cyan,
      apply: (s) {
        s.trainingProgress = (s.trainingProgress + 5).clamp(0, 100);
      },
    ),
    HqPulse(
      id: 'data_packet_$week',
      title: 'التقاط حزمة بيانات',
      rewardLabel: '+4 حداثة، +2 جودة',
      icon: Icons.bolt_rounded,
      color: EmpireColors.sky,
      apply: (s) {
        s.dataFreshness = (s.dataFreshness + 4).clamp(0, 100);
        s.dataQuality = (s.dataQuality + 2).clamp(0, 100);
      },
    ),
    HqPulse(
      id: 'viral_clip_$week',
      title: 'موجة ترند سريعة',
      rewardLabel: '+45 مستخدم، +1 سمعة',
      icon: Icons.trending_up_rounded,
      color: EmpireColors.emerald,
      apply: (s) {
        s.users += 45;
        s.reputation = (s.reputation + 1).clamp(0, 100);
      },
    ),
    HqPulse(
      id: 'micro_deal_$week',
      title: 'استشارة تقنية خاطفة',
      rewardLabel: '+3500 نقد',
      icon: Icons.payments_rounded,
      color: EmpireColors.gold,
      apply: (s) {
        s.cash += 3500;
      },
    ),
    HqPulse(
      id: 'research_spark_$week',
      title: 'فكرة بحثية لامعة',
      rewardLabel: '+6 بحث',
      icon: Icons.auto_fix_high_rounded,
      color: EmpireColors.indigo,
      apply: (s) {
        s.researchProgress = (s.researchProgress + 6).clamp(0, 100);
      },
    ),
  ];

  // اختيار نبضتين متجددتين كل أسبوع بشكل حتمي متوازن
  final rnd = math.Random(week * 31 + state.modelLevel * 7);
  final firstIdx = rnd.nextInt(pool.length);
  final secondIdx = (firstIdx + 1 + rnd.nextInt(pool.length - 1)) % pool.length;
  return [pool[firstIdx], pool[secondIdx]];
}
