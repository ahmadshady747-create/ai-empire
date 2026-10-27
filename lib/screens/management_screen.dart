import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../management.dart';

/// لوحة الإدارة الأولية: أساس المحاكاة الإدارية، لا بطاقة حدث.
/// ثمانية تبويبات تعرض الموارد الحقيقية، وزر واحد "تقدم أسبوعا"
/// ينفذ الأسبوع ويعرض تقريره. الأفعال الإدارية التفصيلية (شراء
/// بيانات، حجز GPU، إطلاق منتج...) تأتي في جولات لاحقة، تبويبا تبويبا.
/// الحفظ على الجهاز من اللوحة نفسها: كل أسبوع يتقدم يُحفظ
/// تلقائيا، وزر "حفظ الإدارة" يحفظ يدويا، وعند فتح اللوحة من
/// جديد تُستأنف الإدارة المحفوظة إن وُجدت، لا تبدأ من الصفر.
class ManagementScreen extends StatefulWidget {
  const ManagementScreen({super.key});

  @override
  State<ManagementScreen> createState() => _ManagementScreenState();
}

class _ManagementScreenState extends State<ManagementScreen>
    with SingleTickerProviderStateMixin {
  static const _saveKey = 'ai_management_v1';

  ManagementState _state = ManagementState();
  WeekReport? _lastReport;
  String? _saveStatus;
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
    'فريق',
    'مالية',
    'مفاهيم',
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: _tabLabels.length, vsync: this);
    _loadSaved();
  }

  /// يستأنف الإدارة المحفوظة على الجهاز إن وُجدت. أي حفظ تالف
  /// يُتجاهل بهدوء وتبدأ إدارة جديدة، فلا يكسر حفظ قديم اللعب.
  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_saveKey);
    if (raw == null) return;
    try {
      final restored =
          ManagementState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      if (!mounted) return;
      setState(() {
        _state = restored;
        _saveStatus =
            'تم استئناف إدارة محفوظة — الأسبوع ${restored.week}، النقد ${restored.cash}.';
      });
    } catch (_) {
      // حفظ تالف: يُتجاهل وتبدأ إدارة جديدة.
    }
  }

  /// يحفظ حالة الإدارة الحالية على الجهاز ويعرض تأكيدا.
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_saveKey, jsonEncode(_state.toJson()));
    if (!mounted) return;
    setState(() {
      _saveStatus = 'تم حفظ الإدارة (الأسبوع ${_state.week}).';
    });
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
    // كل أسبوع يتقدم يُحفظ تلقائيا، فلا تضيع الإدارة
    // إن أُغلقت اللعبة دون حفظ يدوي.
    _save();
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
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: _save,
                      child: const Text('حفظ الإدارة'),
                    ),
                    if (_saveStatus != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _saveStatus!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.green),
                        ),
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
                    if (s.leadershipVictory)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'فوز بالصدارة: بلغت الترتيب الأول أربعة أسابيع متتالية بإدارتك.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.green),
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
                  _row('أسابيع الصدارة المتتالية', '${s.leadershipWeeks}'),
                  _row('الإيراد الأسبوعي', '${s.weeklyRevenue}'),
                  _row('التكلفة الأسبوعية', '${s.weeklyCost}'),
                  _row('صافي الأسبوع', '${s.weeklyNet}'),
                  if (s.lastWorldEvent.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'آخر حدث عالمي: ${s.lastWorldEvent} — سيناريو محاكاة مستوحى من اتجاهات عامة، ليس بيانات رسمية ولا تنبؤات.',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
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
                  const Text('البحث — مشاريع بأثمان ومدد',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  _row('تقدم البحث', '${s.researchProgress} / 100'),
                  _row('تقدم التدريب', '${s.trainingProgress} / 100'),
                  _row('مكافأة البحث الدائمة', '+${s.researchBoost}'),
                  _row('مكافأة التدريب الدائمة', '+${s.trainingBoost}'),
                  _row('مكافأة نمو المستخدمين', '+${s.userGrowthBoost}'),
                  const Text(
                      'عند اكتمال البحث أو التدريب يرتفع مستوى النموذج درجة. مشروع بحثي واحد نشط فقط: اختر اتجاهك، فالثمن يُدفع مقدما والتأثير دائم ويقوّي نظاما آخر.'),
                  const SizedBox(height: 12),
                  if (s.activeResearch != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                                'مشروع نشط: ${s.activeResearch!.name}',
                                style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold)),
                            Text(
                                'الأسبوع ${s.activeResearch!.weeksDone} من ${s.activeResearch!.durationWeeks}'),
                            const SizedBox(height: 6),
                            LinearProgressIndicator(
                              value: s.activeResearch!.weeksDone /
                                  s.activeResearch!.durationWeeks,
                            ),
                          ],
                        ),
                      ),
                    ),
                  for (final def in ManagementState.researchCatalog)
                    _ResearchRow(
                      def: def,
                      active: s.activeResearch?.id == def.id,
                      done: s.completedResearch.contains(def.id),
                      canAfford: s.cash >= def.cost,
                      anyActive: s.activeResearch != null,
                      onStart: () {
                        setState(() {
                          s.startResearch(def.id);
                        });
                      },
                    ),
                ]),
                _panel([
                  const Text('البيانات — شراء وتنظيف وتجديد',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  _row('الكمية', '${s.dataQuantity}'),
                  _row('الجودة', '${s.dataQuality} / 100'),
                  _row('الحداثة', '${s.dataFreshness} / 100'),
                  const Text(
                      'الحداثة تتقادم نقطتين كل أسبوع. جودة منخفضة تحت 40 تبطئ التدريب، وحداثة منخفضة تحت 50 تبطئ البحث، وجودة 80 فأعلى تسرّع التدريب. التنظيف يرفع الجودة لكنه يسقط كمية، والتجديد يرفع الحداثة فقط — فلا عرض واحد يغني عن الباقي.'),
                  const SizedBox(height: 12),
                  for (final def in ManagementState.dataCatalog)
                    _DataRow(
                      def: def,
                      canAfford: s.cash >= def.cost,
                      onBuy: () {
                        setState(() {
                          s.buyData(def.id);
                        });
                      },
                    ),
                  const SizedBox(height: 12),
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text('تنظيف البيانات',
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold)),
                          const Text(
                              'الثمن: 3000 — الجودة +15، الكمية −50.'),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: (s.cash >= 3000 &&
                                    s.dataQuality < 100 &&
                                    s.dataQuantity >= 50)
                                ? () {
                                    setState(() {
                                      s.cleanData();
                                    });
                                  }
                                : null,
                            child: const Text('تنظيف البيانات'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text('تجديد البيانات',
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold)),
                          const Text(
                              'الثمن: 2000 — الحداثة +25، دون تغيير الكمية أو الجودة.'),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: (s.cash >= 2000 &&
                                    s.dataFreshness < 100)
                                ? () {
                                    setState(() {
                                      s.refreshData();
                                    });
                                  }
                                : null,
                            child: const Text('تجديد البيانات'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
                _panel([
                  const Text('الحوسبة',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  _row('المتاحة', '${s.computeAvailable}'),
                  _row('المحجوزة', '${s.computeReserved}'),
                  const Text(
                      'المحجوزة تُستهلك في أسبوعها: 20 وحدة فأكثر تسرّع التدريب، لكن حجز 60 وحدة فأكثر يجهد الموثوقية ويبطئه 4 نقاط — إلا بعقد صيانة وتبريد نشط يمتص الإجهاد لأربعة أسابيع. الخدمات تأكل من المتاح كل أسبوع.'),
                  if (s.maintenanceWeeks > 0)
                    _row('عقد صيانة وتبريد نشط',
                        '${s.maintenanceWeeks} أسبوعا متبقيا'),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: (s.cash >= 4000 && s.computeAvailable < 200)
                        ? () {
                            setState(() {
                              s.buyCompute();
                            });
                          }
                        : null,
                    child: const Text('شراء 25 وحدة (4000)'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: s.computeAvailable >= 20
                        ? () {
                            setState(() {
                              s.reserveCompute(20);
                            });
                          }
                        : null,
                    child: const Text('حجز 20 وحدة للتدريب'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: s.computeAvailable >= 40
                        ? () {
                            setState(() {
                              s.reserveCompute(40);
                            });
                          }
                        : null,
                    child: const Text('حجز 40 وحدة للتدريب'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: (s.cash >= 5000 && s.maintenanceWeeks == 0)
                        ? () {
                            setState(() {
                              s.buyMaintenance();
                            });
                          }
                        : null,
                    child: const Text(
                        'عقد صيانة وتبريد (5000، 4 أسابيع)'),
                  ),
                ]),
                _panel([
                  const Text('النماذج — وظائف بأثمان ومدد',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  _row('مستوى النموذج الرئيسي', '${s.modelLevel}'),
                  _row('أفضل منافس', '${s.bestRivalLevel}'),
                  _row('تقدم التدريب', '${s.trainingProgress} / 100'),
                  _row('تكلفة الاستدلال للمستخدم',
                      '${s.inferencePerUser}'),
                  const Text(
                      'وظيفة نموذج واحدة نشطة فقط: الجيل الجديد وحده يرفع المستوى لكنه يصفّر تقدم التدريب، والتقطير يرخّص الاستدلال دون رفع المستوى، والاسترجاع يرفع السمعة والنمو دون رفع المستوى — فلا عمل واحد يغني عن الباقي.'),
                  const SizedBox(height: 12),
                  if (s.activeModelJob != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                                'وظيفة نشطة: ${s.activeModelJob!.name}',
                                style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold)),
                            Text(
                                'الأسبوع ${s.activeModelJob!.weeksDone} من ${s.activeModelJob!.durationWeeks}'),
                            const SizedBox(height: 6),
                            LinearProgressIndicator(
                              value: s.activeModelJob!.weeksDone /
                                  s.activeModelJob!.durationWeeks,
                            ),
                          ],
                        ),
                      ),
                    ),
                  for (final def in ManagementState.modelCatalog)
                    _ModelRow(
                      def: def,
                      active: s.activeModelJob?.id == def.id,
                      done: s.completedModels.contains(def.id),
                      canAfford: s.cash >= def.cost,
                      anyActive: s.activeModelJob != null,
                      onStart: () {
                        setState(() {
                          s.startModelJob(def.id);
                        });
                      },
                    ),
                ]),
                _panel([
                  const Text('المنتجات — إطلاق بأثمان ونتائج',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  _row('المستخدمون', '${s.users}'),
                  _row('سعر المستخدم', '${s.pricePerUser}'),
                  _row('تكلفة الاستدلال للمستخدم', '${s.inferencePerUser}'),
                  _row('إيراد المنتجات الأسبوعي', '${s.effectiveProductsRevenue}'),
                  _row('صيانة المنتجات الأسبوعية', '${s.productsCost}'),
                  _row('نمو المستخدمين من المنتجات', '+${s.effectiveProductsGrowth}'),
                  _row('التسعير المميز', s.premiumPricing ? 'مفعّل (+30% إيراد، -2 نمو)' : 'مطفأ'),
                  const Text(
                      'لا منتج مهيمن واحد: الواجهة البرمجية أعلى صافي أسبوعي لكن نموها الأبطأ، ومساعد البرمجة أعلى نمو لكن ثمنه الأعلى وصافيه الأدنى، وروبوت المحادثة أرخص دخول بصافي ونمو متوسطين، ومنصة الوكلاء أعلى ثمن إطلاق لكن صافيها ونموها في الوسط، وتحليل الوثائق صافي متوسط بثمن متوسط ونمو متوسط، وتلخيص الاجتماعات صافي متوسط بثمن مرتفع ونمو يساوي منصة الوكلاء لكن صافيه أدنى منها، ومساعد الأبحاث صافي متوسط (500) بثمن مرتفع ونمو متوسط، فلا يهيمن على أي جانب أيضا. كل منتج مطلق يدر إيراده ويكلف صيانته كل أسبوع. التسعير المميز قرار أسبوعي: إيراد أعلى الآن مقابل نمو أبطأ، فلا يصلح دائما.'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: s.launchedProducts.isEmpty
                        ? null
                        : () {
                            setState(() {
                              s.setPremiumPricing(!s.premiumPricing);
                            });
                          },
                    child: Text(s.premiumPricing
                        ? 'إطفاء التسعير المميز'
                        : 'تشغيل التسعير المميز (+30% إيراد، -2 نمو)'),
                  ),
                  const SizedBox(height: 12),
                  for (final def in ManagementState.productCatalog)
                    _ProductRow(
                      def: def,
                      launched: s.launchedProducts.contains(def.id),
                      canAfford: s.cash >= def.cost,
                      onLaunch: () {
                        setState(() {
                          s.launchProduct(def.id);
                        });
                      },
                    ),
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
                  const Text(
                      'استقطاب خبير من منافس يكلف 9000 مقدما، يخفض مستوى المنافس درجة (لا تحت مستوى 1)، ويرفع تسريع تدريبك نقطتين دائما. مرة واحدة لكل منافس فقط، والمنافس قد يستعيد مستواه في الأسابيع التالية، فلا استقطاب مهيمن.'),
                  for (final rival in s.rivals)
                    Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                                '${rival.name} — مستوى ${rival.modelLevel} — استراتيجية: ${rival.strategy}'),
                            if (s.poachedRivals.contains(rival.name))
                              const Text('استُقطب خبير منه من قبل'),
                            const SizedBox(height: 8),
                            OutlinedButton(
                              onPressed: (!s.poachedRivals
                                          .contains(rival.name) &&
                                      rival.modelLevel > 1 &&
                                      s.cash >=
                                          ManagementState.poachCost)
                                  ? () {
                                      setState(() {
                                        s.poachRival(rival.name);
                                      });
                                    }
                                  : null,
                              child: Text(s.poachedRivals
                                      .contains(rival.name)
                                  ? 'استُقطب منه من قبل'
                                  : rival.modelLevel <= 1
                                      ? 'مستواه 1 فلا ما يُضعف'
                                      : s.cash < ManagementState.poachCost
                                          ? 'نقد غير كاف'
                                          : 'استقطاب خبير (9000)'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const Text(
                      'أسماء خيالية من تأليف اللعبة، لا تشير لأي شركة حقيقية.'),
                ]),
                _panel([
                  const Text('الفريق — توظيف متخصصين',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  _row('رواتب الفريق الأسبوعية', '${s.staffSalaries}'),
                  _row('مكافأة البحث الدائمة', '+${s.researchBoost}'),
                  _row('مكافأة نمو المستخدمين', '+${s.userGrowthBoost}'),
                  const Text(
                      'كل دور يُعين مرة واحدة فقط: الثمن يُدفع مقدما، والتأثير دائم، لكن الراتب يُخصم كل أسبوع بعد التعيين — فالتعيين يريحك الآن ويأكل نقدك دائما. لا دور واحد يغني عن بقية الإدارة.'),
                  const SizedBox(height: 12),
                  for (final def in ManagementState.staffCatalog)
                    Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(def.name,
                                style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold)),
                            Text(def.description),
                            Text(
                                'ثمن التعيين: ${def.cost} — راتب أسبوعي: ${def.salary}'),
                            Text('عند التعيين: ${def.effect}'),
                            if (s.hiredStaff.contains(def.id))
                              const Text('معيّن ✓'),
                            const SizedBox(height: 8),
                            if (!s.hiredStaff.contains(def.id))
                              OutlinedButton(
                                onPressed: s.cash >= def.cost
                                    ? () {
                                        setState(() {
                                          s.hireStaff(def.id);
                                        });
                                      }
                                    : null,
                                child: Text(s.cash >= def.cost
                                    ? 'تعيين'
                                    : 'نقد غير كاف'),
                              ),
                          ],
                        ),
                      ),
                    ),
                ]),
                _panel([
                  const Text('المالية',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  _row('النقد', '${s.cash}'),
                  _row('المدى النقدي', runway),
                  _row('رواتب الأسبوع', '${s.weeklySalaries}'),
                  _row('رواتب الفريق المتخصص', '${s.staffSalaries}'),
                  _row('إيراد الأسبوع', '${s.weeklyRevenue}'),
                  _row('تكلفة الاستدلال', '${s.weeklyInferenceCost}'),
                  _row('الائتمان المستخدم', '${s.creditUsed}'),
                  _row('الائتمان المتبقي', '${s.creditRemaining}'),
                  _row('فائدة الائتمان الأسبوعية', '${s.creditInterest}'),
                  const Text(
                      'الاقتراض يسحب من الائتمان إلى النقد الآن لكنه يرفع الفائدة 2% أسبوعيا على المستخدم؛ والسداد يخفضها. رواتب فريقك المتخصص تُخصم كل أسبوع مع الرواتب في تقرير الأسبوع.'),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: s.creditRemaining >= 10000
                        ? () {
                            setState(() {
                              s.takeLoan();
                            });
                          }
                        : null,
                    child: const Text('اقتراض 10000 من الائتمان'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: (s.cash >= 5000 && s.creditUsed >= 5000)
                        ? () {
                            setState(() {
                              s.repayCredit(5000);
                            });
                          }
                        : null,
                    child: const Text('سداد 5000 من الائتمان'),
                  ),
                ]),
                _panel([
                  const Text('مكتبة المفاهيم',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const Text(
                      'شرح عربي واضح لكل نظام إداري: ما يفعله، وما ثمنه في '
                      'الأنظمة الأخرى، ولماذا لا توجد استراتيجية واحدة تفوز '
                      'دائما. أحداث العالم هنا سيناريوهات محاكاة مستوحاة من '
                      'اتجاهات عامة، ليست بيانات رسمية ولا تنبؤات.'),
                  const SizedBox(height: 8),
                  for (final concept in managementConcepts)
                    Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(concept.title,
                                style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(concept.body),
                          ],
                        ),
                      ),
                    ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// صف مشروع بحثي واحد: ثمنه ومدته وتأثيره الدائم وزر بدئه.
class _ResearchRow extends StatelessWidget {
  final ({String id, String name, String description, int cost, int weeks, String effect}) def;
  final bool active;
  final bool done;
  final bool canAfford;
  final bool anyActive;
  final VoidCallback onStart;

  const _ResearchRow({
    required this.def,
    required this.active,
    required this.done,
    required this.canAfford,
    required this.anyActive,
    required this.onStart,
  });

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
            Text(def.description),
            Text('الثمن: ${def.cost} — المدة: ${def.weeks} أسابيع'),
            Text('عند الاكتمال: ${def.effect}'),
            if (done) const Text('مكتمل ✓'),
            if (active) const Text('نشط الآن'),
            const SizedBox(height: 8),
            if (!done && !active)
              OutlinedButton(
                onPressed: (!anyActive && canAfford) ? onStart : null,
                child: Text(canAfford
                    ? 'بدء المشروع'
                    : 'نقد غير كاف'),
              ),
          ],
        ),
      ),
    );
  }
}

/// صف وظيفة نموذج واحدة: ثمنها ومدتها وتأثيرها وزر بدئها.
class _ModelRow extends StatelessWidget {
  final ({String id, String name, String description, int cost, int weeks, String effect}) def;
  final bool active;
  final bool done;
  final bool canAfford;
  final bool anyActive;
  final VoidCallback onStart;

  const _ModelRow({
    required this.def,
    required this.active,
    required this.done,
    required this.canAfford,
    required this.anyActive,
    required this.onStart,
  });

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
            Text(def.description),
            Text('الثمن: ${def.cost} — المدة: ${def.weeks} أسابيع'),
            Text('عند الاكتمال: ${def.effect}'),
            if (done) const Text('مكتمل ✓'),
            if (active) const Text('نشطة الآن'),
            const SizedBox(height: 8),
            if (!done && !active)
              OutlinedButton(
                onPressed: (!anyActive && canAfford) ? onStart : null,
                child: Text(canAfford
                    ? 'بدء الوظيفة'
                    : 'نقد غير كاف'),
              ),
          ],
        ),
      ),
    );
  }
}

/// صف عرض بيانات واحد: ثمنه وكميته وأثره على الجودة والحداثة وزر شرائه.
class _DataRow extends StatelessWidget {
  final ({String id, String name, String description, int cost, int quantity, int qualityDelta, int freshnessDelta}) def;
  final bool canAfford;
  final VoidCallback onBuy;

  const _DataRow({
    required this.def,
    required this.canAfford,
    required this.onBuy,
  });

  String _signed(int v) => v >= 0 ? '+$v' : '$v';

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
            Text(def.description),
            Text(
                'الثمن: ${def.cost} — الكمية: +${def.quantity} — الجودة: ${_signed(def.qualityDelta)} — الحداثة: ${_signed(def.freshnessDelta)}'),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: canAfford ? onBuy : null,
              child: Text(canAfford ? 'شراء المجموعة' : 'نقد غير كاف'),
            ),
          ],
        ),
      ),
    );
  }
}

/// صف منتج واحد: ثمن إطلاقه وإيراده وصيانته ونموه وزر إطلاقه.
class _ProductRow extends StatelessWidget {
  final ({String id, String name, String description, int cost, int revenue, int maintenance, int growth}) def;
  final bool launched;
  final bool canAfford;
  final VoidCallback onLaunch;

  const _ProductRow({
    required this.def,
    required this.launched,
    required this.canAfford,
    required this.onLaunch,
  });

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
            Text(def.description),
            Text(
                'ثمن الإطلاق: ${def.cost} — إيراد ${def.revenue} / أسبوع — صيانة ${def.maintenance} / أسبوع — نمو +${def.growth} مستخدم / أسبوع'),
            if (launched) const Text('مطلق ✓'),
            const SizedBox(height: 8),
            if (!launched)
              OutlinedButton(
                onPressed: canAfford ? onLaunch : null,
                child: Text(canAfford ? 'إطلاق المنتج' : 'نقد غير كاف'),
              ),
          ],
        ),
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
