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

  group('GameCubit State Management & Anti-Cheat Tests', () {
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

        // Reveal card 0
        cubit.revealCard(0);
        expect(cubit.state.revealedCardIndex, 0);
        expect(cubit.state.cards[0].isRevealed, isTrue);

        // Attempt to reveal card 1 while card 0 is still revealed -> MUST BE BLOCKED
        cubit.revealCard(1);
        expect(cubit.state.revealedCardIndex, 0);
        expect(cubit.state.cards[1].isHidden, isTrue);

        // Claim and hide card 0
        cubit.claimAndHideCard(0);
        expect(cubit.state.cards[0].isClaimed, isTrue);
        expect(cubit.state.revealedCardIndex, isNull);
        expect(cubit.state.showPassPhoneOverlay, isTrue);
        expect(cubit.state.nextPlayerNumber, 2);

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
      'claiming all cards transitions to isAllCardsClaimed without showing pass-phone overlay on the final card',
      () {
        final GameCubit cubit = GameCubit();
        cubit.dealCards();

        for (int i = 0; i < cubit.state.cards.length; i++) {
          cubit.revealCard(i);
          cubit.claimAndHideCard(i);
          if (i < cubit.state.cards.length - 1) {
            expect(cubit.state.showPassPhoneOverlay, isTrue);
            cubit.dismissPassPhoneOverlay();
          }
        }

        expect(cubit.state.isAllCardsClaimed, isTrue);
        expect(cubit.state.remainingCardsCount, 0);
        expect(cubit.state.showPassPhoneOverlay, isFalse);

        cubit.close();
      },
    );

    test(
      'reshuffle() resets all cards back to hidden while preserving active playerCount and optional roles',
      () {
        final GameCubit cubit = GameCubit();
        cubit.incrementPlayerCount(); // 7
        cubit.incrementPlayerCount(); // 8
        cubit.toggleOptionalRole(GameRole.sniper.id);
        cubit.toggleOptionalRole(GameRole.regularMafia.id);

        cubit.dealCards();
        cubit.revealCard(0);
        cubit.claimAndHideCard(0);
        expect(cubit.state.claimedCardsCount, 1);

        // Trigger reshuffle
        cubit.reshuffle();

        expect(cubit.state.playerCount, 8);
        expect(
          cubit.state.enabledOptionalRoleIds,
          containsAll(<String>[GameRole.sniper.id, GameRole.regularMafia.id]),
        );
        expect(cubit.state.cards.length, 8);
        expect(
          cubit.state.cards.every((PlayableCard c) => c.isHidden),
          isTrue,
        );
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
        await Future<void>.delayed(const Duration(milliseconds: 20));
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
