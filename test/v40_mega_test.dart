import 'package:ai_empire/audio/empire_audio.dart';
import 'package:ai_empire/management.dart';
import 'package:ai_empire/settings/game_settings.dart';
import 'package:ai_empire/story/story_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('GameSettings يحفظ ويسترجع جميع تفضيلات الصوت والرسوميات والقصة', () {
    const original = GameSettings(
      soundEnabled: false,
      volume: 0.45,
      hapticsEnabled: false,
      highVisualEffects: false,
      unlockAllSystems: true,
      autoPauseOnEvents: false,
      storyEnabled: false,
    );
    final restored = GameSettings.fromJson(original.toJson());
    expect(restored.soundEnabled, isFalse);
    expect(restored.volume, 0.45);
    expect(restored.hapticsEnabled, isFalse);
    expect(restored.highVisualEffects, isFalse);
    expect(restored.unlockAllSystems, isTrue);
    expect(restored.autoPauseOnEvents, isFalse);
    expect(restored.storyEnabled, isFalse);
  });

  test('فصول القصة الستة تبدأ من الأسبوع 3 وتطبق خياراتها على الحالة', () {
    expect(storyChapters.length, 6);
    expect(nextPendingStoryChapter(ManagementState(week: 1), {}), isNull);
    final ch1 = nextPendingStoryChapter(ManagementState(week: 3), {});
    expect(ch1, isNotNull);
    expect(ch1!.id, 'ch1_spark');

    final s = ManagementState(week: 3, cash: 100000);
    ch1.choiceB.apply(s);
    expect(s.cash, 112000);
  });

  test('جميع المؤثرات الصوتية الثمانية تملك مسارات أصول صحيحة', () {
    expect(EmpireSfx.values.length, 8);
    for (final sfx in EmpireSfx.values) {
      expect(sfx.assetPath.startsWith('audio/'), isTrue);
      expect(sfx.assetPath.endsWith('.wav'), isTrue);
    }
  });
}
