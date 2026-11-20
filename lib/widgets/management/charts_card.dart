import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../analytics/company_history.dart';
import '../../theme/empire_theme.dart';

/// بطاقة رسوم بيانية تفاعلية مرسومة بـ CustomPainter لعرض مسار
/// النقد، المستخدمين، صافي الأسبوع، والسمعة عبر الأسابيع.
class EmpireTrendChartCard extends StatefulWidget {
  final List<WeekSnapshot> history;

  const EmpireTrendChartCard({
    super.key,
    required this.history,
  });

  @override
  State<EmpireTrendChartCard> createState() => _EmpireTrendChartCardState();
}

class _EmpireTrendChartCardState extends State<EmpireTrendChartCard> {
  int _metricIndex = 0;

  static const _metrics = [
    (label: 'النقد', color: EmpireColors.emerald),
    (label: 'المستخدمون', color: EmpireColors.sky),
    (label: 'الصافي', color: EmpireColors.cyan),
    (label: 'السمعة', color: EmpireColors.gold),
  ];

  List<double> _extractValues() {
    return widget.history.map((snap) {
      switch (_metricIndex) {
        case 0:
          return snap.cash.toDouble();
        case 1:
          return snap.users.toDouble();
        case 2:
          return snap.weeklyNet.toDouble();
        case 3:
        default:
          return snap.reputation.toDouble();
      }
    }).toList();
  }

  String _formatCompact(double v) {
    final abs = v.abs();
    final sign = v < 0 ? '-' : '';
    if (abs >= 1000000) return '$sign${(abs / 1000000).toStringAsFixed(1)}M';
    if (abs >= 1000) return '$sign${(abs / 1000).toStringAsFixed(1)}K';
    return '${v.round()}';
  }

  @override
  Widget build(BuildContext context) {
    final values = _extractValues();
    final metric = _metrics[_metricIndex];
    final current = values.isEmpty ? 0.0 : values.last;
    final first = values.isEmpty ? 0.0 : values.first;
    final delta = current - first;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: EmpireColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: EmpireColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.show_chart_rounded, color: metric.color, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'مؤشر الأداء التاريخي',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: EmpireColors.textPrimary,
                  ),
                ),
              ),
              if (values.length >= 2)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (delta >= 0
                            ? EmpireColors.emerald
                            : EmpireColors.coral)
                        .withOpacity(0.16),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${delta >= 0 ? '+' : ''}${_formatCompact(delta)}',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: delta >= 0
                          ? EmpireColors.emerald
                          : EmpireColors.coral,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (var i = 0; i < _metrics.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _metricIndex = i),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: i == _metricIndex
                            ? _metrics[i].color.withOpacity(0.18)
                            : EmpireColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: i == _metricIndex
                              ? _metrics[i].color
                              : EmpireColors.border,
                        ),
                      ),
                      child: Text(
                        _metrics[i].label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: i == _metricIndex
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: i == _metricIndex
                              ? _metrics[i].color
                              : EmpireColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          if (values.length < 2)
            Container(
              height: 100,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: EmpireColors.bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: EmpireColors.border),
              ),
              child: const Text(
                'تقدم أسبوعاً واحداً على الأقل لبدء رسم منحنى الأداء.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: EmpireColors.textMuted,
                ),
              ),
            )
          else
            Container(
              height: 132,
              padding: const EdgeInsets.fromLTRB(10, 12, 10, 8),
              decoration: BoxDecoration(
                color: EmpireColors.bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: EmpireColors.border),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: _AreaLinePainter(
                        values: values,
                        color: metric.color,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'من أسبوع ${widget.history.first.week}',
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: EmpireColors.textMuted,
                        ),
                      ),
                      Text(
                        'الأعلى: ${_formatCompact(values.reduce(math.max))}',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: metric.color,
                        ),
                      ),
                      Text(
                        'حتى أسبوع ${widget.history.last.week}',
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: EmpireColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _AreaLinePainter extends CustomPainter {
  final List<double> values;
  final Color color;

  const _AreaLinePainter({
    required this.values,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final minVal = values.reduce(math.min);
    final maxVal = values.reduce(math.max);
    final range = (maxVal - minVal).abs() < 1e-6 ? 1.0 : (maxVal - minVal);

    final gridPaint = Paint()
      ..color = EmpireColors.border.withOpacity(0.45)
      ..strokeWidth = 0.8;
    for (var i = 0; i <= 2; i++) {
      final y = size.height * (i / 2);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final x = (i / (values.length - 1)) * size.width;
      final norm = (values[i] - minVal) / range;
      final y = size.height - 6 - norm * (size.height - 12);
      points.add(Offset(x, y));
    }

    final areaPath = Path()..moveTo(points.first.dx, size.height);
    for (final p in points) {
      areaPath.lineTo(p.dx, p.dy);
    }
    areaPath.lineTo(points.last.dx, size.height);
    areaPath.close();

    final areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(0.32),
          color.withOpacity(0.02),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(areaPath, areaPaint);

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(linePath, linePaint);

    final last = points.last;
    canvas.drawCircle(
      last,
      5.5,
      Paint()..color = color.withOpacity(0.3),
    );
    canvas.drawCircle(
      last,
      3.2,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _AreaLinePainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.color != color;
}
