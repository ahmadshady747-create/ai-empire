import 'package:flutter/material.dart';

import '../theme/empire_theme.dart';

/// هوية شركة منافسة شبه حقيقية في سباق الذكاء الاصطناعي العالمي.
/// تحافظ على المعرف الداخلي في المحرك لضمان توافق الحفظ والاختبارات،
/// وتعرض للاعب علامة تجارية احترافية بشعار ولون ومقر وأسلوب مميز.
class RivalBrand {
  final String internalName;
  final String displayName;
  final String shortName;
  final String headquarters;
  final String tagline;
  final IconData icon;
  final Color color;

  const RivalBrand({
    required this.internalName,
    required this.displayName,
    required this.shortName,
    required this.headquarters,
    required this.tagline,
    required this.icon,
    required this.color,
  });
}

const Map<String, RivalBrand> _knownBrands = {
  'مدار للذكاء': RivalBrand(
    internalName: 'مدار للذكاء',
    displayName: 'OpenMind Labs • أوبن مايند',
    shortName: 'OpenMind',
    headquarters: 'سان فرانسيسكو',
    tagline: 'سباق النماذج العملاقة والإطلاقات المتسارعة',
    icon: Icons.blur_circular_rounded,
    color: EmpireColors.emerald,
  ),
  'نورال للأنظمة': RivalBrand(
    internalName: 'نورال للأنظمة',
    displayName: 'AnthroCore AI • أنثرو كور',
    shortName: 'AnthroCore',
    headquarters: 'بوسطن',
    tagline: 'دقة الاستدلال ومعايير الأمان المؤسسي',
    icon: Icons.shield_moon_rounded,
    color: EmpireColors.gold,
  ),
  'قمة الحوسبة': RivalBrand(
    internalName: 'قمة الحوسبة',
    displayName: 'DeepVortex Cloud • ديب فورتكس',
    shortName: 'DeepVortex',
    headquarters: 'لندن',
    tagline: 'مراكز بيانات فائقة وتسعير سحابي شرس',
    icon: Icons.cyclone_rounded,
    color: EmpireColors.sky,
  ),
};

RivalBrand resolveRivalBrand(String internalName) {
  final found = _knownBrands[internalName];
  if (found != null) return found;
  return RivalBrand(
    internalName: internalName,
    displayName: internalName,
    shortName: internalName,
    headquarters: 'عالمي',
    tagline: 'منافس تقني في سباق الذكاء الاصطناعي',
    icon: Icons.business_rounded,
    color: EmpireColors.indigo,
  );
}

/// يحوّل أسماء المنافسين الداخلية داخل سطور الأخبار إلى الأسماء شبه الحقيقية.
String brandizeText(String text) {
  var result = text;
  for (final entry in _knownBrands.entries) {
    result = result.replaceAll(entry.key, entry.value.shortName);
  }
  return result;
}
