import 'package:flutter/material.dart';

import '../../management.dart';
import '../../theme/empire_theme.dart';
import 'market_share_card.dart';
import 'ui_components.dart';

/// محور السوق: يضم المنتجات والخدمات والمنافسين مع لوحة الصدارة والتحكم المباشر.
class MarketTab extends StatelessWidget {
  final String companyName;
  final ManagementState state;
  final int subIndex;
  final ValueChanged<int> onSubChanged;
  final void Function(VoidCallback action) onMutate;

  const MarketTab({
    super.key,
    required this.companyName,
    required this.state,
    required this.subIndex,
    required this.onSubChanged,
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
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EmpireSubTabBar(
            labels: _subTabs,
            selectedIndex: subIndex,
            onChanged: onSubChanged,
          ),
          if (subIndex == 0) _buildProducts(),
          if (subIndex == 1) _buildServices(),
          if (subIndex == 2) _buildRivals(),
        ],
      ),
    );
  }

  Widget _buildProducts() {
    final s = state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const EmpireSectionHeader(
          title: 'المنتجات — إطلاق بأثمان ونتائج',
          accent: EmpireColors.emerald,
          icon: Icons.rocket_launch_rounded,
        ),
        EmpireMetricGrid(
          items: [
            EmpireMetricItem('المستخدمون', '${s.users}', accent: EmpireColors.sky),
            EmpireMetricItem('سعر المستخدم', '${s.pricePerUser}'),
            EmpireMetricItem('تكلفة الاستدلال', '${s.inferencePerUser}'),
            EmpireMetricItem(
              'إيراد المنتجات الأسبوعي',
              '${s.effectiveProductsRevenue}',
              accent: EmpireColors.emerald,
            ),
            EmpireMetricItem('صيانة المنتجات', '${s.productsCost}'),
            EmpireMetricItem(
              'نمو المستخدمين',
              '+${s.effectiveProductsGrowth}',
              accent: EmpireColors.cyan,
            ),
          ],
        ),
        const EmpireInfoBox(
          text:
              'كل منتج مطلق يدر إيراده ويكلف صيانته أسبوعيا. التسعير المميز قرار أسبوعي يرفع الإيراد +30% مقابل نمو أبطأ (-2).',
          accent: EmpireColors.emerald,
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
                  'صيانة: ${def.maintenance}/أسبوع',
                  'نمو: +${def.growth} مستخدم/أسبوع',
                ],
                badgeText: launched ? 'مطلق ✓' : null,
                badgeColor: launched ? EmpireColors.emerald : null,
                footer: !launched
                    ? OutlinedButton(
                        onPressed: canAfford
                            ? () => onMutate(() => s.launchProduct(def.id))
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
          title: 'الخدمات — تنويع الإيراد',
          accent: EmpireColors.gold,
          icon: Icons.handshake_rounded,
        ),
        EmpireMetricGrid(
          items: [
            EmpireMetricItem(
              'إيراد الخدمات',
              '${s.servicesRevenue}',
              accent: EmpireColors.emerald,
            ),
            EmpireMetricItem('تكلفة الخدمات', '${s.servicesCost}'),
            EmpireMetricItem(
              'حوسبة الخدمات',
              '${s.servicesCompute}',
              accent: EmpireColors.amber,
            ),
            EmpireMetricItem(
              'الائتمان المستخدم',
              '${s.creditUsed} / ${s.creditLimit}',
            ),
            EmpireMetricItem('المدى مع الائتمان', runwayWithCredit),
          ],
        ),
        const EmpireInfoBox(
          text:
              'الشرط الأول للبقاء ألا تفلس. التنويع عبر الخدمات يقلل خطر الإفلاس لكنه يستهلك حوسبة أو فرقاً ويشتت التركيز عن نموذجك الرئيسي.',
          accent: EmpireColors.gold,
        ),
        for (final def in ManagementState.serviceCatalog)
          Builder(
            builder: (_) {
              final active = s.services.any((x) => x.id == def.id);
              final activeClient = s.services
                  .where((x) => x.id == def.id)
                  .map((x) => x.clientName)
                  .join();
              return EmpireActionCard(
                title: def.name,
                description: _serviceRisk(def.id),
                stats: [
                  'إيراد: ${def.revenue}/أسبوع',
                  'تكلفة: ${def.cost}/أسبوع',
                  if (def.compute > 0) 'حوسبة: ${def.compute}',
                  if (def.big) 'عميل كبير',
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
          title: 'المنافسون (خياليون)',
          accent: EmpireColors.coral,
          icon: Icons.groups_3_rounded,
        ),
        MarketLeaderboardCard(companyName: companyName, state: s),
        const EmpireInfoBox(
          text:
              'استقطاب خبير من منافس يكلف 9000 مقدما، يخفض مستوى المنافس درجة (لا تحت مستوى 1)، ويرفع تسريع تدريبك نقطتين دائما. مرة واحدة لكل منافس فقط.',
          accent: EmpireColors.coral,
        ),
        for (final rival in s.rivals)
          Builder(
            builder: (_) {
              final poached = s.poachedRivals.contains(rival.name);
              final canPoach = !poached &&
                  rival.modelLevel > 1 &&
                  s.cash >= ManagementState.poachCost;
              return EmpireActionCard(
                title: rival.name,
                description: 'الاستراتيجية: ${rival.strategy}',
                stats: [
                  'مستوى النموذج: ${rival.modelLevel}',
                ],
                badgeText: poached ? 'تم الاستقطاب' : null,
                badgeColor: poached ? EmpireColors.amber : null,
                footer: OutlinedButton(
                  onPressed: canPoach
                      ? () => onMutate(() => s.poachRival(rival.name))
                      : null,
                  child: Text(
                    poached
                        ? 'استُقطب منه من قبل'
                        : rival.modelLevel <= 1
                            ? 'مستواه 1 فلا ما يُضعف'
                            : s.cash < ManagementState.poachCost
                                ? 'نقد غير كاف'
                                : 'استقطاب خبير (9000)',
                  ),
                ),
              );
            },
          ),
        const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text(
            'أسماء خيالية من تأليف اللعبة، لا تشير لأي شركة حقيقية.',
            style: TextStyle(fontSize: 12, color: EmpireColors.textMuted),
          ),
        ),
      ],
    );
  }
}
