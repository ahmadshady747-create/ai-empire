import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../analytics/career_stats.dart';
import '../analytics/company_history.dart';
import '../audio/empire_audio.dart';
import '../interactive/decision_cards.dart';
import '../interactive/hq_pulses.dart';
import '../interactive/progression_stages.dart';
import '../management.dart';
import '../settings/game_settings.dart';
import '../story/story_engine.dart';
import '../theme/empire_theme.dart';
import '../tutorial.dart';
import '../widgets/management/bottom_action_dock.dart';
import '../widgets/management/command_hud.dart';
import '../widgets/management/empire_tab.dart';
import '../widgets/management/endgame_modal.dart';
import '../widgets/management/game_guide_sheet.dart';
import '../widgets/management/launch_hype_modal.dart';
import '../widgets/management/market_tab.dart';
import '../widgets/management/neural_minigame_modal.dart';
import '../widgets/management/overview_tab.dart';
import '../widgets/management/settings_sheet.dart';
import '../widgets/management/story_dialog.dart';
import '../widgets/management/tech_tab.dart';

/// لوحة إدارة "إمبراطورية الذكاء الاصطناعي" — الإصدار 4.0 Mega Edition:
/// قصة سينمائية من 6 فصول، لعبة مصغّرة لتدريب الشبكة العصبية،
/// مجسمات ثلاثية الأبعاد أيزومترية، 8 مؤثرات صوتية مخصصة، إعدادات احترافية،
/// ودليل قائد مصوّر مع توافق كامل مع الحفظ والاختبارات.
class ManagementScreen extends StatefulWidget {
  const ManagementScreen({super.key});

  @override
  State<ManagementScreen> createState() => _ManagementScreenState();
}

class _ManagementScreenState extends State<ManagementScreen> {
  static const _saveKey = 'ai_management_v1';
  static const _historyKey = 'ai_management_history_v1';
  static const _nameKey = 'ai_company_name_v1';
  static const _careerKey = 'ai_career_stats_v1';
  static const _tutorialKey = 'ai_tutorial_done_v1';
  static const _settingsKey = 'ai_settings_v40';
  static const _storyKey = 'ai_story_v40';

  ManagementState _state = ManagementState();
  CareerStats _career = const CareerStats();
  GameSettings _settings = const GameSettings();
  final Set<String> _completedStoryIds = {};

  String _companyName = 'إمبراطورية الذكاء';
  WeekReport? _lastReport;
  WeekDelta? _lastDelta;
  List<WeekSnapshot> _history = [];
  List<HqPulse> _pulses = [];
  final Set<String> _claimedPulseIds = {};
  bool _miniGameAvailable = true;
  DecisionCardModel? _activeDecision;

  String? _saveStatus;
  int _streakWeeks = 0;
  int _tutorialStep = 0;
  bool _eventSceneDismissed = false;
  String? _eventNote;
  bool _endgameShown = false;

  int _navIndex = 0;
  int _techSub = 0;
  int _marketSub = 0;
  int _empireSub = 0;

  @override
  void initState() {
    super.initState();
    _history = [WeekSnapshot.fromState(_state)];
    _pulses = generateWeeklyPulses(_state.week, _state);
    _loadSaved();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_tutorialKey) == true && mounted) {
      setState(() => _tutorialStep = 3);
    }
    final rawSettings = prefs.getString(_settingsKey);
    if (rawSettings != null) {
      try {
        final parsed = GameSettings.fromJson(
          jsonDecode(rawSettings) as Map<String, dynamic>,
        );
        if (mounted) setState(() => _settings = parsed);
      } catch (_) {}
    }
    final rawStory = prefs.getStringList(_storyKey);
    if (rawStory != null && mounted) {
      setState(() => _completedStoryIds.addAll(rawStory));
    }
  }

  Future<void> _saveSettings(GameSettings next) async {
    setState(() => _settings = next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(next.toJson()));
  }

  Future<void> _persistTutorialDone(bool done) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tutorialKey, done);
  }

  Future<void> _unlockAllNow() async {
    await _saveSettings(_settings.copyWith(unlockAllSystems: true));
    if (!mounted) return;
    setState(() {
      _eventNote = 'تم فتح جميع الأنظمة المتقدمة فوراً!';
    });
    EmpireAudioEngine.instance.play(EmpireSfx.upgrade, settings: _settings);
  }

  void _finishTutorialStep(int next) {
    _tutorialStep = next;
    if (next >= 3) _persistTutorialDone(true);
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString(_nameKey);
    if (savedName != null && savedName.trim().isNotEmpty && mounted) {
      setState(() => _companyName = savedName.trim());
    }

    final rawCareer = prefs.getString(_careerKey);
    if (rawCareer != null) {
      try {
        final restoredCareer = CareerStats.fromJson(
          jsonDecode(rawCareer) as Map<String, dynamic>,
        );
        if (mounted) {
          setState(() => _career = restoredCareer);
        }
      } catch (_) {}
    }

    final raw = prefs.getString(_saveKey);
    if (raw == null) return;
    try {
      final restored =
          ManagementState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      List<WeekSnapshot> restoredHistory = [WeekSnapshot.fromState(restored)];
      final rawHist = prefs.getString(_historyKey);
      if (rawHist != null) {
        try {
          final decoded = jsonDecode(rawHist) as List<dynamic>;
          final parsed = decoded
              .whereType<Map<String, dynamic>>()
              .map(WeekSnapshot.fromJson)
              .toList();
          if (parsed.isNotEmpty) {
            restoredHistory = parsed;
          }
        } catch (_) {}
      }
      if (!mounted) return;
      setState(() {
        _state = restored;
        _history = restoredHistory;
        _pulses = generateWeeklyPulses(restored.week, restored);
        _claimedPulseIds.clear();
        _career = _career.recordProgress(restored);
        _endgameShown = restored.isBankrupt || restored.leadershipVictory;
        _saveStatus =
            'تم استئناف إدارة محفوظة — الأسبوع ${restored.week}، النقد ${restored.cash}.';
      });
    } catch (_) {}
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_saveKey, jsonEncode(_state.toJson()));
    await prefs.setString(
      _historyKey,
      jsonEncode(_history.map((e) => e.toJson()).toList()),
    );
    await prefs.setString(_nameKey, _companyName);
    await prefs.setString(_careerKey, jsonEncode(_career.toJson()));
    await prefs.setStringList(_storyKey, _completedStoryIds.toList());
    if (!mounted) return;
    setState(() {
      _saveStatus = 'تم حفظ الإدارة (الأسبوع ${_state.week}).';
    });
  }

  void _recordSnapshot() {
    final snap = WeekSnapshot.fromState(_state);
    if (_history.isNotEmpty && _history.last.week == snap.week) {
      _history[_history.length - 1] = snap;
    } else {
      _history.add(snap);
      if (_history.length > 40) {
        _history = _history.sublist(_history.length - 40);
      }
    }
    _career = _career.recordProgress(_state);
  }

  void _jumpTo(int navIndex, int subIndex) {
    setState(() {
      _navIndex = navIndex.clamp(0, 3);
      if (_navIndex == 1) _techSub = subIndex;
      if (_navIndex == 2) _marketSub = subIndex;
      if (_navIndex == 3) _empireSub = subIndex;
    });
    EmpireAudioEngine.instance.play(EmpireSfx.click, settings: _settings);
  }

  void _mutate(VoidCallback action) {
    setState(() {
      action();
      _recordSnapshot();
    });
    EmpireAudioEngine.instance.play(EmpireSfx.cash, settings: _settings);
  }

  Future<void> _playNeuralMiniGame() async {
    if (!_miniGameAvailable || _state.isBankrupt) return;
    final res = await showNeuralMiniGame(context: context, settings: _settings);
    if (res == null || !mounted) return;
    setState(() {
      _state.trainingProgress =
          (_state.trainingProgress + res.trainingGain).clamp(0, 100);
      if (res.qualityGain > 0) {
        _state.dataQuality =
            (_state.dataQuality + res.qualityGain).clamp(0, 100);
      }
      _miniGameAvailable = false;
      _eventNote =
          'أنهيت تحدي الشبكة العصبية بنقاط ${res.score}: +${res.trainingGain} تدريب${res.qualityGain > 0 ? ' و+${res.qualityGain} جودة بيانات' : ''}!';
      _recordSnapshot();
    });
    await _save();
  }

  void _claimPulse(HqPulse pulse) {
    if (_claimedPulseIds.contains(pulse.id)) return;
    setState(() {
      pulse.apply(_state);
      _claimedPulseIds.add(pulse.id);
      _eventNote = 'اقتنصت فرصة المقر: ${pulse.title} (${pulse.rewardLabel})!';
      _recordSnapshot();
    });
    EmpireAudioEngine.instance.play(EmpireSfx.pulse, settings: _settings);
  }

  void _chooseDecision(DecisionOption option) {
    setState(() {
      option.apply(_state);
      _activeDecision = null;
      _eventNote = 'نتيجة القرار: ${option.resultNote}';
      _recordSnapshot();
    });
    _save();
    EmpireAudioEngine.instance.play(EmpireSfx.upgrade, settings: _settings);
  }

  Future<void> _maybeTriggerStory() async {
    if (!_settings.storyEnabled || !mounted) return;
    final chapter = nextPendingStoryChapter(_state, _completedStoryIds);
    if (chapter == null) return;
    EmpireAudioEngine.instance.play(EmpireSfx.story, settings: _settings);
    final chosen = await showStoryChapterDialog(
      context: context,
      chapter: chapter,
    );
    if (!mounted) return;
    setState(() {
      _completedStoryIds.add(chapter.id);
      if (chosen != null) {
        chosen.apply(_state);
        _eventNote = '${chapter.title}: ${chosen.epilogue}';
        _recordSnapshot();
      }
    });
    await _save();
    EmpireAudioEngine.instance.play(EmpireSfx.upgrade, settings: _settings);
  }

  void _advanceWeeks(int count) {
    if (_state.isBankrupt) return;
    final prevSnap = WeekSnapshot.fromState(_state);
    final prevModelLevel = _state.modelLevel;
    final wasEnded = _state.isBankrupt || _state.leadershipVictory;

    setState(() {
      for (var i = 0; i < count; i++) {
        if (_state.isBankrupt) break;
        _lastReport = _state.advanceWeek();
        _streakWeeks = _state.isBankrupt ? 0 : _streakWeeks + 1;
        _finishTutorialStep(
          nextTutorialStep(_tutorialStep, TutorialEvent.advanced),
        );
        _eventSceneDismissed = false;
        _eventNote = null;
        _miniGameAvailable = true;
        _claimedPulseIds.clear();
        _pulses = generateWeeklyPulses(_state.week, _state);
        _activeDecision = _lastReport!.worldEvent.isEmpty
            ? pickDecisionForWeek(_state.week)
            : null;
        _recordSnapshot();

        final hitStory = _settings.storyEnabled &&
            nextPendingStoryChapter(_state, _completedStoryIds) != null;
        if (_state.isBankrupt ||
            _state.leadershipVictory ||
            (_settings.autoPauseOnEvents &&
                (_lastReport!.worldEvent.isNotEmpty ||
                    _activeDecision != null ||
                    hitStory))) {
          break;
        }
      }
      _lastDelta = WeekDelta.between(prevSnap, WeekSnapshot.fromState(_state));
      if (!wasEnded && (_state.isBankrupt || _state.leadershipVictory)) {
        _career = _career.recordOutcome(
          victory: _state.leadershipVictory && !_state.isBankrupt,
          bankrupt: _state.isBankrupt,
        );
      }
    });

    _save();
    if (_state.isBankrupt || _state.leadershipVictory) {
      EmpireAudioEngine.instance.play(
        _state.isBankrupt ? EmpireSfx.fail : EmpireSfx.victory,
        settings: _settings,
        heavyHaptic: true,
      );
      if (!wasEnded && !_endgameShown && mounted) {
        _endgameShown = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          showEndgameSummaryDialog(
            context: context,
            companyName: _companyName,
            state: _state,
            history: _history,
            onStartNew: () => _startNewEmpire(startingCash: 150000),
          );
        });
      }
    } else if (_state.modelLevel > prevModelLevel && mounted) {
      EmpireAudioEngine.instance.play(
        EmpireSfx.upgrade,
        settings: _settings,
        heavyHaptic: true,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showLaunchHypeModal(
          context: context,
          title: 'إنجاز تقني: نموذجك بلغ المستوى ${_state.modelLevel}!',
          subtitle:
              'ارتفع تصنيف $_companyName أمام OpenMind وAnthroCore وDeepVortex!',
          state: _state,
          isModelUpgrade: true,
        );
      });
    } else {
      EmpireAudioEngine.instance.play(
        _lastReport != null && _lastReport!.worldEvent.isNotEmpty
            ? EmpireSfx.alert
            : EmpireSfx.click,
        settings: _settings,
      );
      if (_settings.storyEnabled &&
          nextPendingStoryChapter(_state, _completedStoryIds) != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _maybeTriggerStory();
        });
      }
    }
  }

  Future<void> _startNewEmpire({required int startingCash}) async {
    setState(() {
      _state = ManagementState(cash: startingCash);
      _career = _career.recordNewRun().recordProgress(_state);
      _completedStoryIds.clear();
      _lastReport = null;
      _lastDelta = null;
      _history = [WeekSnapshot.fromState(_state)];
      _pulses = generateWeeklyPulses(_state.week, _state);
      _claimedPulseIds.clear();
      _miniGameAvailable = true;
      _activeDecision = null;
      _streakWeeks = 0;
      _eventSceneDismissed = false;
      _eventNote = null;
      _endgameShown = false;
      _saveStatus = 'بدأت شركة جديدة من الأسبوع 1 برأس مال $startingCash.';
    });
    await _save();
  }

  Future<void> _confirmReset() async {
    final startingCash = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: EmpireColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: EmpireColors.border),
        ),
        title: const Text('بدء إمبراطورية جديدة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'اختر سيناريو الانطلاق (سيبقى سجل مسيرتك الدائم محفوظاً):',
              style: TextStyle(
                fontSize: 13,
                color: EmpireColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(150000),
              child: const Text('مرآب ناشئ (قياسي — 150,000)'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(85000),
              child: const Text('تحدي المؤسس (صعب — 85,000)'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(240000),
              child: const Text('تمويل جريء (سريع — 240,000)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
    if (startingCash == null || !mounted) return;
    await _startNewEmpire(startingCash: startingCash);
  }

  Future<void> _renameCompany() async {
    final controller = TextEditingController(text: _companyName);
    final updated = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: EmpireColors.surface,
        title: const Text('تسمية شركتك'),
        content: TextField(
          controller: controller,
          maxLength: 26,
          decoration: const InputDecoration(
            hintText: 'مثلاً: نيورال العرب',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(context).pop(controller.text.trim()),
            child: const Text('حفظ الاسم'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (updated == null || updated.isEmpty || !mounted) return;
    setState(() => _companyName = updated);
    await _save();
  }

  Future<bool> _importSaveJson(String rawJson) async {
    try {
      final restored = ManagementState.fromJson(
        jsonDecode(rawJson) as Map<String, dynamic>,
      );
      if (!mounted) return false;
      setState(() {
        _state = restored;
        _history = [WeekSnapshot.fromState(restored)];
        _pulses = generateWeeklyPulses(restored.week, restored);
        _claimedPulseIds.clear();
        _miniGameAvailable = true;
        _activeDecision = null;
        _lastDelta = null;
        _lastReport = null;
        _endgameShown = restored.isBankrupt || restored.leadershipVictory;
        _career = _career.recordProgress(restored);
        _saveStatus =
            'تمت استعادة النسخة الاحتياطية — الأسبوع ${restored.week}.';
      });
      await _save();
      return true;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('نص الحفظ غير صالح — تأكد من نسخه كاملاً.'),
          ),
        );
      }
      return false;
    }
  }

  Future<void> _deleteAllLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_saveKey);
    await prefs.remove(_historyKey);
    await prefs.remove(_nameKey);
    await prefs.remove(_careerKey);
    await prefs.remove(_tutorialKey);
    await prefs.remove(_settingsKey);
    await prefs.remove(_storyKey);
    if (!mounted) return;
    setState(() {
      _state = ManagementState();
      _career = const CareerStats();
      _settings = const GameSettings();
      _completedStoryIds.clear();
      _companyName = 'إمبراطورية الذكاء';
      _history = [WeekSnapshot.fromState(_state)];
      _pulses = generateWeeklyPulses(_state.week, _state);
      _claimedPulseIds.clear();
      _miniGameAvailable = true;
      _activeDecision = null;
      _lastReport = null;
      _lastDelta = null;
      _streakWeeks = 0;
      _tutorialStep = 0;
      _eventSceneDismissed = false;
      _eventNote = null;
      _endgameShown = false;
      _saveStatus = 'تم مسح جميع البيانات المحلية والبدء من جديد.';
    });
  }

  void _openSettings() {
    showEmpireSettingsSheet(
      context: context,
      companyName: _companyName,
      settings: _settings,
      careerStats: _career,
      saveJson: jsonEncode(_state.toJson()),
      onSettingsChanged: _saveSettings,
      onReplayTutorial: () {
        setState(() {
          _tutorialStep = 0;
          _navIndex = 0;
        });
        _persistTutorialDone(false);
      },
      onOpenGuide: () => showGameGuideSheet(context),
      onOpenStoryJournal: () => showStoryJournalSheet(
        context: context,
        completedChapterIds: _completedStoryIds,
      ),
      onImportSave: _importSaveJson,
      onDeleteAllData: _deleteAllLocalData,
    );
  }

  Widget _buildActiveTab(ProgressionUnlock progression) {
    final s = _state;
    switch (_navIndex) {
      case 0:
        return OverviewTab(
          companyName: _companyName,
          state: s,
          progression: progression,
          lastReport: _lastReport,
          lastDelta: _lastDelta,
          pulses: _pulses,
          claimedPulseIds: _claimedPulseIds,
          miniGameAvailable: _miniGameAvailable,
          highVisualEffects: _settings.highVisualEffects,
          completedStoryCount: _completedStoryIds.length,
          activeDecision: _activeDecision,
          streakWeeks: _streakWeeks,
          tutorialStep: _tutorialStep,
          eventSceneDismissed: _eventSceneDismissed,
          eventNote: _eventNote,
          onJump: _jumpTo,
          onPlayMiniGame: _playNeuralMiniGame,
          onOpenStoryJournal: () => showStoryJournalSheet(
            context: context,
            completedChapterIds: _completedStoryIds,
          ),
          onOpenGuide: () => showGameGuideSheet(context),
          onClaimPulse: _claimPulse,
          onChooseDecision: _chooseDecision,
          onBuyTutorialData: () {
            final affordable = ManagementState.dataCatalog
                .where((d) => s.cash >= d.cost)
                .toList();
            if (affordable.isEmpty) return;
            _mutate(() {
              s.buyData(affordable.first.id);
              _finishTutorialStep(
                nextTutorialStep(
                  _tutorialStep,
                  TutorialEvent.managementAction,
                ),
              );
            });
          },
          onStartTutorialResearch: () {
            final affordable = ManagementState.researchCatalog
                .where(
                  (d) =>
                      s.activeResearch == null &&
                      !s.completedResearch.contains(d.id) &&
                      s.cash >= d.cost,
                )
                .toList();
            if (affordable.isEmpty) return;
            _mutate(() {
              s.startResearch(affordable.first.id);
              _finishTutorialStep(
                nextTutorialStep(
                  _tutorialStep,
                  TutorialEvent.managementAction,
                ),
              );
            });
          },
          onSkipTutorialStep: () {
            setState(() {
              _finishTutorialStep(
                nextTutorialStep(
                  _tutorialStep,
                  TutorialEvent.managementAction,
                ),
              );
            });
          },
          onSkipAllTutorial: () {
            setState(() {
              _finishTutorialStep(
                nextTutorialStep(_tutorialStep, TutorialEvent.skipped),
              );
            });
          },
          onEventBuyCompute: () {
            _mutate(() {
              s.buyCompute();
              _eventSceneDismissed = true;
              _eventNote =
                  'قررت: شراء 25 وحدة حوسبة — حوسبتك المتاحة ارتفعت فورا، وستظهر في المشهد الحي.';
            });
          },
          onEventStartResearch: () {
            final first = ManagementState.researchCatalog.firstWhere(
              (d) =>
                  !s.completedResearch.contains(d.id) && s.cash >= d.cost,
            );
            _mutate(() {
              s.startResearch(first.id);
              _eventSceneDismissed = true;
              _eventNote =
                  'قررت: بدء مشروع بحث (${first.name}) — سيتقدم مع الأسابيع التالية.';
            });
          },
          onEventSaveCash: () {
            _mutate(() {
              _eventSceneDismissed = true;
              _eventNote =
                  'قررت: ادخار النقد — لم تنفق شيئا على الحدث، ونقدك محفوظ للأسبوع التالي.';
            });
          },
        );
      case 1:
        return TechTab(
          state: s,
          progression: progression,
          subIndex: _techSub,
          onSubChanged: (i) => setState(() => _techSub = i),
          onUnlockAll: _unlockAllNow,
          onMutate: _mutate,
        );
      case 2:
        return MarketTab(
          companyName: _companyName,
          state: s,
          progression: progression,
          subIndex: _marketSub,
          onSubChanged: (i) => setState(() => _marketSub = i),
          onUnlockAll: _unlockAllNow,
          onMutate: _mutate,
        );
      case 3:
      default:
        return EmpireTab(
          companyName: _companyName,
          state: s,
          progression: progression,
          history: _history,
          streakWeeks: _streakWeeks,
          subIndex: _empireSub,
          onSubChanged: (i) => setState(() => _empireSub = i),
          onUnlockAll: _unlockAllNow,
          onMutate: _mutate,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final progression = ProgressionUnlock.fromState(
      _state,
      unlockAllOverride: _settings.unlockAllSystems,
    );

    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: _renameCompany,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.hub_rounded, color: EmpireColors.cyan, size: 22),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _companyName,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 5),
                const Icon(
                  Icons.edit_rounded,
                  size: 14,
                  color: EmpireColors.textMuted,
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt_rounded),
            tooltip: 'بدء شركة جديدة',
            onPressed: _confirmReset,
          ),
          IconButton(
            icon: Icon(
              _settings.soundEnabled ? Icons.volume_up : Icons.volume_off,
            ),
            tooltip: _settings.soundEnabled ? 'كتم الصوت' : 'تشغيل الصوت',
            onPressed: () => _saveSettings(
              _settings.copyWith(soundEnabled: !_settings.soundEnabled),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            tooltip: 'الإعدادات والخصوصية',
            onPressed: _openSettings,
          ),
        ],
      ),
      body: Column(
        children: [
          CommandHud(
            state: _state,
            saveStatus: _saveStatus,
            onJump: _jumpTo,
          ),
          Expanded(child: _buildActiveTab(progression)),
          BottomActionDock(
            isBankrupt: _state.isBankrupt,
            highlightAdvance: _tutorialStep == 0 || _tutorialStep == 2,
            onAdvanceWeek: () => _advanceWeeks(1),
            onFastForward: () => _advanceWeeks(4),
            onSave: _save,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (index) {
          setState(() => _navIndex = index);
          EmpireAudioEngine.instance.play(EmpireSfx.click, settings: _settings);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'المقر',
          ),
          NavigationDestination(
            icon: Icon(Icons.psychology_outlined),
            selectedIcon: Icon(Icons.psychology_rounded),
            label: 'التطوير',
          ),
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront_rounded),
            label: 'السوق',
          ),
          NavigationDestination(
            icon: Icon(Icons.workspace_premium_outlined),
            selectedIcon: Icon(Icons.workspace_premium_rounded),
            label: 'الإمبراطورية',
          ),
        ],
      ),
    );
  }
}
