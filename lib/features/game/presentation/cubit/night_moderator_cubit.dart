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
/// 1. `everyoneSleep` (15s) -> `night_sleep.mp3`
/// 2. `mafiaWake` (12s) -> `mafia_wake.mp3`
/// 3. `mafiaSleep` (5s) -> `mafia_sleep.mp3`
/// 4. `everyoneWake` (3s) -> `city_wake.mp3`
class NightModeratorCubit extends Cubit<NightModeratorState> {
  NightModeratorCubit({
    NightAudioPlayer? audioPlayer,
    Duration tickInterval = const Duration(seconds: 1),
  })  : _audioPlayer = audioPlayer ?? AudioPlayersNightAudioPlayer(),
        _tickInterval = tickInterval,
        super(
          NightModeratorState(
            phase: NightModeratorPhase.everyoneSleep,
            remainingSeconds:
                NightModeratorPhase.everyoneSleep.durationSeconds,
          ),
        );

  final NightAudioPlayer _audioPlayer;
  final Duration _tickInterval;
  Timer? _countdownTimer;

  /// Starts the automated Night-1 sequence from Phase 1 (`everyoneSleep`).
  void startNightSequence() {
    _enterPhase(NightModeratorPhase.everyoneSleep);
  }

  /// Replays the audio prompt for the currently active [NightModeratorPhase].
  Future<void> replayCurrentPhaseAudio() async {
    if (isClosed) {
      return;
    }
    unawaited(HapticFeedback.lightImpact());
    emit(
      state.copyWith(
        audioPlaybackCount: state.audioPlaybackCount + 1,
      ),
    );
    await _audioPlayer.stop();
    await _audioPlayer.playAsset(state.phase.audioAssetSource);
  }

  /// Restarts the entire Night-1 sequence from Phase 1 (`everyoneSleep` - 15s).
  void restartNightModerator() {
    if (isClosed) {
      return;
    }
    unawaited(HapticFeedback.mediumImpact());
    _enterPhase(NightModeratorPhase.everyoneSleep);
  }

  /// Immediately stops audio and timers and completes the Night-1 Moderator.
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
        isRunning: false,
        isCompleted: true,
        remainingSeconds: 0,
      ),
    );
  }

  void _enterPhase(NightModeratorPhase nextPhase) {
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

    unawaited(_playPhaseCue(nextPhase.audioAssetSource));

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

    // Current phase finished -> advance to next phase or complete sequence.
    final List<NightModeratorPhase> allPhases = NightModeratorPhase.values;
    final int currentIndex = allPhases.indexOf(state.phase);

    if (currentIndex >= 0 && currentIndex < allPhases.length - 1) {
      _enterPhase(allPhases[currentIndex + 1]);
    } else {
      _countdownTimer?.cancel();
      _countdownTimer = null;
      unawaited(_audioPlayer.stop());
      unawaited(HapticFeedback.heavyImpact());
      emit(
        state.copyWith(
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
