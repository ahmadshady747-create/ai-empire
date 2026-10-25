import '../models.dart';
import 'events.dart';

/// سنوات التدبير في رحلة المؤسس: بين كل حدث مصيري، سنة تدير فيها
/// وقت شركتك بنفسك.
///
/// البند 6 (إيقاع متكامل)، الجولة الأولى: سنة التدبير لم تعد تتكرر
/// حرفيا. كل مرحلة لها ثلاثة إطارات سردية تدور مع عدد سنوات التدبير
/// التي مرّت (cycle)، فلا يقرأ اللاعب النص نفسه كل مرة، مع بقاء
/// الخيارات نفسها حتى لا يتغير توازن اللعبة. وفي المرحلة المتأخرة
/// يظهر خيار إرث إضافي: ما بنيته قديما (مستوى النموذج والإنجازات)
/// يبقى مؤثرا حتى النهاية، وأثره يكبر مع مستوى النموذج، فلا تموت
/// الأنظمة القديمة بمجرد تقدم العمر.
/// البند 6 (إيقاع متكامل)، الجولة الثانية: صدى أحداث العالم.
/// بعد النجاة من حدث عالمي، تحمل سنة التدبير التالية خيار متابعة
/// واحدا مرتبطا بذلك الحدث بالاسم، فلا يبقى الحدث العالمي شاشة
/// عابرة بل يتداخل مع إيقاع السنوات. النافذة تُغلق بعد سنة
/// التدبير تلك سواء أُخذ الخيار أم لا (يغلقها المحرك)، فلا يتكرر
/// الصدى ولا يعلق إلى الأبد.
/// البند 6 (إيقاع متكامل)، الجولة الثالثة: صدى القوس المتسلسل.
/// بعد حلّ فصل من قصة متسلسلة، تحمل سنة التدبير التالية خيار
/// متابعة واحدا مرتبطا باسم القوس، فتتداخل الأقواس مع سنوات
/// التدبير بدلا من أن تنتهي القصة عند فصلها. وقد يجتمع الصديان
/// في سنة واحدة فيظهر الخياران معا، وكلاهما يُغلق بعدها.
LifeEvent yearlyEventForAge(
  int age, {
  int cycle = 0,
  int modelLevel = 0,
  int achievementCount = 0,
  String? worldEchoTitle,
  String? arcEchoTitle,
}) {
  final base = _yearlyEventForAge(
    age,
    cycle: cycle,
    modelLevel: modelLevel,
    achievementCount: achievementCount,
  );
  if (worldEchoTitle == null && arcEchoTitle == null) return base;
  final extra = <EventChoice>[];
  if (worldEchoTitle != null) {
    extra.add(c(
      '🔁 أستثمر في درس "$worldEchoTitle": أحوّله إلى إجراء دائم في شركتي',
      'الدرس لم يبق ذكرى: صار إجراء دائما، وسمعتك وبحثك تقدما معا.',
      const Effect(reputation: 4, research: 6, money: 2),
      cash: 5000,
      jump: 1,
      focus: 'research',
    ));
  }
  if (arcEchoTitle != null) {
    extra.add(c(
      '🔁 أتابع قوس "$arcEchoTitle": أحوّل ما حدث فيه إلى علاقات وعقود دائمة',
      'القصة لم تنته عند فصلها: علاقاتها صارت عقودا، واسمك صار مرتبطا بها في السوق.',
      const Effect(social: 6, reputation: 4, tech: 4),
      cash: 3000,
      jump: 1,
      focus: 'social',
    ));
  }
  return LifeEvent(
    id: base.id,
    minAge: base.minAge,
    maxAge: base.maxAge,
    title: base.title,
    story: base.story,
    choices: [...base.choices, ...extra],
  );
}

LifeEvent _yearlyEventForAge(
  int age, {
  int cycle = 0,
  int modelLevel = 0,
  int achievementCount = 0,
}) {
  final frame = cycle % 3;
  if (age < 32) {
    const stories = [
      'سنة عادية في بداية الطريق: لا حدث مصيري، لكن تراكم السنوات العادية هو ما يصنع الشركة.',
      'سنة أخرى من البناء الهادئ: الفريق يكبر ببطء، والمنتج ينضج، ولا أحد يرى العمل خلف الكواليس بعد.',
      'سنة اختبار صبر: موارد محدودة وأسئلة كثيرة، لكن كل أسبوع عمل يضيف لبنة لا يراها أحد الآن.',
    ];
    return e('yearly_early', age, age, '🗓️ سنة من رحلتك: كيف تديرها؟',
        stories[frame],
        [
          c('أركز على البحث والتطوير', 'نماذجك تتحسن بصمت.',
              const Effect(research: 8, tech: 8, morale: -2), jump: 1, focus: 'research'),
          c('أركز على المبيعات والعملاء', 'إيرادك يكبر، وسمعتك تنتشر.',
              const Effect(money: 8, social: 6), cash: 5000, jump: 1, focus: 'sales'),
          c('أبني فريقي', 'فريق أقوى، وقدرة أكبر.',
              const Effect(skill: 8, social: 6), jump: 1, focus: 'team'),
          c('أستريح وأعيد التفكير', 'رؤية أوضح، وتقدم أبطأ.',
              const Effect(morale: 10, research: -2), jump: 1, focus: 'rest'),
          c('أجمع حوسبة رخيصة من تجارب صغيرة', 'حوسبة مخزنة لجولة '
              'التدريب القادمة، وتعلّم تراكمي.',
              const Effect(research: 4), compute: 10, jump: 1, focus: 'compute'),
        ]);
  }
  if (age < 50) {
    const stories = [
      'سنة من النمو: فريق وشركاء وأسواق، وكل قرار له ثمن.',
      'سنة توسع: عملاء جدد وأسواق جديدة، والقرار هنا ليس هل تنمو بل بأي ثمن تنمو.',
      'سنة مفترق: منتجك صار معروفا، والمنافسون يقلدونك، والسؤال صار عن العمق لا عن الانتشار.',
    ];
    return e('yearly_growth', age, age, '🗓️ سنة من رحلتك: كيف تديرها؟',
        stories[frame],
        [
          c('أتوسع إلى أسواق جديدة', 'انتشار أوسع، ومخاطر أكبر.',
              const Effect(money: 10, social: 8, morale: -2), cash: 10000, jump: 1, focus: 'sales'),
          c('أعمّق منتجي الحالي', 'جودة أعلى، وولاء عملاء أكبر.',
              const Effect(tech: 10, reputation: 6), jump: 1, focus: 'product'),
          c('أستثمر في البحث الطويل', 'رهان على المستقبل، دون عائد فوري.',
              const Effect(research: 10, tech: 6, money: -2), jump: 1, focus: 'research'),
          c('أركز على الربحية', 'مال أكثر، ونمو أبطأ.',
              const Effect(money: 12, morale: -2), cash: 15000, jump: 1, focus: 'profit'),
          c('أحجز حوسبة للتدريب القادم', 'تدفع الآن لتملك وقت حوسبة '
              'حين تحتاجه، بدل أن تشتريه غاليا وقت الذروة.',
              const Effect(tech: 4), cash: -10000, compute: 15, jump: 1, focus: 'compute'),
        ]);
  }
  const stories = [
    'سنة في مرحلة النضج: الإرث والاستقرار والجيل القادم.',
    'سنة إرث: ما بنيته صار أكبر منك، والسؤال لم يعد عن النمو بل عما سيبقى بعدك.',
    'سنة حسم هادئة: الجيل الجديد يطرق الباب، وخبرتك صارت أثمن من حماسك الأول.',
  ];
  // خيار الإرث: أثره يكبر مع مستوى النموذج الذي بلغته ومع عدد
  // إنجازاتك، فالنظامان القديمتان (التدريب والإنجازات) يدفعان
  // عائدا حقيقيا في كل سنة متأخرة، لا مجرد ذكر في شاشة النهاية.
  final legacyRep = 6 + modelLevel * 2 + (achievementCount >= 5 ? 2 : 0);
  final legacyMoney = 4 + modelLevel * 2;
  final legacyCash = modelLevel * 8000;
  return e('yearly_late', age, age, '🗓️ سنة من رحلتك: كيف تديرها؟',
      stories[frame],
      [
        c('أرشد مؤسسين شبابا', 'أثرك يتوسع، وسمعتك ترتفع.',
            const Effect(reputation: 10, social: 8), jump: 1, focus: 'team'),
        c('أستثمر في أبحاث جريئة', 'رهان أخير على اختراق كبير.',
            const Effect(research: 10, tech: 6, money: -4), jump: 1, focus: 'research'),
        c('أستقر وأحصد النتائج', 'سنة هادئة مربحة.',
            const Effect(money: 10, morale: 6), cash: 20000, jump: 1, focus: 'profit'),
        c(
          'أوظّف إرثي: أفتح نماذجي القديمة للجيل الجديد وأبيع خبرتي',
          'نماذجك من المستوى $modelLevel وإنجازاتك الـ $achievementCount صارت مرجعا: '
          'فرق شابة تدفع لتتعلم من تجربتك، وسمعتك تكبر لأن إرثك حيّ لا أرشيف.',
          Effect(reputation: legacyRep, social: 4, money: legacyMoney),
          cash: legacyCash,
          jump: 1,
          focus: 'legacy',
        ),
      ]);
}
