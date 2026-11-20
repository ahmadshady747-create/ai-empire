import 'package:flutter/material.dart';

import '../../interactive/progression_stages.dart';
import '../../management.dart';
import '../../theme/empire_theme.dart';
import 'ui_components.dart';

/// محور التقنية المبسط: يضم النماذج والبحث والبيانات والحوسبة مع فتح تدريجي وزر شرح (?).
class TechTab extends StatelessWidget {
  final ManagementState state;
  final ProgressionUnlock progression;
  final int subIndex;
  final ValueChanged<int> onSubChanged;
  final VoidCallback onUnlockAll;
  final void Function(VoidCallback action) onMutate;

  const TechTab({
    super.key,
    required this.state,
    required this.progression,
    required this.subIndex,
    required this.onSubChanged,
    required this.onUnlockAll,
    required this.onMutate,
  });

  static const _subTabs = ['النماذج', 'البحث', 'البيانات', 'الحوسبة'];

  String _signed(int v) => v >= 0 ? '+$v' : '$v';

  @override
  Widget build(BuildContext context) {
    final locked = <int>{
      if (!progression.computeUnlocked) 3,
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EmpireSubTabBar(
            labels: _subTabs,
            selectedIndex: subIndex,
            onChanged: onSubChanged,
            lockedIndices: locked,
          ),
          if (subIndex == 0) _buildModels(),
          if (subIndex == 1) _buildResearch(),
          if (subIndex == 2) _buildData(),
          if (subIndex == 3)
            progression.computeUnlocked
                ? _buildCompute()
                : EmpireLockedPanel(
                    title: 'الحوسبة والبنية التحتية',
                    unlockHint:
                        'تُفتح تلقائياً في الأسبوع 2 أو بعد إطلاق أول منتج حتى تبدأ بسلاسة.',
                    onUnlockAll: onUnlockAll,
                  ),
        ],
      ),
    );
  }

  Widget _buildModels() {
    final s = state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const EmpireSectionHeader(
          title: 'النماذج الذكية',
          accent: EmpireColors.indigo,
          icon: Icons.auto_awesome_rounded,
          helpText:
              'وظيفة نموذج واحدة نشطة فقط: الجيل الجديد يرفع المستوى ويصفّر التدريب، التقطير يرخّص الاستدلال، والاسترجاع يرفع السمعة والنمو.',
        ),
        EmpireMetricGrid(
          items: [
            EmpireMetricItem(
              'مستوى نموذجك',
              '${s.modelLevel}',
              accent: EmpireColors.cyan,
            ),
            EmpireMetricItem(
              'أفضل منافس',
              '${s.bestRivalLevel}',
              accent: EmpireColors.amber,
            ),
            EmpireMetricItem('تقدم التدريب', '${s.trainingProgress}%'),
            EmpireMetricItem('تكلفة الاستدلال', '${s.inferencePerUser}'),
          ],
        ),
        if (s.activeModelJob != null)
          _ActiveJobCard(
            label: 'وظيفة نشطة: ${s.activeModelJob!.name}',
            weeksDone: s.activeModelJob!.weeksDone,
            durationWeeks: s.activeModelJob!.durationWeeks,
            accent: EmpireColors.indigo,
          ),
        for (final def in ManagementState.modelCatalog)
          Builder(
            builder: (_) {
              final active = s.activeModelJob?.id == def.id;
              final done = s.completedModels.contains(def.id);
              final canAfford = s.cash >= def.cost;
              final anyActive = s.activeModelJob != null;
              return EmpireActionCard(
                title: def.name,
                description: def.description,
                stats: [
                  'الثمن: ${def.cost}',
                  'المدة: ${def.weeks} أسابيع',
                  def.effect,
                ],
                badgeText: done
                    ? 'مكتمل ✓'
                    : active
                        ? 'نشطة الآن'
                        : null,
                badgeColor: done
                    ? EmpireColors.emerald
                    : active
                        ? EmpireColors.indigo
                        : null,
                footer: (!done && !active)
                    ? OutlinedButton(
                        onPressed: (!anyActive && canAfford)
                            ? () => onMutate(() => s.startModelJob(def.id))
                            : null,
                        child: Text(canAfford ? 'بدء الوظيفة' : 'نقد غير كاف'),
                      )
                    : null,
              );
            },
          ),
      ],
    );
  }

  Widget _buildResearch() {
    final s = state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const EmpireSectionHeader(
          title: 'مختبر البحث',
          accent: EmpireColors.cyan,
          icon: Icons.science_rounded,
          helpText:
              'عند اكتمال البحث أو التدريب يرتفع مستوى النموذج درجة. مشروع بحثي واحد نشط فقط ويمنحك مكافآت دائمة.',
        ),
        EmpireMetricGrid(
          items: [
            EmpireMetricItem('تقدم البحث', '${s.researchProgress}%'),
            EmpireMetricItem(
              'مكافأة البحث',
              '+${s.researchBoost}',
              accent: EmpireColors.cyan,
            ),
            EmpireMetricItem(
              'مكافأة التدريب',
              '+${s.trainingBoost}',
              accent: EmpireColors.indigo,
            ),
          ],
        ),
        if (s.activeResearch != null)
          _ActiveJobCard(
            label: 'مشروع نشط: ${s.activeResearch!.name}',
            weeksDone: s.activeResearch!.weeksDone,
            durationWeeks: s.activeResearch!.durationWeeks,
            accent: EmpireColors.cyan,
          ),
        for (final def in ManagementState.researchCatalog)
          Builder(
            builder: (_) {
              final active = s.activeResearch?.id == def.id;
              final done = s.completedResearch.contains(def.id);
              final canAfford = s.cash >= def.cost;
              final anyActive = s.activeResearch != null;
              return EmpireActionCard(
                title: def.name,
                description: def.description,
                stats: [
                  'الثمن: ${def.cost}',
                  'المدة: ${def.weeks} أسابيع',
                  def.effect,
                ],
                badgeText: done
                    ? 'مكتمل ✓'
                    : active
                        ? 'نشط الآن'
                        : null,
                badgeColor: done
                    ? EmpireColors.emerald
                    : active
                        ? EmpireColors.cyan
                        : null,
                footer: (!done && !active)
                    ? OutlinedButton(
                        onPressed: (!anyActive && canAfford)
                            ? () => onMutate(() => s.startResearch(def.id))
                            : null,
                        child: Text(canAfford ? 'بدء المشروع' : 'نقد غير كاف'),
                      )
                    : null,
              );
            },
          ),
      ],
    );
  }

  Widget _buildData() {
    final s = state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const EmpireSectionHeader(
          title: 'البيانات والتغذية',
          accent: EmpireColors.sky,
          icon: Icons.dataset_rounded,
          helpText:
              'الحداثة تنقص نقطتين كل أسبوع. جودة تحت 40 تبطئ التدريب وحداثة تحت 50 تبطئ البحث، وجودة 80+ تسرّع التدريب.',
        ),
        EmpireMetricGrid(
          items: [
            EmpireMetricItem('الكمية', '${s.dataQuantity}', accent: EmpireColors.sky),
            EmpireMetricItem(
              'الجودة',
              '${s.dataQuality} / 100',
              accent: s.dataQuality < 40
                  ? EmpireColors.coral
                  : s.dataQuality >= 80
                      ? EmpireColors.emerald
                      : EmpireColors.textPrimary,
            ),
            EmpireMetricItem(
              'الحداثة',
              '${s.dataFreshness} / 100',
              accent: s.dataFreshness < 50
                  ? EmpireColors.amber
                  : EmpireColors.textPrimary,
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: (s.cash >= 3000 &&
                        s.dataQuality < 100 &&
                        s.dataQuantity >= 50)
                    ? () => onMutate(s.cleanData)
                    : null,
                child: const Text('تنظيف (3000 • +15 جودة)'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: (s.cash >= 2000 && s.dataFreshness < 100)
                    ? () => onMutate(s.refreshData)
                    : null,
                child: const Text('تجديد (2000 • +25 حداثة)'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (final def in ManagementState.dataCatalog)
          EmpireActionCard(
            title: def.name,
            description: def.description,
            stats: [
              'الثمن: ${def.cost}',
              'كمية: +${def.quantity}',
              'جودة: ${_signed(def.qualityDelta)}',
              'حداثة: ${_signed(def.freshnessDelta)}',
            ],
            footer: OutlinedButton(
              onPressed: s.cash >= def.cost
                  ? () => onMutate(() => s.buyData(def.id))
                  : null,
              child: Text(s.cash >= def.cost ? 'شراء المجموعة' : 'نقد غير كاف'),
            ),
          ),
      ],
    );
  }

  Widget _buildCompute() {
    final s = state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const EmpireSectionHeader(
          title: 'الحوسبة والخوادم',
          accent: EmpireColors.amber,
          icon: Icons.memory_rounded,
          helpText:
              'حجز 20+ وحدة يسرّع التدريب، لكن حجز 60+ وحدة دون عقد صيانة يجهد الخوادم ويبطئ التدريب 4 نقاط.',
        ),
        EmpireMetricGrid(
          items: [
            EmpireMetricItem(
              'المتاحة',
              '${s.computeAvailable}',
              accent: s.computeAvailable < 20
                  ? EmpireColors.coral
                  : EmpireColors.cyan,
            ),
            EmpireMetricItem(
              'المحجوزة',
              '${s.computeReserved}',
              accent: EmpireColors.indigo,
            ),
            if (s.maintenanceWeeks > 0)
              EmpireMetricItem(
                'صيانة نشطة',
                '${s.maintenanceWeeks} أسبوع',
                accent: EmpireColors.emerald,
              ),
          ],
        ),
        EmpireActionCard(
          title: 'توسيع الحوسبة',
          stats: const ['الثمن: 4000', 'السعة: +25 وحدة'],
          footer: OutlinedButton(
            onPressed: (s.cash >= 4000 && s.computeAvailable < 200)
                ? () => onMutate(s.buyCompute)
                : null,
            child: const Text('شراء 25 وحدة (4000)'),
          ),
        ),
        EmpireActionCard(
          title: 'تخصيص حوسبة للتدريب',
          footer: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: s.computeAvailable >= 20
                      ? () => onMutate(() => s.reserveCompute(20))
                      : null,
                  child: const Text('حجز 20 وحدة'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: s.computeAvailable >= 40
                      ? () => onMutate(() => s.reserveCompute(40))
                      : null,
                  child: const Text('حجز 40 وحدة'),
                ),
              ),
            ],
          ),
        ),
        EmpireActionCard(
          title: 'عقد صيانة وتبريد',
          stats: const ['الثمن: 5000', 'المدة: 4 أسابيع'],
          badgeText: s.maintenanceWeeks > 0 ? 'نشط ✓' : null,
          badgeColor: s.maintenanceWeeks > 0 ? EmpireColors.emerald : null,
          footer: OutlinedButton(
            onPressed: (s.cash >= 5000 && s.maintenanceWeeks == 0)
                ? () => onMutate(s.buyMaintenance)
                : null,
            child: const Text('تفعيل عقد الصيانة (5000)'),
          ),
        ),
      ],
    );
  }
}

class _ActiveJobCard extends StatelessWidget {
  final String label;
  final int weeksDone;
  final int durationWeeks;
  final Color accent;

  const _ActiveJobCard({
    required this.label,
    required this.weeksDone,
    required this.durationWeeks,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final progress = durationWeeks <= 0
        ? 0.0
        : (weeksDone / durationWeeks).clamp(0.0, 1.0);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'الأسبوع $weeksDone من $durationWeeks',
            style: const TextStyle(
              fontSize: 12.5,
              color: EmpireColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              color: accent,
              backgroundColor: EmpireColors.surfaceElevated,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
