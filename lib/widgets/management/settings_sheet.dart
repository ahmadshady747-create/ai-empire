import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../analytics/career_stats.dart';
import '../../audio/empire_audio.dart';
import '../../settings/game_settings.dart';
import '../../theme/empire_theme.dart';

/// شاشة الإعدادات الاحترافية الشاملة للإصدار 4.0:
/// تحكم بمستوى الصوت والاهتزاز، جودة المجسمات، القصة، الفتح التدريجي،
/// سجل المسيرة، النسخ الاحتياطي، الخصوصية، وحذف البيانات المحلية.
Future<void> showEmpireSettingsSheet({
  required BuildContext context,
  required String companyName,
  required GameSettings settings,
  required CareerStats careerStats,
  required String saveJson,
  required ValueChanged<GameSettings> onSettingsChanged,
  required VoidCallback onReplayTutorial,
  required VoidCallback onOpenGuide,
  required VoidCallback onOpenStoryJournal,
  required Future<bool> Function(String rawJson) onImportSave,
  required Future<void> Function() onDeleteAllData,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: EmpireColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (sheetContext) {
      var local = settings;
      return StatefulBuilder(
        builder: (context, setModalState) {
          void update(GameSettings next) {
            setModalState(() => local = next);
            onSettingsChanged(next);
          }

          return SafeArea(
            child: DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.84,
              maxChildSize: 0.94,
              minChildSize: 0.55,
              builder: (_, scrollController) {
                return ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: EmpireColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const Row(
                      children: [
                        Icon(Icons.tune_rounded, color: EmpireColors.cyan),
                        SizedBox(width: 8),
                        Text(
                          'إعدادات اللعبة ومسيرة الإمبراطورية',
                          style: TextStyle(
                            fontSize: 17.5,
                            fontWeight: FontWeight.w900,
                            color: EmpireColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _SectionCard(
                      title: 'الصوت والاهتزاز',
                      icon: Icons.volume_up_rounded,
                      accent: EmpireColors.cyan,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('المؤثرات الصوتية المخصصة'),
                            value: local.soundEnabled,
                            activeThumbColor: EmpireColors.cyan,
                            onChanged: (v) =>
                                update(local.copyWith(soundEnabled: v)),
                          ),
                          Row(
                            children: [
                              const Text(
                                'مستوى الصوت',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: EmpireColors.textSecondary,
                                ),
                              ),
                              Expanded(
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: EmpireColors.cyan,
                                  ),
                                  child: Slider(
                                    value: local.volume,
                                    onChanged: local.soundEnabled
                                        ? (v) =>
                                            update(local.copyWith(volume: v))
                                        : null,
                                  ),
                                ),
                              ),
                              Text(
                                '${(local.volume * 100).round()}%',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('الاهتزاز التفاعلي (Haptics)'),
                            value: local.hapticsEnabled,
                            activeThumbColor: EmpireColors.cyan,
                            onChanged: (v) =>
                                update(local.copyWith(hapticsEnabled: v)),
                          ),
                          OutlinedButton.icon(
                            onPressed: () {
                              EmpireAudioEngine.instance.play(
                                EmpireSfx.upgrade,
                                settings: local,
                              );
                            },
                            icon: const Icon(Icons.music_note_rounded, size: 17),
                            label: const Text('تجربة المؤثر الصوتي'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    _SectionCard(
                      title: 'الرسوميات وأسلوب اللعب',
                      icon: Icons.auto_awesome_rounded,
                      accent: EmpireColors.indigo,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('توهج المجسمات عالية الجودة'),
                            subtitle: const Text(
                              'أطفئها لتوفير البطارية على الأجهزة الضعيفة',
                              style: TextStyle(fontSize: 11.5),
                            ),
                            value: local.highVisualEffects,
                            activeThumbColor: EmpireColors.indigo,
                            onChanged: (v) =>
                                update(local.copyWith(highVisualEffects: v)),
                          ),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('تفعيل فصول القصة السينمائية'),
                            value: local.storyEnabled,
                            activeThumbColor: EmpireColors.indigo,
                            onChanged: (v) =>
                                update(local.copyWith(storyEnabled: v)),
                          ),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('فتح جميع الأنظمة المتقدمة فوراً'),
                            value: local.unlockAllSystems,
                            activeThumbColor: EmpireColors.indigo,
                            onChanged: (v) =>
                                update(local.copyWith(unlockAllSystems: v)),
                          ),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('إيقاف التسريع 4× عند الأحداث'),
                            value: local.autoPauseOnEvents,
                            activeThumbColor: EmpireColors.indigo,
                            onChanged: (v) =>
                                update(local.copyWith(autoPauseOnEvents: v)),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.of(sheetContext).pop();
                                    onOpenGuide();
                                  },
                                  icon: const Icon(
                                    Icons.menu_book_rounded,
                                    size: 17,
                                  ),
                                  label: const Text('دليل القائد'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.of(sheetContext).pop();
                                    onOpenStoryJournal();
                                  },
                                  icon: const Icon(
                                    Icons.auto_stories_rounded,
                                    size: 17,
                                  ),
                                  label: const Text('سجل القصة'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          OutlinedButton.icon(
                            onPressed: () {
                              onReplayTutorial();
                              Navigator.of(sheetContext).pop();
                            },
                            icon: const Icon(Icons.school_rounded, size: 17),
                            label: const Text('إعادة عرض التعليم التفاعلي'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    _SectionCard(
                      title: 'سجل المسيرة الدائم',
                      icon: Icons.workspace_premium_rounded,
                      accent: EmpireColors.gold,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _StatTag('الجولات', '${careerStats.runsPlayed}'),
                          _StatTag('الانتصارات', '${careerStats.victories}'),
                          _StatTag('أفضل ترتيب', '#${careerStats.bestRank}'),
                          _StatTag('أعلى نقد', '${careerStats.highestCash}'),
                          _StatTag('أعلى مستخدمين', '${careerStats.highestUsers}'),
                          _StatTag(
                            'أعلى نموذج',
                            'مستوى ${careerStats.highestModelLevel}',
                          ),
                          _StatTag(
                            'أطول صمود',
                            '${careerStats.longestRunWeeks} أسبوع',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    _SectionCard(
                      title: 'النسخ الاحتياطي والخصوصية',
                      icon: Icons.verified_user_rounded,
                      accent: EmpireColors.emerald,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    await Clipboard.setData(
                                      ClipboardData(text: saveJson),
                                    );
                                    if (!sheetContext.mounted) return;
                                    ScaffoldMessenger.of(sheetContext)
                                        .showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'تم نسخ بيانات الحفظ إلى الحافظة.',
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.copy_rounded, size: 17),
                                  label: const Text('نسخ الحفظ'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    final ok = await _showImportDialog(
                                      sheetContext,
                                      onImportSave,
                                    );
                                    if (ok && sheetContext.mounted) {
                                      Navigator.of(sheetContext).pop();
                                    }
                                  },
                                  icon:
                                      const Icon(Icons.restore_rounded, size: 17),
                                  label: const Text('استعادة حفظ'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'إمبراطورية الذكاء الاصطناعي — الإصدار 4.0.0\nالشركة الحالية: $companyName',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: EmpireColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'سياسة الخصوصية: تعمل اللعبة بالكامل دون إنترنت، ولا تجمع أو تشارك أي بيانات شخصية أو تتبع إعلاني. يُحفظ تقدمك محلياً على جهازك فقط.',
                            style: TextStyle(
                              fontSize: 12,
                              color: EmpireColors.textSecondary,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: EmpireColors.coral,
                              side: BorderSide(
                                color: EmpireColors.coral.withValues(alpha: 0.5),
                              ),
                            ),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: sheetContext,
                                builder: (c) => AlertDialog(
                                  backgroundColor: EmpireColors.surface,
                                  title: const Text('حذف جميع البيانات المحلية؟'),
                                  content: const Text(
                                    'سيُحذف الحفظ الحالي وسجل القصة والمسيرة والإعدادات نهائياً.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(c).pop(false),
                                      child: const Text('إلغاء'),
                                    ),
                                    FilledButton(
                                      style: FilledButton.styleFrom(
                                        backgroundColor: EmpireColors.coral,
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: () =>
                                          Navigator.of(c).pop(true),
                                      child: const Text('حذف نهائي'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await onDeleteAllData();
                                if (sheetContext.mounted) {
                                  Navigator.of(sheetContext).pop();
                                }
                              }
                            },
                            icon: const Icon(
                              Icons.delete_forever_rounded,
                              size: 18,
                            ),
                            label: const Text('حذف جميع البيانات المحلية'),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      );
    },
  );
}

Future<bool> _showImportDialog(
  BuildContext context,
  Future<bool> Function(String rawJson) onImportSave,
) async {
  final controller = TextEditingController();
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: EmpireColors.surface,
      title: const Text('استعادة حفظ محفوظ'),
      content: TextField(
        controller: controller,
        maxLines: 4,
        decoration: const InputDecoration(
          hintText: 'ألصق نص الحفظ (JSON) هنا...',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          onPressed: () async {
            final ok = await onImportSave(controller.text.trim());
            if (!dialogContext.mounted) return;
            Navigator.of(dialogContext).pop(ok);
          },
          child: const Text('استعادة'),
        ),
      ],
    ),
  );
  controller.dispose();
  return result == true;
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accent;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.accent,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: EmpireColors.bg,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: EmpireColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: accent),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _StatTag extends StatelessWidget {
  final String label;
  final String value;

  const _StatTag(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: EmpireColors.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: EmpireColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: EmpireColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: EmpireColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
