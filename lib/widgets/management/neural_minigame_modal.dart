import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../audio/empire_audio.dart';
import '../../settings/game_settings.dart';
import '../../theme/empire_theme.dart';

class NeuralTrainingResult {
  final int score;
  final int trainingGain;
  final int qualityGain;

  const NeuralTrainingResult({
    required this.score,
    required this.trainingGain,
    required this.qualityGain,
  });
}

enum _NodeKind { idle, cyan, gold, glitch }

/// لعبة مصغّرة تفاعلية حقيقية (10 ثوانٍ):
/// انقر بسرعة على العقد العصبية الزرقاء والذهبية لتدريب نموذجك، وتجنّب العقد الحمراء الساخنة!
Future<NeuralTrainingResult?> showNeuralMiniGame({
  required BuildContext context,
  required GameSettings settings,
}) {
  return showDialog<NeuralTrainingResult>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => _NeuralMiniGameDialog(settings: settings),
  );
}

class _NeuralMiniGameDialog extends StatefulWidget {
  final GameSettings settings;

  const _NeuralMiniGameDialog({required this.settings});

  @override
  State<_NeuralMiniGameDialog> createState() => _NeuralMiniGameDialogState();
}

class _NeuralMiniGameDialogState extends State<_NeuralMiniGameDialog> {
  final _rnd = math.Random();
  List<_NodeKind> _grid = List.filled(9, _NodeKind.idle);
  int _secondsLeft = 10;
  int _score = 0;
  Timer? _countdownTimer;
  Timer? _spawnTimer;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _spawnWave();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsLeft <= 1) {
        _finish();
      } else {
        setState(() => _secondsLeft--);
      }
    });
    _spawnTimer = Timer.periodic(const Duration(milliseconds: 950), (_) {
      if (mounted && !_finished) _spawnWave();
    });
  }

  void _spawnWave() {
    final next = List.filled(9, _NodeKind.idle);
    final cyanIndex = _rnd.nextInt(9);
    next[cyanIndex] = _rnd.nextDouble() < 0.25 ? _NodeKind.gold : _NodeKind.cyan;

    var secondIndex = _rnd.nextInt(9);
    if (secondIndex == cyanIndex) secondIndex = (cyanIndex + 1) % 9;
    next[secondIndex] = _NodeKind.cyan;

    var glitchIndex = _rnd.nextInt(9);
    while (glitchIndex == cyanIndex || glitchIndex == secondIndex) {
      glitchIndex = (glitchIndex + 1) % 9;
    }
    next[glitchIndex] = _NodeKind.glitch;

    setState(() => _grid = next);
  }

  void _tapNode(int index) {
    if (_finished) return;
    final kind = _grid[index];
    if (kind == _NodeKind.idle) return;

    setState(() {
      _grid[index] = _NodeKind.idle;
      if (kind == _NodeKind.cyan) {
        _score += 1;
        EmpireAudioEngine.instance.play(
          EmpireSfx.pulse,
          settings: widget.settings,
        );
      } else if (kind == _NodeKind.gold) {
        _score += 3;
        EmpireAudioEngine.instance.play(
          EmpireSfx.cash,
          settings: widget.settings,
        );
      } else if (kind == _NodeKind.glitch) {
        _score = (_score - 1).clamp(0, 999);
        EmpireAudioEngine.instance.play(
          EmpireSfx.alert,
          settings: widget.settings,
          heavyHaptic: true,
        );
      }
    });
  }

  void _finish() {
    if (_finished) return;
    _finished = true;
    _countdownTimer?.cancel();
    _spawnTimer?.cancel();
    final trainingGain = (3 + _score).clamp(3, 18);
    final qualityGain = _score >= 8 ? 3 : (_score >= 4 ? 1 : 0);
    EmpireAudioEngine.instance.play(
      EmpireSfx.upgrade,
      settings: widget.settings,
    );
    Navigator.of(context).pop(
      NeuralTrainingResult(
        score: _score,
        trainingGain: trainingGain,
        qualityGain: qualityGain,
      ),
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _spawnTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: EmpireColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: EmpireColors.cyan, width: 1.6),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.bolt_rounded, color: EmpireColors.cyan),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'تحدي الشبكة العصبية',
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w900,
                      color: EmpireColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: EmpireColors.gold.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '$_secondsLeft ث',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: EmpireColors.gold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'انقر على العقد الزرقاء (+1) والذهبية (+3) وتجنب الحمراء! • النقاط: $_score',
              style: const TextStyle(
                fontSize: 12.5,
                color: EmpireColors.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 9,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (_, i) {
                final kind = _grid[i];
                Color bg = EmpireColors.bg;
                Color border = EmpireColors.border;
                IconData icon = Icons.circle_outlined;
                if (kind == _NodeKind.cyan) {
                  bg = EmpireColors.cyan.withValues(alpha: 0.24);
                  border = EmpireColors.cyan;
                  icon = Icons.memory_rounded;
                } else if (kind == _NodeKind.gold) {
                  bg = EmpireColors.gold.withValues(alpha: 0.26);
                  border = EmpireColors.gold;
                  icon = Icons.auto_awesome_rounded;
                } else if (kind == _NodeKind.glitch) {
                  bg = EmpireColors.coral.withValues(alpha: 0.24);
                  border = EmpireColors.coral;
                  icon = Icons.local_fire_department_rounded;
                }
                return InkWell(
                  onTap: () => _tapNode(i),
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: border,
                        width: kind == _NodeKind.idle ? 1 : 2,
                      ),
                    ),
                    child: Icon(
                      icon,
                      size: kind == _NodeKind.idle ? 20 : 32,
                      color: kind == _NodeKind.idle
                          ? EmpireColors.textMuted
                          : border,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
            TextButton(
              onPressed: _finish,
              child: const Text('إنهاء وحصد المكافأة الآن'),
            ),
          ],
        ),
      ),
    );
  }
}
