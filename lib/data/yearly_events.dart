import '../models.dart';
import 'events.dart';

/// سنوات التدبير في رحلة المؤسس: بين كل حدث مصيري، سنة تدير فيها
/// وقت شركتك بنفسك.
LifeEvent yearlyEventForAge(int age) {
  if (age < 32) {
    return e('yearly_early', age, age, '🗓️ سنة من رحلتك: كيف تديرها؟',
        'سنة عادية في بداية الطريق: لا حدث مصيري، لكن تراكم السنوات العادية هو ما يصنع الشركة.',
        [
          c('أركز على البحث والتطوير', 'نماذجك تتحسن بصمت.',
              const Effect(research: 8, tech: 8, morale: -2), jump: 1),
          c('أركز على المبيعات والعملاء', 'إيرادك يكبر، وسمعتك تنتشر.',
              const Effect(money: 8, social: 6), cash: 5000, jump: 1),
          c('أبني فريقي', 'فريق أقوى، وقدرة أكبر.',
              const Effect(skill: 8, social: 6), jump: 1),
          c('أستريح وأعيد التفكير', 'رؤية أوضح، وتقدم أبطأ.',
              const Effect(morale: 10, research: -2), jump: 1),
        ]);
  }
  if (age < 50) {
    return e('yearly_growth', age, age, '🗓️ سنة من رحلتك: كيف تديرها؟',
        'سنة من النمو: فريق وشركاء وأسواق، وكل قرار له ثمن.',
        [
          c('أتوسع إلى أسواق جديدة', 'انتشار أوسع، ومخاطر أكبر.',
              const Effect(money: 10, social: 8, morale: -2), cash: 10000, jump: 1),
          c('أعمّق منتجي الحالي', 'جودة أعلى، وولاء عملاء أكبر.',
              const Effect(tech: 10, reputation: 6), jump: 1),
          c('أستثمر في البحث الطويل', 'رهان على المستقبل، دون عائد فوري.',
              const Effect(research: 10, tech: 6, money: -2), jump: 1),
          c('أركز على الربحية', 'مال أكثر، ونمو أبطأ.',
              const Effect(money: 12, morale: -2), cash: 15000, jump: 1),
        ]);
  }
  return e('yearly_late', age, age, '🗓️ سنة من رحلتك: كيف تديرها؟',
      'سنة في مرحلة النضج: الإرث والاستقرار والجيل القادم.',
      [
        c('أرشد مؤسسين شبابا', 'أثرك يتوسع، وسمعتك ترتفع.',
            const Effect(reputation: 10, social: 8), jump: 1),
        c('أستثمر في أبحاث جريئة', 'رهان أخير على اختراق كبير.',
            const Effect(research: 10, tech: 6, money: -4), jump: 1),
        c('أستقر وأحصد النتائج', 'سنة هادئة مربحة.',
            const Effect(money: 10, morale: 6), cash: 20000, jump: 1),
      ]);
}
