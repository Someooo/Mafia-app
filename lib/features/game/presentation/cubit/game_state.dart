import '../../domain/entities/game_role.dart';
import '../../domain/entities/playable_card.dart';
import '../../domain/services/role_shuffler.dart';

/// Unified state for lobby setup configuration and active card dealing session.
class GameState {
  const GameState({
    this.playerCount = RoleShuffler.minPlayers,
    this.enabledOptionalRoleIds = const <String>{},
    this.cards = const <PlayableCard>[],
    this.revealedCardIndex,
    this.showPassPhoneOverlay = false,
  });

  final int playerCount;
  final Set<String> enabledOptionalRoleIds;
  final List<PlayableCard> cards;
  final int? revealedCardIndex;
  final bool showPassPhoneOverlay;

  int get mandatoryCount => GameRole.mandatoryRoles.length;

  int get selectedOptionalCount => enabledOptionalRoleIds.length;

  /// Dynamic count of regular citizens filling the remaining player slots.
  int get remainingCitizenCount =>
      playerCount - mandatoryCount - selectedOptionalCount;

  bool get canIncrementPlayers => playerCount < RoleShuffler.maxPlayers;

  bool get canDecrementPlayers => playerCount > RoleShuffler.minPlayers;

  /// Returns whether an optional role can be toggled on without dropping
  /// [remainingCitizenCount] below 0.
  bool canToggleOptionalRole(String roleId) {
    if (enabledOptionalRoleIds.contains(roleId)) {
      return true;
    }
    return remainingCitizenCount > 0;
  }

  int get totalMafiaCount {
    int count = GameRole.mandatoryRoles
        .where((role) => role.team == RoleTeam.mafia)
        .length;
    for (final role in GameRole.optionalRoles) {
      if (enabledOptionalRoleIds.contains(role.id) &&
          role.team == RoleTeam.mafia) {
        count++;
      }
    }
    return count;
  }

  int get totalCitizensTeamCount => playerCount - totalMafiaCount;

  int get totalCards => cards.length;

  int get claimedCardsCount =>
      cards.where((PlayableCard card) => card.isClaimed).length;

  int get remainingCardsCount =>
      cards.where((PlayableCard card) => !card.isClaimed).length;

  bool get hasRevealedCard => revealedCardIndex != null;

  PlayableCard? get revealedCard {
    final int? index = revealedCardIndex;
    if (index == null || index < 0 || index >= cards.length) {
      return null;
    }
    return cards[index];
  }

  /// 1-based index of the next player who should receive the phone.
  int get nextPlayerNumber => claimedCardsCount + 1;

  bool get isAllCardsClaimed =>
      cards.isNotEmpty && cards.every((PlayableCard card) => card.isClaimed);

  static const Object _unset = Object();

  GameState copyWith({
    int? playerCount,
    Set<String>? enabledOptionalRoleIds,
    List<PlayableCard>? cards,
    Object? revealedCardIndex = _unset,
    bool? showPassPhoneOverlay,
  }) {
    return GameState(
      playerCount: playerCount ?? this.playerCount,
      enabledOptionalRoleIds:
          enabledOptionalRoleIds ?? this.enabledOptionalRoleIds,
      cards: cards ?? this.cards,
      revealedCardIndex: identical(revealedCardIndex, _unset)
          ? this.revealedCardIndex
          : revealedCardIndex as int?,
      showPassPhoneOverlay: showPassPhoneOverlay ?? this.showPassPhoneOverlay,
    );
  }
}
