import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'theme/empire_theme.dart';

/// طبقة إحساس اللعب: عدّادات تنتقل بسلاسة من القيمة السابقة
/// إلى الجديدة دون القفز للصفر، أشرطة تقدم واضحة، ورد فعل
/// صوتي ولمسي اختياري يعمل محلياً دون أصول خارجية.
class AnimatedCountText extends StatefulWidget {
  final String prefix;
  final int value;
  final String suffix;
  final TextStyle? style;
  final TextAlign? textAlign;

  const AnimatedCountText({
    super.key,
    required this.prefix,
    required this.value,
    this.suffix = '',
    this.style,
    this.textAlign,
  });

  @override
  State<AnimatedCountText> createState() => _AnimatedCountTextState();
}

class _AnimatedCountTextState extends State<AnimatedCountText> {
  late int _beginValue;

  @override
  void initState() {
    super.initState();
    _beginValue = widget.value;
  }

  @override
  void didUpdateWidget(covariant AnimatedCountText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _beginValue = oldWidget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mergedStyle = (widget.style ?? const TextStyle()).copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: _beginValue, end: widget.value),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, _) {
        return Text(
          '${widget.prefix}$animatedValue${widget.suffix}',
          style: mergedStyle,
          textAlign: widget.textAlign,
        );
      },
    );
  }
}

class AnimatedBar extends StatefulWidget {
  final String label;
  final double fraction;
  final Color? color;
  final bool compact;

  const AnimatedBar({
    super.key,
    required this.label,
    required this.fraction,
    this.color,
    this.compact = false,
  });

  @override
  State<AnimatedBar> createState() => _AnimatedBarState();
}

class _AnimatedBarState extends State<AnimatedBar> {
  late double _beginFraction;

  @override
  void initState() {
    super.initState();
    _beginFraction = widget.fraction.clamp(0.0, 1.0);
  }

  @override
  void didUpdateWidget(covariant AnimatedBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldClamped = oldWidget.fraction.clamp(0.0, 1.0);
    final newClamped = widget.fraction.clamp(0.0, 1.0);
    if (oldClamped != newClamped) {
      _beginFraction = oldClamped;
    }
  }

  @override
  Widget build(BuildContext context) {
    final clamped = widget.fraction.clamp(0.0, 1.0);
    final barColor = widget.color ?? EmpireColors.cyan;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                widget.label,
                style: TextStyle(
                  fontSize: widget.compact ? 12 : 13.5,
                  color: EmpireColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            AnimatedCountText(
              prefix: '',
              value: (clamped * 100).round(),
              suffix: '%',
              style: TextStyle(
                fontSize: widget.compact ? 12 : 13,
                fontWeight: FontWeight.w700,
                color: barColor,
              ),
            ),
          ],
        ),
        SizedBox(height: widget.compact ? 3 : 5),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: _beginFraction, end: clamped),
          duration: const Duration(milliseconds: 550),
          curve: Curves.easeOutCubic,
          builder: (context, animatedValue, _) {
            return ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              child: LinearProgressIndicator(
                value: animatedValue,
                color: barColor,
                backgroundColor: EmpireColors.surfaceElevated,
                minHeight: widget.compact ? 6 : 9,
              ),
            );
          },
        ),
        SizedBox(height: widget.compact ? 4 : 8),
      ],
    );
  }
}

class GameFeel {
  const GameFeel._();

  static void playAction({required bool soundOn}) {
    if (soundOn) {
      try {
        SystemSound.play(SystemSoundType.click);
      } catch (_) {}
    }
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}
  }

  static void playSuccess({required bool soundOn}) {
    if (soundOn) {
      try {
        SystemSound.play(SystemSoundType.click);
      } catch (_) {}
    }
    try {
      HapticFeedback.selectionClick();
    } catch (_) {}
  }

  static void playImportant({required bool soundOn}) {
    if (soundOn) {
      try {
        SystemSound.play(SystemSoundType.alert);
      } catch (_) {}
    }
    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}
  }
}
