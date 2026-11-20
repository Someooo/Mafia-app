import 'package:barber_sync/features/game/domain/entities/game_role.dart';
import 'package:barber_sync/features/game/domain/entities/playable_card.dart';
import 'package:barber_sync/features/game/presentation/cubit/game_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('GameCubit State Management, Sequential Player Binding & Verification Vault Tests', () {
    test(
      'enforces player count bounds (6..18) and prevents remainingCitizenCount from dropping below 0',
      () {
        final GameCubit cubit = GameCubit();

        expect(cubit.state.playerCount, 6);
        expect(cubit.state.remainingCitizenCount, 2);

        // At 6 players (4 mandatory + 2 remaining slots), only 2 optional roles can be enabled
        cubit.toggleOptionalRole(GameRole.avengerVillager.id);
        cubit.toggleOptionalRole(GameRole.sniper.id);
        expect(cubit.state.selectedOptionalCount, 2);
        expect(cubit.state.remainingCitizenCount, 0);

        // Attempting to enable a 3rd optional role when remainingCitizenCount == 0 is blocked
        cubit.toggleOptionalRole(GameRole.regularMafia.id);
        expect(
          cubit.state.enabledOptionalRoleIds
              .contains(GameRole.regularMafia.id),
          isFalse,
        );
        expect(cubit.state.remainingCitizenCount, 0);

        // Increasing player count to 7 unlocks the slot
        cubit.incrementPlayerCount();
        expect(cubit.state.playerCount, 7);
        expect(cubit.state.remainingCitizenCount, 1);

        cubit.toggleOptionalRole(GameRole.regularMafia.id);
        expect(cubit.state.selectedOptionalCount, 3);
        expect(cubit.state.remainingCitizenCount, 0);

        // Decreasing player count back to 6 automatically trims 1 optional role to keep remainingCitizenCount >= 0
        cubit.decrementPlayerCount();
        expect(cubit.state.playerCount, 6);
        expect(cubit.state.selectedOptionalCount, 2);
        expect(cubit.state.remainingCitizenCount, 0);

        cubit.close();
      },
    );

    test(
      'revealing one card locks all other cards until claimed and pass-phone overlay is dismissed',
      () {
        final GameCubit cubit = GameCubit();
        cubit.dealCards();

        expect(cubit.state.cards.length, 6);
        expect(cubit.state.revealedCardIndex, isNull);
        expect(cubit.state.currentTurnPlayerNumber, 1);

        // Reveal card 0
        cubit.revealCard(0);
        expect(cubit.state.revealedCardIndex, 0);
        expect(cubit.state.cards[0].isRevealed, isTrue);

        // Attempt to reveal card 1 while card 0 is still revealed -> MUST BE BLOCKED
        cubit.revealCard(1);
        expect(cubit.state.revealedCardIndex, 0);
        expect(cubit.state.cards[1].isHidden, isTrue);

        // Claim and hide card 0 -> binds to Player #1 and advances turn to Player #2
        cubit.claimAndHideCard(0);
        expect(cubit.state.cards[0].isClaimed, isTrue);
        expect(cubit.state.cards[0].assignedPlayerNumber, 1);
        expect(cubit.state.playerRoles[1], cubit.state.cards[0].role);
        expect(cubit.state.revealedCardIndex, isNull);
        expect(cubit.state.showPassPhoneOverlay, isTrue);
        expect(cubit.state.currentTurnPlayerNumber, 2);

        // Attempt to reveal card 1 while Pass-the-Phone privacy shield is still active -> MUST BE BLOCKED
        cubit.revealCard(1);
        expect(cubit.state.revealedCardIndex, isNull);
        expect(cubit.state.cards[1].isHidden, isTrue);

        // Dismiss Pass-the-Phone privacy shield -> unlocks next turn
        cubit.dismissPassPhoneOverlay();
        expect(cubit.state.showPassPhoneOverlay, isFalse);

        // Now player 2 can reveal card 1
        cubit.revealCard(1);
        expect(cubit.state.revealedCardIndex, 1);
        expect(cubit.state.cards[1].isRevealed, isTrue);

        cubit.close();
      },
    );

    test(
      'binds players sequentially (1..N) regardless of which grid index they pick and supports verifyPlayerRole lookup',
      () {
        final GameCubit cubit = GameCubit();
        cubit.dealCards();

        // Players pick cards in non-linear grid order: [4, 1, 5, 0, 3, 2]
        const List<int> pickOrder = [4, 1, 5, 0, 3, 2];

        for (int turn = 0; turn < pickOrder.length; turn++) {
          final int expectedPlayerNumber = turn + 1;
          final int pickedCardIndex = pickOrder[turn];

          expect(cubit.state.currentTurnPlayerNumber, expectedPlayerNumber);
          cubit.revealCard(pickedCardIndex);
          cubit.claimAndHideCard(pickedCardIndex);

          expect(
            cubit.state.cards[pickedCardIndex].assignedPlayerNumber,
            expectedPlayerNumber,
          );
          expect(
            cubit.state.getRoleForPlayer(expectedPlayerNumber),
            cubit.state.cards[pickedCardIndex].role,
          );

          if (turn < pickOrder.length - 1) {
            expect(cubit.state.showPassPhoneOverlay, isTrue);
            cubit.dismissPassPhoneOverlay();
          }
        }

        expect(cubit.state.isAllCardsClaimed, isTrue);
        expect(cubit.state.playerRoles.length, 6);
        expect(cubit.state.showPassPhoneOverlay, isFalse);

        // Verify Player #1 (who picked card index 4) and Player #3 (who picked card index 5)
        final GameRole? player1Role = cubit.verifyPlayerRole(1);
        expect(player1Role, cubit.state.cards[4].role);
        expect(cubit.state.revealedEliminatedPlayers, contains(1));

        final GameRole? player3Role = cubit.verifyPlayerRole(3);
        expect(player3Role, cubit.state.cards[5].role);
        expect(cubit.state.revealedEliminatedPlayers, containsAll(<int>[1, 3]));

        // Out-of-range player numbers return null and are not added
        expect(cubit.verifyPlayerRole(0), isNull);
        expect(cubit.verifyPlayerRole(99), isNull);
        expect(cubit.state.revealedEliminatedPlayers.length, 2);

        cubit.close();
      },
    );

    test(
      'reshuffle() resets all cards, playerRoles, currentTurnPlayerNumber, and revealedEliminatedPlayers while preserving setup config',
      () {
        final GameCubit cubit = GameCubit();
        cubit.incrementPlayerCount(); // 7
        cubit.incrementPlayerCount(); // 8
        cubit.toggleOptionalRole(GameRole.sniper.id);
        cubit.toggleOptionalRole(GameRole.regularMafia.id);

        cubit.dealCards();
        cubit.revealCard(3);
        cubit.claimAndHideCard(3);
        cubit.dismissPassPhoneOverlay();
        cubit.verifyPlayerRole(1);

        expect(cubit.state.claimedCardsCount, 1);
        expect(cubit.state.currentTurnPlayerNumber, 2);
        expect(cubit.state.playerRoles.isNotEmpty, isTrue);
        expect(cubit.state.revealedEliminatedPlayers.isNotEmpty, isTrue);

        // Trigger reshuffle
        cubit.reshuffle();

        expect(cubit.state.playerCount, 8);
        expect(
          cubit.state.enabledOptionalRoleIds,
          containsAll(<String>[GameRole.sniper.id, GameRole.regularMafia.id]),
        );
        expect(cubit.state.cards.length, 8);
        expect(
          cubit.state.cards.every(
            (PlayableCard c) => c.isHidden && c.assignedPlayerNumber == null,
          ),
          isTrue,
        );
        expect(cubit.state.currentTurnPlayerNumber, 1);
        expect(cubit.state.playerRoles, isEmpty);
        expect(cubit.state.revealedEliminatedPlayers, isEmpty);
        expect(cubit.state.revealedCardIndex, isNull);
        expect(cubit.state.showPassPhoneOverlay, isFalse);

        cubit.close();
      },
    );

    test(
      'persists and restores playerCount and enabledOptionalRoleIds via SharedPreferences',
      () async {
        final GameCubit firstCubit = GameCubit();
        firstCubit.incrementPlayerCount(); // 7
        firstCubit.incrementPlayerCount(); // 8
        firstCubit.toggleOptionalRole(GameRole.sniper.id);
        await firstCubit.close();

        final GameCubit restoredCubit = GameCubit();
        await restoredCubit.loadSavedSettings();

        expect(restoredCubit.state.playerCount, 8);
        expect(
          restoredCubit.state.enabledOptionalRoleIds,
          contains(GameRole.sniper.id),
        );

        await restoredCubit.close();
      },
    );
  });
}
