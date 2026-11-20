import 'package:flutter/material.dart';

import '../../theme/empire_theme.dart';

/// شريط تبويبات فرعية مضغوط داخل كل محور رئيسي مع دعم أيقونة القفل للفتح التدريجي.
class EmpireSubTabBar extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final Set<int> lockedIndices;

  const EmpireSubTabBar({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.lockedIndices = const {},
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            InkWell(
              onTap: () => onChanged(i),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: i == selectedIndex
                      ? EmpireColors.cyan.withValues(alpha: 0.18)
                      : EmpireColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: i == selectedIndex
                        ? EmpireColors.cyan
                        : EmpireColors.border,
                    width: i == selectedIndex ? 1.4 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (lockedIndices.contains(i)) ...[
                      const Icon(
                        Icons.lock_outline_rounded,
                        size: 13,
                        color: EmpireColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      labels[i],
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: i == selectedIndex
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: i == selectedIndex
                            ? EmpireColors.cyan
                            : lockedIndices.contains(i)
                                ? EmpireColors.textMuted
                                : EmpireColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// عنوان قسم واضح مع زر مساعدة (?) اختياري يخفي الشرح الطويل حتى يطلبه اللاعب.
class EmpireSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? helpText;
  final Color accent;
  final IconData? icon;

  const EmpireSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.helpText,
    this.accent = EmpireColors.cyan,
    this.icon,
  });

  void _showHelp(BuildContext context) {
    if (helpText == null) return;
    showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: EmpireColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: accent.withValues(alpha: 0.5)),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: accent,
            fontSize: 16.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          helpText!,
          style: const TextStyle(
            fontSize: 13.5,
            color: EmpireColors.textPrimary,
            height: 1.5,
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(c).pop(),
            child: const Text('فهمت'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 4,
            height: subtitle == null ? 22 : 38,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18, color: accent),
                      const SizedBox(width: 6),
                    ],
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17.5,
                          fontWeight: FontWeight.w800,
                          color: EmpireColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: EmpireColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (helpText != null)
            IconButton(
              icon: const Icon(
                Icons.help_outline_rounded,
                size: 20,
                color: EmpireColors.textSecondary,
              ),
              tooltip: 'شرح النظام',
              onPressed: () => _showHelp(context),
            ),
        ],
      ),
    );
  }
}

/// بطاقة قفل لطيفة للأنظمة التي تُفتح تدريجياً مع خيار فتح الكل فوراً.
class EmpireLockedPanel extends StatelessWidget {
  final String title;
  final String unlockHint;
  final VoidCallback onUnlockAll;

  const EmpireLockedPanel({
    super.key,
    required this.title,
    required this.unlockHint,
    required this.onUnlockAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: EmpireColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: EmpireColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: EmpireColors.indigo.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_clock_rounded,
              size: 32,
              color: EmpireColors.indigo,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: EmpireColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            unlockHint,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: EmpireColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onUnlockAll,
            icon: const Icon(Icons.lock_open_rounded, size: 18),
            label: const Text('فتح جميع الأنظمة المتقدمة الآن'),
          ),
        ],
      ),
    );
  }
}

/// صندوق ملاحظة قصير (يُستخدم لرسائل النتائج الفورية).
class EmpireInfoBox extends StatelessWidget {
  final String text;
  final Color accent;
  final IconData icon;

  const EmpireInfoBox({
    super.key,
    required this.text,
    this.accent = EmpireColors.indigo,
    this.icon = Icons.info_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.32)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: accent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12.5,
                color: EmpireColors.textPrimary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// شبكة مؤشرات مدمجة ببطاقات داكنة واضحة.
class EmpireMetricGrid extends StatelessWidget {
  final List<EmpireMetricItem> items;

  const EmpireMetricGrid({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final item in items)
            Container(
              constraints: const BoxConstraints(minWidth: 145),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: EmpireColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: item.accent != null
                      ? item.accent!.withValues(alpha: 0.4)
                      : EmpireColors.border,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.label,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: EmpireColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.value,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: item.accent ?? EmpireColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class EmpireMetricItem {
  final String label;
  final String value;
  final Color? accent;

  const EmpireMetricItem(this.label, this.value, {this.accent});
}

/// شارة حالة صغيرة.
class EmpireBadge extends StatelessWidget {
  final String text;
  final Color color;

  const EmpireBadge({
    super.key,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

/// بطاقة عنصر إداري موحدة.
class EmpireActionCard extends StatelessWidget {
  final String title;
  final String? description;
  final List<String> stats;
  final String? badgeText;
  final Color? badgeColor;
  final Color accent;
  final Widget? footer;

  const EmpireActionCard({
    super.key,
    required this.title,
    this.description,
    this.stats = const [],
    this.badgeText,
    this.badgeColor,
    this.accent = EmpireColors.cyan,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final activeBorder = badgeColor ?? EmpireColors.border;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: EmpireColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: badgeColor != null
              ? activeBorder.withValues(alpha: 0.55)
              : EmpireColors.border,
          width: badgeColor != null ? 1.3 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: EmpireColors.textPrimary,
                  ),
                ),
              ),
              if (badgeText != null && badgeColor != null) ...[
                const SizedBox(width: 8),
                EmpireBadge(text: badgeText!, color: badgeColor!),
              ],
            ],
          ),
          if (description != null && description!.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              description!,
              style: const TextStyle(
                fontSize: 13,
                color: EmpireColors.textSecondary,
              ),
            ),
          ],
          if (stats.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final stat in stats)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: EmpireColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      stat,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: EmpireColors.textPrimary,
                      ),
                    ),
                  ),
              ],
            ),
          ],
          if (footer != null) ...[
            const SizedBox(height: 10),
            footer!,
          ],
        ],
      ),
    );
  }
}
