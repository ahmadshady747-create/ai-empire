import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../analytics/career_stats.dart';
import '../../theme/empire_theme.dart';

/// شاشة الإعدادات والخصوصية والنسخ الاحتياطي المتوافقة مع متطلبات
/// Google Play وApple App Store (الخصوصية، حذف البيانات، النسخ الاحتياطي، سجل المسيرة).
Future<void> showEmpireSettingsSheet({
  required BuildContext context,
  required String companyName,
  required bool soundOn,
  required CareerStats careerStats,
  required String saveJson,
  required VoidCallback onToggleSound,
  required VoidCallback onReplayTutorial,
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
      return SafeArea(
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.78,
          maxChildSize: 0.92,
          minChildSize: 0.5,
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
                    Icon(Icons.settings_rounded, color: EmpireColors.cyan),
                    SizedBox(width: 8),
                    Text(
                      'الإعدادات ومسيرة الإمبراطورية',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: EmpireColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
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
                      _StatTag('أعلى نموذج', 'مستوى ${careerStats.highestModelLevel}'),
                      _StatTag('أطول صمود', '${careerStats.longestRunWeeks} أسبوع'),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                _SectionCard(
                  title: 'تفضيلات اللعب',
                  icon: Icons.tune_rounded,
                  accent: EmpireColors.cyan,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('المؤثرات الصوتية واللمسية'),
                        value: soundOn,
                        activeColor: EmpireColors.cyan,
                        onChanged: (_) {
                          onToggleSound();
                          Navigator.of(sheetContext).pop();
                        },
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          onReplayTutorial();
                          Navigator.of(sheetContext).pop();
                        },
                        icon: const Icon(Icons.school_rounded, size: 18),
                        label: const Text('إعادة عرض التعليم التفاعلي'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                _SectionCard(
                  title: 'النسخ الاحتياطي ونقل الحفظ',
                  icon: Icons.backup_rounded,
                  accent: EmpireColors.indigo,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'احفظ نسخة نصية من تقدمك لنقله إلى جهاز آخر دون حساب أو إنترنت.',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: EmpireColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                await Clipboard.setData(
                                  ClipboardData(text: saveJson),
                                );
                                if (!sheetContext.mounted) return;
                                ScaffoldMessenger.of(sheetContext).showSnackBar(
                                  const SnackBar(
                                    content: Text('تم نسخ بيانات الحفظ إلى الحافظة.'),
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
                              icon: const Icon(Icons.restore_rounded, size: 17),
                              label: const Text('استعادة حفظ'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                _SectionCard(
                  title: 'الخصوصية وحول اللعبة',
                  icon: Icons.verified_user_rounded,
                  accent: EmpireColors.emerald,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'إمبراطورية الذكاء الاصطناعي — الإصدار 2.0.0\nالشركة الحالية: $companyName',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: EmpireColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'سياسة الخصوصية: تعمل اللعبة بالكامل دون إنترنت، ولا تجمع أو تشارك أي بيانات شخصية أو تتبع إعلاني. يُحفظ تقدمك محلياً على جهازك فقط. جميع أسماء الشركات المنافسة والأحداث العالمية خيالية لأغراض المحاكاة.',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: EmpireColors.textSecondary,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: EmpireColors.coral,
                          side: BorderSide(
                            color: EmpireColors.coral.withOpacity(0.5),
                          ),
                        ),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: sheetContext,
                            builder: (c) => AlertDialog(
                              backgroundColor: EmpireColors.surface,
                              title: const Text('حذف جميع البيانات المحلية؟'),
                              content: const Text(
                                'سيُحذف الحفظ الحالي وسجل المسيرة والإعدادات نهائياً من هذا الجهاز.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(c).pop(false),
                                  child: const Text('إلغاء'),
                                ),
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: EmpireColors.coral,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () => Navigator.of(c).pop(true),
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
                        icon: const Icon(Icons.delete_forever_rounded, size: 18),
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
          const SizedBox(height: 10),
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
