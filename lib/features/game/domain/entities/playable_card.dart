import 'game_role.dart';

/// Lifecycle state of an individual dealt card on the play grid.
enum CardRevealStatus {
  hidden,
  revealed,
  claimed,
}

/// Pure-Dart domain entity representing an individual card instance dealt into the play grid.
class PlayableCard {
  const PlayableCard({
    required this.id,
    required this.index,
    required this.role,
    this.status = CardRevealStatus.hidden,
    this.assignedPlayerNumber,
  });

  final String id;
  final int index;
  final GameRole role;
  final CardRevealStatus status;

  /// The 1-based player number who claimed this card during the sequential deal.
  final int? assignedPlayerNumber;

  bool get isHidden => status == CardRevealStatus.hidden;
  bool get isRevealed => status == CardRevealStatus.revealed;
  bool get isClaimed => status == CardRevealStatus.claimed;

  static const Object _unset = Object();

  PlayableCard copyWith({
    String? id,
    int? index,
    GameRole? role,
    CardRevealStatus? status,
    Object? assignedPlayerNumber = _unset,
  }) {
    return PlayableCard(
      id: id ?? this.id,
      index: index ?? this.index,
      role: role ?? this.role,
      status: status ?? this.status,
      assignedPlayerNumber: identical(assignedPlayerNumber, _unset)
          ? this.assignedPlayerNumber
          : assignedPlayerNumber as int?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is PlayableCard &&
        other.id == id &&
        other.index == index &&
        other.role == role &&
        other.status == status &&
        other.assignedPlayerNumber == assignedPlayerNumber;
  }

  @override
  int get hashCode => Object.hash(
        id,
        index,
        role,
        status,
        assignedPlayerNumber,
      );
}
