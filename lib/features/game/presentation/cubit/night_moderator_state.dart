import '../../domain/entities/game_role.dart';

/// Phases of the automated Night-1 Audio & Visual Moderator, starting in
/// a manual [standby] state so players can place the phone on the table first.
enum NightOnePhase {
  standby(
    stepNumber: 0,
    durationSeconds: 0,
    title: 'اكتمل توزيع الأدوار بنجاح',
    instruction:
        'ضع الهاتف في منتصف الطاولة، وعندما يكون الجميع جاهزاً اضغط لبدء الليلة الأولى',
    audioAssetSource: null,
    audioAssetPath: null,
    isMafiaActive: false,
  ),
  everyoneSleep(
    stepNumber: 1,
    durationSeconds: 15,
    title: 'سبات المدينة',
    instruction: 'المدينة تغفو الآن... على الجميع إغماض أعينهم بالكامل',
    audioAssetSource: GameAssets.nightSleepAudioSource,
    audioAssetPath: GameAssets.nightSleepAudio,
    isMafiaActive: false,
  ),
  mafiaWake(
    stepNumber: 2,
    durationSeconds: 12,
    title: 'استيقاظ المافيا',
    instruction: 'فريق المافيا فقط... افتحوا أعينكم الآن وتعرفوا على بعضكم بصمت',
    audioAssetSource: GameAssets.mafiaWakeAudioSource,
    audioAssetPath: GameAssets.mafiaWakeAudio,
    isMafiaActive: true,
  ),
  mafiaSleep(
    stepNumber: 3,
    durationSeconds: 5,
    title: 'عودة المافيا للسبات',
    instruction: 'انتهى الوقت... فريق المافيا، أغمضوا أعينكم الآن',
    audioAssetSource: GameAssets.mafiaSleepAudioSource,
    audioAssetPath: GameAssets.mafiaSleepAudio,
    isMafiaActive: false,
  ),
  everyoneWake(
    stepNumber: 4,
    durationSeconds: 3,
    title: 'شروق الصباح',
    instruction: 'أشرق الصباح... على الجميع فتح أعينهم الآن. ابدأوا النقاش!',
    audioAssetSource: GameAssets.cityWakeAudioSource,
    audioAssetPath: GameAssets.cityWakeAudio,
    isMafiaActive: false,
  ),
  completed(
    stepNumber: 4,
    durationSeconds: 0,
    title: 'انتهت الليلة الأولى',
    instruction: 'انتقل إلى خزنة التحقق من الهوية لمتابعة الجولة',
    audioAssetSource: null,
    audioAssetPath: null,
    isMafiaActive: false,
  );

  const NightOnePhase({
    required this.stepNumber,
    required this.durationSeconds,
    required this.title,
    required this.instruction,
    required this.audioAssetSource,
    required this.audioAssetPath,
    required this.isMafiaActive,
  });

  final int stepNumber;
  final int durationSeconds;
  final String title;
  final String instruction;
  final String? audioAssetSource;
  final String? audioAssetPath;
  final bool isMafiaActive;

  bool get isStandby => this == NightOnePhase.standby;
  bool get isCompletedPhase => this == NightOnePhase.completed;
  bool get isActiveCountdownPhase =>
      this != NightOnePhase.standby && this != NightOnePhase.completed;

  /// The 4 timed audio phases of Night 1.
  static const List<NightOnePhase> activePhases = <NightOnePhase>[
    everyoneSleep,
    mafiaWake,
    mafiaSleep,
    everyoneWake,
  ];

  static int get totalSteps => activePhases.length;
}

/// Alias preserving backwards compatibility with existing references.
typedef NightModeratorPhase = NightOnePhase;

/// Immutable state for the Night-1 Moderator sequence.
class NightModeratorState {
  const NightModeratorState({
    this.phase = NightOnePhase.standby,
    this.remainingSeconds = 0,
    this.isRunning = false,
    this.isCompleted = false,
    this.audioPlaybackCount = 0,
  });

  final NightOnePhase phase;
  final int remainingSeconds;
  final bool isRunning;
  final bool isCompleted;

  /// Tracks how many times phase audio was triggered (useful for UI feedback & tests).
  final int audioPlaybackCount;

  bool get isStandby => phase == NightOnePhase.standby;

  int get totalPhaseSeconds => phase.durationSeconds;

  double get phaseProgress {
    if (totalPhaseSeconds <= 0) {
      return 0.0;
    }
    return (remainingSeconds / totalPhaseSeconds).clamp(0.0, 1.0);
  }

  NightModeratorState copyWith({
    NightOnePhase? phase,
    int? remainingSeconds,
    bool? isRunning,
    bool? isCompleted,
    int? audioPlaybackCount,
  }) {
    return NightModeratorState(
      phase: phase ?? this.phase,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isRunning: isRunning ?? this.isRunning,
      isCompleted: isCompleted ?? this.isCompleted,
      audioPlaybackCount: audioPlaybackCount ?? this.audioPlaybackCount,
    );
  }
}
