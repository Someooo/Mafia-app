import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'night_moderator_state.dart';

/// Abstraction over `audioplayers` with safe `try/catch` fallback so missing
/// audio devices or test environments never crash the Night Moderator timer.
abstract class NightAudioPlayer {
  Future<void> playAsset(String assetSourcePath);
  Future<void> stop();
  Future<void> dispose();
}

/// Default production implementation backed by `package:audioplayers`.
class AudioPlayersNightAudioPlayer implements NightAudioPlayer {
  AudioPlayersNightAudioPlayer([AudioPlayer? player]) : _player = player;

  AudioPlayer? _player;

  AudioPlayer _ensurePlayer() {
    return _player ??= AudioPlayer();
  }

  @override
  Future<void> playAsset(String assetSourcePath) async {
    try {
      final AudioPlayer player = _ensurePlayer();
      await player.stop();
      await player.play(AssetSource(assetSourcePath));
    } catch (_) {
      // Safe fallback when audio hardware/channel is unavailable.
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _player?.stop();
    } catch (_) {}
  }

  @override
  Future<void> dispose() async {
    try {
      await _player?.stop();
      await _player?.dispose();
    } catch (_) {}
  }
}

/// Controls the automated Night-1 Audio & Visual Moderator state machine:
/// - Starts in `NightOnePhase.standby` (waiting for manual trigger, no audio/timer).
/// - `startNightSequence()` transitions into:
///   1. `everyoneSleep` (15s) -> `night_sleep.mp3`
///   2. `mafiaWake` (12s) -> `mafia_wake.mp3`
///   3. `mafiaSleep` (5s) -> `mafia_sleep.mp3`
///   4. `everyoneWake` (3s) -> `city_wake.mp3`
///   5. `completed` -> auto-navigates to `VerificationVaultScreen`
class NightModeratorCubit extends Cubit<NightModeratorState> {
  NightModeratorCubit({
    NightAudioPlayer? audioPlayer,
    Duration tickInterval = const Duration(seconds: 1),
  })  : _audioPlayer = audioPlayer ?? AudioPlayersNightAudioPlayer(),
        _tickInterval = tickInterval,
        super(
          const NightModeratorState(
            phase: NightOnePhase.standby,
            remainingSeconds: 0,
            isRunning: false,
            isCompleted: false,
          ),
        );

  final NightAudioPlayer _audioPlayer;
  final Duration _tickInterval;
  Timer? _countdownTimer;

  /// Manually starts the Night-1 sequence from `standby` into `everyoneSleep` (15s).
  void startNightSequence() {
    if (isClosed) {
      return;
    }
    unawaited(HapticFeedback.mediumImpact());
    _enterPhase(NightOnePhase.everyoneSleep);
  }

  /// Replays the audio prompt for the currently active [NightOnePhase].
  Future<void> replayCurrentPhaseAudio() async {
    if (isClosed) {
      return;
    }
    final String? audioSource = state.phase.audioAssetSource;
    if (audioSource == null) {
      return;
    }
    unawaited(HapticFeedback.lightImpact());
    emit(
      state.copyWith(
        audioPlaybackCount: state.audioPlaybackCount + 1,
      ),
    );
    await _audioPlayer.stop();
    await _audioPlayer.playAsset(audioSource);
  }

  /// Stops any active audio/timer and returns cleanly to [NightOnePhase.standby]
  /// so players can start the night sequence again when ready.
  Future<void> restartNightModerator() async {
    if (isClosed) {
      return;
    }
    unawaited(HapticFeedback.mediumImpact());
    _countdownTimer?.cancel();
    _countdownTimer = null;
    await _audioPlayer.stop();
    if (isClosed) {
      return;
    }
    emit(
      state.copyWith(
        phase: NightOnePhase.standby,
        remainingSeconds: 0,
        isRunning: false,
        isCompleted: false,
      ),
    );
  }

  /// Immediately stops audio and timers and transitions to [NightOnePhase.completed].
  Future<void> skipNightModerator() async {
    if (isClosed) {
      return;
    }
    unawaited(HapticFeedback.lightImpact());
    _countdownTimer?.cancel();
    _countdownTimer = null;
    await _audioPlayer.stop();
    if (isClosed) {
      return;
    }
    emit(
      state.copyWith(
        phase: NightOnePhase.completed,
        isRunning: false,
        isCompleted: true,
        remainingSeconds: 0,
      ),
    );
  }

  void _enterPhase(NightOnePhase nextPhase) {
    if (isClosed) {
      return;
    }
    _countdownTimer?.cancel();

    if (nextPhase.isMafiaActive) {
      unawaited(HapticFeedback.heavyImpact());
    } else {
      unawaited(HapticFeedback.mediumImpact());
    }

    emit(
      state.copyWith(
        phase: nextPhase,
        remainingSeconds: nextPhase.durationSeconds,
        isRunning: true,
        isCompleted: false,
        audioPlaybackCount: state.audioPlaybackCount + 1,
      ),
    );

    final String? audioSource = nextPhase.audioAssetSource;
    if (audioSource != null) {
      unawaited(_playPhaseCue(audioSource));
    }

    _countdownTimer = Timer.periodic(_tickInterval, (_) {
      _onTick();
    });
  }

  Future<void> _playPhaseCue(String assetSourcePath) async {
    await _audioPlayer.stop();
    await _audioPlayer.playAsset(assetSourcePath);
  }

  void _onTick() {
    if (isClosed || !state.isRunning) {
      return;
    }

    if (state.remainingSeconds > 1) {
      emit(state.copyWith(remainingSeconds: state.remainingSeconds - 1));
      return;
    }

    // Current phase finished -> advance to next active phase or complete sequence.
    const List<NightOnePhase> activePhases = NightOnePhase.activePhases;
    final int currentIndex = activePhases.indexOf(state.phase);

    if (currentIndex >= 0 && currentIndex < activePhases.length - 1) {
      _enterPhase(activePhases[currentIndex + 1]);
    } else {
      _countdownTimer?.cancel();
      _countdownTimer = null;
      unawaited(_audioPlayer.stop());
      unawaited(HapticFeedback.heavyImpact());
      emit(
        state.copyWith(
          phase: NightOnePhase.completed,
          remainingSeconds: 0,
          isRunning: false,
          isCompleted: true,
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    await _audioPlayer.dispose();
    return super.close();
  }
}
