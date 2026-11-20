import '../management.dart';

/// نظام الفتح التدريجي للأنظمة:
/// يمنع إغراق اللاعب الجديد بـ 9 أنظمة في الأسبوع الأول،
/// مع إمكانية فتح الوضع المتقدم الكامل بنقرة واحدة في أي وقت.
class ProgressionUnlock {
  final int stage;
  final String stageName;
  final bool researchUnlocked;
  final bool dataUnlocked;
  final bool computeUnlocked;
  final bool servicesUnlocked;
  final bool rivalsUnlocked;
  final bool teamUnlocked;

  const ProgressionUnlock({
    required this.stage,
    required this.stageName,
    required this.researchUnlocked,
    required this.dataUnlocked,
    required this.computeUnlocked,
    required this.servicesUnlocked,
    required this.rivalsUnlocked,
    required this.teamUnlocked,
  });

  factory ProgressionUnlock.fromState(
    ManagementState s, {
    required bool unlockAllOverride,
  }) {
    if (unlockAllOverride || s.week >= 6 || s.modelLevel >= 3) {
      return const ProgressionUnlock(
        stage: 4,
        stageName: 'إمبراطورية متكاملة',
        researchUnlocked: true,
        dataUnlocked: true,
        computeUnlocked: true,
        servicesUnlocked: true,
        rivalsUnlocked: true,
        teamUnlocked: true,
      );
    }
    if (s.week >= 4 || s.modelLevel >= 2 || s.launchedProducts.length >= 2) {
      return const ProgressionUnlock(
        stage: 3,
        stageName: 'توسّع السوق',
        researchUnlocked: true,
        dataUnlocked: true,
        computeUnlocked: true,
        servicesUnlocked: true,
        rivalsUnlocked: true,
        teamUnlocked: true,
      );
    }
    if (s.week >= 2 || s.launchedProducts.isNotEmpty) {
      return const ProgressionUnlock(
        stage: 2,
        stageName: 'مختبر ناشئ',
        researchUnlocked: true,
        dataUnlocked: true,
        computeUnlocked: true,
        servicesUnlocked: false,
        rivalsUnlocked: false,
        teamUnlocked: false,
      );
    }
    return const ProgressionUnlock(
      stage: 1,
      stageName: 'بداية المرآب',
      researchUnlocked: true,
      dataUnlocked: true,
      computeUnlocked: false,
      servicesUnlocked: false,
      rivalsUnlocked: false,
      teamUnlocked: false,
    );
  }
}
