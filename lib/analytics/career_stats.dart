import '../management.dart';

/// إحصائيات مسيرة اللاعب الدائمة عبر جميع الجولات (تبقى محفوظة حتى بعد بدء شركة جديدة).
class CareerStats {
  final int runsPlayed;
  final int victories;
  final int bankruptcies;
  final int bestRank;
  final int highestCash;
  final int highestUsers;
  final int highestModelLevel;
  final int longestRunWeeks;

  const CareerStats({
    this.runsPlayed = 1,
    this.victories = 0,
    this.bankruptcies = 0,
    this.bestRank = 4,
    this.highestCash = 150000,
    this.highestUsers = 0,
    this.highestModelLevel = 1,
    this.longestRunWeeks = 1,
  });

  CareerStats recordProgress(ManagementState s) => CareerStats(
        runsPlayed: runsPlayed,
        victories: victories,
        bankruptcies: bankruptcies,
        bestRank: s.rank > 0 && s.rank < bestRank ? s.rank : bestRank,
        highestCash: s.cash > highestCash ? s.cash : highestCash,
        highestUsers: s.users > highestUsers ? s.users : highestUsers,
        highestModelLevel:
            s.modelLevel > highestModelLevel ? s.modelLevel : highestModelLevel,
        longestRunWeeks: s.week > longestRunWeeks ? s.week : longestRunWeeks,
      );

  CareerStats recordOutcome({required bool victory, required bool bankrupt}) =>
      CareerStats(
        runsPlayed: runsPlayed,
        victories: victory ? victories + 1 : victories,
        bankruptcies: bankrupt ? bankruptcies + 1 : bankruptcies,
        bestRank: bestRank,
        highestCash: highestCash,
        highestUsers: highestUsers,
        highestModelLevel: highestModelLevel,
        longestRunWeeks: longestRunWeeks,
      );

  CareerStats recordNewRun() => CareerStats(
        runsPlayed: runsPlayed + 1,
        victories: victories,
        bankruptcies: bankruptcies,
        bestRank: bestRank,
        highestCash: highestCash,
        highestUsers: highestUsers,
        highestModelLevel: highestModelLevel,
        longestRunWeeks: longestRunWeeks,
      );

  Map<String, dynamic> toJson() => {
        'runs': runsPlayed,
        'wins': victories,
        'loss': bankruptcies,
        'bestRank': bestRank,
        'maxCash': highestCash,
        'maxUsers': highestUsers,
        'maxModel': highestModelLevel,
        'maxWeeks': longestRunWeeks,
      };

  factory CareerStats.fromJson(Map<String, dynamic> j) => CareerStats(
        runsPlayed: (j['runs'] as num?)?.toInt() ?? 1,
        victories: (j['wins'] as num?)?.toInt() ?? 0,
        bankruptcies: (j['loss'] as num?)?.toInt() ?? 0,
        bestRank: (j['bestRank'] as num?)?.toInt() ?? 4,
        highestCash: (j['maxCash'] as num?)?.toInt() ?? 150000,
        highestUsers: (j['maxUsers'] as num?)?.toInt() ?? 0,
        highestModelLevel: (j['maxModel'] as num?)?.toInt() ?? 1,
        longestRunWeeks: (j['maxWeeks'] as num?)?.toInt() ?? 1,
      );
}
