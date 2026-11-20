import 'package:flutter/material.dart';

import '../../theme/empire_theme.dart';

/// شريط تبويبات فرعية مضغوط داخل كل محور رئيسي.
class EmpireSubTabBar extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const EmpireSubTabBar({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
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
                      ? EmpireColors.cyan.withOpacity(0.18)
                      : EmpireColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: i == selectedIndex
                        ? EmpireColors.cyan
                        : EmpireColors.border,
                    width: i == selectedIndex ? 1.4 : 1,
                  ),
                ),
                child: Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: i == selectedIndex
                        ? FontWeight.w800
                        : FontWeight.w600,
                    color: i == selectedIndex
                        ? EmpireColors.cyan
                        : EmpireColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// عنوان قسم واضح مع شريط لوني جانبي.
class EmpireSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Color accent;
  final IconData? icon;

  const EmpireSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.accent = EmpireColors.cyan,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: subtitle == null ? 22 : 38,
            margin: const EdgeInsets.only(top: 2),
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
                          fontSize: 18,
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
        ],
      ),
    );
  }
}

/// صندوق ملاحظة أو شرح استراتيجي مضغوط.
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
        color: accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withOpacity(0.32)),
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
                color: EmpireColors.textSecondary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// شبكة مؤشرات مدمجة ببطاقات داكنة واضحة بدل الصفوف النصية الطويلة.
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
                      ? item.accent!.withOpacity(0.4)
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

/// شارة حالة صغيرة (نشط / مكتمل / معيّن / مطلق).
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
        color: color.withOpacity(0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
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

/// بطاقة عنصر إداري موحدة (بحث، نموذج، بيانات، منتج، خدمة، توظيف).
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
              ? activeBorder.withOpacity(0.55)
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
