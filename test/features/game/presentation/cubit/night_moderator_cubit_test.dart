import 'package:barber_sync/features/game/domain/entities/game_role.dart';
import 'package:barber_sync/features/game/presentation/cubit/night_moderator_cubit.dart';
import 'package:barber_sync/features/game/presentation/cubit/night_moderator_state.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeNightAudioPlayer implements NightAudioPlayer {
  final List<String> playedAssets = <String>[];
  int stopCount = 0;
  int disposeCount = 0;

  @override
  Future<void> playAsset(String assetSourcePath) async {
    playedAssets.add(assetSourcePath);
  }

  @override
  Future<void> stop() async {
    stopCount++;
  }

  @override
  Future<void> dispose() async {
    disposeCount++;
  }
}

void main() {
  group('NightModeratorCubit Automated Night-1 Sequence Tests', () {
    testWidgets(
      'runs through all 4 Night-1 phases (15s -> 12s -> 5s -> 3s) with exact Arabic prompts and MP3 assets',
      (WidgetTester tester) async {
        final FakeNightAudioPlayer fakeAudio = FakeNightAudioPlayer();
        final NightModeratorCubit cubit = NightModeratorCubit(
          audioPlayer: fakeAudio,
        );

        cubit.startNightSequence();
        await tester.pump();

        // Phase 1: everyoneSleep (15s)
        expect(cubit.state.phase, NightModeratorPhase.everyoneSleep);
        expect(cubit.state.remainingSeconds, 15);
        expect(
          cubit.state.phase.instruction,
          'المدينة تغفو الآن... على الجميع إغماض أعينهم بالكامل',
        );
        expect(cubit.state.isRunning, isTrue);
        expect(cubit.state.isCompleted, isFalse);
        expect(fakeAudio.playedAssets.last, GameAssets.nightSleepAudioSource);
        expect(fakeAudio.stopCount, 1);

        // Advance 14 seconds -> still in everyoneSleep with 1s left
        await tester.pump(const Duration(seconds: 14));
        expect(cubit.state.phase, NightModeratorPhase.everyoneSleep);
        expect(cubit.state.remainingSeconds, 1);

        // Advance 1 more second (total 15s) -> transitions to Phase 2: mafiaWake (12s)
        await tester.pump(const Duration(seconds: 1));
        expect(cubit.state.phase, NightModeratorPhase.mafiaWake);
        expect(cubit.state.remainingSeconds, 12);
        expect(
          cubit.state.phase.instruction,
          'فريق المافيا فقط... افتحوا أعينكم الآن وتعرفوا على بعضكم بصمت',
        );
        expect(cubit.state.phase.isMafiaActive, isTrue);
        expect(fakeAudio.playedAssets.last, GameAssets.mafiaWakeAudioSource);

        // Advance 12 seconds -> transitions to Phase 3: mafiaSleep (5s)
        await tester.pump(const Duration(seconds: 12));
        expect(cubit.state.phase, NightModeratorPhase.mafiaSleep);
        expect(cubit.state.remainingSeconds, 5);
        expect(
          cubit.state.phase.instruction,
          'انتهى الوقت... فريق المافيا، أغمضوا أعينكم الآن',
        );
        expect(fakeAudio.playedAssets.last, GameAssets.mafiaSleepAudioSource);

        // Advance 5 seconds -> transitions to Phase 4: everyoneWake (3s)
        await tester.pump(const Duration(seconds: 5));
        expect(cubit.state.phase, NightModeratorPhase.everyoneWake);
        expect(cubit.state.remainingSeconds, 3);
        expect(
          cubit.state.phase.instruction,
          'أشرق الصباح... على الجميع فتح أعينهم الآن. ابدأوا النقاش!',
        );
        expect(fakeAudio.playedAssets.last, GameAssets.cityWakeAudioSource);

        // Advance final 3 seconds -> completes Night Moderator
        await tester.pump(const Duration(seconds: 3));
        expect(cubit.state.isCompleted, isTrue);
        expect(cubit.state.isRunning, isFalse);
        expect(cubit.state.remainingSeconds, 0);

        await cubit.close();
      },
    );

    testWidgets(
      'replayCurrentPhaseAudio() replays the active phase MP3 without resetting the phase timer',
      (WidgetTester tester) async {
        final FakeNightAudioPlayer fakeAudio = FakeNightAudioPlayer();
        final NightModeratorCubit cubit = NightModeratorCubit(
          audioPlayer: fakeAudio,
        );

        cubit.startNightSequence();
        await tester.pump(const Duration(seconds: 15)); // Now in mafiaWake (12s)
        await tester.pump(const Duration(seconds: 4)); // 8s remaining in mafiaWake

        expect(cubit.state.phase, NightModeratorPhase.mafiaWake);
        expect(cubit.state.remainingSeconds, 8);
        final int countBefore = fakeAudio.playedAssets.length;

        await cubit.replayCurrentPhaseAudio();

        expect(fakeAudio.playedAssets.length, countBefore + 1);
        expect(fakeAudio.playedAssets.last, GameAssets.mafiaWakeAudioSource);
        expect(cubit.state.remainingSeconds, 8);

        await cubit.close();
      },
    );

    testWidgets(
      'restartNightModerator() resets from any phase back to Phase 1 (everyoneSleep - 15s)',
      (WidgetTester tester) async {
        final FakeNightAudioPlayer fakeAudio = FakeNightAudioPlayer();
        final NightModeratorCubit cubit = NightModeratorCubit(
          audioPlayer: fakeAudio,
        );

        cubit.startNightSequence();
        await tester.pump(const Duration(seconds: 20)); // Inside mafiaWake
        expect(cubit.state.phase, NightModeratorPhase.mafiaWake);

        cubit.restartNightModerator();
        await tester.pump();

        expect(cubit.state.phase, NightModeratorPhase.everyoneSleep);
        expect(cubit.state.remainingSeconds, 15);
        expect(cubit.state.isRunning, isTrue);
        expect(cubit.state.isCompleted, isFalse);
        expect(fakeAudio.playedAssets.last, GameAssets.nightSleepAudioSource);

        await cubit.close();
      },
    );

    testWidgets(
      'skipNightModerator() stops audio and timer immediately and marks isCompleted = true',
      (WidgetTester tester) async {
        final FakeNightAudioPlayer fakeAudio = FakeNightAudioPlayer();
        final NightModeratorCubit cubit = NightModeratorCubit(
          audioPlayer: fakeAudio,
        );

        cubit.startNightSequence();
        await tester.pump(const Duration(seconds: 5));

        await cubit.skipNightModerator();

        expect(cubit.state.isCompleted, isTrue);
        expect(cubit.state.isRunning, isFalse);
        expect(cubit.state.remainingSeconds, 0);
        expect(fakeAudio.stopCount, greaterThanOrEqualTo(1));

        await cubit.close();
      },
    );
  });
}
