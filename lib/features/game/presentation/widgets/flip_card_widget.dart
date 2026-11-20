import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/game_role.dart';
import '../../domain/entities/playable_card.dart';

/// 3D Y-axis rotating role card following the Obsidian Syndicate playing-card motif.
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
    if (widget.card.isClaimed) {
      return _ClaimedCardSlot(cardNumber: widget.card.index + 1);
    }

    return AnimatedOpacity(
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
                      child: _CardFrontFace(role: widget.card.role),
                    )
                  : _CardBackFace(
                      cardNumber: widget.card.index + 1,
                      isLocked: widget.isLockedByAnotherReveal,
                    ),
            );
          },
        ),
      ),
    );
  }
}

class _CardBackFace extends StatelessWidget {
  const _CardBackFace({
    required this.cardNumber,
    required this.isLocked,
  });

  final int cardNumber;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.charcoalCardTier1,
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
            fit: BoxFit.cover,
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
          // Dark vignette overlay for high-contrast numbering
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.obsidianCanvas.withValues(alpha: 0.55),
                  Colors.transparent,
                  AppColors.obsidianCanvas.withValues(alpha: 0.82),
                ],
              ),
            ),
          ),
          // Top-right card number badge
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.obsidianCanvas.withValues(alpha: 0.82),
                borderRadius: AppRadius.smAll,
                border: Border.all(
                  color: AppColors.borderRaised,
                  width: 0.8,
                ),
              ),
              child: Text(
                '$cardNumber',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.pureWhite,
                  fontWeight: FontWeight.w700,
                ),
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
    );
  }
}

class _CardFrontFace extends StatelessWidget {
  const _CardFrontFace({required this.role});

  final GameRole role;

  @override
  Widget build(BuildContext context) {
    final bool isMafia = role.team == RoleTeam.mafia;
    final Color accentColor =
        isMafia ? AppColors.syndicateCrimson : AppColors.citizensTeam;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.charcoalCardTier2,
        borderRadius: AppRadius.lgAll,
        border: Border.all(
          color: AppColors.syndicateCrimson,
          width: AppElevation.borderWidth + 0.5,
        ),
        boxShadow: const [AppElevation.activeCardGlow],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            role.imagePath,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: AppColors.charcoalCardTier2,
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.obsidianCanvas.withValues(alpha: 0.65),
                  Colors.transparent,
                  AppColors.obsidianCanvas.withValues(alpha: 0.94),
                ],
              ),
            ),
          ),
          // Top-right corner faction index ("م" or "مـ")
          Positioned(
            top: 6,
            right: 6,
            child: _CornerIndexPip(
              indexText: role.team.cornerIndex,
              suitText: role.team.suitSymbol,
              color: accentColor,
            ),
          ),
          // Bottom-left mirrored corner faction index
          Positioned(
            bottom: 6,
            left: 6,
            child: _CornerIndexPip(
              indexText: role.team.cornerIndex,
              suitText: role.team.suitSymbol,
              color: accentColor,
            ),
          ),
          // Role Title & Tap-to-Hide hint
          Positioned(
            right: 6,
            left: 6,
            bottom: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  role.title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.pureWhite,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'اضغط للإخفاء',
                  textAlign: TextAlign.center,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.syndicateCrimson,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CornerIndexPip extends StatelessWidget {
  const _CornerIndexPip({
    required this.indexText,
    required this.suitText,
    required this.color,
  });

  final String indexText;
  final String suitText;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.obsidianCanvas.withValues(alpha: 0.85),
        borderRadius: AppRadius.smAll,
        border: Border.all(
          color: color,
          width: 0.8,
        ),
      ),
      child: Text(
        '$indexText $suitText',
        style: AppTypography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ClaimedCardSlot extends StatelessWidget {
  const _ClaimedCardSlot({required this.cardNumber});

  final int cardNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(
            '#$cardNumber',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.mutedSlateSilver.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
