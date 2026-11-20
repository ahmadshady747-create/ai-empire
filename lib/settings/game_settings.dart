/// إعدادات اللعبة الشاملة (الإصدار 4.0) المحفوظة محلياً على الجهاز.
class GameSettings {
  final bool soundEnabled;
  final double volume;
  final bool hapticsEnabled;
  final bool highVisualEffects;
  final bool unlockAllSystems;
  final bool autoPauseOnEvents;
  final bool storyEnabled;

  const GameSettings({
    this.soundEnabled = true,
    this.volume = 0.8,
    this.hapticsEnabled = true,
    this.highVisualEffects = true,
    this.unlockAllSystems = false,
    this.autoPauseOnEvents = true,
    this.storyEnabled = true,
  });

  GameSettings copyWith({
    bool? soundEnabled,
    double? volume,
    bool? hapticsEnabled,
    bool? highVisualEffects,
    bool? unlockAllSystems,
    bool? autoPauseOnEvents,
    bool? storyEnabled,
  }) {
    return GameSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      volume: volume ?? this.volume,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      highVisualEffects: highVisualEffects ?? this.highVisualEffects,
      unlockAllSystems: unlockAllSystems ?? this.unlockAllSystems,
      autoPauseOnEvents: autoPauseOnEvents ?? this.autoPauseOnEvents,
      storyEnabled: storyEnabled ?? this.storyEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'sound': soundEnabled,
        'vol': volume,
        'haptics': hapticsEnabled,
        'vfx': highVisualEffects,
        'unlockAll': unlockAllSystems,
        'autoPause': autoPauseOnEvents,
        'story': storyEnabled,
      };

  factory GameSettings.fromJson(Map<String, dynamic> j) => GameSettings(
        soundEnabled: (j['sound'] as bool?) ?? true,
        volume: ((j['vol'] as num?)?.toDouble() ?? 0.8).clamp(0.0, 1.0),
        hapticsEnabled: (j['haptics'] as bool?) ?? true,
        highVisualEffects: (j['vfx'] as bool?) ?? true,
        unlockAllSystems: (j['unlockAll'] as bool?) ?? false,
        autoPauseOnEvents: (j['autoPause'] as bool?) ?? true,
        storyEnabled: (j['story'] as bool?) ?? true,
      );
}
