import 'package:flutter/material.dart';

import '../management.dart';

/// لوحة الإدارة الأولية: أساس المحاكاة الإدارية، لا بطاقة حدث.
/// ثمانية تبويبات تعرض الموارد الحقيقية، وزر واحد "تقدم أسبوعا"
/// ينفذ الأسبوع ويعرض تقريره. الأفعال الإدارية التفصيلية (شراء
/// بيانات، حجز GPU، إطلاق منتج...) تأتي في جولات لاحقة، تبويبا تبويبا.
class ManagementScreen extends StatefulWidget {
  const ManagementScreen({super.key});

  @override
  State<ManagementScreen> createState() => _ManagementScreenState();
}

class _ManagementScreenState extends State<ManagementScreen>
    with SingleTickerProviderStateMixin {
  final ManagementState _state = ManagementState();
  WeekReport? _lastReport;
  late final TabController _tabs;

  static const _tabLabels = [
    'نظرة عامة',
    'بحث',
    'بيانات',
    'حوسبة',
    'نماذج',
    'منتجات',
    'خدمات',
    'منافسون',
    'مالية',
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: _tabLabels.length, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  void _advanceWeek() {
    setState(() {
      _lastReport = _state.advanceWeek();
    });
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 16)),
            Text(value,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      );

  Widget _panel(List<Widget> children) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final s = _state;
    final runway = s.runwayWeeks >= 999
        ? 'مستدام'
        : '${s.runwayWeeks} أسبوع';
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة إدارة الشركة'),
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabs: [for (final label in _tabLabels) Tab(text: label)],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('الأسبوع ${s.week}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('الترتيب #${s.rank}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('النقد: ${s.cash}'),
                        Text('المدى: $runway'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('النموذج: مستوى ${s.modelLevel}'),
                        Text('المستخدمون: ${s.users}'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: s.isBankrupt ? null : _advanceWeek,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      child: const Text('تقدم أسبوعا ⏭️'),
                    ),
                    if (s.isBankrupt)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'الشركة مفلسة: نفد النقد ونفد الائتمان. البقاء كان الشرط الأول.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _panel([
                  const Text('نظرة عامة',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  _row('السمعة', '${s.reputation} / 100'),
                  _row('الإيراد الأسبوعي', '${s.weeklyRevenue}'),
                  _row('التكلفة الأسبوعية', '${s.weeklyCost}'),
                  _row('صافي الأسبوع', '${s.weeklyNet}'),
                  const SizedBox(height: 12),
                  const Text('أخبار الأسبوع الأخير:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  if (_lastReport == null)
                    const Text(
                        'لم يمر أسبوع بعد. اضغط "تقدم أسبوعا" لترى أول تقرير.')
                  else
                    for (final line in _lastReport!.lines)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Text('• $line'),
                      ),
                ]),
                _panel([
                  const Text('البحث',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  _row('تقدم البحث', '${s.researchProgress} / 100'),
                  _row('تقدم التدريب', '${s.trainingProgress} / 100'),
                  const Text(
                      'عند اكتمال البحث أو التدريب يرتفع مستوى النموذج درجة. أفعال البحث التفصيلية تأتي في جولة البحث.'),
                ]),
                _panel([
                  const Text('البيانات',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  _row('الكمية', '${s.dataQuantity}'),
                  _row('الجودة', '${s.dataQuality} / 100'),
                  _row('الحداثة', '${s.dataFreshness} / 100'),
                  const Text(
                      'الحداثة تتقادم أسبوعا بعد أسبوع. شراء البيانات وتنظيفها يأتيان في جولة البيانات.'),
                ]),
                _panel([
                  const Text('الحوسبة',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  _row('المتاحة', '${s.computeAvailable}'),
                  _row('المحجوزة', '${s.computeReserved}'),
                  const Text(
                      'الحوسبة المحجوزة تُستهلك في أسبوعها وتسرّع التدريب. حجز GPU يأتي في جولة الحوسبة.'),
                ]),
                _panel([
                  const Text('النماذج',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  _row('مستوى النموذج الرئيسي', '${s.modelLevel}'),
                  _row('أفضل منافس', '${s.bestRivalLevel}'),
                  const Text(
                      'التدريب والتحسين التفصيلي يأتيان في جولة النماذج.'),
                ]),
                _panel([
                  const Text('المنتجات',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  _row('المستخدمون', '${s.users}'),
                  _row('سعر المستخدم', '${s.pricePerUser}'),
                  _row('تكلفة الاستدلال للمستخدم', '${s.inferencePerUser}'),
                  const Text(
                      'إطلاق المنتجات والتسويق والتسعير يأتي في جولة المنتجات.'),
                ]),
                _panel([
                  const Text('الخدمات — كل ما حول النماذج',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const Text(
                      'الشرط الأول للبقاء: ألا تفلس. الإفلاس هو نفاد النقد مع نفاد الائتمان، والصدارة هدف بعد البقاء. التنويع يقلل خطر الإفلاس لكنه يشتت التركيز عن نموذجك الرئيسي.'),
                  _row('إيراد الخدمات الأسبوعي', '${s.servicesRevenue}'),
                  _row('تكلفة الخدمات الأسبوعية', '${s.servicesCost}'),
                  _row('حوسبة تستهلكها الخدمات', '${s.servicesCompute}'),
                  _row('الائتمان المستخدم', '${s.creditUsed} / ${s.creditLimit}'),
                  _row('الائتمان المتبقي', '${s.creditRemaining}'),
                  _row('المدى مع الائتمان',
                      s.runwayWithCreditWeeks >= 999
                          ? 'مستدام'
                          : '${s.runwayWithCreditWeeks} أسبوع'),
                  const SizedBox(height: 12),
                  for (final def in ManagementState.serviceCatalog)
                    _ServiceRow(
                      def: def,
                      active: s.services.any((x) => x.id == def.id),
                      activeClient: s.services
                          .where((x) => x.id == def.id)
                          .map((x) => x.clientName)
                          .join(),
                      onToggle: () {
                        setState(() {
                          if (s.services.any((x) => x.id == def.id)) {
                            s.stopService(def.id);
                          } else {
                            s.startService(def.id);
                          }
                        });
                      },
                    ),
                ]),
                _panel([
                  const Text('المنافسون (خياليون)',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  for (final rival in s.rivals)
                    _row(rival.name, 'مستوى ${rival.modelLevel}'),
                  const Text(
                      'أسماء خيالية من تأليف اللعبة، لا تشير لأي شركة حقيقية.'),
                ]),
                _panel([
                  const Text('المالية',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  _row('النقد', '${s.cash}'),
                  _row('المدى النقدي', runway),
                  _row('رواتب الأسبوع', '${s.weeklySalaries}'),
                  _row('إيراد الأسبوع', '${s.weeklyRevenue}'),
                  _row('تكلفة الاستدلال', '${s.weeklyInferenceCost}'),
                  const Text(
                      'القروض والسداد والتوظيف تأتي في جولة المالية.'),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// صف خدمة واحدة: إيرادها وتكلفتها وخطرها المتشابك، وزر بدء/إيقاف.
class _ServiceRow extends StatelessWidget {
  final ({String id, String name, int revenue, int cost, int compute, bool team, bool big}) def;
  final bool active;
  final String activeClient;
  final VoidCallback onToggle;

  const _ServiceRow({
    required this.def,
    required this.active,
    required this.activeClient,
    required this.onToggle,
  });

  String get _risk {
    switch (def.id) {
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
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(def.name,
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
                'إيراد ${def.revenue} / أسبوع — تكلفة ${def.cost} / أسبوع${def.compute > 0 ? ' — حوسبة ${def.compute}' : ''}${def.big ? ' — عميل كبير' : ''}'),
            Text(_risk),
            if (active) Text('نشطة — العميل: $activeClient'),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: onToggle,
              child: Text(active ? 'إيقاف الخدمة' : 'بدء الخدمة'),
            ),
          ],
        ),
      ),
    );
  }
}
