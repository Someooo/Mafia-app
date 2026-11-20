import 'dart:math';

import '../entities/game_role.dart';
import '../entities/playable_card.dart';

/// Cryptographically secure role deck builder and shuffler.
abstract final class RoleShuffler {
  static const int minPlayers = 6;
  static const int maxPlayers = 18;

  /// Builds and shuffles a deck of [PlayableCard]s of length [playerCount].
  ///
  /// Guarantees:
  /// 1. Exactly 4 mandatory roles (`citizens_leader`, `medic`, `mafia_leader`, `silencer_mafia`).
  /// 2. All active optional roles from [enabledOptionalRoleIds] (up to available slots).
  /// 3. Remaining slots filled with [GameRole.regularCitizen] so total count == [playerCount].
  /// 4. Shuffled using [Random.secure()] via Fisher-Yates algorithm.
  static List<PlayableCard> buildShuffledDeck({
    required int playerCount,
    required Set<String> enabledOptionalRoleIds,
  }) {
    final int clampedPlayerCount = playerCount.clamp(minPlayers, maxPlayers);

    final List<GameRole> pool = List<GameRole>.from(GameRole.mandatoryRoles);

    for (final GameRole optionalRole in GameRole.optionalRoles) {
      if (enabledOptionalRoleIds.contains(optionalRole.id) &&
          pool.length < clampedPlayerCount) {
        pool.add(optionalRole);
      }
    }

    while (pool.length < clampedPlayerCount) {
      pool.add(GameRole.regularCitizen);
    }

    final Random secureRandom = Random.secure();
    for (int i = pool.length - 1; i > 0; i--) {
      final int j = secureRandom.nextInt(i + 1);
      final GameRole temp = pool[i];
      pool[i] = pool[j];
      pool[j] = temp;
    }

    return List<PlayableCard>.generate(
      pool.length,
      (int index) => PlayableCard(
        id: 'card_${index}_${pool[index].id}',
        index: index,
        role: pool[index],
        status: CardRevealStatus.hidden,
      ),
      growable: false,
    );
  }
}
