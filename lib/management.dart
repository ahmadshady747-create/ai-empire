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

/// عقد خدمة واحد من خدمات الذكاء الاصطناعي حول النماذج.
/// كل خدمة أصلية من تصميم هذه اللعبة: اسمها وعميلها الخيالي
/// وإيرادها وتكلفتها وخطرها المتشابك. لا خدمة دخل مجاني هنا.
class ServiceContract {
  final String id;
  final String name;
  final String clientName;
  final int weeklyRevenue;
  final int weeklyCost;
  final int computeUsed;
  final bool teamLoad;
  final bool bigClient;
  final bool hostsRival;
  int weeksActive;

  ServiceContract({
    required this.id,
    required this.name,
    required this.clientName,
    required this.weeklyRevenue,
    required this.weeklyCost,
    required this.computeUsed,
    required this.teamLoad,
    required this.bigClient,
    required this.hostsRival,
    this.weeksActive = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'clientName': clientName,
        'weeklyRevenue': weeklyRevenue,
        'weeklyCost': weeklyCost,
        'computeUsed': computeUsed,
        'teamLoad': teamLoad,
        'bigClient': bigClient,
        'hostsRival': hostsRival,
        'weeksActive': weeksActive,
      };

  factory ServiceContract.fromJson(Map<String, dynamic> j) =>
      ServiceContract(
        id: j['id'] as String,
        name: j['name'] as String,
        clientName: j['clientName'] as String,
        weeklyRevenue: (j['weeklyRevenue'] as num).toInt(),
        weeklyCost: (j['weeklyCost'] as num).toInt(),
        computeUsed: (j['computeUsed'] as num).toInt(),
        teamLoad: j['teamLoad'] as bool,
        bigClient: j['bigClient'] as bool,
        hostsRival: j['hostsRival'] as bool,
        weeksActive: (j['weeksActive'] as num?)?.toInt() ?? 0,
      );
}

/// مشروع بحثي واحد: اتجاه بحث بأصل أصلي من تصميم هذه اللعبة،
/// له ثمن نقدي ومدة بالأسابيع وتأثير دائم عند اكتماله. لا يكتمل
/// مشروعان معا أبدا: التركيز على اتجاه واحد هو ثمن الاختيار،
/// فلا استراتيجية بحثية مهيمنة واحدة.
class ResearchProject {
  final String id;
  final String name;
  final String description;
  final int cost;
  final int durationWeeks;
  int weeksDone;

  ResearchProject({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    required this.durationWeeks,
    this.weeksDone = 0,
  });

  bool get completed => weeksDone >= durationWeeks;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'cost': cost,
        'durationWeeks': durationWeeks,
        'weeksDone': weeksDone,
      };

  factory ResearchProject.fromJson(Map<String, dynamic> j) =>
      ResearchProject(
        id: j['id'] as String,
        name: j['name'] as String,
        description: j['description'] as String,
        cost: (j['cost'] as num).toInt(),
        durationWeeks: (j['durationWeeks'] as num).toInt(),
        weeksDone: (j['weeksDone'] as num?)?.toInt() ?? 0,
      );
}

/// وظيفة نموذج واحدة: عمل تفصيلي على النموذج بأصل أصلي من
/// تصميم هذه اللعبة، له ثمن نقدي ومدة بالأسابيع وتأثير دائم
/// عند اكتماله. وظيفة واحدة نشطة فقط، كالمشروع البحثي،
/// فلا خيار مهيمن واحد: الجيل الجديد يرفع المستوى لكنه
/// يصفّر تقدم التدريب، والتقطير يرخّص الاستدلال دون رفع
/// المستوى، والاسترجاع يرفع السمعة والنمو دون رفع المستوى.
class ModelJob {
  final String id;
  final String name;
  final String description;
  final int cost;
  final int durationWeeks;
  int weeksDone;

  ModelJob({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    required this.durationWeeks,
    this.weeksDone = 0,
  });

  bool get completed => weeksDone >= durationWeeks;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'cost': cost,
        'durationWeeks': durationWeeks,
        'weeksDone': weeksDone,
      };

  factory ModelJob.fromJson(Map<String, dynamic> j) => ModelJob(
        id: j['id'] as String,
        name: j['name'] as String,
        description: j['description'] as String,
        cost: (j['cost'] as num).toInt(),
        durationWeeks: (j['durationWeeks'] as num).toInt(),
        weeksDone: (j['weeksDone'] as num?)?.toInt() ?? 0,
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
  final int servicesRevenue;
  final int servicesCost;
  final int creditInterest;
  final int creditDrawn;
  final int creditUsedAfter;
  final List<String> churnedServices;
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
  final String researchCompleted;
  final String modelCompleted;
  final List<String> lines;

  const WeekReport({
    required this.week,
    required this.cashBefore,
    required this.cashAfter,
    required this.revenue,
    required this.salaries,
    required this.inferenceCost,
    this.servicesRevenue = 0,
    this.servicesCost = 0,
    this.creditInterest = 0,
    this.creditDrawn = 0,
    this.creditUsedAfter = 0,
    this.churnedServices = const [],
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
    this.researchCompleted = '',
    this.modelCompleted = '',
    required this.lines,
  });

  int get net =>
      revenue + servicesRevenue - salaries - inferenceCost - servicesCost - creditInterest;

  /// مفلس فعلا فقط بعد نفاد النقد ونفاد الائتمان معا: إن غطى
  /// الائتمان العجز عاد النقد إلى صفر ولم يعد مفلسا.
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
  int creditLimit;
  int creditUsed;
  List<ServiceContract> services;
  ResearchProject? activeResearch;
  int researchBoost;
  int trainingBoost;
  int userGrowthBoost;
  List<String> completedResearch;
  ModelJob? activeModelJob;
  List<String> completedModels;
  int inferenceSaving;

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
    this.creditLimit = 50000,
    this.creditUsed = 0,
    List<ServiceContract>? services,
    this.activeResearch,
    this.researchBoost = 0,
    this.trainingBoost = 0,
    this.userGrowthBoost = 0,
    List<String>? completedResearch,
    this.activeModelJob,
    List<String>? completedModels,
    this.inferenceSaving = 0,
  })  : rivals = rivals ??
            [
              Rival(name: 'مدار للذكاء', modelLevel: 1),
              Rival(name: 'نورال للأنظمة', modelLevel: 2),
              Rival(name: 'قمة الحوسبة', modelLevel: 1),
            ],
        services = services ?? [],
        completedResearch = completedResearch ?? [],
        completedModels = completedModels ?? [];

  /// كتالوج مشاريع البحث الأصلي: أربعة اتجاهات من عصر النماذج
  /// الحدودية والوكلاء الحالي، لا من عصر قديم. كل اتجاه له
  /// ثمن ومدة وتأثير دائم مختلف، فيتشابك مع نظام آخر.
  static const List<({String id, String name, String description, int cost, int weeks, String effect})>
      researchCatalog = [
    (
      id: 'architecture',
      name: 'معمارية جديدة',
      description: 'تصميم معمارية أقدر على الاستدلال الطويل والوكلاء.',
      cost: 8000,
      weeks: 6,
      effect: 'بحثك الأسبوعي أسرع بنقطتين دائما.',
    ),
    (
      id: 'scaling',
      name: 'قوانين التوسع',
      description: 'قياس كيف ينمو الأداء مع الحجم والبيانات والحوسبة.',
      cost: 6000,
      weeks: 5,
      effect: 'تدريبك الأسبوعي أسرع بأربع نقاط دائما.',
    ),
    (
      id: 'alignment',
      name: 'مواءمة وأمان',
      description: 'مواءمة النموذج مع المستخدمين وتقليل مخاطره.',
      cost: 5000,
      weeks: 4,
      effect: 'سمعتك ترتفع 10 نقاط عند الاكتمال.',
    ),
    (
      id: 'agents',
      name: 'وكلاء وأدوات',
      description: 'وكلاء يستخدمون أدوات وينفذون مهام متعددة الخطوات.',
      cost: 7000,
      weeks: 5,
      effect: 'نمو مستخدميك الأسبوعي أسرع بخمسة دائما.',
    ),
  ];

  /// بدء مشروع بحث: مشروع واحد نشط فقط، ولا إعادة لمشروع
  /// مكتمل، ولا بدء بلا نقد كاف. الثمن يُدفع مقدما.
  bool startResearch(String id) {
    if (activeResearch != null) return false;
    if (completedResearch.contains(id)) return false;
    final def = researchCatalog.firstWhere((d) => d.id == id);
    if (cash < def.cost) return false;
    cash -= def.cost;
    activeResearch = ResearchProject(
      id: def.id,
      name: def.name,
      description: def.description,
      cost: def.cost,
      durationWeeks: def.weeks,
    );
    return true;
  }

  /// تطبيق تأثير مشروع مكتمل: كل اتجاه يقوّي نظاما آخر،
  /// لا مكافأة نقدية مباشرة، حتى لا يصير البحث دخلاً مجانيا.
  String _applyResearchEffect(ResearchProject project) {
    switch (project.id) {
      case 'architecture':
        researchBoost += 2;
      case 'scaling':
        trainingBoost += 4;
      case 'alignment':
        reputation = _clampInt(reputation + 10, 0, 100);
      case 'agents':
        userGrowthBoost += 5;
    }
    final def =
        researchCatalog.firstWhere((d) => d.id == project.id);
    return 'اكتمل مشروع البحث "${project.name}": ${def.effect}';
  }

  /// كتالوج وظائف النماذج الأصلي: ثلاثة أعمال على النموذج
  /// بثمن ومدة وتأثير مختلف، بلا عمل مهيمن واحد: الجيل
  /// الجديد وحده يرفع المستوى لكنه يصفّر تقدم التدريب،
  /// والتقطير يرخّص الاستدلال دون رفع المستوى، والاسترجاع
  /// يرفع السمعة والنمو دون رفع المستوى.
  static const List<({String id, String name, String description, int cost, int weeks, String effect})>
      modelCatalog = [
    (
      id: 'new_generation',
      name: 'جيل جديد',
      description: 'تدريب جيل جديد من الصفر على بياناتك الحالية.',
      cost: 12000,
      weeks: 6,
      effect: 'مستوى نموذجك يرتفع درجة عند الاكتمال، لكن تقدم التدريب الحالي يُصفَّر.',
    ),
    (
      id: 'distillation',
      name: 'تقطير نموذج خفيف',
      description: 'نموذج أصغر مقطّر من الرئيسي، أرخص في الاستدلال.',
      cost: 6000,
      weeks: 3,
      effect: 'تكلفة الاستدلال لكل مستخدم تنخفض نقطة دائما.',
    ),
    (
      id: 'retrieval',
      name: 'استرجاع وأدوات',
      description: 'نموذجك يستدعي معرفة خارجية ويستخدم أدوات.',
      cost: 8000,
      weeks: 4,
      effect: 'سمعتك ترتفع 8 نقاط ونمو مستخدميك أسرع بثلاث نقاط دائما.',
    ),
  ];

  /// بدء وظيفة نموذج: وظيفة واحدة نشطة فقط، ولا إعادة
  /// لوظيفة مكتملة، ولا بدء بلا نقد كاف. الثمن يُدفع مقدما.
  bool startModelJob(String id) {
    if (activeModelJob != null) return false;
    if (completedModels.contains(id)) return false;
    final def = modelCatalog.firstWhere((d) => d.id == id);
    if (cash < def.cost) return false;
    cash -= def.cost;
    activeModelJob = ModelJob(
      id: def.id,
      name: def.name,
      description: def.description,
      cost: def.cost,
      durationWeeks: def.weeks,
    );
    return true;
  }

  /// تطبيق تأثير وظيفة مكتملة: كل عمل يقوّي جانبا واحدا
  /// فقط، ويترك الجوانب الأخرى كما هي، فلا عمل واحد
  /// يغني عن بقية الإدارة.
  String _applyModelEffect(ModelJob job) {
    switch (job.id) {
      case 'new_generation':
        modelLevel += 1;
        trainingProgress = 0;
      case 'distillation':
        inferenceSaving = _clampInt(inferenceSaving + 1, 0, 1);
      case 'retrieval':
        reputation = _clampInt(reputation + 8, 0, 100);
        userGrowthBoost += 3;
    }
    final def = modelCatalog.firstWhere((d) => d.id == job.id);
    return 'اكتملت وظيفة النموذج "${job.name}": ${def.effect}';
  }

  /// كتالوج عروض البيانات الأصلي: ثلاثة عروض بثمن وكمية
  /// وجودة وحداثة مختلفة، بلا عرض مهيمن واحد: الرخيص الواسع
  /// يضخم الكمية لكنه يخفّض متوسط الجودة، والمنقى غالٍ على
  /// كميته لكنه يرفع الجودة، والمتخصص حديث لكن كميته متوسطة.
  static const List<({String id, String name, String description, int cost, int quantity, int qualityDelta, int freshnessDelta})>
      dataCatalog = [
    (
      id: 'web',
      name: 'مجموعة ويب واسعة',
      description: 'نصوص عامة كثيرة من مصادر مفتوحة، تحتاج تنظيفا.',
      cost: 5000,
      quantity: 500,
      qualityDelta: -5,
      freshnessDelta: 15,
    ),
    (
      id: 'curated',
      name: 'مجموعة منقاة مختارة',
      description: 'بيانات مختارة ومراجعة، كميتها أقل وثمنها أعلى.',
      cost: 8000,
      quantity: 150,
      qualityDelta: 10,
      freshnessDelta: 5,
    ),
    (
      id: 'specialized',
      name: 'مجموعة متخصصة حديثة',
      description: 'بيانات متخصصة حديثة من مجال ضيق واحد.',
      cost: 6000,
      quantity: 200,
      qualityDelta: 5,
      freshnessDelta: 20,
    ),
  ];

  /// شراء بيانات: ثمن مقدم، والكمية تزيد دائما، أما الجودة
  /// والحداثة فتتحركان بحسب العرض، فقد تنخفض الجودة مع
  /// العرض الواسع الخام. الشراء متكرر لأن مجموعات جديدة
  /// تصل كل مرة، لكن النقد هو ما يحدّه.
  bool buyData(String id) {
    final def = dataCatalog.firstWhere((d) => d.id == id);
    if (cash < def.cost) return false;
    cash -= def.cost;
    dataQuantity += def.quantity;
    dataQuality = _clampInt(dataQuality + def.qualityDelta, 0, 100);
    dataFreshness =
        _clampInt(dataFreshness + def.freshnessDelta, 0, 100);
    return true;
  }

  /// تنظيف البيانات: ثمن مقدم، يرفع الجودة 15 نقطة لكنه
  /// يسقط 50 وحدة رديئة أو مكررة من الكمية. لا تنظيف بلا
  /// نقد كاف، ولا تنظيف لجودة كاملة، ولا تنظيف يمحي الكمية.
  bool cleanData() {
    if (cash < 3000 || dataQuality >= 100 || dataQuantity < 50) {
      return false;
    }
    cash -= 3000;
    dataQuality = _clampInt(dataQuality + 15, 0, 100);
    dataQuantity -= 50;
    return true;
  }

  /// تجديد البيانات: ثمن مقدم، يرفع الحداثة 25 نقطة دون
  /// تغيير الكمية أو الجودة. لا تجديد لحداثة كاملة.
  bool refreshData() {
    if (cash < 2000 || dataFreshness >= 100) return false;
    cash -= 2000;
    dataFreshness = _clampInt(dataFreshness + 25, 0, 100);
    return true;
  }

  /// شراء حوسبة: 25 وحدة دائمة مقابل 4000، بسقف 200 وحدة
  /// متاحة. لا شراء بلا نقد كاف، ولا شراء فوق السقف.
  bool buyCompute() {
    if (cash < 4000 || computeAvailable >= 200) return false;
    cash -= 4000;
    computeAvailable = _clampInt(computeAvailable + 25, 0, 200);
    return true;
  }

  /// حجز حوسبة للتدريب: نقل وحدات من المتاح إلى المحجوز،
  /// فيُستهلك المحجوز في أسبوعه ويسرّع التدريب. لا حجز
  /// فوق المتاح، ولا حجز صفر أو سالب. الحجز الثقيل (60
  /// وحدة فأكثر) يجهد الموثوقية ويبطئ التدريب 4 نقاط
  /// في أسبوعه، فلا يكون الحجز الأقصى دائما هو الأفضل.
  bool reserveCompute(int units) {
    if (units <= 0 || units > computeAvailable) return false;
    computeAvailable -= units;
    computeReserved += units;
    return true;
  }

  /// كتالوج الخدمات الأصلي: خمس خدمات حول النماذج، لا نماذج فقط.
  /// أسماء العملاء خيالية عامة، لا تشير لأي شركة حقيقية.
  static const List<({String id, String name, int revenue, int cost, int compute, bool team, bool big})>
      serviceCatalog = [
    (
      id: 'hosting',
      name: 'استضافة نماذج منافسين',
      revenue: 900,
      cost: 200,
      compute: 30,
      team: false,
      big: false,
    ),
    (
      id: 'compute_rental',
      name: 'تأجير حوسبة فائضة',
      revenue: 700,
      cost: 100,
      compute: 40,
      team: false,
      big: false,
    ),
    (
      id: 'fine_tuning',
      name: 'ضبط دقيق للغير',
      revenue: 1100,
      cost: 400,
      compute: 0,
      team: true,
      big: false,
    ),
    (
      id: 'data_labeling',
      name: 'تنظيف ووسم بيانات للغير',
      revenue: 800,
      cost: 300,
      compute: 0,
      team: true,
      big: false,
    ),
    (
      id: 'consulting',
      name: 'استشارات ودمج ذكاء اصطناعي',
      revenue: 1300,
      cost: 500,
      compute: 0,
      team: true,
      big: true,
    ),
  ];

  static const _serviceClients = [
    'مكتبة المعرفة',
    'متجر النور',
    'عيادة الشفاء',
    'مصنع الواحة',
    'بنك الأفق',
  ];

  /// بدء خدمة: الاستضافة ترتبط بأضعف منافس (عميلها هو المنافس
  /// نفسه)، وباقي الخدمات ترتبط بعميل خيالي من القائمة.
  bool startService(String id) {
    if (services.any((s) => s.id == id)) return false;
    final def = serviceCatalog.firstWhere((d) => d.id == id);
    final client = def.id == 'hosting'
        ? rivals.fold<Rival>(rivals.first,
            (a, b) => b.modelLevel < a.modelLevel ? b : a).name
        : _serviceClients[services.length % _serviceClients.length];
    services.add(ServiceContract(
      id: def.id,
      name: def.name,
      clientName: client,
      weeklyRevenue: def.revenue,
      weeklyCost: def.cost,
      computeUsed: def.compute,
      teamLoad: def.team,
      bigClient: def.big,
      hostsRival: def.id == 'hosting',
    ));
    return true;
  }

  bool stopService(String id) {
    final before = services.length;
    services.removeWhere((s) => s.id == id);
    return services.length < before;
  }

  int get servicesRevenue =>
      services.fold(0, (a, s) => a + s.weeklyRevenue);
  int get servicesCost => services.fold(0, (a, s) => a + s.weeklyCost);
  int get servicesCompute =>
      services.fold(0, (a, s) => a + s.computeUsed);
  int get teamServiceCount => services.where((s) => s.teamLoad).length;
  int get creditRemaining => creditLimit - creditUsed;
  int get creditInterest => creditUsed ~/ 50;
  int get totalWeeklyRevenue => weeklyRevenue + servicesRevenue;
  int get totalWeeklyCost =>
      weeklyCost + servicesCost + creditInterest;
  int get totalWeeklyNet => totalWeeklyRevenue - totalWeeklyCost;

  /// المدى مع الائتمان: النقد + الائتمان المتبقي مقسوما على الحرق.
  /// أما runwayWeeks فيبقى بالنقد فقط حفاظا على معناه القديم.
  int get runwayWithCreditWeeks {
    if (cash + creditRemaining <= 0) return 0;
    if (totalWeeklyNet >= 0) return 999;
    return (cash + creditRemaining) ~/ (-totalWeeklyNet);
  }

  /// تكلفة الرواتب الأسبوعية: قاعدة تنمو مع مستوى النموذج.
  int get weeklySalaries => 3000 + modelLevel * 500;

  /// سعر الاشتراك الفعال لكل مستخدم في الأسبوع (وحدات لعب).
  int get pricePerUser => 12;

  /// تكلفة الاستدلال لكل مستخدم في الأسبوع (وحدات لعب).
  /// التقطير وحده يخفضها نقطة، ولا تنخفض تحت نقطة واحدة
  /// أبدا، فلا يصير الاستدلال مجانيا.
  int get inferencePerUser => _clampInt(2 - inferenceSaving, 1, 2);

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

    // 1) المالية: إيراد المنتجات + إيراد الخدمات، ثم رواتب
    // وتكلفة استدلال وتكلفة خدمات وفائدة الائتمان (2% أسبوعيا
    // على المستخدم منه). إن نفد النقد يُسحب من الائتمان،
    // والإفلاس الحقيقي هو نفاد الاثنين معا فقط.
    final revenue = weeklyRevenue;
    final salaries = weeklySalaries;
    final inference = weeklyInferenceCost;
    final svcRevenue = servicesRevenue;
    final svcCost = servicesCost;
    final interest = creditInterest;
    cash += revenue + svcRevenue - salaries - inference - svcCost - interest;
    var creditDrawn = 0;
    if (cash < 0 && creditRemaining > 0) {
      creditDrawn = -cash < creditRemaining ? -cash : creditRemaining;
      creditUsed += creditDrawn;
      cash += creditDrawn;
    }

    // 2) نمو المستخدمين: ينمو مع مستوى النموذج والسمعة، ويتباطأ
    // إن تراجعت السمعة كثيرا. لا ينخفض المستخدمون تحت الصفر.
    var userDelta = 4 + modelLevel * 2 + reputation ~/ 25 + r.nextInt(7) + userGrowthBoost;
    if (reputation < 30) userDelta -= 6;
    users = _clampInt(users + userDelta, 0, 1000000);

    // 3) تقدم البحث والتدريب، بثمن الخدمات المتشابك: كل خدمة
    // فرق نشطة تبطئ البحث 3 نقاط، وتأجير الحوسبة يبطئ التدريب
    // 6 نقاط، وحوسبة الخدمات تأكل من المتاح الأسبوعي.
    final teamSlow = teamServiceCount * 3;
    final rentalSlow =
        services.any((s) => s.id == 'compute_rental') ? 6 : 0;
    // تشابك البيانات: حداثة منخفضة تحت 50 تبطئ البحث
    // نقطتين، وجودة منخفضة تحت 40 تبطئ التدريب أربع
    // نقاط، وجودة عالية 80 فأعلى تسرّعه نقطتين. القيم
    // الابتدائية (حداثة 80 وجودة 55) لا تتأثر، فيبقى
    // سلوك الأساس كما هو حتى يهمل اللاعب بياناته أو
    // ينظفها ويرفعها.
    final freshnessSlow = dataFreshness < 50 ? 2 : 0;
    researchProgress += _clampInt(
        6 + r.nextInt(6) - teamSlow + researchBoost - freshnessSlow,
        1,
        100);
    var trainingGain = (computeReserved >= 20 ? 12 : 4) + trainingBoost;
    if (dataQuality < 40) {
      trainingGain -= 4;
    } else if (dataQuality >= 80) {
      trainingGain += 2;
    }
    // إجهاد الحوسبة: حجز ثقيل 60 وحدة فأكثر يبطئ التدريب
    // 4 نقاط في أسبوعه، فيوازن بين تسريع التدريب بالحجز
    // وبين إجهاد الموثوقية بالحجز المفرط.
    final overloaded = computeReserved >= 60;
    if (overloaded) trainingGain -= 4;
    trainingProgress += _clampInt(trainingGain - rentalSlow, 1, 100);
    // الحوسبة المحجوزة تُستهلك في أسبوعها، وتعود متاحة جزئيا
    // في الأسبوع التالي، مطروحا منها ما استهلكته الخدمات.
    computeReserved = 0;
    computeAvailable =
        _clampInt(computeAvailable + 10 - servicesCompute, 0, 200);
    for (final svc in services) {
      svc.weeksActive += 1;
    }
    if (researchProgress >= 100) {
      researchProgress -= 100;
      modelLevel += 1;
    }
    if (trainingProgress >= 100) {
      trainingProgress -= 100;
      modelLevel += 1;
    }

    // 3ب) تقدم مشروع البحث النشط: أسبوع من مدته كل أسبوع،
    // وعند اكتماله يُطبق تأثيره الدائم مرة واحدة فقط.
    var researchCompleted = '';
    if (activeResearch != null) {
      activeResearch!.weeksDone += 1;
      if (activeResearch!.completed) {
        researchCompleted = _applyResearchEffect(activeResearch!);
        completedResearch.add(activeResearch!.id);
        activeResearch = null;
      }
    }

    // 3ج) تقدم وظيفة النموذج النشطة: أسبوع من مدتها كل
    // أسبوع، وعند اكتمالها يُطبق تأثيرها مرة واحدة فقط.
    // توضع بعد رفع المستوى بالتدريب، فيصفّر الجيل الجديد
    // تقدم التدريب الحالي فعلا لا شكليا.
    var modelCompleted = '';
    if (activeModelJob != null) {
      activeModelJob!.weeksDone += 1;
      if (activeModelJob!.completed) {
        modelCompleted = _applyModelEffect(activeModelJob!);
        completedModels.add(activeModelJob!.id);
        activeModelJob = null;
      }
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

    // 5ب) ثمن الخدمات على المنافسين: استضافة منافس تقوّيه
    // (فرصة تقدم إضافية)، وخدمة الغير قد تسرب خبرة لمنافس
    // عشوائي (فرصة تقدم أصغر). هذا هو قلب التوازن: دخل
    // الخدمات يقوّي منافسيك وأنت تحاول ألا تفلس.
    final hosted = services.where((s) => s.hostsRival).toList();
    for (final svc in hosted) {
      final rival = rivals.firstWhere(
        (rv) => rv.name == svc.clientName,
        orElse: () => rivals.first,
      );
      if (r.nextDouble() < 0.35) {
        rival.modelLevel += 1;
        rivalMoves.add(
            'استضافتك لنموذج ${rival.name} قوّته: ارتفع إلى مستوى ${rival.modelLevel}.');
      }
    }
    if (services.any((s) => s.id == 'fine_tuning') &&
        r.nextDouble() < 0.15) {
      final leaked = rivals[r.nextInt(rivals.length)];
      leaked.modelLevel += 1;
      rivalMoves.add(
          'تسرّبت خبرة من ضبطك للغير إلى ${leaked.name} (مستوى ${leaked.modelLevel}).');
    }

    // 5ج) فقدان عميل خدمة فجأة: العميل الكبير ينسحب بفرصة
    // أعلى، فيسقط إيراده من الأسبوع التالي ويهدد المدى.
    final churned = <String>[];
    final survivors = <ServiceContract>[];
    for (final svc in services) {
      final chance = svc.bigClient ? 0.10 : 0.05;
      if (r.nextDouble() < chance) {
        churned.add('${svc.name} (${svc.clientName})');
      } else {
        survivors.add(svc);
      }
    }
    services
      ..clear()
      ..addAll(survivors);

    // 6) السمعة: تتقدم إن كنت في الصدارة، وتتراجع إن تأخرت
    // عن أفضل منافس بمستويين أو أكثر. الاستشارات النشطة
    // تضيف نقطة سمعة لأنها تظهر خبرتك للسوق.
    if (modelLevel >= bestRivalLevel) {
      reputation = _clampInt(reputation + 1, 0, 100);
    } else if (bestRivalLevel - modelLevel >= 2) {
      reputation = _clampInt(reputation - 1, 0, 100);
    }
    if (survivors.any((s) => s.id == 'consulting')) {
      reputation = _clampInt(reputation + 1, 0, 100);
    }

    week += 1;
    final lines = <String>[
      'إيراد الأسبوع: $revenue، رواتب: $salaries، استدلال: $inference، صافي: ${revenue - salaries - inference}.',
      if (svcRevenue > 0 || svcCost > 0)
        'الخدمات: إيراد $svcRevenue، تكلفة $svcCost، صافي ${svcRevenue - svcCost}.',
      if (interest > 0) 'فائدة الائتمان: $interest (مستخدم: $creditUsed).',
      if (creditDrawn > 0)
        'سُحب من الائتمان: $creditDrawn لتغطية العجز (متبق: $creditRemaining).',
      'المستخدمون: $usersBefore → $users.',
      'البحث: $researchBefore → $researchProgress، التدريب: $trainingBefore → $trainingProgress.',
      if (overloaded)
        'حجز حوسبة ثقيل (60 وحدة فأكثر) أجهد الموثوقية: التدريب أبطأ 4 نقاط هذا الأسبوع.',
      if (modelLevel != modelBefore)
        'ارتفع مستوى نموذجك من $modelBefore إلى $modelLevel.',
      if (researchCompleted.isNotEmpty) researchCompleted,
      if (modelCompleted.isNotEmpty) modelCompleted,
      ...rivalMoves,
      for (final c in churned)
        'فقدت عميل خدمة فجأة: $c — إيراده يسقط من الأسبوع التالي.',
      if (cash < 0)
        'نفد النقد ونفد الائتمان: الشركة مفلسة. البقاء كان الشرط الأول.',
    ];
    return WeekReport(
      week: week - 1,
      cashBefore: cashBefore,
      cashAfter: cash,
      revenue: revenue,
      salaries: salaries,
      inferenceCost: inference,
      servicesRevenue: svcRevenue,
      servicesCost: svcCost,
      creditInterest: interest,
      creditDrawn: creditDrawn,
      creditUsedAfter: creditUsed,
      churnedServices: churned,
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
      researchCompleted: researchCompleted,
      modelCompleted: modelCompleted,
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
        'creditLimit': creditLimit,
        'creditUsed': creditUsed,
        'services': services.map((s) => s.toJson()).toList(),
        'activeResearch': activeResearch?.toJson(),
        'researchBoost': researchBoost,
        'trainingBoost': trainingBoost,
        'userGrowthBoost': userGrowthBoost,
        'completedResearch': completedResearch,
        'activeModelJob': activeModelJob?.toJson(),
        'completedModels': completedModels,
        'inferenceSaving': inferenceSaving,
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
        creditLimit: (j['creditLimit'] as num?)?.toInt() ?? 50000,
        creditUsed: (j['creditUsed'] as num?)?.toInt() ?? 0,
        services: (j['services'] as List?)
            ?.map((e) => ServiceContract.fromJson(e as Map<String, dynamic>))
            .toList(),
        activeResearch: j['activeResearch'] == null
            ? null
            : ResearchProject.fromJson(
                j['activeResearch'] as Map<String, dynamic>),
        researchBoost: (j['researchBoost'] as num?)?.toInt() ?? 0,
        trainingBoost: (j['trainingBoost'] as num?)?.toInt() ?? 0,
        userGrowthBoost: (j['userGrowthBoost'] as num?)?.toInt() ?? 0,
        completedResearch: (j['completedResearch'] as List?)
            ?.map((e) => e as String)
            .toList(),
        activeModelJob: j['activeModelJob'] == null
            ? null
            : ModelJob.fromJson(
                j['activeModelJob'] as Map<String, dynamic>),
        completedModels: (j['completedModels'] as List?)
            ?.map((e) => e as String)
            .toList(),
        inferenceSaving: (j['inferenceSaving'] as num?)?.toInt() ?? 0,
      );
}
