import 'package:flutter/material.dart';

import '../../theme/empire_theme.dart';

/// شريط الأفعال السفلي تحت الإبهام (Elite Action Dock):
/// يضع زر "تقدم أسبوعا ⏭️" وزر التسريع "4×" وزر "حفظ الإدارة"
/// في متناول الإبهام مباشرة مثل ألعاب الموبايل الاحترافية.
class BottomActionDock extends StatelessWidget {
  final bool isBankrupt;
  final bool highlightAdvance;
  final VoidCallback onAdvanceWeek;
  final VoidCallback onFastForward;
  final VoidCallback onSave;

  const BottomActionDock({
    super.key,
    required this.isBankrupt,
    required this.highlightAdvance,
    required this.onAdvanceWeek,
    required this.onFastForward,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: const BoxDecoration(
        color: EmpireColors.surface,
        border: Border(
          top: BorderSide(color: EmpireColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: highlightAdvance
                  ? BoxDecoration(
                      border: Border.all(color: EmpireColors.gold, width: 2.2),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: EmpireColors.gold.withValues(alpha: 0.35),
                          blurRadius: 10,
                        ),
                      ],
                    )
                  : null,
              child: FilledButton(
                onPressed: isBankrupt ? null : onAdvanceWeek,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                child: const Text('تقدم أسبوعا ⏭️'),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: 'تسريع ذكي 4 أسابيع',
            child: OutlinedButton(
              onPressed: isBankrupt ? null : onFastForward,
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              child: const Text('4× ⏩'),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: onSave,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            child: const Text('حفظ الإدارة'),
          ),
        ],
      ),
    );
  }
}
