import 'package:flutter/material.dart';

import '../../management.dart';
import '../../theme/empire_theme.dart';

/// نافذة احتفالية لإطلاق منتج جديد أو ترقية النموذج إلى مستوى أعلى
/// مع تقييم النقاد والمجتمع لخلق لحظة إنجاز ملموسة.
Future<void> showLaunchHypeModal({
  required BuildContext context,
  required String title,
  required String subtitle,
  required ManagementState state,
  required bool isModelUpgrade,
}) {
  final rawScore = 6.2 +
      (state.modelLevel * 0.45) +
      (state.reputation / 100 * 1.4) +
      (state.dataQuality / 100 * 0.9);
  final score = rawScore.clamp(6.0, 9.9).toStringAsFixed(1);
  final accent = isModelUpgrade ? EmpireColors.indigo : EmpireColors.emerald;

  final review1 = rawScore >= 8.5
      ? '«قفزة حقيقية! سرعة ودقة تتفوق على أغلب المنافسين.»'
      : '«إطلاق قوي وواعد، ننتظر التحديثات القادمة بحماس.»';
  final review2 = state.dataQuality >= 70
      ? '«جودة الإجابات واضحة جداً بفضل البيانات النظيفة.»'
      : '«الفكرة ممتازة لكن تحسين جودة البيانات سيرفع الأداء أكثر.»';

  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: EmpireColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: accent, width: 1.6),
      ),
      title: Row(
        children: [
          Icon(
            isModelUpgrade
                ? Icons.auto_awesome_rounded
                : Icons.rocket_launch_rounded,
            color: accent,
            size: 26,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: accent,
                fontSize: 17.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13.5,
              color: EmpireColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: accent.withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                const Text(
                  'تقييم مجتمع التقنية',
                  style: TextStyle(
                    fontSize: 12,
                    color: EmpireColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$score / 10 ★',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: accent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            review1,
            style: const TextStyle(
              fontSize: 12.5,
              color: EmpireColors.textPrimary,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            review2,
            style: const TextStyle(
              fontSize: 12.5,
              color: EmpireColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('رائع! متابعة'),
        ),
      ],
    ),
  );
}
