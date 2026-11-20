import 'package:flutter/material.dart';

import '../../interactive/decision_cards.dart';
import '../../theme/empire_theme.dart';

/// بطاقة موقف وقرار سريع تظهر في شاشة القيادة مع خيارين واضحين بأوسمة الأثر.
class DecisionCardWidget extends StatelessWidget {
  final DecisionCardModel card;
  final void Function(DecisionOption option) onChoose;

  const DecisionCardWidget({
    super.key,
    required this.card,
    required this.onChoose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('decision-card'),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            card.accent.withValues(alpha: 0.2),
            EmpireColors.surface,
          ],
        ),
        border: Border.all(color: card.accent.withValues(alpha: 0.7), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: card.accent.withValues(alpha: 0.16),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: card.accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(card.icon, color: card.accent, size: 20),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'قرار عاجل • ${card.category}',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: card.accent,
                      ),
                    ),
                    Text(
                      card.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: EmpireColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            card.story,
            style: const TextStyle(
              fontSize: 13.5,
              color: EmpireColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          _OptionButton(
            option: card.optionA,
            accent: card.accent,
            onTap: () => onChoose(card.optionA),
          ),
          const SizedBox(height: 8),
          _OptionButton(
            option: card.optionB,
            accent: EmpireColors.textSecondary,
            onTap: () => onChoose(card.optionB),
          ),
        ],
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final DecisionOption option;
  final Color accent;
  final VoidCallback onTap;

  const _OptionButton({
    required this.option,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: EmpireColors.surfaceElevated,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: accent.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              option.label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: EmpireColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                for (final tag in option.impactTags)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (tag.startsWith('-')
                              ? EmpireColors.coral
                              : EmpireColors.emerald)
                          .withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: tag.startsWith('-')
                            ? EmpireColors.coral
                            : EmpireColors.emerald,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
