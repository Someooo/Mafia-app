import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/game_settings_storage.dart';
import '../../domain/entities/game_role.dart';
import '../../domain/entities/playable_card.dart';
import '../../domain/services/role_shuffler.dart';
import 'game_state.dart';

/// Manages Lobby Setup configuration (with SharedPreferences persistence),
/// Sequential Player-to-Card Dealing, the Post-Deal Verification Vault,
/// and Instant Rematch round resets.
class GameCubit extends Cubit<GameState> {
  GameCubit({
    GameSettingsStorage? settingsStorage,
  })  : _settingsStorage = settingsStorage ?? const GameSettingsStorage(),
        super(const GameState());

  final GameSettingsStorage _settingsStorage;
  Future<void> _pendingSave = Future<void>.value();

  /// Restores last saved `playerCount` and `enabledOptionalRoleIds` from local storage.
  Future<void> loadSavedSettings() async {
    try {
      await _pendingSave;
      final saved = await _settingsStorage.loadSettings();
      if (isClosed) {
        return;
      }
      emit(
        state.copyWith(
          playerCount: saved.playerCount,
          enabledOptionalRoleIds: saved.enabledOptionalRoleIds,
        ),
      );
    } catch (_) {
      // Fallback gracefully to default GameState if storage is unavailable.
    }
  }

  void _persistCurrentSettings() {
    final int playerCount = state.playerCount;
    final Set<String> optionalRoleIds =
        Set<String>.from(state.enabledOptionalRoleIds);
    _pendingSave = _pendingSave.then((_) {
      return _settingsStorage.saveSettings(
        playerCount: playerCount,
        enabledOptionalRoleIds: optionalRoleIds,
      );
    }).catchError((_) {});
  }

  /// Increases player count up to [RoleShuffler.maxPlayers] (18).
  void incrementPlayerCount() {
    if (!state.canIncrementPlayers) {
      return;
    }
    unawaited(HapticFeedback.lightImpact());
    final int nextCount = state.playerCount + 1;
    emit(state.copyWith(playerCount: nextCount));
    _persistCurrentSettings();
  }

  /// Decreases player count down to [RoleShuffler.minPlayers] (6).
  /// Automatically trims optional roles if [remainingCitizenCount] would drop below 0.
  void decrementPlayerCount() {
    if (!state.canDecrementPlayers) {
      return;
    }
    unawaited(HapticFeedback.lightImpact());
    final int nextCount = state.playerCount - 1;
    final int maxOptionalAllowed = nextCount - state.mandatoryCount;
    final Set<String> updatedOptional =
        Set<String>.from(state.enabledOptionalRoleIds);

    while (updatedOptional.length > maxOptionalAllowed &&
        updatedOptional.isNotEmpty) {
      updatedOptional.remove(updatedOptional.last);
    }

    emit(
      state.copyWith(
        playerCount: nextCount,
        enabledOptionalRoleIds: updatedOptional,
      ),
    );
    _persistCurrentSettings();
  }

  /// Toggles an optional role on or off.
  /// Prevents enabling if [remainingCitizenCount] would drop below 0.
  void toggleOptionalRole(String roleId) {
    final Set<String> updated = Set<String>.from(state.enabledOptionalRoleIds);
    if (updated.contains(roleId)) {
      unawaited(HapticFeedback.lightImpact());
      updated.remove(roleId);
      emit(state.copyWith(enabledOptionalRoleIds: updated));
      _persistCurrentSettings();
      return;
    }

    if (state.remainingCitizenCount <= 0) {
      return;
    }

    unawaited(HapticFeedback.lightImpact());
    updated.add(roleId);
    emit(state.copyWith(enabledOptionalRoleIds: updated));
    _persistCurrentSettings();
  }

  /// Builds and cryptographically shuffles the card pool for a new round,
  /// resetting sequential player bindings and verification vault state.
  void dealCards() {
    unawaited(HapticFeedback.mediumImpact());
    final List<PlayableCard> deck = RoleShuffler.buildShuffledDeck(
      playerCount: state.playerCount,
      enabledOptionalRoleIds: state.enabledOptionalRoleIds,
    );

    emit(
      state.copyWith(
        cards: deck,
        revealedCardIndex: null,
        showPassPhoneOverlay: false,
        currentTurnPlayerNumber: 1,
        playerRoles: const <int, GameRole>{},
        revealedEliminatedPlayers: const <int>{},
      ),
    );
  }

  /// Flips a card at [index] only if no other card is currently revealed,
  /// no handoff overlay is active, and the target card is still [CardRevealStatus.hidden].
  void revealCard(int index) {
    if (state.hasRevealedCard || state.showPassPhoneOverlay) {
      return;
    }
    if (index < 0 || index >= state.cards.length) {
      return;
    }

    final PlayableCard target = state.cards[index];
    if (!target.isHidden) {
      return;
    }

    unawaited(HapticFeedback.mediumImpact());

    final List<PlayableCard> updatedCards =
        List<PlayableCard>.from(state.cards);
    updatedCards[index] = target.copyWith(status: CardRevealStatus.revealed);

    emit(
      state.copyWith(
        cards: updatedCards,
        revealedCardIndex: index,
      ),
    );
  }

  /// Binds the currently revealed card at [index] to [state.currentTurnPlayerNumber],
  /// marks the card as permanently [CardRevealStatus.claimed], increments
  /// [currentTurnPlayerNumber], and activates the pass-the-phone privacy overlay
  /// if unseen cards remain.
  void claimAndHideCard(int index) {
    if (state.revealedCardIndex != index) {
      return;
    }
    if (index < 0 || index >= state.cards.length) {
      return;
    }

    unawaited(HapticFeedback.lightImpact());

    final int currentPlayer = state.currentTurnPlayerNumber;
    final PlayableCard claimedCard = state.cards[index];

    final List<PlayableCard> updatedCards =
        List<PlayableCard>.from(state.cards);
    updatedCards[index] = claimedCard.copyWith(
      status: CardRevealStatus.claimed,
      assignedPlayerNumber: currentPlayer,
    );

    final Map<int, GameRole> updatedPlayerRoles =
        Map<int, GameRole>.from(state.playerRoles);
    updatedPlayerRoles[currentPlayer] = claimedCard.role;

    final bool hasMoreHiddenCards =
        updatedCards.any((PlayableCard card) => !card.isClaimed);

    final int nextTurnPlayer =
        hasMoreHiddenCards ? currentPlayer + 1 : currentPlayer;

    emit(
      state.copyWith(
        cards: updatedCards,
        revealedCardIndex: null,
        showPassPhoneOverlay: hasMoreHiddenCards,
        currentTurnPlayerNumber: nextTurnPlayer,
        playerRoles: Map<int, GameRole>.unmodifiable(updatedPlayerRoles),
      ),
    );
  }

  /// Dismisses the "مرر الهاتف للاعب التالي" privacy shield so the next player can draw.
  void dismissPassPhoneOverlay() {
    if (!state.showPassPhoneOverlay) {
      return;
    }
    unawaited(HapticFeedback.lightImpact());
    emit(state.copyWith(showPassPhoneOverlay: false));
  }

  /// Verifies and records an eliminated player's role in the post-deal vault.
  /// Returns the bound [GameRole] if [playerNumber] is valid (`1..playerCount`), or `null`.
  GameRole? verifyPlayerRole(int playerNumber) {
    if (playerNumber < 1 || playerNumber > state.playerCount) {
      return null;
    }
    final GameRole? role = state.playerRoles[playerNumber];
    if (role == null) {
      return null;
    }

    unawaited(HapticFeedback.heavyImpact());

    final Set<int> updatedEliminated =
        Set<int>.from(state.revealedEliminatedPlayers)..add(playerNumber);

    emit(
      state.copyWith(
        revealedEliminatedPlayers: Set<int>.unmodifiable(updatedEliminated),
      ),
    );
    return role;
  }

  /// Instant Rematch: Re-shuffles a fresh deck using [RoleShuffler] with the
  /// exact same [playerCount] and [enabledOptionalRoleIds], clears [playerRoles],
  /// resets [currentTurnPlayerNumber] to `1`, clears [revealedEliminatedPlayers],
  /// resets [revealedCardIndex] to `null`, and triggers [HapticFeedback.heavyImpact].
  void startInstantRematch() {
    unawaited(HapticFeedback.heavyImpact());
    final List<PlayableCard> deck = RoleShuffler.buildShuffledDeck(
      playerCount: state.playerCount,
      enabledOptionalRoleIds: state.enabledOptionalRoleIds,
    );

    emit(
      state.copyWith(
        cards: deck,
        revealedCardIndex: null,
        showPassPhoneOverlay: false,
        currentTurnPlayerNumber: 1,
        playerRoles: const <int, GameRole>{},
        revealedEliminatedPlayers: const <int>{},
      ),
    );
  }

  /// Safely restarts the round and re-shuffles all cards while retaining setup configuration.
  void reshuffle() {
    startInstantRematch();
  }

  @override
  Future<void> close() async {
    await _pendingSave;
    return super.close();
  }
}
