import 'package:flutter/material.dart';

import '../management.dart';
import '../theme/empire_theme.dart';

enum StorySpeaker {
  sami, // سامي المنصور — الشريك التقني CTO
  layla, // ليلى الحربي — مديرة العمليات والمالية COO
  karim, // كريم زيدان — الصحفي التقني
  vance, // د. ألكسندر فانس — المستثمر الغامض
}

class CharacterProfile {
  final StorySpeaker speaker;
  final String name;
  final String role;
  final Color color;
  final IconData emblem;

  const CharacterProfile({
    required this.speaker,
    required this.name,
    required this.role,
    required this.color,
    required this.emblem,
  });
}

const Map<StorySpeaker, CharacterProfile> storyCast = {
  StorySpeaker.sami: CharacterProfile(
    speaker: StorySpeaker.sami,
    name: 'سامي المنصور',
    role: 'الشريك التقني (CTO)',
    color: EmpireColors.cyan,
    emblem: Icons.memory_rounded,
  ),
  StorySpeaker.layla: CharacterProfile(
    speaker: StorySpeaker.layla,
    name: 'ليلى الحربي',
    role: 'مديرة العمليات (COO)',
    color: EmpireColors.emerald,
    emblem: Icons.analytics_rounded,
  ),
  StorySpeaker.karim: CharacterProfile(
    speaker: StorySpeaker.karim,
    name: 'كريم زيدان',
    role: 'صحفي ومحلل سوق AI',
    color: EmpireColors.sky,
    emblem: Icons.podcasts_rounded,
  ),
  StorySpeaker.vance: CharacterProfile(
    speaker: StorySpeaker.vance,
    name: 'د. ألكسندر فانس',
    role: 'مستثمر استراتيجي',
    color: EmpireColors.gold,
    emblem: Icons.diamond_rounded,
  ),
};

class StoryLine {
  final StorySpeaker speaker;
  final String text;

  const StoryLine(this.speaker, this.text);
}

class StoryChoice {
  final String label;
  final List<String> impactTags;
  final String epilogue;
  final void Function(ManagementState state) apply;

  const StoryChoice({
    required this.label,
    required this.impactTags,
    required this.epilogue,
    required this.apply,
  });
}

class StoryChapter {
  final String id;
  final int chapterNumber;
  final String title;
  final String unlockHint;
  final bool Function(ManagementState state) shouldTrigger;
  final List<StoryLine> dialogue;
  final StoryChoice choiceA;
  final StoryChoice choiceB;

  const StoryChapter({
    required this.id,
    required this.chapterNumber,
    required this.title,
    required this.unlockHint,
    required this.shouldTrigger,
    required this.dialogue,
    required this.choiceA,
    required this.choiceB,
  });
}

final List<StoryChapter> storyChapters = [
  StoryChapter(
    id: 'ch1_spark',
    chapterNumber: 1,
    title: 'الفصل 1: شرارة المرآب',
    unlockHint: 'يُفتح في الأسبوع 3',
    shouldTrigger: (s) => s.week >= 3,
    dialogue: const [
      StoryLine(
        StorySpeaker.sami,
        'المراوح تدور بأقصى سرعتها، لكن النموذج الأولي بدأ يجيب بذكاء مذهل! لو ضغطنا أكثر هذا الأسبوع قد نلفت أنظار السوق.',
      ),
      StoryLine(
        StorySpeaker.layla,
        'انتبه يا سامي؛ OpenMind وDeepVortex يراقبان كل مختبر ناشئ. قرارنا الآن سيحدد هل نراهن على السرعة أم على استقرار السيولة.',
      ),
    ],
    choiceA: StoryChoice(
      label: 'نراهن على قفزة تقنية جريئة',
      impactTags: const ['+18 تدريب', '+6 سمعة', '-5000 نقد'],
      epilogue: 'أطلقتم سباق تطوير ليلياً قفز بالتدريب وأشعل حماس الفريق.',
      apply: (s) {
        s.trainingProgress = (s.trainingProgress + 18).clamp(0, 100);
        s.reputation = (s.reputation + 6).clamp(0, 100);
        s.cash = (s.cash - 5000).clamp(0, 999999999);
      },
    ),
    choiceB: StoryChoice(
      label: 'نثبّت الأساس المالي أولاً',
      impactTags: const ['+12000 نقد', '+8 جودة بيانات'],
      epilogue: 'نجحت ليلى في إبرام عقد مبكر نظّف البيانات وأمّن خزينة الشركة.',
      apply: (s) {
        s.cash += 12000;
        s.dataQuality = (s.dataQuality + 8).clamp(0, 100);
      },
    ),
  ),
  StoryChapter(
    id: 'ch2_spotlight',
    chapterNumber: 2,
    title: 'الفصل 2: تحت الأضواء',
    unlockHint: 'يُفتح في الأسبوع 6',
    shouldTrigger: (s) => s.week >= 6,
    dialogue: const [
      StoryLine(
        StorySpeaker.karim,
        'مساء الخير! مقالي القادم يتحدث عن الصاعد الجديد الذي يهدد احتكار OpenMind. هل أنتم مستعدون لمقابلة جريئة تكشف أرقامكم؟',
      ),
      StoryLine(
        StorySpeaker.layla,
        'الظهور الإعلامي قد يضاعف المستخدمين في ليلة واحدة، لكنه سيجعل AnthroCore يسرّع وتيرته ضدنا.',
      ),
    ],
    choiceA: StoryChoice(
      label: 'تحدَّ العمالقة علناً في المقابلة',
      impactTags: const ['+320 مستخدم', '+10 سمعة'],
      epilogue: 'تصدّر اسم شركتك عناوين التقنية وتدفق المستخدمون على منتجاتك.',
      apply: (s) {
        s.users += 320;
        s.reputation = (s.reputation + 10).clamp(0, 100);
      },
    ),
    choiceB: StoryChoice(
      label: 'اعمل بصمت وركّز على البحث',
      impactTags: const ['+20 بحث', '+10 حداثة بيانات'],
      epilogue: 'تفاديتم الضوضاء الإعلامية وحققتم اختراقاً بحثياً هادئاً.',
      apply: (s) {
        s.researchProgress = (s.researchProgress + 20).clamp(0, 100);
        s.dataFreshness = (s.dataFreshness + 10).clamp(0, 100);
      },
    ),
  ),
  StoryChapter(
    id: 'ch3_chip_war',
    chapterNumber: 3,
    title: 'الفصل 3: حرب الرقائق',
    unlockHint: 'يُفتح في الأسبوع 10',
    shouldTrigger: (s) => s.week >= 10,
    dialogue: const [
      StoryLine(
        StorySpeaker.vance,
        'أعجبني صمودكم حتى الآن. سلاسل توريد الرقائق تختنق، وDeepVortex تحاول احتكار الشحنات. أستطيع فتح خط حوسبة خاص لكم الليلة.',
      ),
      StoryLine(
        StorySpeaker.sami,
        'هذه الحوسبة قد تختصر علينا شهراً كاملاً من التدريب، لكنها ليست مجانية!',
      ),
    ],
    choiceA: StoryChoice(
      label: 'اقبل صفقة د. فانس للحوسبة',
      impactTags: const ['+35 حوسبة', '-8000 نقد'],
      epilogue: 'امتلأت رفوف مركز البيانات ببطاقات جديدة جاهزة للتدريب المكثف.',
      apply: (s) {
        s.computeAvailable = (s.computeAvailable + 35).clamp(0, 200);
        s.cash = (s.cash - 8000).clamp(0, 999999999);
      },
    ),
    choiceB: StoryChoice(
      label: 'اعتمد على تحسين الكفاءة داخلياً',
      impactTags: const ['+15 تدريب', '+10000 نقد'],
      epilogue: 'ابتكر فريقك ضغطاً ذكياً للنماذج وفّر عليكم تكلفة التوسعة.',
      apply: (s) {
        s.trainingProgress = (s.trainingProgress + 15).clamp(0, 100);
        s.cash += 10000;
      },
    ),
  ),
  StoryChapter(
    id: 'ch4_breakthrough',
    chapterNumber: 4,
    title: 'الفصل 4: اختراق الجيل الجديد',
    unlockHint: 'يُفتح عند بلوغ النموذج المستوى 3',
    shouldTrigger: (s) => s.modelLevel >= 3,
    dialogue: const [
      StoryLine(
        StorySpeaker.sami,
        'فعلناها! اختبارات القياس تؤكد أن نموذجنا بالمستوى 3 ينافس أقوى ما لدى OpenMind وAnthroCore!',
      ),
      StoryLine(
        StorySpeaker.karim,
        'السوق يغلي الآن — الشركات الكبرى تنتظر هل ستفتتحون شراكات مؤسسية أم ستتوسعون لجمهور المستخدمين.',
      ),
    ],
    choiceA: StoryChoice(
      label: 'حملة توسع جماهيري ضخمة',
      impactTags: const ['+600 مستخدم', '+8 سمعة'],
      epilogue: 'انفجرت شعبية منتجك بين المطورين والطلاب حول العالم.',
      apply: (s) {
        s.users += 600;
        s.reputation = (s.reputation + 8).clamp(0, 100);
      },
    ),
    choiceB: StoryChoice(
      label: 'عقود مؤسسية عالية القيمة',
      impactTags: const ['+28000 نقد', '+5 سمعة'],
      epilogue: 'وقّعت ليلى سلسلة عقود مؤسسية ضخّت سيولة تاريخية في الخزينة.',
      apply: (s) {
        s.cash += 28000;
        s.reputation = (s.reputation + 5).clamp(0, 100);
      },
    ),
  ),
  StoryChapter(
    id: 'ch5_summit',
    chapterNumber: 5,
    title: 'الفصل 5: قمة الذكاء العالمية',
    unlockHint: 'يُفتح في الأسبوع 15',
    shouldTrigger: (s) => s.week >= 15,
    dialogue: const [
      StoryLine(
        StorySpeaker.vance,
        'دُعيتم إلى القمة المغلقة لقادة الذكاء الاصطناعي. عرض الاستحواذ على الطاولة، أو يمكنك إعلان خطتك لبناء إمبراطورية مستقلة.',
      ),
      StoryLine(
        StorySpeaker.layla,
        'كل الأنظار عليك. خطابك اليوم إما يجذب أفضل العقول في العالم أو يؤمّن لنا جولة تمويل أسطورية.',
      ),
    ],
    choiceA: StoryChoice(
      label: 'أعلن رؤية الإمبراطورية المستقلة',
      impactTags: const ['+12 سمعة', '+25 بحث', '+25 تدريب'],
      epilogue: 'أشعل خطابك الحماس وتطوعت نخبة من الباحثين للانضمام لمشروعك.',
      apply: (s) {
        s.reputation = (s.reputation + 12).clamp(0, 100);
        s.researchProgress = (s.researchProgress + 25).clamp(0, 100);
        s.trainingProgress = (s.trainingProgress + 25).clamp(0, 100);
      },
    ),
    choiceB: StoryChoice(
      label: 'وقّع تحالف تمويل استراتيجي',
      impactTags: const ['+40000 نقد', '+20 حوسبة'],
      epilogue: 'حصلتم على أكبر دفعة تمويل وحوسبة منذ تأسيس الشركة.',
      apply: (s) {
        s.cash += 40000;
        s.computeAvailable = (s.computeAvailable + 20).clamp(0, 200);
      },
    ),
  ),
  StoryChapter(
    id: 'ch6_throne',
    chapterNumber: 6,
    title: 'الفصل 6: على أعتاب العرش',
    unlockHint: 'يُفتح عند بلوغ الترتيب #1 لأول مرة',
    shouldTrigger: (s) => s.rank == 1 && s.week >= 3,
    dialogue: const [
      StoryLine(
        StorySpeaker.karim,
        'خبر عاجل: شركتك تتصدر التصنيف العالمي للذكاء الاصطناعي رسمياً فوق OpenMind وAnthroCore وDeepVortex!',
      ),
      StoryLine(
        StorySpeaker.sami,
        'الوصول للقمة صعب، لكن البقاء عليها أربعة أسابيع متتالية هو الامتحان الحقيقي. لنحسم السباق!',
      ),
    ],
    choiceA: StoryChoice(
      label: 'اضغط بأقصى طاقة لحسم الصدارة',
      impactTags: const ['+20 تدريب', '+15 حوسبة'],
      epilogue: 'كل أنظمة الشركة تعمل الآن بانسجام تام لتثبيت العرش.',
      apply: (s) {
        s.trainingProgress = (s.trainingProgress + 20).clamp(0, 100);
        s.computeAvailable = (s.computeAvailable + 15).clamp(0, 200);
      },
    ),
    choiceB: StoryChoice(
      label: 'حصّن الخزينة والسمعة ضد أي هجوم',
      impactTags: const ['+25000 نقد', '+10 سمعة'],
      epilogue: 'باتت شركتك محصنة مالياً وإعلامياً ضد أي رد فعل من المنافسين.',
      apply: (s) {
        s.cash += 25000;
        s.reputation = (s.reputation + 10).clamp(0, 100);
      },
    ),
  ),
];

/// يعيد أول فصل قصة لم يُشاهد بعد وتحقق شرط فتحه.
StoryChapter? nextPendingStoryChapter(
  ManagementState state,
  Set<String> completedIds,
) {
  for (final ch in storyChapters) {
    if (!completedIds.contains(ch.id) && ch.shouldTrigger(state)) {
      return ch;
    }
  }
  return null;
}
