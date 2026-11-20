import 'package:ai_empire/interactive/rival_brands.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('هويات الشركات شبه الحقيقية تربط الأسماء الداخلية دون كسرها', () {
    final openMind = resolveRivalBrand('مدار للذكاء');
    final anthroCore = resolveRivalBrand('نورال للأنظمة');
    final deepVortex = resolveRivalBrand('قمة الحوسبة');

    expect(openMind.shortName, 'OpenMind');
    expect(anthroCore.shortName, 'AnthroCore');
    expect(deepVortex.shortName, 'DeepVortex');

    expect(
      brandizeText('ارتفع مستوى مدار للذكاء وتقدمت قمة الحوسبة'),
      'ارتفع مستوى OpenMind وتقدمت DeepVortex',
    );
  });
}
