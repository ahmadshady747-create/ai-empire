import 'dart:math';

/// أساس المحاكاة الإدارية للعبة إمبراطورية الذكاء الاصطناعي.
///
/// هذا تصميم أصلي من الصفر: أرقام وأسماء وأفعال خاصة بهذه اللعبة،
/// وليست منقولة من أي لعبة أخرى. الدور = أسبوع واحد، وزر "تقدم
/// أسبوعا" ينفذ الرواتب وتكلفة الاستدلال ونمو المستخدمين وتقدم
/// البحث والتدريب وتحركات منافسين خياليين، ثم يعود بتقرير الأسبوع.
int _clampInt(int v, int min, int max) =>
    v < min ? min : (v > max ? max : v);

/// منافس خيالي تماما، اسمه من تأليف هذه اللعبة ولا يشير لأي شركة حقيقية.
class Rival {
  final String name;
  int modelLevel;

  Rival({required this.name, required this.modelLevel});

  Map<String, dynamic> toJson() => {'name': name, 'modelLevel': modelLevel};

  factory Rival.fromJson(Map<String, dynamic> j) => Rival(
        name: j['name'] as String,
        modelLevel: (j['modelLevel'] as num).toInt(),
      );
}

/// تقرير أسبوع واحد: كل رقم فيه محسوب فعلا من حالة ما قبل الأسبوع
/// وما بعده، لا تقدير ولا نص جاهز.
class WeekReport {
  final int week;
  final int cashBefore;
  final int cashAfter;
  final int revenue;
  final int salaries;
  final int inferenceCost;
  final int usersBefore;
  final int usersAfter;
  final int researchBefore;
  final int researchAfter;
  final int trainingBefore;
  final int trainingAfter;
  final int modelLevelBefore;
  final int modelLevelAfter;
  final int reputationBefore;
  final int reputationAfter;
  final List<String> rivalMoves;
  final List<String> lines;

  const WeekReport({
    required this.week,
    required this.cashBefore,
    required this.cashAfter,
    required this.revenue,
    required this.salaries,
    required this.inferenceCost,
    required this.usersBefore,
    required this.usersAfter,
    required this.researchBefore,
    required this.researchAfter,
    required this.trainingBefore,
    required this.trainingAfter,
    required this.modelLevelBefore,
    required this.modelLevelAfter,
    required this.reputationBefore,
    required this.reputationAfter,
    required this.rivalMoves,
    required this.lines,
  });

  int get net => revenue - salaries - inferenceCost;
  bool get bankrupt => cashAfter < 0;
}

/// حالة إدارة الشركة: نقد، مدى نقدي، بيانات، حوسبة، نموذج،
/// مستخدمون، إيراد، تكلفة، ترتيب، سمعة.
class ManagementState {
  int week;
  int cash;
  int dataQuantity;
  int dataQuality;
  int dataFreshness;
  int computeAvailable;
  int computeReserved;
  int modelLevel;
  int users;
  int reputation;
  int researchProgress;
  int trainingProgress;
  List<Rival> rivals;

  ManagementState({
    this.week = 1,
    this.cash = 150000,
    this.dataQuantity = 800,
    this.dataQuality = 55,
    this.dataFreshness = 80,
    this.computeAvailable = 100,
    this.computeReserved = 20,
    this.modelLevel = 1,
    this.users = 120,
    this.reputation = 50,
    this.researchProgress = 0,
    this.trainingProgress = 0,
    List<Rival>? rivals,
  }) : rivals = rivals ??
            [
              Rival(name: 'مدار للذكاء', modelLevel: 1),
              Rival(name: 'نورال للأنظمة', modelLevel: 2),
              Rival(name: 'قمة الحوسبة', modelLevel: 1),
            ];

  /// تكلفة الرواتب الأسبوعية: قاعدة تنمو مع مستوى النموذج.
  int get weeklySalaries => 3000 + modelLevel * 500;

  /// سعر الاشتراك الفعال لكل مستخدم في الأسبوع (وحدات لعب).
  int get pricePerUser => 12;

  /// تكلفة الاستدلال لكل مستخدم في الأسبوع (وحدات لعب).
  int get inferencePerUser => 2;

  int get weeklyRevenue => users * pricePerUser;
  int get weeklyInferenceCost => users * inferencePerUser;
  int get weeklyCost => weeklySalaries + weeklyInferenceCost;
  int get weeklyNet => weeklyRevenue - weeklyCost;

  /// المدى النقدي بالأسابيع: إن كان صافي الأسبوع غير سالب فالشركة
  /// مستدامة (نرمز لها بـ 999 في المنطق، وتعرضها الواجهة "مستدام").
  int get runwayWeeks {
    if (cash <= 0) return 0;
    if (weeklyNet >= 0) return 999;
    return cash ~/ (-weeklyNet);
  }

  bool get isBankrupt => cash < 0;

  /// الترتيب: 1 + عدد المنافسين الذين نموذجهم أقوى من نموذجك.
  int get rank =>
      1 + rivals.where((r) => r.modelLevel > modelLevel).length;

  int get bestRivalLevel =>
      rivals.map((r) => r.modelLevel).fold(0, (a, b) => a > b ? a : b);

  /// تنفيذ أسبوع واحد كامل. يمرّر [random] في الاختبارات لنتائج حتمية.
  WeekReport advanceWeek({Random? random}) {
    final r = random ?? Random();
    final cashBefore = cash;
    final usersBefore = users;
    final researchBefore = researchProgress;
    final trainingBefore = trainingProgress;
    final modelBefore = modelLevel;
    final reputationBefore = reputation;

    // 1) المالية: إيراد، ثم رواتب وتكلفة استدلال.
    final revenue = weeklyRevenue;
    final salaries = weeklySalaries;
    final inference = weeklyInferenceCost;
    cash += revenue - salaries - inference;

    // 2) نمو المستخدمين: ينمو مع مستوى النموذج والسمعة، ويتباطأ
    // إن تراجعت السمعة كثيرا. لا ينخفض المستخدمون تحت الصفر.
    var userDelta = 4 + modelLevel * 2 + reputation ~/ 25 + r.nextInt(7);
    if (reputation < 30) userDelta -= 6;
    users = _clampInt(users + userDelta, 0, 1000000);

    // 3) تقدم البحث والتدريب: البحث يتقدم كل أسبوع، والتدريب
    // يتقدم أسرع عندما تكون حوسبة محجوزة لهذا الأسبوع.
    researchProgress += 6 + r.nextInt(6);
    trainingProgress += computeReserved >= 20 ? 12 : 4;
    // الحوسبة المحجوزة تُستهلك في أسبوعها، وتعود متاحة جزئيا
    // في الأسبوع التالي (إدارة بسيطة، تُعمّق في جولات الحوسبة).
    computeReserved = 0;
    computeAvailable = _clampInt(computeAvailable + 10, 0, 200);
    if (researchProgress >= 100) {
      researchProgress -= 100;
      modelLevel += 1;
    }
    if (trainingProgress >= 100) {
      trainingProgress -= 100;
      modelLevel += 1;
    }

    // 4) حداثة البيانات تتقادم أسبوعا بعد أسبوع.
    dataFreshness = _clampInt(dataFreshness - 2, 0, 100);

    // 5) تحركات المنافسين الخياليين: لكل منافس فرصة للتقدم،
    // تزداد إن كان متأخرا عن الصدارة.
    final rivalMoves = <String>[];
    for (final rival in rivals) {
      final chance = rival.modelLevel < bestRivalLevel ? 0.45 : 0.30;
      if (r.nextDouble() < chance) {
        rival.modelLevel += 1;
        rivalMoves.add('أصدرت ${rival.name} نموذجا أقوى (مستوى ${rival.modelLevel}).');
      }
    }

    // 6) السمعة: تتقدم إن كنت في الصدارة، وتتراجع إن تأخرت
    // عن أفضل منافس بمستويين أو أكثر.
    if (modelLevel >= bestRivalLevel) {
      reputation = _clampInt(reputation + 1, 0, 100);
    } else if (bestRivalLevel - modelLevel >= 2) {
      reputation = _clampInt(reputation - 1, 0, 100);
    }

    week += 1;
    final lines = <String>[
      'إيراد الأسبوع: $revenue، رواتب: $salaries، استدلال: $inference، صافي: ${revenue - salaries - inference}.',
      'المستخدمون: $usersBefore → $users.',
      'البحث: $researchBefore → $researchProgress، التدريب: $trainingBefore → $trainingProgress.',
      if (modelLevel != modelBefore)
        'ارتفع مستوى نموذجك من $modelBefore إلى $modelLevel.',
      ...rivalMoves,
      if (cash < 0) 'نفد النقد: الشركة مفلسة ما لم تُنقذ بقرار مالي.',
    ];
    return WeekReport(
      week: week - 1,
      cashBefore: cashBefore,
      cashAfter: cash,
      revenue: revenue,
      salaries: salaries,
      inferenceCost: inference,
      usersBefore: usersBefore,
      usersAfter: users,
      researchBefore: researchBefore,
      researchAfter: researchProgress,
      trainingBefore: trainingBefore,
      trainingAfter: trainingProgress,
      modelLevelBefore: modelBefore,
      modelLevelAfter: modelLevel,
      reputationBefore: reputationBefore,
      reputationAfter: reputation,
      rivalMoves: rivalMoves,
      lines: lines,
    );
  }

  Map<String, dynamic> toJson() => {
        'week': week,
        'cash': cash,
        'dataQuantity': dataQuantity,
        'dataQuality': dataQuality,
        'dataFreshness': dataFreshness,
        'computeAvailable': computeAvailable,
        'computeReserved': computeReserved,
        'modelLevel': modelLevel,
        'users': users,
        'reputation': reputation,
        'researchProgress': researchProgress,
        'trainingProgress': trainingProgress,
        'rivals': rivals.map((r) => r.toJson()).toList(),
      };

  factory ManagementState.fromJson(Map<String, dynamic> j) =>
      ManagementState(
        week: (j['week'] as num?)?.toInt() ?? 1,
        cash: (j['cash'] as num?)?.toInt() ?? 150000,
        dataQuantity: (j['dataQuantity'] as num?)?.toInt() ?? 800,
        dataQuality: (j['dataQuality'] as num?)?.toInt() ?? 55,
        dataFreshness: (j['dataFreshness'] as num?)?.toInt() ?? 80,
        computeAvailable: (j['computeAvailable'] as num?)?.toInt() ?? 100,
        computeReserved: (j['computeReserved'] as num?)?.toInt() ?? 20,
        modelLevel: (j['modelLevel'] as num?)?.toInt() ?? 1,
        users: (j['users'] as num?)?.toInt() ?? 120,
        reputation: (j['reputation'] as num?)?.toInt() ?? 50,
        researchProgress: (j['researchProgress'] as num?)?.toInt() ?? 0,
        trainingProgress: (j['trainingProgress'] as num?)?.toInt() ?? 0,
        rivals: (j['rivals'] as List?)
            ?.map((e) => Rival.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
