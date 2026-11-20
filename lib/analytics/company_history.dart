import '../management.dart';

/// لقطة أسبوعية لحفظ تطور الشركة عبر الزمن وعرض الرسوم البيانية.
class WeekSnapshot {
  final int week;
  final int cash;
  final int users;
  final int weeklyRevenue;
  final int weeklyCost;
  final int weeklyNet;
  final int modelLevel;
  final int rank;
  final int reputation;
  final int computeAvailable;

  const WeekSnapshot({
    required this.week,
    required this.cash,
    required this.users,
    required this.weeklyRevenue,
    required this.weeklyCost,
    required this.weeklyNet,
    required this.modelLevel,
    required this.rank,
    required this.reputation,
    required this.computeAvailable,
  });

  factory WeekSnapshot.fromState(ManagementState s) => WeekSnapshot(
        week: s.week,
        cash: s.cash,
        users: s.users,
        weeklyRevenue: s.weeklyRevenue,
        weeklyCost: s.weeklyCost,
        weeklyNet: s.weeklyNet,
        modelLevel: s.modelLevel,
        rank: s.rank,
        reputation: s.reputation,
        computeAvailable: s.computeAvailable,
      );

  Map<String, dynamic> toJson() => {
        'w': week,
        'c': cash,
        'u': users,
        'r': weeklyRevenue,
        'k': weeklyCost,
        'n': weeklyNet,
        'm': modelLevel,
        'rk': rank,
        'rep': reputation,
        'cmp': computeAvailable,
      };

  factory WeekSnapshot.fromJson(Map<String, dynamic> j) => WeekSnapshot(
        week: (j['w'] as num?)?.toInt() ?? 1,
        cash: (j['c'] as num?)?.toInt() ?? 0,
        users: (j['u'] as num?)?.toInt() ?? 0,
        weeklyRevenue: (j['r'] as num?)?.toInt() ?? 0,
        weeklyCost: (j['k'] as num?)?.toInt() ?? 0,
        weeklyNet: (j['n'] as num?)?.toInt() ?? 0,
        modelLevel: (j['m'] as num?)?.toInt() ?? 1,
        rank: (j['rk'] as num?)?.toInt() ?? 4,
        reputation: (j['rep'] as num?)?.toInt() ?? 50,
        computeAvailable: (j['cmp'] as num?)?.toInt() ?? 0,
      );
}

/// فروقات الأسبوع الأخير مقارنة بالأسبوع الذي سبقه.
class WeekDelta {
  final int cashDelta;
  final int usersDelta;
  final int reputationDelta;
  final int rankDelta; // موجب يعني تحسن الترتيب (مثلا من 4 إلى 2 => +2)
  final int modelDelta;

  const WeekDelta({
    required this.cashDelta,
    required this.usersDelta,
    required this.reputationDelta,
    required this.rankDelta,
    required this.modelDelta,
  });

  factory WeekDelta.between(WeekSnapshot prev, WeekSnapshot curr) => WeekDelta(
        cashDelta: curr.cash - prev.cash,
        usersDelta: curr.users - prev.users,
        reputationDelta: curr.reputation - prev.reputation,
        rankDelta: prev.rank - curr.rank,
        modelDelta: curr.modelLevel - prev.modelLevel,
      );
}
