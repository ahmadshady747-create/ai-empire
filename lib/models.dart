import 'dart:math';

/// إحصاءات الشخصية السبع. كل قيمة بين 0 و 100.
/// المال هنا مستوى ثروة عام، أما الرصيد النقدي الفعلي فيحفظه المحرك.
class Stats {
  int tech;
  int morale;
  int research;
  int money;
  int social;
  int skill;
  int reputation;

  Stats({
    required this.tech,
    required this.morale,
    required this.research,
    required this.money,
    required this.social,
    required this.skill,
    required this.reputation,
  });

  factory Stats.random(Random r, {required int money}) {
    return Stats(
      tech: 60 + r.nextInt(36),
      morale: 50 + r.nextInt(36),
      research: 40 + r.nextInt(46),
      money: money,
      social: 45 + r.nextInt(41),
      skill: 20 + r.nextInt(41),
      reputation: 40 + r.nextInt(31),
    );
  }

  void apply(Effect e) {
    tech = _clamp(tech + e.tech);
    morale = _clamp(morale + e.morale);
    research = _clamp(research + e.research);
    money = _clamp(money + e.money);
    social = _clamp(social + e.social);
    skill = _clamp(skill + e.skill);
    reputation = _clamp(reputation + e.reputation);
  }

  static int _clamp(int v) => v < 0 ? 0 : (v > 100 ? 100 : v);

  List<(String label, String icon, int value)> asList() => [
        ('التقنية', '💻', tech),
        ('الروح المعنوية', '🔥', morale),
        ('البحث', '🧪', research),
        ('المال', '💰', money),
        ('العلاقات', '🤝', social),
        ('المهارة', '🛠️', skill),
        ('السمعة', '⭐', reputation),
      ];

  Map<String, int> toJson() => {
        'tech': tech,
        'morale': morale,
        'research': research,
        'money': money,
        'social': social,
        'skill': skill,
        'reputation': reputation,
      };

  factory Stats.fromJson(Map<String, dynamic> j) => Stats(
        tech: (j['tech'] as num).toInt(),
        morale: (j['morale'] as num).toInt(),
        research: (j['research'] as num).toInt(),
        money: (j['money'] as num).toInt(),
        social: (j['social'] as num).toInt(),
        skill: (j['skill'] as num?)?.toInt() ?? 30,
        reputation: (j['reputation'] as num?)?.toInt() ?? 50,
      );
}

/// أثر خيار واحد على الإحصاءات.
class Effect {
  final int tech;
  final int morale;
  final int research;
  final int money;
  final int social;
  final int skill;
  final int reputation;

  const Effect({
    this.tech = 0,
    this.morale = 0,
    this.research = 0,
    this.money = 0,
    this.social = 0,
    this.skill = 0,
    this.reputation = 0,
  });

  bool get isEmpty =>
      tech == 0 &&
      morale == 0 &&
      research == 0 &&
      money == 0 &&
      social == 0 &&
      skill == 0 &&
      reputation == 0;

  /// نص مختصر للتغيرات، مثل: +10 سعادة، -5 مال.
  String describe() {
    final parts = <String>[];
    void add(int v, String label) {
      if (v != 0) parts.add('${v > 0 ? '+' : ''}$v $label');
    }

    add(tech, 'تقنية');
    add(morale, 'معنويات');
    add(research, 'بحث');
    add(money, 'مال');
    add(social, 'شبكة علاقات');
    add(skill, 'مهارة');
    add(reputation, 'سمعة');
    return parts.join('، ');
  }
}

/// خيار واحد داخل حدث.
class EventChoice {
  final String text;
  final String outcome;
  final Effect effect;
  final List<String> addTraits;
  final List<String> removeTraits;
  final int ageJump;
  final String? deathCause;

  /// طموح حياة يختاره اللاعب مرة واحدة (مثل 'wealth' أو 'family').
  final String? ambition;

  /// وظيفة جديدة يبدأها هذا الخيار، مع راتب سنوي تقريبي بوحدات اللعبة.
  final String? job;
  final int jobSalary;

  /// تغير مباشر في الرصيد النقدي (ربح استثمار، دين، شراء...).
  final int cash;

  /// الفصل التالي في قصة متسلسلة، إن كان هذا الخيار يفتح واحدا.
  /// بهذا لا ينتهي القرار عند نتيجته، بل يحدد ما سيحدث بعد سنة.
  final String? nextId;

  const EventChoice({
    required this.text,
    required this.outcome,
    this.effect = const Effect(),
    this.addTraits = const [],
    this.removeTraits = const [],
    this.ageJump = 2,
    this.deathCause,
    this.ambition,
    this.job,
    this.jobSalary = 0,
    this.cash = 0,
    this.nextId,
  });
}

/// حدث واحد في حياة الشخص.
/// حقول المنطقة والاقتصاد تخص الأحداث العالمية فقط: فحدث حرب إقليمية
/// مثلا لا يناسب إلا من يعيش في ذلك الإقليم، وحدث أزمة اقتصادية يضرب
/// أكثر من يعيش في اقتصاد هش.
class LifeEvent {
  final String id;
  final int minAge;
  final int maxAge;
  final String title;
  final String story;
  final List<EventChoice> choices;
  final String? requiresTrait;
  final String? forbidsTrait;
  final String? region;
  final int? maxEconomy;
  final int? minEconomy;
  final bool isWorld;

  /// فصل في قصة متسلسلة، واسم القصة لعرضه في الواجهة.
  final bool isArcChapter;
  final String? arcName;

  const LifeEvent({
    required this.id,
    required this.minAge,
    required this.maxAge,
    required this.title,
    required this.story,
    required this.choices,
    this.requiresTrait,
    this.forbidsTrait,
    this.region,
    this.maxEconomy,
    this.minEconomy,
    this.isWorld = false,
    this.isArcChapter = false,
    this.arcName,
  });

  bool fits(
    int age,
    Set<String> traits,
    Set<String> used, {
    String? personRegion,
    int? personEconomy,
  }) {
    if (used.contains(id)) return false;
    if (age < minAge || age > maxAge) return false;
    if (requiresTrait != null && !traits.contains(requiresTrait)) return false;
    if (forbidsTrait != null && traits.contains(forbidsTrait)) return false;
    if (region != null && region != personRegion) return false;
    final maxEco = maxEconomy;
    if (maxEco != null && personEconomy != null && personEconomy > maxEco) {
      return false;
    }
    final minEco = minEconomy;
    if (minEco != null && personEconomy != null && personEconomy < minEco) {
      return false;
    }
    return true;
  }
}

/// دولة للولادة العشوائية.
/// الأرقام الأربعة الأخيرة ملف سياسات مبسّط لأغراض اللعب فقط (0-100)،
/// وليست بيانات رسمية: اقتصاد قوي يعني رواتب أعلى وأزمات أخف،
/// ورعاية صحية قوية تعني علاجا أرخص وأمراضا أخف، وأمان عالٍ يعني
/// حروبا وجرائم أقل، وتعليم قوي يعني دراسة أرخص وأفضل.
class Country {
  final String name;
  final String flag;
  final int weight;
  final List<String> maleNames;
  final List<String> femaleNames;
  final List<String> surnames;
  final String region;
  final int economy;
  final int techcare;
  final int safety;
  final int education;

  const Country({
    required this.name,
    required this.flag,
    required this.weight,
    required this.maleNames,
    required this.femaleNames,
    required this.surnames,
    required this.region,
    required this.economy,
    required this.techcare,
    required this.safety,
    required this.education,
  });
}

/// الشخصية المولودة عشوائيا.
class Person {
  final String firstName;
  final String lastName;
  final String country;
  final String flag;
  final bool isMale;
  final int birthYear;
  final String familyClass;
  final String company;

  const Person({
    required this.firstName,
    required this.lastName,
    required this.country,
    required this.flag,
    required this.isMale,
    required this.birthYear,
    required this.familyClass,
    required this.company,
  });

  String get fullName => '$firstName $lastName';
  String get genderLabel => isMale ? 'ذكر' : 'أنثى';

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'country': country,
        'flag': flag,
        'isMale': isMale,
        'birthYear': birthYear,
        'familyClass': familyClass,
        'company': company,
      };

  factory Person.fromJson(Map<String, dynamic> j) => Person(
        firstName: j['firstName'] as String,
        lastName: j['lastName'] as String,
        country: j['country'] as String,
        flag: j['flag'] as String,
        isMale: j['isMale'] as bool,
        birthYear: (j['birthYear'] as num).toInt(),
        familyClass: j['familyClass'] as String,
        company: j['company'] as String? ?? 'شركة ناشئة',
      );
}

/// سطر واحد في سجل الحياة.
class LogEntry {
  final int age;
  final String title;
  final String choice;
  final String outcome;

  const LogEntry({
    required this.age,
    required this.title,
    required this.choice,
    required this.outcome,
  });

  Map<String, dynamic> toJson() => {
        'age': age,
        'title': title,
        'choice': choice,
        'outcome': outcome,
      };

  factory LogEntry.fromJson(Map<String, dynamic> j) => LogEntry(
        age: (j['age'] as num).toInt(),
        title: j['title'] as String,
        choice: j['choice'] as String,
        outcome: j['outcome'] as String,
      );
}

/// رؤية الشركة التي يختارها اللاعب في بداية الرحلة.
const ambitionLabels = {
  'dominance': 'رؤية الهيمنة السوقية',
  'agi': 'رؤية الذكاء العام',
  'opensource': 'رؤية المصدر المفتوح',
  'profit': 'رؤية الربحية المستدامة',
};

/// الإنجازات القابلة للفتح خلال الرحلة.
const achievementLabels = {
  'age50': '🏅 مسيرة 25 سنة في الذكاء الاصطناعي',
  'age80': '🏆 أسطورة المجال',
  'graduate': '🎓 دكتوراه في الذكاء الاصطناعي',
  'business': '🏢 أسس شركة',
  'rich': '💰 بلغ ثروة 90 أو أكثر',
  'traveler': '✈️ حاضر دائم في المؤتمرات',
  'techy': '💻 بلغ تقنية 90 أو أكثر',
  'famous': '⭐ بلغ سمعة 90 أو أكثر',
  'survivor': '🛡️ نجا من أزمة عالمية',
  'unicorn': '🦄 شركة بقيمة مليارية',
  'firstmodel': '🤖 أطلق نموذجه الأول',
};

String stageLabel(int age) {
  if (age < 26) return 'مرحلة المرآب';
  if (age < 33) return 'شركة ناشئة';
  if (age < 46) return 'شركة نامية';
  if (age < 58) return 'شركة كبرى';
  return 'إمبراطورية';
}

String stageEmoji(int age, bool isMale) {
  if (age < 26) return '💻';
  if (age < 33) return '🚀';
  if (age < 46) return '🏢';
  if (age < 58) return '🏭';
  return '👑';
}

/// أسماء السمات بالعربية لعرضها كشارات.
const traitLabels = {
  'student': 'طالب دكتوراه',
  'graduate': 'حاصل على دكتوراه',
  'employed': 'موظف',
  'partner': 'شريك مؤسس',
  'business': 'صاحب شركة',
  'traveler': 'حاضر مؤتمرات',
  'retired': 'متقاعد',
  'funded': 'مموّل',
  'unicorn': 'يونيكورن',
  'opensource': 'مفتوح المصدر',
  'firstmodel': 'أطلق نموذجا',
};
