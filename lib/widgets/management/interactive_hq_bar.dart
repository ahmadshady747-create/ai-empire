import 'package:flutter/material.dart';

import '../../interactive/hq_pulses.dart';
import '../../theme/empire_theme.dart';

/// شريط الفرص التفاعلية باللمس داخل المقر:
/// يعرض نبضتين حيّتين كل أسبوع ينقر عليهما اللاعب لكسب مكافآت فورية.
class InteractiveHqBar extends StatelessWidget {
  final List<HqPulse> pulses;
  final Set<String> claimedIds;
  final void Function(HqPulse pulse) onClaim;

  const InteractiveHqBar({
    super.key,
    required this.pulses,
    required this.claimedIds,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    final available = pulses.where((p) => !claimedIds.contains(p.id)).toList();
    if (available.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: EmpireColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: EmpireColors.cyan.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.touch_app_rounded, color: EmpireColors.cyan, size: 17),
              SizedBox(width: 6),
              Text(
                'فرص فورية داخل المقر — انقر للاقتناص!',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: EmpireColors.cyan,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var i = 0; i < available.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: () => onClaim(available[i]),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            available[i].color.withValues(alpha: 0.22),
                            EmpireColors.surfaceElevated,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: available[i].color.withValues(alpha: 0.65),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            available[i].icon,
                            size: 20,
                            color: available[i].color,
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  available[i].title,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: EmpireColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  available[i].rewardLabel,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: available[i].color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
