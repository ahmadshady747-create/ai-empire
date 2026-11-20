import 'package:flutter/material.dart';

import '../../story/story_engine.dart';
import '../../theme/empire_theme.dart';

/// نافذة عرض فصل القصة السينمائية مع بورتريهات شخصيات مرسومة بـ CustomPainter
/// وحوار تفاعلي وخيارين حاسمين يؤثران مباشرة في مسار الشركة.
Future<StoryChoice?> showStoryChapterDialog({
  required BuildContext context,
  required StoryChapter chapter,
  bool readOnly = false,
}) {
  return showDialog<StoryChoice>(
    context: context,
    barrierDismissible: readOnly,
    builder: (dialogContext) => _StoryDialogBody(
      chapter: chapter,
      readOnly: readOnly,
    ),
  );
}

class _StoryDialogBody extends StatefulWidget {
  final StoryChapter chapter;
  final bool readOnly;

  const _StoryDialogBody({
    required this.chapter,
    required this.readOnly,
  });

  @override
  State<_StoryDialogBody> createState() => _StoryDialogBodyState();
}

class _StoryDialogBodyState extends State<_StoryDialogBody> {
  int _lineIndex = 0;

  @override
  Widget build(BuildContext context) {
    final lines = widget.chapter.dialogue;
    final currentLine = lines[_lineIndex];
    final profile = storyCast[currentLine.speaker]!;
    final isLastLine = _lineIndex >= lines.length - 1;

    return Dialog(
      backgroundColor: EmpireColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: profile.color.withValues(alpha: 0.75), width: 1.6),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: profile.color.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.chapter.title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: profile.color,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${_lineIndex + 1} / ${lines.length}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: EmpireColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _CharacterPortrait(profile: profile),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name,
                        style: const TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w900,
                          color: EmpireColors.textPrimary,
                        ),
                      ),
                      Text(
                        profile.role,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: profile.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: EmpireColors.bg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: EmpireColors.border),
              ),
              child: Text(
                '«${currentLine.text}»',
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.55,
                  color: EmpireColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 14),
            if (!isLastLine)
              FilledButton(
                onPressed: () => setState(() => _lineIndex++),
                child: const Text('متابعة الحوار ◀'),
              )
            else if (widget.readOnly)
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('إغلاق'),
              )
            else ...[
              _StoryChoiceTile(
                choice: widget.chapter.choiceA,
                accent: profile.color,
                onTap: () => Navigator.of(context).pop(widget.chapter.choiceA),
              ),
              const SizedBox(height: 8),
              _StoryChoiceTile(
                choice: widget.chapter.choiceB,
                accent: EmpireColors.textSecondary,
                onTap: () => Navigator.of(context).pop(widget.chapter.choiceB),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CharacterPortrait extends StatelessWidget {
  final CharacterProfile profile;

  const _CharacterPortrait({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            profile.color.withValues(alpha: 0.45),
            EmpireColors.bg,
          ],
        ),
        border: Border.all(color: profile.color, width: 2),
        boxShadow: [
          BoxShadow(
            color: profile.color.withValues(alpha: 0.35),
            blurRadius: 12,
          ),
        ],
      ),
      child: Icon(profile.emblem, color: profile.color, size: 28),
    );
  }
}

class _StoryChoiceTile extends StatelessWidget {
  final StoryChoice choice;
  final Color accent;
  final VoidCallback onTap;

  const _StoryChoiceTile({
    required this.choice,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: EmpireColors.surfaceElevated,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: accent.withValues(alpha: 0.6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              choice.label,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: EmpireColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                for (final tag in choice.impactTags)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
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
                        fontSize: 11,
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

/// نافذة سجل القصة لعرض الفصول المفتوحة والمقبلة وإعادة قراءة الحوارات.
Future<void> showStoryJournalSheet({
  required BuildContext context,
  required Set<String> completedChapterIds,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: EmpireColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (sheetContext) => SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.72,
        maxChildSize: 0.9,
        builder: (_, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.all(16),
          children: [
            const Row(
              children: [
                Icon(Icons.auto_stories_rounded, color: EmpireColors.gold),
                SizedBox(width: 8),
                Text(
                  'سجل قصة الإمبراطورية (6 فصول)',
                  style: TextStyle(
                    fontSize: 17.5,
                    fontWeight: FontWeight.w800,
                    color: EmpireColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final ch in storyChapters) ...[
              Builder(
                builder: (_) {
                  final unlocked = completedChapterIds.contains(ch.id);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: EmpireColors.bg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: unlocked
                            ? EmpireColors.gold.withValues(alpha: 0.55)
                            : EmpireColors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          unlocked
                              ? Icons.check_circle_rounded
                              : Icons.lock_outline_rounded,
                          color: unlocked
                              ? EmpireColors.gold
                              : EmpireColors.textMuted,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ch.title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: EmpireColors.textPrimary,
                                ),
                              ),
                              Text(
                                unlocked ? 'مكتمل — انقر لإعادة القراءة' : ch.unlockHint,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: EmpireColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (unlocked)
                          OutlinedButton(
                            onPressed: () {
                              showStoryChapterDialog(
                                context: sheetContext,
                                chapter: ch,
                                readOnly: true,
                              );
                            },
                            child: const Text('قراءة'),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
