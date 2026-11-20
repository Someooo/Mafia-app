import '../../domain/entities/night_one_phase.dart';

export '../../domain/entities/night_one_phase.dart';

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
