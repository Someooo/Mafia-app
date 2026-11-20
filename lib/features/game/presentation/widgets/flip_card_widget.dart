import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/game_role.dart';
import '../../domain/entities/playable_card.dart';

/// 3D Y-axis rotating role card following the exact 2:3 portrait aspect ratio
/// of the generated role card artwork (`assets/images/*.jpg`).
class FlipCardWidget extends StatefulWidget {
  const FlipCardWidget({
    super.key,
    required this.card,
    required this.isLockedByAnotherReveal,
    required this.onTapHidden,
    required this.onTapRevealed,
  });

  final PlayableCard card;
  final bool isLockedByAnotherReveal;
  final VoidCallback onTapHidden;
  final VoidCallback onTapRevealed;

  /// Exact 2:3 portrait aspect ratio matching the role card artwork.
  static const double cardAspectRatio = 2 / 3;

  @override
  State<FlipCardWidget> createState() => _FlipCardWidgetState();
}

class _FlipCardWidgetState extends State<FlipCardWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
      value: widget.card.isRevealed ? 1.0 : 0.0,
    );
    _flipAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void didUpdateWidget(covariant FlipCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.card.isRevealed && !oldWidget.card.isRevealed) {
      _controller.forward();
    } else if (!widget.card.isRevealed && oldWidget.card.isRevealed) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: FlipCardWidget.cardAspectRatio,
      child: widget.card.isClaimed
          ? _ClaimedCardSlot(
              assignedPlayerNumber: widget.card.assignedPlayerNumber,
            )
          : AnimatedOpacity(
              duration: const Duration(milliseconds: 220),
              opacity: widget.isLockedByAnotherReveal ? 0.32 : 1.0,
              child: GestureDetector(
                onTap: () {
                  if (widget.card.isHidden && !widget.isLockedByAnotherReveal) {
                    widget.onTapHidden();
                  } else if (widget.card.isRevealed) {
                    widget.onTapRevealed();
                  }
                },
                child: AnimatedBuilder(
                  animation: _flipAnimation,
                  builder: (BuildContext context, Widget? child) {
                    final double angle = _flipAnimation.value * math.pi;
                    final bool showFrontFace = angle > (math.pi / 2);

                    final Matrix4 transform = Matrix4.identity()
                      ..setEntry(3, 2, 0.0012)
                      ..rotateY(angle);

                    return Transform(
                      alignment: Alignment.center,
                      transform: transform,
                      child: showFrontFace
                          ? Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.rotationY(math.pi),
                              child: RoleCardFace(role: widget.card.role),
                            )
                          : _CardBackFace(
                              isLocked: widget.isLockedByAnotherReveal,
                            ),
                    );
                  },
                ),
              ),
            ),
    );
  }
}

/// Large 3D spotlight flip card used when a player reveals a card in the overlay.
/// Automatically animates a 3D Y-axis flip from `card_back` to the 2:3 role artwork.
class SpotlightRoleFlipCard extends StatefulWidget {
  const SpotlightRoleFlipCard({
    super.key,
    required this.role,
    this.onTap,
  });

  final GameRole role;
  final VoidCallback? onTap;

  @override
  State<SpotlightRoleFlipCard> createState() => _SpotlightRoleFlipCardState();
}

class _SpotlightRoleFlipCardState extends State<SpotlightRoleFlipCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 540),
    )..forward();
    _flipAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AspectRatio(
        aspectRatio: FlipCardWidget.cardAspectRatio,
        child: AnimatedBuilder(
          animation: _flipAnimation,
          builder: (BuildContext context, Widget? child) {
            final double angle = _flipAnimation.value * math.pi;
            final bool showFrontFace = angle > (math.pi / 2);

            final Matrix4 transform = Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle);

            return Transform(
              alignment: Alignment.center,
              transform: transform,
              child: showFrontFace
                  ? Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(math.pi),
                      child: RoleCardFace(role: widget.role),
                    )
                  : const _CardBackFace(isLocked: false),
            );
          },
        ),
      ),
    );
  }
}

/// Renders the uncropped 2:3 role card artwork inside an `#0D0D0D` frame.
class RoleCardFace extends StatelessWidget {
  const RoleCardFace({
    super.key,
    required this.role,
  });

  final GameRole role;

  @override
  Widget build(BuildContext context) {
    final bool isMafia = role.team == RoleTeam.mafia;
    final Color accentColor =
        isMafia ? AppColors.syndicateCrimson : AppColors.citizensTeam;

    return AspectRatio(
      aspectRatio: FlipCardWidget.cardAspectRatio,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.obsidianCanvas,
          borderRadius: AppRadius.lgAll,
          border: Border.all(
            color: accentColor,
            width: AppElevation.borderWidth + 0.5,
          ),
          boxShadow: const [AppElevation.activeCardGlow],
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.asset(
          role.imagePath,
          fit: BoxFit.contain,
          alignment: Alignment.center,
          errorBuilder: (_, __, ___) => Container(
            color: AppColors.charcoalCardTier2,
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  role.team.cornerIndex,
                  style: AppTypography.displayLarge.copyWith(
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  role.title,
                  textAlign: TextAlign.center,
                  style: AppTypography.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  role.description,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardBackFace extends StatelessWidget {
  const _CardBackFace({
    required this.isLocked,
  });

  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: FlipCardWidget.cardAspectRatio,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.obsidianCanvas,
          borderRadius: AppRadius.lgAll,
          border: Border.all(
            color: isLocked
                ? AppColors.borderResting
                : AppColors.syndicateCrimson.withValues(alpha: 0.65),
            width: AppElevation.borderWidth,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              GameAssets.cardBack,
              fit: BoxFit.contain,
              alignment: Alignment.center,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.charcoalCardTier1,
                child: const Center(
                  child: Icon(
                    Icons.shield_outlined,
                    color: AppColors.syndicateCrimson,
                    size: 36,
                  ),
                ),
              ),
            ),
            // Top-right decorative playing card pip (unnumbered for intuitive picking)
            Positioned(
              top: 6,
              right: 8,
              child: Text(
                '♦',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.pipInactive,
                ),
              ),
            ),
            // Bottom-left decorative playing card pip
            Positioned(
              bottom: 6,
              left: 8,
              child: Text(
                '♠',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.pipInactive,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClaimedCardSlot extends StatelessWidget {
  const _ClaimedCardSlot({this.assignedPlayerNumber});

  final int? assignedPlayerNumber;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: FlipCardWidget.cardAspectRatio,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.charcoalCardTier1.withValues(alpha: 0.35),
          borderRadius: AppRadius.lgAll,
          border: Border.all(
            color: AppColors.borderResting.withValues(alpha: 0.6),
            width: AppElevation.borderWidth,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.obsidianCanvas,
                border: Border.all(
                  color: AppColors.borderRaised,
                  width: AppElevation.borderWidth,
                ),
              ),
              child: const Icon(
                Icons.check,
                size: 16,
                color: AppColors.mutedSlateSilver,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'تم السحب',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.mutedSlateSilver,
              ),
            ),
            if (assignedPlayerNumber != null)
              Text(
                'لاعب #$assignedPlayerNumber',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.mutedSlateSilver.withValues(alpha: 0.6),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
