import '../models.dart';

EventChoice c(
  String text,
  String outcome,
  Effect effect, {
  List<String> add = const [],
  List<String> remove = const [],
  int jump = 2,
  String? dies,
  String? ambition,
  String? job,
  int jobSalary = 0,
  int cash = 0,
  String? nextId,
}) =>
    EventChoice(
      text: text,
      outcome: outcome,
      effect: effect,
      addTraits: add,
      removeTraits: remove,
      ageJump: jump,
      deathCause: dies,
      ambition: ambition,
      job: job,
      jobSalary: jobSalary,
      cash: cash,
      nextId: nextId,
    );

LifeEvent e(
  String id,
  int min,
  int max,
  String title,
  String story,
  List<EventChoice> choices, {
  String? requires,
  String? forbids,
}) =>
    LifeEvent(
      id: id,
      minAge: min,
      maxAge: max,
      title: title,
      story: story,
      choices: choices,
      requiresTrait: requires,
      forbidsTrait: forbids,
    );

LifeEvent w(
  String id,
  int min,
  int max,
  String title,
  String story,
  List<EventChoice> choices, {
  String? region,
  int? maxEconomy,
  int? minEconomy,
  String? requires,
  String? forbids,
}) =>
    LifeEvent(
      id: id,
      minAge: min,
      maxAge: max,
      title: title,
      story: story,
      choices: choices,
      requiresTrait: requires,
      forbidsTrait: forbids,
      region: region,
      maxEconomy: maxEconomy,
      minEconomy: minEconomy,
      isWorld: true,
    );

LifeEvent a(
  String id,
  String arcName,
  String title,
  String story,
  List<EventChoice> choices, {
  String? requires,
  String? forbids,
}) =>
    LifeEvent(
      id: id,
      minAge: 0,
      maxAge: 120,
      title: title,
      story: story,
      choices: choices,
      requiresTrait: requires,
      forbidsTrait: forbids,
      isArcChapter: true,
      arcName: arcName,
    );

/// أحداث بداية المسيرة: من مطور إلى مؤسس.
final allEvents = <LifeEvent>[
  e('vision', 22, 24, 'ما هي رؤيتك؟',
      'قبل أن تبني أي شيء، عليك أن تختار ما الذي تريد أن تصبح عليه شركتك فعلا. هذه الرؤية ستُقاس في نهاية مسيرتك.',
      [
        c('الهيمنة على السوق', 'هدفك أن تكون شركتك الأولى في سوقها، مهما كلف الأمر.',
            const Effect(money: 2), ambition: 'dominance', jump: 1),
        c('بناء ذكاء عام حقيقي', 'هدفك ليس منتجا، بل عقلا اصطناعيا عاما يفهم العالم.',
            const Effect(research: 10), ambition: 'agi', jump: 1),
        c('نماذج مفتوحة للجميع', 'تؤمن أن الذكاء يجب أن يكون مفتوحا، لا حكرا على الكبار.',
            const Effect(reputation: 8), ambition: 'opensource', jump: 1),
        c('شركة رابحة ومستدامة', 'لا فقاعات ولا حرق أموال: ربح حقيقي ونمو ثابت.',
            const Effect(money: 6), ambition: 'profit', jump: 1),
      ]),
  e('first_model', 22, 28, 'نموذجك الأول',
      'بعد أشهر من العمل ليلا، نموذجك الأول يعمل أخيرا. إنه صغير ومتواضع، لكنه لك.',
      [
        c('أطلقه مجانا للجميع', 'انتشر النموذج، وصار اسمك معروفا في المجتمع.',
            const Effect(reputation: 12, social: 8, money: -2), add: ['firstmodel', 'opensource'], jump: 1),
        c('أبيعه لشركة صغيرة', 'بعتَ النموذج بمبلغ جيد، وبدأتَ تفكر في التالي.',
            const Effect(money: 12), cash: 15000, add: ['firstmodel'], jump: 1),
        c('أخفيه وأطوّره أكثر', 'بقي النموذج سرا، ونضج ببطء دون ضغط السوق.',
            const Effect(tech: 10, research: 8), add: ['firstmodel'], jump: 2),
      ]),
  e('phd_offer', 22, 27, 'عرض دكتوراه',
      'جامعة مرموقة تعرض عليك مقعد دكتوراه في تعلم الآلة، مع منحة وبحث حر.',
      [
        c('أقبل الدكتوراه', 'سنوات من البحث العميق، وشهادة تفتح أبوابا كثيرة.',
            const Effect(research: 14, skill: 10), add: ['student'], jump: 3),
        c('أرفض وأبني شركتي', 'اخترتَ السوق على الأكاديميا، وتعلمتَ بالتجربة.',
            const Effect(money: 4, skill: 6), jump: 1),
      ]),
  e('cofounder', 23, 32, 'شريك مؤسس',
      'مهندس موهوب يعرض الشراكة معك: هو يبني، وأنت تقود الرؤية. الشراكة قد تصنع الشركة أو تكسرها.',
      [
        c('أشاركه تأسيس الشركة', 'صارت لديك شركة حقيقية، وشريك تثق به.',
            const Effect(skill: 8, social: 8, morale: 8), add: ['partner', 'business'], jump: 1),
        c('أبقى وحيدا', 'بقيتَ حر القرارات، وحيدا في كل الأزمات.',
            const Effect(skill: 4, morale: -2), jump: 1),
      ]),
  e('seed_round', 24, 34, 'جولة تمويل أولى',
      'مستثمر ملاك يعرض تمويلا أوليا مقابل حصة من شركتك. المال سيسرّع كل شيء، والحصّة لن تعود.',
      [
        c('أقبل التمويل', 'دخل المال، ووظفتَ فريقا، وبدأ السباق.',
            const Effect(money: 16, skill: 4), cash: 50000, add: ['funded'], jump: 1),
        c('أرفض وأنمو من إيراداتي', 'نمو بطيء، لكن الشركة كلها لك.',
            const Effect(money: 4, morale: 4), jump: 2),
        c('أقبل بشروط أقسى مقابل مال أكثر', 'مال كثير، وضغط أكبر من المستثمرين.',
            const Effect(money: 20, morale: -6), cash: 90000, add: ['funded'], jump: 1),
      ], requires: 'business'),
  e('talent_war', 25, 40, 'حرب المواهب',
      'شركة عملاقة تحاول خطف أفضل مهندسيك برواتب مضاعفة.',
      [
        c('أرفع الرواتب وأحتفظ بهم', 'بقي فريقك، ودفعتَ ثمنا باهظا.',
            const Effect(money: -10, morale: 8, social: 6), cash: -20000, jump: 1),
        c('أدعهم يرحلون وأبني فريقا جديدا', 'خسرتَ خبرة، وكسبتَ طاقة جديدة.',
            const Effect(skill: -6, morale: -4), jump: 1),
      ], requires: 'business'),
  e('data_scandal', 24, 45, 'فضيحة بيانات',
      'يُكتشف أن بيانات تدريب أحد نماذجك جُمعت دون إذن واضح. الصحافة تسأل، والمستخدمون غاضبون.',
      [
        c('أعترف وأحذف البيانات وأعيد التدريب', 'خسرتَ وقتا ومالا، وكسبتَ ثقة.',
            const Effect(reputation: 10, money: -10, tech: -4), cash: -15000, jump: 2),
        c('أنكر وأخفي الأمر', 'مرّت العاصفة، لكن الخوف من الانكشاف بقي.',
            const Effect(reputation: -12, morale: -6), jump: 1),
      ]),
  e('open_source_dilemma', 25, 45, 'فتح المصدر أم إغلاقه؟',
      'نموذجك الجديد قوي. فتحه سيمنحك مجتمعا وشهرة، وإغلاقه سيمنحك إيرادا.',
      [
        c('أفتحه للجميع', 'صار نموذجك معيارا، واسمك في كل مكان.',
            const Effect(reputation: 14, social: 10, money: -4), add: ['opensource'], jump: 1),
        c('أغلقه وأبيعه باشتراك', 'إيراد ثابت، ومجتمع أصغر.',
            const Effect(money: 14, reputation: -2), cash: 20000, jump: 1),
      ], requires: 'firstmodel'),
  e('compute_crisis', 25, 50, 'أزمة حوسبة',
      'أسعار وحدات المعالجة ترتفع، ومزود السحابة يرفع أسعاره فجأة. تدريب نموذجك القادم صار مكلفا جدا.',
      [
        c('أدفع وأدرّب كما خططت', 'دفعتَ كثيرا، لكن النموذج خرج قويا.',
            const Effect(tech: 10, money: -14), cash: -30000, jump: 1),
        c('أؤجل التدريب وأحسّن النموذج الحالي', 'وفرتَ المال، وتأخرتَ عن المنافسين قليلا.',
            const Effect(skill: 8, money: 2), jump: 2),
        c('أبني بنية حوسبة خاصة صغيرة', 'استثمار طويل، واستقلال تدريجي.',
            const Effect(tech: 8, money: -8), cash: -20000, jump: 2),
      ]),
  e('conference', 24, 50, 'مؤتمر عالمي',
      'مؤتمر ذكاء اصطناعي كبير يدعوك لعرض نموذجك. الحضور من كل الشركات الكبرى.',
      [
        c('أعرض نموذجك بجرأة', 'انبهر الحضور، وعروض العمل والشراكة انهالت.',
            const Effect(reputation: 12, social: 10), add: ['traveler'], jump: 1),
        c('أحضر مستمعا فقط', 'تعلمتَ كثيرا، دون أن ينتبه إليك أحد.',
            const Effect(research: 8, social: 4), jump: 1),
      ]),
  e('safety_incident', 26, 50, 'حادث سلامة',
      'نموذجك ينتج مخرجات خطيرة في حالة نادرة. إصلاحه سيؤخر الإطلاق، وتجاهله مخاطرة.',
      [
        c('أوقف الإطلاق وأصلح الأمان', 'تأخرتَ، لكن نموذجك صار آمنا وموثوقا.',
            const Effect(tech: 6, reputation: 10, money: -6), jump: 2),
        c('أطلق مع تحذير صغير', 'انطلق المنتج، وظهرت حالات أخرى لاحقا.',
            const Effect(money: 8, reputation: -10), cash: 10000, jump: 1),
      ], requires: 'firstmodel'),
  e('acqui_offer', 28, 45, 'عرض استحواذ',
      'شركة عملاقة تعرض شراء شركتك بمبلغ مغرٍ. البيع يعني ثروة ونهاية حلم الاستقلال.',
      [
        c('أبيع', 'بعتَ شركتك، وصرتَ ثريا، وبدأتَ تفكر في مشروعك التالي.',
            const Effect(money: 20, morale: 6), cash: 150000, jump: 1),
        c('أرفض وأستمر مستقلا', 'بقيتَ حرا، والطريق أصعب وأجمل.',
            const Effect(morale: 8, reputation: 6), jump: 1),
      ], requires: 'business'),
];

/// أحداث مرحلة النمو والهيمنة.
final laterEvents = <LifeEvent>[
  e('series_b', 30, 50, 'جولة تمويل كبرى',
      'صناديق استثمارية تتنافس لتمويل توسعك العالمي. التقييم خيالي، والشروط معقدة.',
      [
        c('أقبل التقييم الأعلى', 'صارت شركتك يونيكورن، والضغط صار هائلا.',
            const Effect(money: 18, morale: -4), cash: 200000, add: ['unicorn', 'funded'], jump: 1),
        c('أقبل تقييما أقل بشروط أفضل', 'مال أقل، وسيطرة أكبر على شركتك.',
            const Effect(money: 12, morale: 4), cash: 100000, add: ['funded'], jump: 1),
      ], requires: 'business'),
  e('agi_race', 32, 55, 'سباق الذكاء العام',
      'منافس يعلن اقترابه من الذكاء العام. السوق يشتعل، والمواهب تتسابق.',
      [
        c('أضاعف البحث في الذكاء العام', 'تقدمتَ كثيرا، واحترقت أموال كثيرة.',
            const Effect(research: 16, tech: 10, money: -12), cash: -50000, jump: 2),
        c('أركز على منتجات رابحة بدلا من السباق', 'ربحتَ مالا، وتأخرتَ في السباق.',
            const Effect(money: 12, research: -4), cash: 40000, jump: 1),
      ]),
  e('ipo', 35, 60, 'الاكتتاب العام',
      'شركتك جاهزة للاكتتاب العام. يوم الإدراج سيحدد مصيرك المالي ومكانتك.',
      [
        c('أطرح الشركة للاكتتاب', 'يوم تاريخي: أسهمك ترتفع، وشركتك صارت عامة.',
            const Effect(money: 20, reputation: 14), cash: 300000, jump: 1),
        c('أؤجل الاكتتاب', 'بقيتَ خاصا، ومرنا، وبعيدا عن ضغط السوق اليومي.',
            const Effect(morale: 6, money: 4), jump: 2),
      ], requires: 'unicorn'),
  e('regulator', 30, 60, 'تحقيق تنظيمي',
      'جهة تنظيمية تحقق في هيمنة شركتك على السوق وطريقة جمع بياناتها.',
      [
        c('أتعاون كاملا وأصلح الممارسات', 'خرجتَ بغرامة صغيرة وسمعة نظيفة نسبيا.',
            const Effect(money: -10, reputation: 6), cash: -40000, jump: 2),
        c('أقاوم قانونيا', 'معركة طويلة مكلفة، وانتصار جزئي.',
            const Effect(money: -14, reputation: -6), cash: -60000, jump: 3),
      ], requires: 'business'),
  e('talent_academy', 32, 55, 'أكاديمية المواهب',
      'تفكر في إنشاء برنامج لتدريب مهندسي ذكاء اصطناعي داخل شركتك.',
      [
        c('أنشئ الأكاديمية', 'صارت شركتك مصنعا للمواهب، وسمعتك ارتفعت.',
            const Effect(skill: 12, reputation: 10, money: -6), cash: -20000, jump: 2),
        c('أوظف جاهزين فقط', 'أسرع، وأغلى، وأقل ولاء.',
            const Effect(money: -4, skill: 4), jump: 1),
      ]),
  e('rival_breakthrough', 30, 58, 'اختراق منافس',
      'منافس يطلق نموذجا يتفوق على نموذجك في كل الاختبارات. عملاؤك يفكرون بالرحيل.',
      [
        c('أعيد بناء النموذج من الصفر', 'سنوات صعبة، ثم عودة أقوى.',
            const Effect(tech: 14, research: 10, money: -10), cash: -40000, jump: 3),
        c('أشتري المنافس', 'اشتريتَ التهديد، وصار جزءا منك.',
            const Effect(money: -12, tech: 10), cash: -80000, jump: 1),
        c('أركز على سوق متخصص', 'تركتَ السباق العام، وسيطرتَ على سوقك الخاص.',
            const Effect(money: 8, reputation: 4), jump: 1),
      ]),
  e('foundation', 40, 65, 'مؤسسة خيرية',
      'بعد النجاح، تفكر في تخصيص جزء من ثروتك لمؤسسة تعليم ذكاء اصطناعي للجميع.',
      [
        c('أنشئ المؤسسة', 'صار أثرك يتجاوز شركتك، إلى أجيال كاملة.',
            const Effect(reputation: 16, morale: 12, money: -8), cash: -50000, jump: 2),
        c('أركز على الشركة فقط', 'بقيتَ ثروتك في الشركة، وأثرك فيها.',
            const Effect(money: 6), jump: 1),
      ]),
  e('burnout', 30, 55, 'احتراق وظيفي',
      'سنوات من العمل المتواصل تصل بك إلى حافة الاحتراق. جسدك وعقلك يطلبان التوقف.',
      [
        c('أستريح سنة وأعيد ترتيب حياتي', 'عدتَ أقوى وأوضح رؤية.',
            const Effect(morale: 14, tech: -2, money: -4), jump: 2),
        c('أستمر رغم التعب', 'استمريتَ، ودفعتَ ثمنا من صحتك ومعنوياتك.',
            const Effect(morale: -14, tech: -4, money: 4), jump: 2),
      ]),
  e('next_gen', 45, 65, 'الجيل التالي',
      'جيل جديد من المؤسسين الشباب ينظر إليك كقدوة أو كعقبة. كيف تتعامل معهم؟',
      [
        c('أرشدهم وأستثمر فيهم', 'صرتَ معلما، وشبكة تلاميذك تتوسع.',
            const Effect(reputation: 12, social: 10, money: -4), cash: -20000, jump: 2),
        c('أنافسهم بشراسة', 'بقيتَ في القمة، لكن صورتك تغيرت.',
            const Effect(money: 8, reputation: -6), jump: 1),
      ]),
];

LifeEvent genericEvent(int age) {
  if (age < 30) {
    return e('generic_early', age, age, 'سنة في بداية الطريق',
        'سنة من التجارب: نماذج تفشل، وأفكار تتغير، وتعلم لا يتوقف.',
        [
          c('أركز على البحث', 'تقدمتَ بحثيا خطوة مهمة.',
              const Effect(research: 8, tech: 6), jump: 1),
          c('أركز على المنتج والسوق', 'اقتربتَ من المستخدمين أكثر.',
              const Effect(money: 8, social: 6), jump: 1),
        ]);
  }
  if (age < 50) {
    return e('generic_growth', age, age, 'سنة من النمو',
        'سنة من التوسع: فريق يكبر، ومنتجات تتعدد، وقرارات تصعب.',
        [
          c('أوسّع الفريق والمنتجات', 'نمو سريع، وتكاليف أعلى.',
              const Effect(money: 6, skill: 6, social: 4), jump: 1),
          c('أعمّق الجودة قبل التوسع', 'منتج أفضل، ونمو أبطأ.',
              const Effect(tech: 8, reputation: 6), jump: 1),
        ]);
  }
  return e('generic_late', age, age, 'سنة من النضج',
      'سنة هادئة نسبيا: شركتك مستقرة، وأنت تفكر في الإرث الذي ستتركه.',
      [
        c('أستثمر في الجيل القادم', 'أثرك يتوسع خارج شركتك.',
            const Effect(reputation: 8, social: 8), jump: 1),
        c('أركز على استقرار الشركة', 'استقرار وربح، دون مغامرات جديدة.',
            const Effect(money: 8, morale: 4), jump: 1),
      ]);
}
