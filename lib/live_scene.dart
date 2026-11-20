import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'game_feel.dart';
import 'theme/empire_theme.dart';

/// نسب المشهد الحي المشتقة من الأرقام الحقيقية للإدارة:
/// - ارتفاع برج شركتك وأبراج المنافسين يعكس مستوياتهم الحقيقية.
/// - عدد النقاط المضيئة يعكس عدد المستخدمين الحقيقي (نقطة لكل 100 مستخدم).
/// - لون الأجواء والطاقة يعكس حالة الحوسبة والإفلاس والصدارة.
double computeFraction(int available) => (available / 200).clamp(0.0, 1.0);

double usersFraction(int users) => (math.sqrt(users / 10000)).clamp(0.0, 1.0);

double levelFraction(int level) => (level / 10).clamp(0.0, 1.0);

int userDots(int users) => (users ~/ 100).clamp(0, 24);

String _companyStageLabel(int modelLevel, bool isBankrupt, bool victory) {
  if (isBankrupt) return 'حالة طوارئ مالية';
  if (victory) return 'إمبراطورية مهيمنة';
  if (modelLevel >= 7) return 'عملاق ذكاء عالمي';
  if (modelLevel >= 5) return 'مركز بيانات عملاق';
  if (modelLevel >= 3) return 'مختبر نماذج متقدم';
  if (modelLevel >= 2) return 'شركة ناشئة صاعدة';
  return 'مرآب المطورين';
}

class CompanyLiveScene extends StatelessWidget {
  final int computeAvailable;
  final int computeReserved;
  final int users;
  final int modelLevel;
  final List<String> rivalNames;
  final List<int> rivalLevels;
  final int reputation;
  final bool isBankrupt;
  final bool leadershipVictory;

  const CompanyLiveScene({
    super.key,
    required this.computeAvailable,
    required this.computeReserved,
    required this.users,
    required this.modelLevel,
    required this.rivalNames,
    required this.rivalLevels,
    required this.reputation,
    required this.isBankrupt,
    required this.leadershipVictory,
  });

  @override
  Widget build(BuildContext context) {
    final accent = isBankrupt
        ? EmpireColors.coral
        : computeAvailable < 20
            ? EmpireColors.amber
            : leadershipVictory
                ? EmpireColors.emerald
                : EmpireColors.cyan;

    final dots = userDots(users);
    final stageLabel =
        _companyStageLabel(modelLevel, isBankrupt, leadershipVictory);

    return Container(
      key: const Key('live-scene'),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            accent.withOpacity(0.16),
            EmpireColors.surface,
            EmpireColors.bg,
          ],
        ),
        border: Border.all(
          color: accent.withOpacity(0.5),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.14),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: accent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: accent.withOpacity(0.8),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'مشهد الشركة الحي',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: EmpireColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: accent.withOpacity(0.45)),
                    ),
                    child: Text(
                      isBankrupt
                          ? 'الشركة متعثرة'
                          : leadershipVictory
                              ? 'أنت في الصدارة'
                              : 'السمعة $reputation / 100',
                      style: TextStyle(
                        color: accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'المرحلة الحالية: $stageLabel',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: EmpireColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.fromLTRB(8, 14, 8, 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF070B14),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: EmpireColors.border),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _CyberSkylineBackdropPainter(
                          accent: accent,
                          reputationFraction: (reputation / 100).clamp(0.0, 1.0),
                        ),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _TowerWidget(
                          label: 'شركتك',
                          level: modelLevel,
                          highlight: true,
                          color: accent,
                        ),
                        for (var i = 0; i < rivalNames.length; i++)
                          _TowerWidget(
                            label: rivalNames[i],
                            level:
                                i < rivalLevels.length ? rivalLevels[i] : 1,
                            highlight: false,
                            color: const Color(0xFF64748B),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.memory_rounded, size: 18, color: accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AnimatedBar(
                      label:
                          'الحوسبة المتاحة ($computeAvailable، محجوز $computeReserved)',
                      fraction: computeFraction(computeAvailable),
                      color: accent,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(
                    Icons.groups_rounded,
                    size: 18,
                    color: EmpireColors.sky,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'المستخدمون: $users — كل نقطة مضيئة تمثل 100 مستخدم حقيقي',
                      style: const TextStyle(
                        fontSize: 13,
                        color: EmpireColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (var i = 0; i < dots; i++)
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.4, end: 1.0),
                      duration: Duration(milliseconds: 350 + (i % 5) * 100),
                      builder: (context, value, _) => Opacity(
                        opacity: value,
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: EmpireColors.sky,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: EmpireColors.sky.withOpacity(0.65),
                                blurRadius: 5,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (dots == 0)
                    const Text(
                      'لا نقاط بعد — أطلق منتجا ليأتي المستخدمون',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: EmpireColors.textMuted,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CyberSkylineBackdropPainter extends CustomPainter {
  final Color accent;
  final double reputationFraction;

  const _CyberSkylineBackdropPainter({
    required this.accent,
    required this.reputationFraction,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = EmpireColors.border.withOpacity(0.35)
      ..strokeWidth = 0.8;

    const step = 22.0;
    for (double y = step; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    for (double x = step; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    final horizonGlow = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          accent.withOpacity(0.18 + reputationFraction * 0.12),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, size.height * 0.45, size.width, size.height * 0.55));
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.45, size.width, size.height * 0.55),
      horizonGlow,
    );
  }

  @override
  bool shouldRepaint(covariant _CyberSkylineBackdropPainter oldDelegate) =>
      oldDelegate.accent != accent ||
      oldDelegate.reputationFraction != reputationFraction;
}

class _TowerWidget extends StatelessWidget {
  final String label;
  final int level;
  final bool highlight;
  final Color color;

  const _TowerWidget({
    required this.label,
    required this.level,
    required this.highlight,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final targetHeight = 32.0 + levelFraction(level) * 76.0;
    final width = highlight ? 48.0 : 38.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: highlight
                ? color.withOpacity(0.2)
                : EmpireColors.surfaceElevated,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'مستوى $level',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: highlight ? color : EmpireColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 4),
        if (highlight)
          Container(
            width: 4,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.8), blurRadius: 6),
              ],
            ),
          ),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 32, end: targetHeight),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          builder: (context, heightValue, _) {
            return Container(
              width: width,
              height: heightValue,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: highlight
                      ? [color.withOpacity(0.92), color.withOpacity(0.32)]
                      : [
                          const Color(0xFF475569),
                          const Color(0xFF1E293B),
                        ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
                border: Border.all(
                  color: highlight ? color : const Color(0xFF64748B),
                  width: highlight ? 1.5 : 1,
                ),
                boxShadow: highlight
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: CustomPaint(
                painter: _TowerWindowsPainter(
                  highlight: highlight,
                  windowColor: highlight
                      ? Colors.white.withOpacity(0.85)
                      : Colors.white.withOpacity(0.28),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 5),
        SizedBox(
          width: 66,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: highlight ? FontWeight.w800 : FontWeight.w500,
              color: highlight
                  ? EmpireColors.textPrimary
                  : EmpireColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _TowerWindowsPainter extends CustomPainter {
  final bool highlight;
  final Color windowColor;

  const _TowerWindowsPainter({
    required this.highlight,
    required this.windowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = windowColor;
    final cols = highlight ? 3 : 2;
    const w = 6.0;
    const h = 4.0;
    const gapY = 6.0;
    final totalW = cols * w + (cols - 1) * 5.0;
    final startX = (size.width - totalW) / 2;

    for (double y = 7; y + h < size.height - 6; y += h + gapY) {
      for (int c = 0; c < cols; c++) {
        final x = startX + c * (w + 5.0);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, w, h),
            const Radius.circular(1),
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TowerWindowsPainter oldDelegate) =>
      oldDelegate.highlight != highlight ||
      oldDelegate.windowColor != windowColor;
}
