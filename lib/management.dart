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

  /// استراتيجية المنافس المعلنة في تبويب المنافسين: سرعة
  /// إصدار، أو جودة، أو سعر. أسماء خيالية واستراتيجيات
  /// عامة، لا تشير لأي شركة حقيقية.
  final String strategy;

  Rival({required this.name, required this.modelLevel, this.strategy = 'سرعة'});

  Map<String, dynamic> toJson() =>
      {'name': name, 'modelLevel': modelLevel, 'strategy': strategy};

  factory Rival.fromJson(Map<String, dynamic> j) => Rival(
        name: j['name'] as String,
        modelLevel: (j['modelLevel'] as num).toInt(),
        strategy: j['strategy'] as String? ?? 'سرعة',
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
  final int productRevenue;
  final int productCost;
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
  final String worldEvent;
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
    this.productRevenue = 0,
    this.productCost = 0,
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
    this.worldEvent = '',
    required this.lines,
  });

  int get net =>
      revenue +
      servicesRevenue +
      productRevenue -
      salaries -
      inferenceCost -
      servicesCost -
      productCost -
      creditInterest;

  /// مفلس فعلا فقط بعد نفاد النقد ونفاد الائتمان معا: إن غطى
  /// الائتمان العجز عاد النقد إلى صفر ولم يعد مفلسا.
  bool get bankrupt => cashAfter < 0;
}

/// مفهوم واحد في مكتبة مفاهيم اللعبة: شرح عربي واضح لنظام
/// إداري واحد، يبين ثمنه في الأنظمة الأخرى، فلا يبقى العمق
/// أزرارا بلا فهم. محتوى أصلي من تصميم هذه اللعبة، وأحداث
/// العالم المذكورة سيناريوهات محاكاة مستوحاة من اتجاهات عامة،
/// ليست بيانات رسمية ولا تنبؤات، ولا تظهر فيها أسماء أو شعارات
/// شركات حقيقية أبدا.
class ManagementConcept {
  final String title;
  final String body;

  const ManagementConcept({required this.title, required this.body});
}

/// مكتبة المفاهيم: شرح لكل نظام إداري في اللعبة، مرتبة كما
/// تظهر تبويباتها، مع بند ختامي عن شرط البقاء. القائمة ثابتة
/// لا تتغير بحالة اللعب، فالاختبارات تتحقق من تغطيتها فقط.
const managementConcepts = <ManagementConcept>[
  ManagementConcept(
    title: 'البحث',
    body:
        'تختار اتجاها بحثيا واحدا في كل مرة — معمارية جديدة، أو قوانين '
        'توسع، أو مواءمة وأمان، أو وكلاء وأدوات — وتدفع ثمنه مقدما وتنتظر '
        'مدته بالأسابيع. كل اتجاه يمنح مكافأة دائمة مختلفة: تسريع بحث، أو '
        'تسريع تدريب، أو سمعة، أو نمو مستخدمين. لا اتجاه يمنح كل شيء، '
        'والانتظار نفسه ثمن، لأن الأسابيع تمر والمنافسون يتقدمون.',
  ),
  ManagementConcept(
    title: 'البيانات',
    body:
        'البيانات لها كمية وجودة وحداثة، وكل عرض شراء يرفع واحدة ويخفض '
        'أخرى: الواسعة تزيد الكمية وتخفض الجودة، والمنقاة ترفع الجودة '
        'بكمية أقل. التنظيف يرفع الجودة ويأكل من الكمية، والتجديد يرفع '
        'الحداثة دون لمس الباقي. جودة منخفضة تبطئ التدريب، وحداثة '
        'منخفضة تبطئ البحث، فجودة بياناتك تحدد سقف نموذجك فعلا.',
  ),
  ManagementConcept(
    title: 'الحوسبة',
    body:
        'تشتري وحدات حوسبة دائمة بسقف، وتحجز منها للتدريب. الحجز القليل '
        'يبطئ التدريب، والحجز الثقيل يسرّعه لكنه يجهد الموثوقية ويبطئه '
        'من جديد، وعقد الصيانة والتبريد يمتص هذا الإجهاد أربعة أسابيع '
        'فقط. تأجير الحوسبة الفائضة يدر نقدا لكنه يبطئ تدريبك، فكل وحدة '
        'لها وجهة واحدة في الأسبوع الواحد.',
  ),
  ManagementConcept(
    title: 'النماذج',
    body:
        'النموذج الرئيسي يتقدم بالتدريب الأسبوعي، ووظائف النماذج تمنح '
        'أثرا دائما مختلفا: الجيل الجديد يرفع المستوى لكنه يصفّر تقدم '
        'التدريب الحالي، والتقطير يرخّص الاستدلال دون رفع المستوى، '
        'والاسترجاع والأدوات يرفعان السمعة ونمو المستخدمين دون رفع '
        'المستوى. رفع المستوى وحده لا يكفي إن أكلت تكلفة الاستدلال '
        'إيرادك.',
  ),
  ManagementConcept(
    title: 'المنتجات',
    body:
        'النموذج لا يربح وحده، بل المنتجات التي تبنى عليه: مستخدمون '
        'يدفعون سعرا، وكل مستخدم يكلفك استدلالا. رفع السعر يزيد الإيراد '
        'للمستخدم لكنه قد يبطئ النمو، والتسويق يجلب مستخدمين بتكلفة، '
        'والموثوقية المنخفضة تسربهم. هامشك هو الفرق بين السعر وتكلفة '
        'الاستدلال مضروبا في عدد من يبقون فعلا.',
  ),
  ManagementConcept(
    title: 'الخدمات',
    body:
        'حول النماذج خدمات تدر نقدا بثمن متشابك: استضافة نماذج منافسين '
        'تقوّي المنافس نفسه وتأكل حوسبتك، وتأجير الحوسبة يبطئ تدريبك، '
        'وخدمة الغير تستهلك فرقك وقد تسرب خبرة لمنافس، وفقدان عميل كبير '
        'يضرب الإيراد فجأة. التنويع يقلل خطر الإفلاس لكنه يشتت التركيز '
        'عن نموذجك الرئيسي، والتركيز الكامل يرفع سقف الفوز ويرفع خطر '
        'الإفلاس معا.',
  ),
  ManagementConcept(
    title: 'المنافسون',
    body:
        'ثلاثة منافسين خياليون باستراتيجيات مختلفة: سرعة، وجودة، وسعر. '
        'يتقدمون كل أسبوع، واستضافتك لأحدهم تقوّيه، واستقطاب خبير منه '
        'يخفض مستواه درجة ويسرّع تدريبك، لكنه مرة واحدة لكل منافس '
        'وبثمن كبير. الترتيب نتيجة مقارنة مستويات، لا رقم يرفع بزر '
        'مباشر.',
  ),
  ManagementConcept(
    title: 'الفريق',
    body:
        'توظف متخصصين مرة واحدة لكل دور: باحث يسرّع البحث، ومهندس '
        'يضيف حوسبة عند التعيين، ومدير منتجات يسرّع نمو المستخدمين. '
        'لكل دور ثمن مقدم وراتب أسبوعي دائم، فيدخل الراتب في التكلفة '
        'الأسبوعية والمدى النقدي. الفريق الكامل أقوى لكنه أغلى، والراتب '
        'لا يتوقف في الأسابيع الصعبة.',
  ),
  ManagementConcept(
    title: 'المالية',
    body:
        'النقد يدخل من المستخدمين والخدمات والمنتجات، ويخرج رواتب '
        'واستدلالا وفوائد وخدمات. الائتمان يغطي العجز حتى سقفه بفائدة '
        'أسبوعية، والمدى النقدي يقيس كم أسبوعا يصمد النقد مع الائتمان. '
        'القرض ينقذ أسبوعا ويكلف أسابيع، فالإنفاق اليوم قرار بقاء، لا '
        'رقم تجميلي.',
  ),
  ManagementConcept(
    title: 'البقاء أولا',
    body:
        'الإفلاس هو شرط الخسارة الرئيسي: نفاد النقد مع نفاد الائتمان '
        'معا في نهاية أسبوع، لا مجرد التراجع في الترتيب. الترتيب '
        'والصدارة هدف للفوز، لكن البقاء هو الأساس الذي لا يسقط: شركة '
        'مفلسة لا تكمل اللعب ولو كان نموذجها قويا. كل قرار مالي في هذه '
        'المكتبة يُقرأ بسؤال واحد: هل يطيل المدى أم يقصّره؟',
  ),
];

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
  List<String> launchedProducts;

  /// التسعير المميز للمنتجات المطلقة: مطفأ افتراضا.
  /// عند تشغيله يرتفع إيراد المنتجات 30% لكن نمو
  /// المستخدمين منها ينخفض نقطتين، فلا يكون رفع السعر
  /// حلا مهيمنا دائما: نقد أسرع الآن مقابل قاعدة
  /// مستخدمين أبطأ نموا.
  bool premiumPricing;

  /// أسماء المنافسين الذين استُقطب خبير منهم من قبل:
  /// استقطاب واحد فقط لكل منافس، فلا يصير الاستقطاب
  /// مصدر تسريع بلا سقف.
  List<String> poachedRivals;

  /// معرفات المتخصصين المعيّنين في فريقك (كل دور مرة
  /// واحدة فقط، وراتبه الأسبوعي يُخصم كل أسبوع بعد تعيينه).
  List<String> hiredStaff;

  /// أسابيع عقد الصيانة والتبريد المتبقية: ما دام أكبر من
  /// صفر، يمتص العقد إجهاد الحجز الثقيل فلا يبطأ التدريب،
  /// ثم ينقص أسبوعا كل أسبوع حتى ينتهي ويعود الإجهاد.
  int maintenanceWeeks;

  /// آخر حدث عالمي وقع في اللعبة (اسم الحدث فقط): يُحفظ
  /// ويُستأنف، ويُعرض في نظرة عامة اللوحة، فتبقى أخبار
  /// العالم نتيجة مرئية لا خيارا سرديا.
  String lastWorldEvent;

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
    List<String>? launchedProducts,
    this.premiumPricing = false,
    List<String>? poachedRivals,
    List<String>? hiredStaff,
    this.maintenanceWeeks = 0,
    this.lastWorldEvent = '',
  })  : rivals = rivals ??
            [
              Rival(name: 'مدار للذكاء', modelLevel: 1, strategy: 'سرعة'),
              Rival(name: 'نورال للأنظمة', modelLevel: 2, strategy: 'جودة'),
              Rival(name: 'قمة الحوسبة', modelLevel: 1, strategy: 'سعر'),
            ],
        services = services ?? [],
        completedResearch = completedResearch ?? [],
        completedModels = completedModels ?? [],
        launchedProducts = launchedProducts ?? [],
        poachedRivals = poachedRivals ?? [],
        hiredStaff = hiredStaff ?? [];

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

  /// كتالوج المنتجات الأصلي: أربعة منتجات على نموذجك،
  /// بثمن إطلاق مقدم وإيراد أسبوعي وتكلفة صيانة أسبوعية
  /// ونمو مستخدمين أسبوعي مختلف، بلا منتج مهيمن واحد:
  /// الواجهة البرمجية أعلى صافي أسبوعي لكن نموها الأبطأ،
  /// ومساعد البرمجة أعلى نمو لكن صافيها الأدنى وثمنها
  /// الأعلى، وروبوت المحادثة أرخص دخول بصافي ونمو متوسطين،
  /// ومنصة الوكلاء أعلى ثمن إطلاق لكن صافيها ونموها
  /// في الوسط، فلا تغني عن غيرها.
  static const List<({String id, String name, String description, int cost, int revenue, int maintenance, int growth})>
      productCatalog = [
    (
      id: 'chatbot',
      name: 'روبوت محادثة',
      description: 'محادثة عامة للمستخدمين على نموذجك الرئيسي.',
      cost: 9000,
      revenue: 600,
      maintenance: 200,
      growth: 3,
    ),
    (
      id: 'api',
      name: 'واجهة برمجية للمطورين',
      description: 'وصول مدفوع للمطورين إلى نموذجك عبر واجهة.',
      cost: 11000,
      revenue: 900,
      maintenance: 300,
      growth: 2,
    ),
    (
      id: 'coding',
      name: 'مساعد برمجة',
      description: 'مساعد يكتب ويراجع الكود داخل بيئات المطورين.',
      cost: 13000,
      revenue: 800,
      maintenance: 400,
      growth: 5,
    ),
    (
      id: 'agents',
      name: 'منصة وكلاء للمؤسسات',
      description: 'وكلاء ينفذون مهام متعددة الخطوات لعملاء المؤسسات.',
      cost: 15000,
      revenue: 1000,
      maintenance: 450,
      growth: 4,
    ),
  ];

  /// إطلاق منتج: ثمن مقدم، ولا إطلاق مكرر لمنتج مطلق
  /// من قبل، ولا إطلاق بلا نقد كاف. المنتج يبقى مطلقا
  /// ويدر إيراده ويكلف صيانته كل أسبوع بعد إطلاقه.
  bool launchProduct(String id) {
    if (launchedProducts.contains(id)) return false;
    final def = productCatalog.firstWhere((d) => d.id == id);
    if (cash < def.cost) return false;
    cash -= def.cost;
    launchedProducts.add(id);
    return true;
  }

  int get productsRevenue => launchedProducts.fold(
      0,
      (a, id) =>
          a +
          productCatalog.firstWhere((d) => d.id == id).revenue);
  int get productsCost => launchedProducts.fold(
      0,
      (a, id) =>
          a +
          productCatalog.firstWhere((d) => d.id == id).maintenance);
  int get productsGrowth => launchedProducts.fold(
      0,
      (a, id) =>
          a + productCatalog.firstWhere((d) => d.id == id).growth);

  /// إيراد المنتجات الفعّال مع التسعير: مميز يضيف 30%
  /// (قسمة صحيحة)، وعادي يبقي الإيراد كما هو.
  int get effectiveProductsRevenue =>
      premiumPricing ? productsRevenue * 13 ~/ 10 : productsRevenue;

  /// نمو المستخدمين الفعّال مع التسعير: مميز يخصم
  /// نقطتين، ولا ينخفض تحت الصفر أبدا.
  int get effectiveProductsGrowth => premiumPricing
      ? _clampInt(productsGrowth - 2, 0, 100)
      : productsGrowth;

  /// تبديل التسعير المميز: قرار أسبوعي قابل للعكس،
  /// بلا ثمن مقدم، لأن ثمنه هو النمو المفقود نفسه.
  void setPremiumPricing(bool value) {
    premiumPricing = value;
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

  /// ثمن عقد الصيانة والتبريد المقدم.
  static const maintenanceCost = 5000;

  /// مدة عقد الصيانة والتبريد بالأسابيع.
  static const maintenanceDuration = 4;

  /// شراء عقد صيانة وتبريد: 5000 مقدما لأربعة أسابيع،
  /// يمتص خلالها إجهاد الحجز الثقيل (60 وحدة فأكثر)
  /// فلا يبطأ التدريب 4 نقاط في أسابيعه. مرفوض بلا
  /// خصم عند وجود عقد نشط أصلا (لا تكديس)، أو بلا
  /// نقد كاف. الثمن الحقيقي هو النقد المقدم مقابل
  /// دفع الحوسبة إلى أقصاها مؤقتا: عقد ينتهي، والإجهاد
  /// يعود، فلا يصير الحجز الأقصى مجانيا دائما.
  bool buyMaintenance() {
    if (maintenanceWeeks > 0) return false;
    if (cash < maintenanceCost) return false;
    cash -= maintenanceCost;
    maintenanceWeeks = maintenanceDuration;
    return true;
  }

  /// كتالوج الخدمات الأصلي: ست خدمات حول النماذج، لا نماذج فقط.
  /// السادسة (دعم وتشغيل نماذج مفتوحة للغير) هي الوحيدة التي
  /// تكلّف حوسبة وفريقا معا: حوسبة 20 وفريقا، فثمنها مزدوج.
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
    (
      id: 'open_model_support',
      name: 'دعم وتشغيل نماذج مفتوحة للغير',
      revenue: 1000,
      cost: 350,
      compute: 20,
      team: true,
      big: false,
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

  /// مبلغ الاقتراض الصريح من الائتمان المتبقي.
  static const loanChunk = 10000;

  /// مبلغ السداد الصريح من النقد نحو الائتمان المستخدم.
  static const repayChunk = 5000;

  /// اقتراض صريح من المالية: يسحب 10000 من الائتمان المتبقي إلى
  /// النقد الآن، فيرفع المستخدم وبالتالي فائدة الأسبوع التالي (2%).
  /// يفيد لتمويل فعل قبل أن يجبرك العجز على السحب التلقائي،
  /// لكنه ليس نقدا مجانيا: الفائدة تدخل في تكلفة كل أسبوع بعده.
  /// مرفوض إن لم يبق ائتمان كاف.
  bool takeLoan() {
    if (creditRemaining < loanChunk) return false;
    cash += loanChunk;
    creditUsed += loanChunk;
    return true;
  }

  /// سداد صريح من المالية: يدفع [amount] من النقد نحو الائتمان
  /// المستخدم، فيخفض فائدة الأسابيع التالية. مرفوض بصفر أو سالب،
  /// أو فوق النقد، أو فوق المستخدم، ولا يخصم شيئا عند الرفض.
  bool repayCredit(int amount) {
    if (amount <= 0) return false;
    if (amount > cash) return false;
    if (amount > creditUsed) return false;
    cash -= amount;
    creditUsed -= amount;
    return true;
  }

  /// ثمن استقطاب خبير واحد من منافس.
  static const poachCost = 9000;

  /// استقطاب خبير من منافس: ثمن مقدم 9000، يخفض مستوى
  /// نموذج المنافس درجة واحدة (لا تحت مستوى 1)، ويرفع
  /// تسريع تدريبك الدائم نقطتين، لأن الخبير ينقل خبرته
  /// إليك. مرفوض بلا خصم: إن لم يوجد المنافس، أو كان
  /// مستواه 1 فلا ما يُضعف، أو استُقطب منه من قبل، أو
  /// كان النقد غير كاف. لا استراتيجية مهيمنة هنا: الثمن
  /// مرتفع، والاستقطاب مرة واحدة لكل منافس، والمنافس
  /// قد يستعيد مستواه بتحركات الأسابيع التالية.
  bool poachRival(String name) {
    final matches = rivals.where((r) => r.name == name).toList();
    if (matches.isEmpty) return false;
    final rival = matches.first;
    if (rival.modelLevel <= 1) return false;
    if (poachedRivals.contains(name)) return false;
    if (cash < poachCost) return false;
    cash -= poachCost;
    rival.modelLevel -= 1;
    trainingBoost += 2;
    poachedRivals.add(name);
    return true;
  }

  /// كتالوج المتخصصين الأصلي: خمسة أدوار بثمن تعيين
  /// مقدم وراتب أسبوعي دائم وتأثير مختلف، بلا دور
  /// مهيمن واحد: الباحث يسرّع البحث لكن راتبه الأعلى،
  /// ومهندس البنية يضيف حوسبة مرة واحدة دون تسريع
  /// متكرر، ومدير المنتجات يسرّع نمو المستخدمين دون
  /// رفع مستوى النموذج، وخبير البيانات يرفع جودة
  /// البيانات 15 نقطة مرة واحدة عند التعيين، فيقترب
  /// اللاعب من عتبة الجودة 80 التي تسرّع التدريب،
  /// لكنه لا يعبرها وحده من الجودة الابتدائية 55،
  /// فيحتاج تنظيفا قبله أو بعده ليبلغها، وخبير المواءمة
  /// يرفع السمعة 10 نقاط فورا عند التعيين — مثل مشروع
  /// بحث المواءمة تماما في الأثر، لكنه فوري لا بعد
  /// أربعة أسابيع، وثمنه أعلى (8000 مقدما و900 أسبوعيا
  /// مقابل 5000 مرة واحدة)، فالاختيار بين السرعة
  /// والكلفة قرار توازن لا حل واحد دائم. الراتب الدائم
  /// هو الثمن الحقيقي: التعيين يريحك الآن ويأكل
  /// نقدك كل أسبوع بعده.
  static const List<({String id, String name, String description, int cost, int salary, String effect})>
      staffCatalog = [
    (
      id: 'research_lead',
      name: 'باحث نماذج أول',
      description: 'يقود تجارب المعمارية وقوانين التوسع.',
      cost: 7000,
      salary: 800,
      effect: 'بحثك الأسبوعي أسرع بنقطتين دائما.',
    ),
    (
      id: 'infra_engineer',
      name: 'مهندس بنية وحوسبة',
      description: 'يبني ويصون بنيتك الحوسبية.',
      cost: 6000,
      salary: 700,
      effect: 'حوسبتك المتاحة تزيد 25 وحدة عند التعيين.',
    ),
    (
      id: 'product_manager',
      name: 'مدير منتجات',
      description: 'ينظم المنتجات ويتابع انتشارها.',
      cost: 5000,
      salary: 600,
      effect: 'نمو مستخدميك الأسبوعي أسرع بنقطتين دائما.',
    ),
    (
      id: 'data_lead',
      name: 'خبير بيانات أول',
      description: 'يرفع جودة بياناتك وينظم تنظيفها وتجديدها.',
      cost: 6500,
      salary: 750,
      effect: 'جودة بياناتك ترتفع 15 نقطة مرة واحدة عند التعيين.',
    ),
    (
      id: 'safety_lead',
      name: 'خبير مواءمة وأمان أول',
      description: 'يوائم نماذجك مع المستخدمين ويقلل مخاطرها.',
      cost: 8000,
      salary: 900,
      effect: 'سمعتك ترتفع 10 نقاط فورا عند التعيين.',
    ),
  ];

  /// تعيين متخصص: كل دور مرة واحدة فقط، ولا تعيين بلا
  /// نقد كاف للثمن المقدم. التأثير يُطبق مرة واحدة عند
  /// التعيين، والراتب يبدأ من الأسبوع التالي.
  bool hireStaff(String id) {
    if (hiredStaff.contains(id)) return false;
    final def = staffCatalog.firstWhere((d) => d.id == id);
    if (cash < def.cost) return false;
    cash -= def.cost;
    hiredStaff.add(id);
    switch (id) {
      case 'research_lead':
        researchBoost += 2;
      case 'infra_engineer':
        computeAvailable = _clampInt(computeAvailable + 25, 0, 200);
      case 'product_manager':
        userGrowthBoost += 2;
      case 'data_lead':
        dataQuality = _clampInt(dataQuality + 15, 0, 100);
      case 'safety_lead':
        reputation = _clampInt(reputation + 10, 0, 100);
    }
    return true;
  }

  int get staffSalaries => hiredStaff.fold(
      0,
      (a, id) =>
          a + staffCatalog.firstWhere((d) => d.id == id).salary);

  int get servicesRevenue =>
      services.fold(0, (a, s) => a + s.weeklyRevenue);
  int get servicesCost => services.fold(0, (a, s) => a + s.weeklyCost);
  int get servicesCompute =>
      services.fold(0, (a, s) => a + s.computeUsed);
  int get teamServiceCount => services.where((s) => s.teamLoad).length;
  int get creditRemaining => creditLimit - creditUsed;
  int get creditInterest => creditUsed ~/ 50;
  int get totalWeeklyRevenue =>
      weeklyRevenue + servicesRevenue + effectiveProductsRevenue;
  int get totalWeeklyCost =>
      weeklyCost + servicesCost + creditInterest + productsCost + staffSalaries;
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

  /// دورة أحداث العالم الأصلية: ثلاثة سيناريوهات محاكاة
  /// مستوحاة من اتجاهات عامة في صناعة الذكاء الاصطناعي،
  /// ليست بيانات رسمية ولا تنبؤات، وبلا أسماء أو شعارات
  /// شركات حقيقية. يقع حدث واحد كل ثمانية أسابيع
  /// (الأسبوع 8 ثم 16 ثم 24...) ويدور بين الثلاثة، فلا
  /// يفاجأ اللاعب بحدث كل أسبوع ولا يبقى العالم ساكنا:
  /// أزمة الإمداد تأكل الحوسبة، وطفرة الوكلاء ترفع
  /// المستخدمين (ومعهم تكلفة الاستدلال لاحقا)، والتشديد
  /// التنظيمي يخفض السمعة. أخبار الأسبوع كنتيجة لإدارتك
  /// وللعالم معا، لا كخيار سردي يقرر مصيرك.
  static const List<({String id, String name, String effect})>
      worldEventCycle = [
    (
      id: 'chip_crunch',
      name: 'أزمة إمداد رقائق',
      effect: 'حوسبتك المتاحة تنقص 20 وحدة هذا الأسبوع.',
    ),
    (
      id: 'agent_surge',
      name: 'طفرة طلب على الوكلاء',
      effect: 'مستخدموك ينمون 10 إضافية هذا الأسبوع.',
    ),
    (
      id: 'regulation',
      name: 'تشديد تنظيمي مؤقت',
      effect: 'سمعتك تنقص 3 نقاط هذا الأسبوع.',
    ),
  ];

  /// تنفيذ أسبوع واحد كامل. يمرّر [random] في الاختبارات لنتائج حتمية.
  WeekReport advanceWeek({Random? random}) {
    final r = random ?? Random();
    final cashBefore = cash;
    final usersBefore = users;
    final researchBefore = researchProgress;
    final trainingBefore = trainingProgress;
    final modelBefore = modelLevel;
    final reputationBefore = reputation;

    // حدث العالم الدوري: يقع كل ثمانية أسابيع ويدور بين
    // سيناريوهات الدورة الثلاثة، فلا يطال الأسابيع الأولى
    // ولا يتكرر الحدث نفسه أسبوعا بعد أسبوع.
    final worldEvent = week % 8 == 0
        ? worldEventCycle[(week ~/ 8 - 1) % worldEventCycle.length]
        : null;
    final worldEventLine = worldEvent == null
        ? ''
        : 'حدث عالمي (سيناريو محاكاة، لا تنبؤ): ${worldEvent.name} — ${worldEvent.effect}';
    if (worldEvent != null) lastWorldEvent = worldEvent.name;

    // 1) المالية: إيراد المنتجات + إيراد الخدمات، ثم رواتب
    // وتكلفة استدلال وتكلفة خدمات وفائدة الائتمان (2% أسبوعيا
    // على المستخدم منه). إن نفد النقد يُسحب من الائتمان،
    // والإفلاس الحقيقي هو نفاد الاثنين معا فقط.
    final revenue = weeklyRevenue;
    final salaries = weeklySalaries;
    final inference = weeklyInferenceCost;
    final staffCost = staffSalaries;
    final svcRevenue = servicesRevenue;
    final svcCost = servicesCost;
    final prodRevenue = effectiveProductsRevenue;
    final prodCost = productsCost;
    final interest = creditInterest;
    cash += revenue +
        svcRevenue +
        prodRevenue -
        salaries -
        staffCost -
        inference -
        svcCost -
        prodCost -
        interest;
    var creditDrawn = 0;
    if (cash < 0 && creditRemaining > 0) {
      creditDrawn = -cash < creditRemaining ? -cash : creditRemaining;
      creditUsed += creditDrawn;
      cash += creditDrawn;
    }

    // 2) نمو المستخدمين: ينمو مع مستوى النموذج والسمعة، ويتباطأ
    // إن تراجعت السمعة كثيرا. لا ينخفض المستخدمون تحت الصفر.
    var userDelta = 4 + modelLevel * 2 + reputation ~/ 25 + r.nextInt(7) + userGrowthBoost + effectiveProductsGrowth;
    // طفرة الوكلاء: نمو إضافي في أسبوع الحدث نفسه، لكن
    // المستخدمين الجدد يرفعون تكلفة الاستدلال من الأسبوع
    // التالي، فلا تكون الطفرة دخلا مجانيا.
    if (worldEvent?.id == 'agent_surge') userDelta += 10;
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
    final maintenanceActive = maintenanceWeeks > 0;
    if (overloaded && !maintenanceActive) trainingGain -= 4;
    trainingProgress += _clampInt(trainingGain - rentalSlow, 1, 100);
    if (maintenanceActive) maintenanceWeeks -= 1;
    // الحوسبة المحجوزة تُستهلك في أسبوعها، وتعود متاحة جزئيا
    // في الأسبوع التالي، مطروحا منها ما استهلكته الخدمات.
    computeReserved = 0;
    computeAvailable =
        _clampInt(computeAvailable + 10 - servicesCompute, 0, 200);
    // أزمة الإمداد: تنقص الحوسبة المتاحة بعد تجديد الأسبوع،
    // فيشعر بها اللاعب فعلا في حجز الأسبوع التالي.
    if (worldEvent?.id == 'chip_crunch') {
      computeAvailable = _clampInt(computeAvailable - 20, 0, 200);
    }
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
    // التشديد التنظيمي: يخفض السمعة بعد تعديلات الأسبوع،
    // فيدخل في نمو المستخدمين وترتيب الأسابيع التالية.
    if (worldEvent?.id == 'regulation') {
      reputation = _clampInt(reputation - 3, 0, 100);
    }

    week += 1;
    final lines = <String>[
      'إيراد الأسبوع: $revenue، رواتب: $salaries، استدلال: $inference، صافي: ${revenue - salaries - inference}.',
      if (staffCost > 0) 'رواتب فريقك المتخصص: $staffCost.',
      if (svcRevenue > 0 || svcCost > 0)
        'الخدمات: إيراد $svcRevenue، تكلفة $svcCost، صافي ${svcRevenue - svcCost}.',
      if (prodRevenue > 0 || prodCost > 0)
        'المنتجات: إيراد $prodRevenue، صيانة $prodCost، صافي ${prodRevenue - prodCost}.',
      if (premiumPricing && prodRevenue > 0)
        'التسعير المميز مفعّل: إيراد المنتجات أعلى 30% لكن نمو المستخدمين منها أبطأ نقطتين.',
      if (interest > 0) 'فائدة الائتمان: $interest (مستخدم: $creditUsed).',
      if (creditDrawn > 0)
        'سُحب من الائتمان: $creditDrawn لتغطية العجز (متبق: $creditRemaining).',
      'المستخدمون: $usersBefore → $users.',
      'البحث: $researchBefore → $researchProgress، التدريب: $trainingBefore → $trainingProgress.',
      if (overloaded && !maintenanceActive)
        'حجز حوسبة ثقيل (60 وحدة فأكثر) أجهد الموثوقية: التدريب أبطأ 4 نقاط هذا الأسبوع.',
      if (overloaded && maintenanceActive)
        'عقد الصيانة والتبريد امتص إجهاد الحجز الثقيل: التدريب لم يبطأ هذا الأسبوع (بقي $maintenanceWeeks أسبوعا).',
      if (modelLevel != modelBefore)
        'ارتفع مستوى نموذجك من $modelBefore إلى $modelLevel.',
      if (researchCompleted.isNotEmpty) researchCompleted,
      if (modelCompleted.isNotEmpty) modelCompleted,
      if (worldEventLine.isNotEmpty) worldEventLine,
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
      productRevenue: prodRevenue,
      productCost: prodCost,
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
      worldEvent: worldEvent?.name ?? '',
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
        'launchedProducts': launchedProducts,
        'premiumPricing': premiumPricing,
        'poachedRivals': poachedRivals,
        'hiredStaff': hiredStaff,
        'maintenanceWeeks': maintenanceWeeks,
        'lastWorldEvent': lastWorldEvent,
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
        launchedProducts: (j['launchedProducts'] as List?)
            ?.map((e) => e as String)
            .toList(),
        premiumPricing: (j['premiumPricing'] as bool?) ?? false,
        poachedRivals: (j['poachedRivals'] as List?)
            ?.map((e) => e as String)
            .toList(),
        hiredStaff: (j['hiredStaff'] as List?)
            ?.map((e) => e as String)
            .toList(),
        maintenanceWeeks: (j['maintenanceWeeks'] as num?)?.toInt() ?? 0,
        lastWorldEvent: (j['lastWorldEvent'] as String?) ?? '',
      );
}
