import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'game_feel.dart';
import 'theme/empire_theme.dart';

/// نسب المشهد الحي المشتقة من الأرقام الحقيقية للإدارة.
double computeFraction(int available) => (available / 200).clamp(0.0, 1.0);

double usersFraction(int users) => (math.sqrt(users / 10000)).clamp(0.0, 1.0);

double levelFraction(int level) => (level / 10).clamp(0.0, 1.0);

int userDots(int users) => (users ~/ 100).clamp(0, 24);

String _companyStageLabel(int modelLevel, bool isBankrupt, bool victory) {
  if (isBankrupt) return 'حالة طوارئ مالية';
  if (victory) return 'إمبراطورية مهيمنة';
  if (modelLevel >= 7) return 'قلعة ذكاء عالمية';
  if (modelLevel >= 5) return 'مركز بيانات عملاق';
  if (modelLevel >= 3) return 'مختبر نماذج متقدم';
  if (modelLevel >= 2) return 'شركة ناشئة صاعدة';
  return 'مرآب المطورين';
}

/// المشهد الحي ثلاثي الأبعاد الأيزومتري (الإصدار 4.0):
/// يرسم مجسمات أبراج ثلاثية الأبعاد (وجه أيمن + وجه أيسر مظلل + سقف أيزومتري + هوائي مضيء)
/// لشركتك والمنافسين فوق شبكة أيزومترية رقمية تتفاعل مع مستوى النموذج والسمعة والحوسبة.
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
  final bool highVisualEffects;

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
    this.highVisualEffects = true,
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
            accent.withValues(alpha: 0.16),
            EmpireColors.surface,
            EmpireColors.bg,
          ],
        ),
        border: Border.all(color: accent.withValues(alpha: 0.55), width: 1.4),
        boxShadow: highVisualEffects
            ? [
                BoxShadow(
                  color: accent.withValues(alpha: 0.16),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
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
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                        boxShadow: highVisualEffects
                            ? [
                                BoxShadow(
                                  color: accent.withValues(alpha: 0.85),
                                  blurRadius: 8,
                                ),
                              ]
                            : null,
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
                    color: accent.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: accent.withValues(alpha: 0.45)),
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
            const SizedBox(height: 4),
            Text(
              'المجسم الحالي: $stageLabel (3D Isometric)',
              style: const TextStyle(
                fontSize: 12,
                color: EmpireColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.fromLTRB(6, 14, 6, 10),
              decoration: BoxDecoration(
                color: const Color(0xFF050810),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: EmpireColors.border),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _IsometricFloorPainter(
                        accent: accent,
                        reputationFraction: (reputation / 100).clamp(0.0, 1.0),
                      ),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _IsometricBuildingWidget(
                        label: 'شركتك',
                        level: modelLevel,
                        highlight: true,
                        color: accent,
                      ),
                      for (var i = 0; i < rivalNames.length; i++)
                        _IsometricBuildingWidget(
                          label: rivalNames[i],
                          level: i < rivalLevels.length ? rivalLevels[i] : 1,
                          highlight: false,
                          color: _rivalTowerColor(i),
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
                      fontSize: 12.5,
                      color: EmpireColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (var i = 0; i < dots; i++)
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.4, end: 1.0),
                    duration: Duration(milliseconds: 350 + (i % 5) * 90),
                    builder: (context, value, _) => Opacity(
                      opacity: value,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: EmpireColors.sky,
                          shape: BoxShape.circle,
                          boxShadow: highVisualEffects
                              ? [
                                  BoxShadow(
                                    color: EmpireColors.sky.withValues(alpha: 0.7),
                                    blurRadius: 5,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ),
                  ),
                if (dots == 0)
                  const Text(
                    'لا نقاط بعد — أطلق منتجا ليأتي المستخدمون',
                    style: TextStyle(
                      fontSize: 12,
                      color: EmpireColors.textMuted,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _rivalTowerColor(int index) {
    switch (index % 3) {
      case 0:
        return EmpireColors.emerald;
      case 1:
        return EmpireColors.gold;
      default:
        return EmpireColors.sky;
    }
  }
}

class _IsometricFloorPainter extends CustomPainter {
  final Color accent;
  final double reputationFraction;

  const _IsometricFloorPainter({
    required this.accent,
    required this.reputationFraction,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = EmpireColors.border.withValues(alpha: 0.32)
      ..strokeWidth = 0.8;

    // شبكة أيزومترية مائلة تعطي عمقاً ثلاثي الأبعاد للأرضية
    const spacing = 26.0;
    for (double x = -size.height; x < size.width + size.height; x += spacing) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height * 0.65, size.height * 0.45),
        gridPaint,
      );
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x - size.height * 0.65, size.height * 0.45),
        gridPaint,
      );
    }

    // هالة ضوئية في الأفق تتقوى مع ارتفاع السمعة
    final glow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, 0.7),
        radius: 0.9,
        colors: [
          accent.withValues(alpha: 0.2 + reputationFraction * 0.14),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), glow);
  }

  @override
  bool shouldRepaint(covariant _IsometricFloorPainter oldDelegate) =>
      oldDelegate.accent != accent ||
      oldDelegate.reputationFraction != reputationFraction;
}

class _IsometricBuildingWidget extends StatelessWidget {
  final String label;
  final int level;
  final bool highlight;
  final Color color;

  const _IsometricBuildingWidget({
    required this.label,
    required this.level,
    required this.highlight,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final targetHeight = 42.0 + levelFraction(level) * 78.0;
    final boxWidth = highlight ? 64.0 : 52.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: highlight
                ? color.withValues(alpha: 0.22)
                : EmpireColors.surfaceElevated,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'مستوى $level',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: highlight ? color : EmpireColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 3),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 42, end: targetHeight),
          duration: const Duration(milliseconds: 550),
          curve: Curves.easeOutCubic,
          builder: (context, h, _) => SizedBox(
            width: boxWidth,
            height: h + 18,
            child: CustomPaint(
              painter: _IsometricTowerPainter(
                color: color,
                highlight: highlight,
                towerHeight: h,
              ),
            ),
          ),
        ),
        const SizedBox(height: 3),
        SizedBox(
          width: 68,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: highlight ? FontWeight.w800 : FontWeight.w600,
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

class _IsometricTowerPainter extends CustomPainter {
  final Color color;
  final bool highlight;
  final double towerHeight;

  const _IsometricTowerPainter({
    required this.color,
    required this.highlight,
    required this.towerHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final halfW = size.width * 0.42;
    final roofDepth = halfW * 0.46;
    final baseY = size.height - roofDepth - 2;
    final topY = (baseY - towerHeight + roofDepth).clamp(14.0, baseY - 12);

    // 1. الوجه الأيسر (المظلل)
    final leftFace = Path()
      ..moveTo(cx - halfW, topY)
      ..lineTo(cx, topY + roofDepth)
      ..lineTo(cx, baseY + roofDepth)
      ..lineTo(cx - halfW, baseY)
      ..close();
    canvas.drawPath(
      leftFace,
      Paint()
        ..color = highlight
            ? color.withValues(alpha: 0.45)
            : color.withValues(alpha: 0.24),
    );

    // 2. الوجه الأيمن (المضاء)
    final rightFace = Path()
      ..moveTo(cx, topY + roofDepth)
      ..lineTo(cx + halfW, topY)
      ..lineTo(cx + halfW, baseY)
      ..lineTo(cx, baseY + roofDepth)
      ..close();
    canvas.drawPath(
      rightFace,
      Paint()
        ..color = highlight
            ? color.withValues(alpha: 0.82)
            : color.withValues(alpha: 0.48),
    );

    // 3. السقف الأيزومتري (معيّن ثلاثي الأبعاد)
    final roof = Path()
      ..moveTo(cx, topY - roofDepth)
      ..lineTo(cx + halfW, topY)
      ..lineTo(cx, topY + roofDepth)
      ..lineTo(cx - halfW, topY)
      ..close();
    canvas.drawPath(
      roof,
      Paint()
        ..color = highlight ? color : color.withValues(alpha: 0.72),
    );

    // 4. نوافذ زجاجية مضيئة على الوجهين
    final winPaint = Paint()
      ..color = highlight
          ? Colors.white.withValues(alpha: 0.85)
          : Colors.white.withValues(alpha: 0.38)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    for (double y = topY + roofDepth + 8; y < baseY - 4; y += 9) {
      canvas.drawLine(
        Offset(cx + 4, y),
        Offset(cx + halfW - 4, y - roofDepth * 0.72),
        winPaint,
      );
      canvas.drawLine(
        Offset(cx - 4, y),
        Offset(cx - halfW + 4, y - roofDepth * 0.72),
        Paint()
          ..color = Colors.white.withValues(alpha: highlight ? 0.42 : 0.18)
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round,
      );
    }

    // 5. هوائي مضيء فوق برج شركتك
    if (highlight) {
      final antPaint = Paint()
        ..color = color
        ..strokeWidth = 2.2;
      canvas.drawLine(
        Offset(cx, topY - roofDepth),
        Offset(cx, topY - roofDepth - 10),
        antPaint,
      );
      canvas.drawCircle(
        Offset(cx, topY - roofDepth - 11),
        3.2,
        Paint()..color = Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _IsometricTowerPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.highlight != highlight ||
      oldDelegate.towerHeight != towerHeight;
}
