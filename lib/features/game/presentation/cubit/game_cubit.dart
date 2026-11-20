import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/game_settings_storage.dart';
import '../../domain/entities/playable_card.dart';
import '../../domain/services/role_shuffler.dart';
import 'game_state.dart';

/// Manages both Lobby Setup configuration (with SharedPreferences persistence)
/// and Play Grid card reveal lifecycle (with tactile HapticFeedback).
class GameCubit extends Cubit<GameState> {
  GameCubit({
    GameSettingsStorage? settingsStorage,
  })  : _settingsStorage = settingsStorage ?? const GameSettingsStorage(),
        super(const GameState());

  final GameSettingsStorage _settingsStorage;

  /// Restores last saved `playerCount` and `enabledOptionalRoleIds` from local storage.
  Future<void> loadSavedSettings() async {
    try {
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

  void _persistCurrentSettings(int playerCount, Set<String> optionalRoleIds) {
    unawaited(
      _settingsStorage.saveSettings(
        playerCount: playerCount,
        enabledOptionalRoleIds: optionalRoleIds,
      ),
    );
  }

  /// Increases player count up to [RoleShuffler.maxPlayers] (18).
  void incrementPlayerCount() {
    if (!state.canIncrementPlayers) {
      return;
    }
    unawaited(HapticFeedback.lightImpact());
    final int nextCount = state.playerCount + 1;
    emit(state.copyWith(playerCount: nextCount));
    _persistCurrentSettings(nextCount, state.enabledOptionalRoleIds);
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
    _persistCurrentSettings(nextCount, updatedOptional);
  }

  /// Toggles an optional role on or off.
  /// Prevents enabling if [remainingCitizenCount] would drop below 0.
  void toggleOptionalRole(String roleId) {
    final Set<String> updated = Set<String>.from(state.enabledOptionalRoleIds);
    if (updated.contains(roleId)) {
      unawaited(HapticFeedback.lightImpact());
      updated.remove(roleId);
      emit(state.copyWith(enabledOptionalRoleIds: updated));
      _persistCurrentSettings(state.playerCount, updated);
      return;
    }

    if (state.remainingCitizenCount <= 0) {
      return;
    }

    unawaited(HapticFeedback.lightImpact());
    updated.add(roleId);
    emit(state.copyWith(enabledOptionalRoleIds: updated));
    _persistCurrentSettings(state.playerCount, updated);
  }

  /// Builds and cryptographically shuffles the card pool for a new round.
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

    unawaited(HapticFeedback.lightImpact());

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
    unawaited(HapticFeedback.lightImpact());
    emit(state.copyWith(showPassPhoneOverlay: false));
  }

  /// Safely restarts the round and re-shuffles all cards while retaining setup configuration.
  void reshuffle() {
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
      ),
    );
  }
}
