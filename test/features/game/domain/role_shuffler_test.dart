import 'package:barber_sync/features/game/domain/entities/game_role.dart';
import 'package:barber_sync/features/game/domain/entities/playable_card.dart';
import 'package:barber_sync/features/game/domain/services/role_shuffler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RoleShuffler Unit Tests', () {
    test(
      'generates exact player count N for every N in 6..18 with all 4 mandatory roles and fills remaining slots with regular_citizen',
      () {
        final Set<String> optionalRoles = {
          GameRole.avengerVillager.id,
          GameRole.sniper.id,
        };

        for (int n = RoleShuffler.minPlayers;
            n <= RoleShuffler.maxPlayers;
            n++) {
          final List<PlayableCard> deck = RoleShuffler.buildShuffledDeck(
            playerCount: n,
            enabledOptionalRoleIds: optionalRoles,
          );

          // 1. Deck size is strictly N
          expect(
            deck.length,
            n,
            reason: 'Deck length must equal playerCount ($n)',
          );

          // 2. All cards start hidden
          expect(
            deck.every((PlayableCard c) => c.isHidden),
            isTrue,
          );

          // 3. All 4 mandatory roles are present exactly once
          expect(
            deck
                .where((PlayableCard c) =>
                    c.role.id == GameRole.citizensLeader.id)
                .length,
            1,
          );
          expect(
            deck
                .where((PlayableCard c) => c.role.id == GameRole.medic.id)
                .length,
            1,
          );
          expect(
            deck
                .where(
                    (PlayableCard c) => c.role.id == GameRole.mafiaLeader.id)
                .length,
            1,
          );
          expect(
            deck
                .where(
                    (PlayableCard c) => c.role.id == GameRole.silencerMafia.id)
                .length,
            1,
          );

          // 4. Selected optional roles are present
          expect(
            deck
                .where((PlayableCard c) =>
                    c.role.id == GameRole.avengerVillager.id)
                .length,
            1,
          );
          expect(
            deck
                .where((PlayableCard c) => c.role.id == GameRole.sniper.id)
                .length,
            1,
          );

          // 5. Remaining slots are filled with regular_citizen
          final int expectedRegularCitizens = n - 4 - optionalRoles.length;
          final int actualRegularCitizens = deck
              .where((PlayableCard c) =>
                  c.role.id == GameRole.regularCitizen.id)
              .length;
          expect(actualRegularCitizens, expectedRegularCitizens);
        }
      },
    );

    test(
      'clamps optional roles safely if more optional roles are passed than available slots',
      () {
        final List<PlayableCard> deck = RoleShuffler.buildShuffledDeck(
          playerCount: 6,
          enabledOptionalRoleIds: {
            GameRole.avengerVillager.id,
            GameRole.sniper.id,
            GameRole.regularMafia.id,
          },
        );

        expect(deck.length, 6);
        final int mandatoryInDeck =
            deck.where((PlayableCard c) => c.role.isMandatory).length;
        expect(mandatoryInDeck, 4);
      },
    );

    test(
      'produces randomization variance across consecutive shuffles using Random.secure()',
      () {
        final Set<String> distinctOrderings = <String>{};

        for (int attempt = 0; attempt < 20; attempt++) {
          final List<PlayableCard> deck = RoleShuffler.buildShuffledDeck(
            playerCount: 10,
            enabledOptionalRoleIds: {
              GameRole.avengerVillager.id,
              GameRole.sniper.id,
              GameRole.regularMafia.id,
            },
          );
          final String signature =
              deck.map((PlayableCard c) => c.role.id).join(',');
          distinctOrderings.add(signature);
        }

        // Across 20 independent cryptographic shuffles of 10 cards, we must observe multiple distinct permutations.
        expect(distinctOrderings.length, greaterThan(1));
      },
    );
  });
}
