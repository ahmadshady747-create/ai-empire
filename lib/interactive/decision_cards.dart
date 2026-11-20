import 'package:flutter/material.dart';

import '../management.dart';
import '../theme/empire_theme.dart';

/// خيار واحد داخل بطاقة القرار السريع.
class DecisionOption {
  final String label;
  final List<String> impactTags;
  final String resultNote;
  final void Function(ManagementState state) apply;

  const DecisionOption({
    required this.label,
    required this.impactTags,
    required this.resultNote,
    required this.apply,
  });
}

/// بطاقة موقف وقرار سريع (بأسلوب Reigns / Game Dev Tycoon)
/// تظهر كل أسبوعين لخلق مواقف حيّة بخيارين واضحين وأثر فوري.
class DecisionCardModel {
  final String id;
  final String category;
  final String title;
  final String story;
  final IconData icon;
  final Color accent;
  final DecisionOption optionA;
  final DecisionOption optionB;

  const DecisionCardModel({
    required this.id,
    required this.category,
    required this.title,
    required this.story,
    required this.icon,
    required this.accent,
    required this.optionA,
    required this.optionB,
  });
}

final List<DecisionCardModel> decisionDeck = [
  DecisionCardModel(
    id: 'influencer_demo',
    category: 'تسويق وإعلام',
    title: 'صانع محتوى تقني يطلب تجربة نموذجك',
    story:
        'مؤثر شهير يريد بثاً مباشراً لتجربة منتجك أمام مئات الآلاف. قد ينفجر عدد المستخدمين أو تظهر أخطاء محرجة.',
    icon: Icons.live_tv_rounded,
    accent: EmpireColors.sky,
    optionA: DecisionOption(
      label: 'وافق على البث المباشر',
      impactTags: const ['+180 مستخدم', '+4 سمعة', '-2500 نقد'],
      resultNote: 'البث نجح وجذب موجة مستخدمين جدد مع تكلفة تجهيز خوادم.',
      apply: (s) {
        s.users += 180;
        s.reputation = (s.reputation + 4).clamp(0, 100);
        s.cash = (s.cash - 2500).clamp(0, 999999999);
      },
    ),
    optionB: DecisionOption(
      label: 'أرسل نسخة مسجّلة آمنة',
      impactTags: const ['+60 مستخدم', '+2 سمعة'],
      resultNote: 'تغطية هادئة وآمنة رفعت السمعة دون ضغط على السيولة.',
      apply: (s) {
        s.users += 60;
        s.reputation = (s.reputation + 2).clamp(0, 100);
      },
    ),
  ),
  DecisionCardModel(
    id: 'angel_investor',
    category: 'تمويل عاجل',
    title: 'مستثمر ملائكي يعرض منحة سريعة',
    story:
        'مستثمر معجب بوتيرة فريقك يعرض ضخ سيولة فورية، لكنه يطلب تركيزاً مؤقتاً على عرض تجاري سريع.',
    icon: Icons.handshake_rounded,
    accent: EmpireColors.gold,
    optionA: DecisionOption(
      label: 'اقبل التمويل الفوري',
      impactTags: const ['+14000 نقد', '-8 بحث'],
      resultNote: 'دخلت السيولة خزينتك فوراً مقابل تباطؤ مؤقت في مسار البحث.',
      apply: (s) {
        s.cash += 14000;
        s.researchProgress = (s.researchProgress - 8).clamp(0, 100);
      },
    ),
    optionB: DecisionOption(
      label: 'ارفض وحافظ على الاستقلالية',
      impactTags: const ['+8 بحث', '+3 سمعة'],
      resultNote: 'أشاد الفريق باستقلالية القرار وتسارع تقدم البحث.',
      apply: (s) {
        s.researchProgress = (s.researchProgress + 8).clamp(0, 100);
        s.reputation = (s.reputation + 3).clamp(0, 100);
      },
    ),
  ),
  DecisionCardModel(
    id: 'gpu_flash_sale',
    category: 'بنية تحتية',
    title: 'عرض تصفية لخوادم GPU مستعملة',
    story:
        'شركة ناشئة أغلقت أبوابها وتبيع حزمة بطاقات حوسبة بنصف السعر خلال 24 ساعة فقط.',
    icon: Icons.memory_rounded,
    accent: EmpireColors.cyan,
    optionA: DecisionOption(
      label: 'اقتنص الصفقة الآن',
      impactTags: const ['+20 حوسبة', '-2500 نقد'],
      resultNote: 'ارتفعت حوسبتك المتاحة بسعر استثنائي.',
      apply: (s) {
        if (s.cash >= 2500) {
          s.cash -= 2500;
          s.computeAvailable = (s.computeAvailable + 20).clamp(0, 200);
        } else {
          s.computeAvailable = (s.computeAvailable + 8).clamp(0, 200);
        }
      },
    ),
    optionB: DecisionOption(
      label: 'وفّر النقد واستخدمه بالتدريب',
      impactTags: const ['+10 تدريب'],
      resultNote: 'حسّن فريقك كفاءة التدريب على الخوادم الحالية.',
      apply: (s) {
        s.trainingProgress = (s.trainingProgress + 10).clamp(0, 100);
      },
    ),
  ),
  DecisionCardModel(
    id: 'open_source_release',
    category: 'مجتمع المطورين',
    title: 'نشر أداة مساعدة مفتوحة المصدر؟',
    story:
        'مهندسوك يقترحون فتح مصدر مكتبة داخلية لتنظيف النصوص؛ قد يكسبك ذلك تعاطف المطورين أو يفيد منافسيك.',
    icon: Icons.code_rounded,
    accent: EmpireColors.indigo,
    optionA: DecisionOption(
      label: 'انشرها مفتوحة المصدر',
      impactTags: const ['+7 سمعة', '+120 مستخدم', '+6 جودة بيانات'],
      resultNote: 'ساهم المجتمع في تحسين أدواتك وارتفعت سمعتك بقوة.',
      apply: (s) {
        s.reputation = (s.reputation + 7).clamp(0, 100);
        s.users += 120;
        s.dataQuality = (s.dataQuality + 6).clamp(0, 100);
      },
    ),
    optionB: DecisionOption(
      label: 'أبقِها سرية وبِعها كترخيص',
      impactTags: const ['+9000 نقد', '-2 سمعة'],
      resultNote: 'حققت إيراداً سريعاً من ترخيص الأداة لشركات أخرى.',
      apply: (s) {
        s.cash += 9000;
        s.reputation = (s.reputation - 2).clamp(0, 100);
      },
    ),
  ),
  DecisionCardModel(
    id: 'security_bug',
    category: 'أزمة تقنية',
    title: 'باحث أمني يكتشف ثغرة في واجهة API',
    story:
        'تلقيت تقريراً خاصاً عن ثغرة تسمح بتجاوز حدود الاستخدام. كيف تتصرف؟',
    icon: Icons.security_rounded,
    accent: EmpireColors.coral,
    optionA: DecisionOption(
      label: 'ادفع مكافأة وأصلحها علناً',
      impactTags: const ['-3500 نقد', '+8 سمعة'],
      resultNote: 'تحوّلت الأزمة إلى قصة شفافية عززت ثقة السوق بشركتك.',
      apply: (s) {
        s.cash = (s.cash - 3500).clamp(0, 999999999);
        s.reputation = (s.reputation + 8).clamp(0, 100);
      },
    ),
    optionB: DecisionOption(
      label: 'أصلحها بصمت دون مكافأة',
      impactTags: const ['-5 سمعة', '+4 تدريب'],
      resultNote: 'تسرّب خبر الثغرة وأثّر قليلاً على السمعة لكنك وفّرت النقد.',
      apply: (s) {
        s.reputation = (s.reputation - 5).clamp(0, 100);
        s.trainingProgress = (s.trainingProgress + 4).clamp(0, 100);
      },
    ),
  ),
  DecisionCardModel(
    id: 'university_grant',
    category: 'شراكة بحثية',
    title: 'جامعة تقنية تطلب شراكة بيانات',
    story:
        'مختبر أكاديمي يعرض تبادل مجموعات بيانات نظيفة وحديثة مقابل حصة حوسبة مؤقتة.',
    icon: Icons.school_rounded,
    accent: EmpireColors.emerald,
    optionA: DecisionOption(
      label: 'وقّع الشراكة الأكاديمية',
      impactTags: const ['+12 جودة', '+15 حداثة', '+10 بحث'],
      resultNote: 'قفزت جودة وحداثة بياناتك وتسارع البحث بشكل ملحوظ.',
      apply: (s) {
        s.dataQuality = (s.dataQuality + 12).clamp(0, 100);
        s.dataFreshness = (s.dataFreshness + 15).clamp(0, 100);
        s.researchProgress = (s.researchProgress + 10).clamp(0, 100);
      },
    ),
    optionB: DecisionOption(
      label: 'اعرض عليهم اشتراكاً مدفوعاً',
      impactTags: const ['+8000 نقد', '+50 مستخدم'],
      resultNote: 'تحولت الجامعة إلى عميل مدفوع زاد نقدك ومستخدميك.',
      apply: (s) {
        s.cash += 8000;
        s.users += 50;
      },
    ),
  ),
  DecisionCardModel(
    id: 'enterprise_pilot',
    category: 'صفقة كبرى',
    title: 'بنك إقليمي يطلب تجربة نموذجك',
    story:
        'إدارة بنك كبير تطلب اختباراً سريعاً لخدمة تحليل العقود، ما يعني عوائد كبيرة أو ضغطاً على الفريق.',
    icon: Icons.apartment_rounded,
    accent: EmpireColors.gold,
    optionA: DecisionOption(
      label: 'أطلق التجربة فوراً',
      impactTags: const ['+16000 نقد', '+5 سمعة', '-10 حوسبة'],
      resultNote: 'نجح العرض التجريبي وأدرّ عوائد قوية مع استهلاك جزء من الحوسبة.',
      apply: (s) {
        s.cash += 16000;
        s.reputation = (s.reputation + 5).clamp(0, 100);
        s.computeAvailable = (s.computeAvailable - 10).clamp(0, 200);
      },
    ),
    optionB: DecisionOption(
      label: 'أجّلها وركّز على النموذج',
      impactTags: const ['+14 تدريب'],
      resultNote: 'تفرغ الفريق بالكامل وحقق قفزة قوية في تقدم التدريب.',
      apply: (s) {
        s.trainingProgress = (s.trainingProgress + 14).clamp(0, 100);
      },
    ),
  ),
  DecisionCardModel(
    id: 'team_hackathon',
    category: 'ثقافة الفريق',
    title: 'هاكاثون داخلي لمدة 48 ساعة',
    story:
        'الفريق متحمس لتجربة أفكار جريئة خارج الخطة الرسمية في عطلة نهاية الأسبوع.',
    icon: Icons.rocket_launch_rounded,
    accent: EmpireColors.indigo,
    optionA: DecisionOption(
      label: 'ادعم الهاكاثون بميزانية صغيرة',
      impactTags: const ['-2000 نقد', '+12 تدريب', '+10 بحث'],
      resultNote: 'أثمر الهاكاثون تحسينات مذهلة في التدريب والبحث معاً.',
      apply: (s) {
        s.cash = (s.cash - 2000).clamp(0, 999999999);
        s.trainingProgress = (s.trainingProgress + 12).clamp(0, 100);
        s.researchProgress = (s.researchProgress + 10).clamp(0, 100);
      },
    ),
    optionB: DecisionOption(
      label: 'امنح الفريق إجازة للراحة',
      impactTags: const ['+5 سمعة', '+4 جودة بيانات'],
      resultNote: 'ارتفعت معنويات الفريق وانعكست على جودة العمل.',
      apply: (s) {
        s.reputation = (s.reputation + 5).clamp(0, 100);
        s.dataQuality = (s.dataQuality + 4).clamp(0, 100);
      },
    ),
  ),
];

/// يعيد بطاقة قرار كل أسبوعين (الأسبوع 2، 4، 6...) ما لم يكن هناك حدث عالمي.
DecisionCardModel? pickDecisionForWeek(int week) {
  if (week < 2 || week % 2 != 0) return null;
  final idx = ((week ~/ 2) - 1) % decisionDeck.length;
  return decisionDeck[idx];
}
