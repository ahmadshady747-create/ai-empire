import '../models.dart';

/// القصص المتسلسلة للعبة الذكاء الاصطناعي.
/// البداية تدخل في المجموعة العادية للأحداث، والفصل التالي يُفرض
/// عبر nextId في المحرك، فلا ينتهي القرار عند نتيجته بل يحدد
/// ما سيحدث بعده. أحداث العالم هنا سيناريوهات محاكاة مستوحاة من
/// اتجاهات عامة، ليست بيانات رسمية ولا تنبؤات.
const arcStarters = <LifeEvent>[
  LifeEvent(
    id: 'arc_launch',
    minAge: 26,
    maxAge: 45,
    title: 'ليلة الإطلاق الكبير',
    story:
        'نموذجك الجديد جاهز أخيرا، بعد سنتين من العمل والسهر. الصحافة '
        'تنتظر، والمستثمرون يراقبون، والمنافسون يتربصون. الليلة وحدها '
        'ستحدد كيف سيراك العالم: مفتوحا للجميع، أم مغلقا ثمينا، أم '
        'متأنيا حتى الكمال؟',
    choices: [
      EventChoice(
        text: 'إطلاق مفتوح المصدر للجميع',
        outcome:
            'انتشر النموذج كالنار، وصار اسم شركتك على كل لسان. لكن بعد '
            'أسابيع، أطلق منافس نسخة مطابقة تقريبا، مدعيا أنها من بنائه.',
        effect: Effect(reputation: 14, social: 10, money: -6),
        addTraits: ['opensource'],
        ageJump: 1,
        nextId: 'launch_open',
      ),
      EventChoice(
        text: 'إطلاق مغلق بسعر مرتفع',
        outcome:
            'اشترت الشركات الكبرى النموذج بسعر عال، وامتلأ رصيدك. لكن '
            'صحفيا شهيرا كتب مقالا يتهمك باحتكار الذكاء وحجبه عن الناس.',
        effect: Effect(money: 14, reputation: -4),
        ageJump: 1,
        nextId: 'launch_closed',
      ),
      EventChoice(
        text: 'تأجيل الإطلاق لإصلاح الثغرات',
        outcome:
            'اخترتَ الكمال على السرعة. وبينما كنتَ تصلح الثغرات، أعلن '
            'منافس أصغر منك إطلاق نموذج مشابه، وسرق الأضواء كلها.',
        effect: Effect(tech: 10, research: 8, morale: -6),
        ageJump: 1,
        nextId: 'launch_delay',
      ),
    ],
  ),
];

const arcChapters = <LifeEvent>[
  LifeEvent(
    id: 'launch_open',
    minAge: 0,
    maxAge: 120,
    title: 'الكل ينسخ نموذجك',
    story:
        'نموذجك المفتوح صار أساسا لعشرات المنتجات، ومنافسك يبيع نسخة '
        'منه باسم مختلف. المجتمع منقسم: بعضهم يدافع عنك، وبعضهم يقول '
        'إن المفتوح ملك للجميع. ماذا تفعل؟',
    choices: [
      EventChoice(
        text: 'أقاضي المنافس',
        outcome:
            'ربحتَ القضية وتعويضا ماليا بعد معركة طويلة، لكن صورتك تغيرت: صار البعض '
            'يراك مدافعا عن الملكية لا عن الانفتاح.',
        effect: Effect(reputation: 6, money: 6, social: -6),
        cash: 40000,
        ageJump: 2,
      ),
      EventChoice(
        text: 'أحتضن النسخ وأبني المجتمع',
        outcome:
            'دعوتَ كل من نسخ النموذج إلى مجتمعك، فصار مجتمعك أكبر من '
            'أي شركة، وصار اسمك مرادفا للانفتاح نفسه.',
        effect: Effect(social: 14, reputation: 10, money: -4),
        ageJump: 1,
      ),
      EventChoice(
        text: 'أطلق نسخة أقوى مغلقة',
        outcome:
            'تركتَ النسخة المفتوحة للجميع، وأطلقتَ نسخة أقوى مدفوعة. '
            'المنافس بقي خلفك بخطوة، لكن بعض المجتمع شعر بالخذلان.',
        effect: Effect(tech: 12, money: 8, morale: -4, social: -4),
        ageJump: 2,
      ),
    ],
    isArcChapter: true,
    arcName: 'إطلاق النموذج الكبير',
  ),
  LifeEvent(
    id: 'launch_closed',
    minAge: 0,
    maxAge: 120,
    title: 'اتهام بالاحتكار',
    story:
        'مقال الصحفي انتشر، وصارت شركتك حديث المجالس: هل أنتَ مبتكر '
        'أم محتكر؟ المستثمرون قلقون، والمجتمع غاضب، والمنافسون '
        'يستغلون الفرصة. كيف ترد؟',
    choices: [
      EventChoice(
        text: 'أخفّض السعر للجميع',
        outcome:
            'انخفضت أرباحك، لكن الغضب خمد، وصارت شركتك تُذكر كمثال '
            'على شركة تراجعت بشجاعة.',
        effect: Effect(money: -10, reputation: 14),
        ageJump: 1,
      ),
      EventChoice(
        text: 'أتجاهل الاتهام تماما',
        outcome:
            'استمرت المبيعات قوية، لكن سمعتك تآكلت ببطء، وصار كل خبر '
            'عنك يُقرأ بريبة.',
        effect: Effect(money: 12, reputation: -12),
        ageJump: 2,
      ),
      EventChoice(
        text: 'أطلق نسخة مجانية محدودة',
        outcome:
            'نسخة مجانية محدودة للجميع، ونسخة كاملة مدفوعة للشركات. '
            'الجميع ربح شيئا، وأنتَ ربحتَ الهدوء.',
        effect: Effect(reputation: 10, social: 8, money: -4),
        ageJump: 1,
      ),
    ],
    isArcChapter: true,
    arcName: 'إطلاق النموذج الكبير',
  ),
  LifeEvent(
    id: 'launch_delay',
    minAge: 0,
    maxAge: 120,
    title: 'منافس يسبقك إلى السوق',
    story:
        'نموذج المنافس ليس أفضل من نموذجك، لكنه وصل أولا، والأول يأخذ '
        'الأضواء. فريقك محبط، والمستثمرون يسألون: هل التأني كان حكمة '
        'أم ترددا؟',
    choices: [
      EventChoice(
        text: 'أطلق بسرعة بميزات أقل',
        outcome:
            'أطلقتَ نموذجا مقبولا لكنه ليس ما حلمتَ به. استعدتَ بعض '
            'الأضواء، وخسرتَ بعض الثقة.',
        effect: Effect(tech: 6, reputation: -6, morale: -4),
        ageJump: 1,
      ),
      EventChoice(
        text: 'أغيّر الاتجاه كليا',
        outcome:
            'تركتَ السباق كله، وبنيتَ نموذجا لنقطة قوة مختلفة لم ينتبه '
            'لها أحد. صار لك سوقك الخاص.',
        effect: Effect(research: 14, tech: 8, money: -6),
        ageJump: 2,
      ),
      EventChoice(
        text: 'أعرض الشراكة على المنافس',
        outcome:
            'قبل المنافس الشراكة: نموذجه للانتشار، ونموذجك للعمق. صارت '
            'لكما شركة أقوى، لكنك لم تعد وحدك في القيادة.',
        effect: Effect(social: 14, money: 10, reputation: -4),
        addTraits: ['partner'],
        ageJump: 1,
      ),
    ],
    isArcChapter: true,
    arcName: 'إطلاق النموذج الكبير',
  ),
];
