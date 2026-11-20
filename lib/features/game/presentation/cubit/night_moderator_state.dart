import '../../domain/entities/game_role.dart';

/// Sequential phases of the automated Night-1 Audio & Visual Moderator.
enum NightModeratorPhase {
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
  );

  const NightModeratorPhase({
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
  final String audioAssetSource;
  final String audioAssetPath;
  final bool isMafiaActive;

  static int get totalSteps => NightModeratorPhase.values.length;
}

/// Immutable state for the automated Night-1 Moderator sequence.
class NightModeratorState {
  const NightModeratorState({
    this.phase = NightModeratorPhase.everyoneSleep,
    this.remainingSeconds = 15,
    this.isRunning = false,
    this.isCompleted = false,
    this.audioPlaybackCount = 0,
  });

  final NightModeratorPhase phase;
  final int remainingSeconds;
  final bool isRunning;
  final bool isCompleted;

  /// Tracks how many times phase audio was triggered (useful for UI feedback & tests).
  final int audioPlaybackCount;

  int get totalPhaseSeconds => phase.durationSeconds;

  double get phaseProgress {
    if (totalPhaseSeconds <= 0) {
      return 0.0;
    }
    return (remainingSeconds / totalPhaseSeconds).clamp(0.0, 1.0);
  }

  NightModeratorState copyWith({
    NightModeratorPhase? phase,
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
