import '../../domain/entities/game_role.dart';
import '../../domain/entities/playable_card.dart';
import '../../domain/services/role_shuffler.dart';

/// Unified state for lobby setup configuration, sequential player-to-card dealing,
/// and post-deal player role verification vault.
class GameState {
  const GameState({
    this.playerCount = RoleShuffler.minPlayers,
    this.enabledOptionalRoleIds = const <String>{},
    this.cards = const <PlayableCard>[],
    this.revealedCardIndex,
    this.showPassPhoneOverlay = false,
    this.currentTurnPlayerNumber = 1,
    this.playerRoles = const <int, GameRole>{},
    this.revealedEliminatedPlayers = const <int>{},
  });

  final int playerCount;
  final Set<String> enabledOptionalRoleIds;
  final List<PlayableCard> cards;
  final int? revealedCardIndex;
  final bool showPassPhoneOverlay;

  /// Tracks which player number (1..N) is currently drawing a card.
  final int currentTurnPlayerNumber;

  /// Maps each player number (1..N) to the [GameRole] they claimed.
  final Map<int, GameRole> playerRoles;

  /// Set of player numbers whose roles have been verified in the post-deal vault.
  final Set<int> revealedEliminatedPlayers;

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

  /// Alias for [currentTurnPlayerNumber] for handoff display.
  int get nextPlayerNumber => currentTurnPlayerNumber;

  bool get isAllCardsClaimed =>
      cards.isNotEmpty && cards.every((PlayableCard card) => card.isClaimed);

  /// Looks up the bound [GameRole] for a 1-based [playerNumber].
  GameRole? getRoleForPlayer(int playerNumber) => playerRoles[playerNumber];

  static const Object _unset = Object();

  GameState copyWith({
    int? playerCount,
    Set<String>? enabledOptionalRoleIds,
    List<PlayableCard>? cards,
    Object? revealedCardIndex = _unset,
    bool? showPassPhoneOverlay,
    int? currentTurnPlayerNumber,
    Map<int, GameRole>? playerRoles,
    Set<int>? revealedEliminatedPlayers,
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
      currentTurnPlayerNumber:
          currentTurnPlayerNumber ?? this.currentTurnPlayerNumber,
      playerRoles: playerRoles ?? this.playerRoles,
      revealedEliminatedPlayers:
          revealedEliminatedPlayers ?? this.revealedEliminatedPlayers,
    );
  }
}
