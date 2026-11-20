import 'game_role.dart';

/// Lifecycle state of an individual dealt card on the play grid.
enum CardRevealStatus {
  hidden,
  revealed,
  claimed,
}

/// Represents an individual card instance dealt into the play grid.
class PlayableCard {
  const PlayableCard({
    required this.id,
    required this.index,
    required this.role,
    this.status = CardRevealStatus.hidden,
  });

  final String id;
  final int index;
  final GameRole role;
  final CardRevealStatus status;

  bool get isHidden => status == CardRevealStatus.hidden;
  bool get isRevealed => status == CardRevealStatus.revealed;
  bool get isClaimed => status == CardRevealStatus.claimed;

  PlayableCard copyWith({
    String? id,
    int? index,
    GameRole? role,
    CardRevealStatus? status,
  }) {
    return PlayableCard(
      id: id ?? this.id,
      index: index ?? this.index,
      role: role ?? this.role,
      status: status ?? this.status,
    );
  }
}
