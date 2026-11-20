import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/playable_card.dart';
import '../../domain/services/role_shuffler.dart';
import 'game_state.dart';

/// Manages both Lobby Setup configuration and Play Grid card reveal lifecycle.
class GameCubit extends Cubit<GameState> {
  GameCubit() : super(const GameState());

  /// Increases player count up to [RoleShuffler.maxPlayers] (18).
  void incrementPlayerCount() {
    if (!state.canIncrementPlayers) {
      return;
    }
    emit(state.copyWith(playerCount: state.playerCount + 1));
  }

  /// Decreases player count down to [RoleShuffler.minPlayers] (6).
  /// Automatically trims optional roles if [remainingCitizenCount] would drop below 0.
  void decrementPlayerCount() {
    if (!state.canDecrementPlayers) {
      return;
    }
    final int nextCount = state.playerCount - 1;
    final int maxOptionalAllowed = nextCount - state.mandatoryCount;
    Set<String> updatedOptional = Set<String>.from(state.enabledOptionalRoleIds);

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
  }

  /// Toggles an optional role on or off.
  /// Prevents enabling if [remainingCitizenCount] would drop below 0.
  void toggleOptionalRole(String roleId) {
    final Set<String> updated = Set<String>.from(state.enabledOptionalRoleIds);
    if (updated.contains(roleId)) {
      updated.remove(roleId);
      emit(state.copyWith(enabledOptionalRoleIds: updated));
      return;
    }

    if (state.remainingCitizenCount <= 0) {
      return;
    }

    updated.add(roleId);
    emit(state.copyWith(enabledOptionalRoleIds: updated));
  }

  /// Builds and cryptographically shuffles the card pool for a new round.
  void dealCards() {
    final List<PlayableCard> deck = RoleShuffler.buildShuffledDeck(
      playerCount: state.playerCount,
      enabledOptionalRoleIds: state.enabledOptionalRoleIds,
    );

    emit(
      state.copyWith(
        cards: deck,
        revealedCardIndex: null,
        showPassPhoneOverlay: false,
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

  /// Marks the currently revealed card at [index] as permanently [CardRevealStatus.claimed],
  /// clears [revealedCardIndex], and activates the pass-the-phone privacy overlay
  /// if unseen cards remain.
  void claimAndHideCard(int index) {
    if (state.revealedCardIndex != index) {
      return;
    }
    if (index < 0 || index >= state.cards.length) {
      return;
    }

    final List<PlayableCard> updatedCards =
        List<PlayableCard>.from(state.cards);
    updatedCards[index] =
        updatedCards[index].copyWith(status: CardRevealStatus.claimed);

    final bool hasMoreHiddenCards =
        updatedCards.any((PlayableCard card) => !card.isClaimed);

    emit(
      state.copyWith(
        cards: updatedCards,
        revealedCardIndex: null,
        showPassPhoneOverlay: hasMoreHiddenCards,
      ),
    );
  }

  /// Dismisses the "مرر الهاتف للاعب التالي" privacy shield so the next player can draw.
  void dismissPassPhoneOverlay() {
    if (!state.showPassPhoneOverlay) {
      return;
    }
    emit(state.copyWith(showPassPhoneOverlay: false));
  }

  /// Safely restarts the round and re-shuffles all cards while retaining setup configuration.
  void reshuffle() {
    dealCards();
  }
}
