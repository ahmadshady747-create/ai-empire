import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

import '../settings/game_settings.dart';

enum EmpireSfx {
  click('audio/click.wav'),
  pulse('audio/pulse.wav'),
  cash('audio/cash.wav'),
  upgrade('audio/upgrade.wav'),
  alert('audio/alert.wav'),
  story('audio/story.wav'),
  victory('audio/victory.wav'),
  fail('audio/fail.wav');

  final String assetPath;
  const EmpireSfx(this.assetPath);
}

/// محرك الصوت والاهتزاز المتقدم للعبة (الإصدار 4.0):
/// يشغّل المؤثرات الصوتية المخصصة مع التحكم بمستوى الصوت والاهتزاز،
/// ويعمل بأمان تام في بيئة الاختبارات دون التسبب بأي استثناء.
class EmpireAudioEngine {
  EmpireAudioEngine._();

  static final EmpireAudioEngine instance = EmpireAudioEngine._();
  AudioPlayer? _player;

  Future<void> play(
    EmpireSfx sfx, {
    required GameSettings settings,
    bool heavyHaptic = false,
  }) async {
    if (settings.hapticsEnabled) {
      try {
        if (heavyHaptic) {
          HapticFeedback.mediumImpact();
        } else {
          HapticFeedback.lightImpact();
        }
      } catch (_) {}
    }

    if (!settings.soundEnabled || settings.volume <= 0.01) return;

    try {
      _player ??= AudioPlayer();
      await _player!.setVolume(settings.volume.clamp(0.0, 1.0));
      await _player!.stop();
      await _player!.play(AssetSource(sfx.assetPath));
    } catch (_) {
      // في بيئة الاختبارات أو عند عدم توفر مشغل صوت نستخدم صوت النظام كبديل صامت
      try {
        SystemSound.play(
          sfx == EmpireSfx.alert || sfx == EmpireSfx.fail
              ? SystemSoundType.alert
              : SystemSoundType.click,
        );
      } catch (_) {}
    }
  }
}
