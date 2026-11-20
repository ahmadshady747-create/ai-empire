import 'package:flutter/material.dart';

import '../../interactive/progression_stages.dart';
import '../../interactive/rival_brands.dart';
import '../../management.dart';
import '../../theme/empire_theme.dart';
import 'launch_hype_modal.dart';
import 'market_share_card.dart';
import 'ui_components.dart';

/// محور السوق (الإصدار 3.0): المنتجات باحتفالية الإطلاق، الخدمات،
/// وساحة المنافسين بشعارات وأسماء شبه حقيقية (OpenMind, AnthroCore, DeepVortex).
class MarketTab extends StatelessWidget {
  final String companyName;
  final ManagementState state;
  final ProgressionUnlock progression;
  final int subIndex;
  final ValueChanged<int> onSubChanged;
  final VoidCallback onUnlockAll;
  final void Function(VoidCallback action) onMutate;

  const MarketTab({
    super.key,
    required this.companyName,
    required this.state,
    required this.progression,
    required this.subIndex,
    required this.onSubChanged,
    required this.onUnlockAll,
    required this.onMutate,
  });

  static const _subTabs = ['المنتجات', 'الخدمات', 'المنافسون'];

  String _serviceRisk(String id) {
    switch (id) {
      case 'hosting':
        return 'الخطر: تقوّي المنافس المستضاف وتأكل حوسبتك.';
      case 'compute_rental':
        return 'الخطر: يبطئ تدريبك وبحثك.';
      case 'fine_tuning':
        return 'الخطر: يستهلك فرقك وقد يسرب خبرة لمنافس.';
      case 'data_labeling':
        return 'الخطر: يستهلك فرقك ويبطئ بحثك.';
      case 'consulting':
        return 'الخطر: عميل كبير، فقدانه يضرب الإيراد فجأة.';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final locked = <int>{
      if (!progression.servicesUnlocked) 1,
      if (!progression.rivalsUnlocked) 2,
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EmpireSubTabBar(
            labels: _subTabs,
            selectedIndex: subIndex,
            onChanged: onSubChanged,
            lockedIndices: locked,
          ),
          if (subIndex == 0) _buildProducts(context),
          if (subIndex == 1)
            progression.servicesUnlocked
                ? _buildServices()
                : EmpireLockedPanel(
                    title: 'الخدمات التجارية',
                    unlockHint:
                        'تُفتح في المرحلة 3 (الأسبوع 4 أو مستوى نموذج 2) لتوسيع مصادر دخلك.',
                    onUnlockAll: onUnlockAll,
                  ),
          if (subIndex == 2)
            progression.rivalsUnlocked
                ? _buildRivals()
                : EmpireLockedPanel(
                    title: 'ساحة المنافسين العالميين',
                    unlockHint:
                        'تُفتح في المرحلة 3 لمنافسة OpenMind وAnthroCore وDeepVortex واستقطاب خبرائهم.',
                    onUnlockAll: onUnlockAll,
                  ),
        ],
      ),
    );
  }

  Widget _buildProducts(BuildContext context) {
    final s = state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const EmpireSectionHeader(
          title: 'المنتجات في السوق',
          accent: EmpireColors.emerald,
          icon: Icons.rocket_launch_rounded,
          helpText:
              'كل منتج مطلق يدر إيراداً ويجلب مستخدمين كل أسبوع مقابل تكلفة صيانة. التسعير المميز يرفع الإيراد +30% مقابل نمو أبطأ.',
        ),
        EmpireMetricGrid(
          items: [
            EmpireMetricItem('المستخدمون', '${s.users}', accent: EmpireColors.sky),
            EmpireMetricItem(
              'إيراد المنتجات',
              '${s.effectiveProductsRevenue}',
              accent: EmpireColors.emerald,
            ),
            EmpireMetricItem(
              'النمو الأسبوعي',
              '+${s.effectiveProductsGrowth}',
              accent: EmpireColors.cyan,
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: s.launchedProducts.isEmpty
              ? null
              : () => onMutate(() => s.setPremiumPricing(!s.premiumPricing)),
          icon: Icon(
            s.premiumPricing
                ? Icons.toggle_on_rounded
                : Icons.toggle_off_rounded,
          ),
          label: Text(
            s.premiumPricing
                ? 'إطفاء التسعير المميز'
                : 'تشغيل التسعير المميز (+30% إيراد، -2 نمو)',
          ),
        ),
        const SizedBox(height: 10),
        for (final def in ManagementState.productCatalog)
          Builder(
            builder: (_) {
              final launched = s.launchedProducts.contains(def.id);
              final canAfford = s.cash >= def.cost;
              return EmpireActionCard(
                title: def.name,
                description: def.description,
                stats: [
                  'الإطلاق: ${def.cost}',
                  'إيراد: ${def.revenue}/أسبوع',
                  'صيانة: ${def.maintenance}',
                  'نمو: +${def.growth}',
                ],
                badgeText: launched ? 'مطلق ✓' : null,
                badgeColor: launched ? EmpireColors.emerald : null,
                footer: !launched
                    ? OutlinedButton(
                        onPressed: canAfford
                            ? () {
                                var ok = false;
                                onMutate(() {
                                  ok = s.launchProduct(def.id);
                                });
                                if (ok && context.mounted) {
                                  showLaunchHypeModal(
                                    context: context,
                                    title: 'إطلاق ناجح: ${def.name}!',
                                    subtitle:
                                        'دخل منتجك السوق وبدأ يجلب +${def.growth} مستخدم و+${def.revenue} إيراد أسبوعياً.',
                                    state: s,
                                    isModelUpgrade: false,
                                  );
                                }
                              }
                            : null,
                        child: Text(canAfford ? 'إطلاق المنتج' : 'نقد غير كاف'),
                      )
                    : null,
              );
            },
          ),
      ],
    );
  }

  Widget _buildServices() {
    final s = state;
    final runwayWithCredit = s.runwayWithCreditWeeks >= 999
        ? 'مستدام'
        : '${s.runwayWithCreditWeeks} أسبوع';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const EmpireSectionHeader(
          title: 'الخدمات التجارية',
          accent: EmpireColors.gold,
          icon: Icons.handshake_rounded,
          helpText:
              'تنويع الدخل يقلل خطر الإفلاس، لكن كل خدمة لها ثمن متشابك في الحوسبة أو تركيز الفريق.',
        ),
        EmpireMetricGrid(
          items: [
            EmpireMetricItem(
              'إيراد الخدمات',
              '${s.servicesRevenue}',
              accent: EmpireColors.emerald,
            ),
            EmpireMetricItem(
              'حوسبة الخدمات',
              '${s.servicesCompute}',
              accent: EmpireColors.amber,
            ),
            EmpireMetricItem('المدى مع الائتمان', runwayWithCredit),
          ],
        ),
        for (final def in ManagementState.serviceCatalog)
          Builder(
            builder: (_) {
              final active = s.services.any((x) => x.id == def.id);
              final activeClient = s.services
                  .where((x) => x.id == def.id)
                  .map((x) => resolveRivalBrand(x.clientName).shortName)
                  .join();
              return EmpireActionCard(
                title: def.name,
                description: _serviceRisk(def.id),
                stats: [
                  'إيراد: ${def.revenue}/أسبوع',
                  'تكلفة: ${def.cost}/أسبوع',
                  if (def.compute > 0) 'حوسبة: ${def.compute}',
                  if (active && activeClient.isNotEmpty)
                    'العميل: $activeClient',
                ],
                badgeText: active ? 'نشطة ✓' : null,
                badgeColor: active ? EmpireColors.cyan : null,
                footer: OutlinedButton(
                  onPressed: () => onMutate(() {
                    if (active) {
                      s.stopService(def.id);
                    } else {
                      s.startService(def.id);
                    }
                  }),
                  child: Text(active ? 'إيقاف الخدمة' : 'بدء الخدمة'),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildRivals() {
    final s = state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const EmpireSectionHeader(
          title: 'عمالقة الذكاء المنافسون',
          accent: EmpireColors.coral,
          icon: Icons.groups_3_rounded,
          helpText:
              'استقطاب خبير يكلف 9000، يخفض مستوى المنافس درجة، ويرفع تسريع تدريبك نقطتين دائماً (مرة واحدة لكل منافس). الأسماء خيالية مستوحاة من عالم التقنية.',
        ),
        MarketLeaderboardCard(companyName: companyName, state: s),
        for (final rival in s.rivals)
          Builder(
            builder: (_) {
              final brand = resolveRivalBrand(rival.name);
              final poached = s.poachedRivals.contains(rival.name);
              final canPoach = !poached &&
                  rival.modelLevel > 1 &&
                  s.cash >= ManagementState.poachCost;
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: EmpireColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: brand.color.withValues(alpha: 0.45),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: brand.color.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(brand.icon, color: brand.color, size: 22),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                brand.displayName,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: EmpireColors.textPrimary,
                                ),
                              ),
                              Text(
                                '${brand.headquarters} • ${brand.tagline}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: EmpireColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        EmpireBadge(
                          text: 'مستوى ${rival.modelLevel}',
                          color: brand.color,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: canPoach
                          ? () => onMutate(() => s.poachRival(rival.name))
                          : null,
                      child: Text(
                        poached
                            ? 'تم استقطاب خبير سابقاً ✓'
                            : rival.modelLevel <= 1
                                ? 'مستواه 1 — لا يمكن إضعافه'
                                : s.cash < ManagementState.poachCost
                                    ? 'نقد غير كاف (تحتاج 9000)'
                                    : 'استقطاب خبير من ${brand.shortName} (9000)',
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
