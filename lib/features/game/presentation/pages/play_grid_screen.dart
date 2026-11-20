import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/game_role.dart';
import '../../domain/entities/playable_card.dart';
import '../cubit/game_cubit.dart';
import '../cubit/game_state.dart';
import '../widgets/flip_card_widget.dart';
import 'night_moderator_screen.dart';
import 'verification_vault_screen.dart';

/// Play Grid Screen managing sequential player-to-card role distribution,
/// unnumbered intuitive 3D card picking (exact 2:3 aspect ratio),
/// enlarged 3D spotlight card reveal overlay, pass-the-phone privacy shield,
/// automated Night-1 Audio & Visual Moderator, and transition to the Verification Vault.
class PlayGridScreen extends StatefulWidget {
  const PlayGridScreen({super.key});

  @override
  State<PlayGridScreen> createState() => _PlayGridScreenState();
}

class _PlayGridScreenState extends State<PlayGridScreen> {
  bool _hasPrecached = false;
  bool _hasCompletedNightModerator = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasPrecached) {
      _hasPrecached = true;
      unawaited(GameAssets.precacheAll(context));
    }
  }

  Future<void> _confirmReshuffle(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('إعادة خلط البطاقات؟'),
          content: const Text(
            'سيتم إلغاء التوزيع الحالي وإعادة خلط جميع البطاقات عشوائياً من اللاعب رقم 1 بنفس الإعدادات.',
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('تراجع'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('إعادة خلط'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      context.read<GameCubit>().reshuffle();
    }
  }

  Future<void> _confirmExitRound(BuildContext context) async {
    final bool? shouldExit = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('إنهاء الجولة؟'),
          content: const Text(
            'هل تريد إنهاء الجولة الحالية والعودة للإعدادات؟',
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('متابعة اللعب'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('إنهاء الجولة'),
            ),
          ],
        );
      },
    );

    if (shouldExit == true && context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameCubit, GameState>(
      listenWhen: (GameState previous, GameState current) =>
          previous.isAllCardsClaimed && !current.isAllCardsClaimed,
      listener: (BuildContext context, GameState state) {
        if (!state.isAllCardsClaimed && _hasCompletedNightModerator) {
          setState(() {
            _hasCompletedNightModerator = false;
          });
        }
      },
      builder: (BuildContext context, GameState state) {
        final GameCubit cubit = context.read<GameCubit>();
        final bool showNightModerator =
            state.isAllCardsClaimed && !_hasCompletedNightModerator;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (bool didPop, Object? result) {
            if (didPop) {
              return;
            }
            unawaited(_confirmExitRound(context));
          },
          child: Scaffold(
            backgroundColor: AppColors.obsidianCanvas,
            body: SafeArea(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top Tactical Header Bar
                      _PlayGridHeader(
                        remainingCount: state.remainingCardsCount,
                        totalCount: state.totalCards,
                        currentTurnPlayerNumber: state.currentTurnPlayerNumber,
                        isAllClaimed: state.isAllCardsClaimed,
                        isNightModeratorActive: showNightModerator,
                        onReshufflePressed: () => _confirmReshuffle(context),
                        onBackPressed: () => _confirmExitRound(context),
                      ),
                      // Top 2px countdown/progress razor gauge (hidden while NightModerator renders its own gauge)
                      if (!showNightModerator)
                        LinearProgressIndicator(
                          value: state.totalCards == 0
                              ? 0
                              : state.remainingCardsCount / state.totalCards,
                          minHeight: AppSpacing.countdownGaugeHeight,
                          backgroundColor: AppColors.charcoalCardTier2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            state.remainingCardsCount <= 2
                                ? AppColors.syndicateCrimson
                                : AppColors.mutedSlateSilver,
                          ),
                        ),
                      Expanded(
                        child: state.isAllCardsClaimed
                            ? (showNightModerator
                                ? NightModeratorScreen(
                                    onCompleted: () {
                                      if (mounted) {
                                        setState(() {
                                          _hasCompletedNightModerator = true;
                                        });
                                      }
                                    },
                                  )
                                : VerificationVaultView(
                                    onInstantRematch: () {
                                      setState(() {
                                        _hasCompletedNightModerator = false;
                                      });
                                      cubit.startInstantRematch();
                                    },
                                    onReplayNightModerator: () {
                                      setState(() {
                                        _hasCompletedNightModerator = false;
                                      });
                                    },
                                    onReturnToSetup: () =>
                                        _confirmExitRound(context),
                                    onReturnHome: () => Navigator.of(context)
                                        .popUntil(
                                            (Route<dynamic> r) => r.isFirst),
                                  ))
                            : _CardsGridContent(
                                state: state,
                                onCardTapHidden: cubit.revealCard,
                                onCardTapRevealed: cubit.claimAndHideCard,
                              ),
                      ),
                    ],
                  ),

                  // Enlarged 2:3 Spotlight Revealed Role Overlay with 8px backdrop blur
                  if (state.revealedCard != null)
                    _RevealedRoleOverlay(
                      card: state.revealedCard!,
                      playerNumber: state.currentTurnPlayerNumber,
                      onClaimAndHide: () =>
                          cubit.claimAndHideCard(state.revealedCardIndex!),
                    ),

                  // Transitional Pass-the-Phone Privacy Shield
                  if (state.showPassPhoneOverlay)
                    _PassPhonePrivacyOverlay(
                      nextPlayerNumber: state.currentTurnPlayerNumber,
                      onContinue: cubit.dismissPassPhoneOverlay,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PlayGridHeader extends StatelessWidget {
  const _PlayGridHeader({
    required this.remainingCount,
    required this.totalCount,
    required this.currentTurnPlayerNumber,
    required this.isAllClaimed,
    this.isNightModeratorActive = false,
    required this.onReshufflePressed,
    required this.onBackPressed,
  });

  final int remainingCount;
  final int totalCount;
  final int currentTurnPlayerNumber;
  final bool isAllClaimed;
  final bool isNightModeratorActive;
  final VoidCallback onReshufflePressed;
  final VoidCallback onBackPressed;

  @override
  Widget build(BuildContext context) {
    final String headerTitle = isNightModeratorActive
        ? 'الليدر الآلي — الليلة الأولى'
        : (isAllClaimed
            ? 'خزنة التحقق من الهوية'
            : 'البطاقات المتبقية: $remainingCount من $totalCount');

    final String headerSubtitle = isNightModeratorActive
        ? 'توجيه صوتي وبصري آلي لتعارف المافيا في الليلة الأولى'
        : (isAllClaimed
            ? 'جميع البطاقات موزعة ومربوطة بأرقام اللاعبين'
            : 'دور اللاعب رقم $currentTurnPlayerNumber • اختر بطاقة عشوائياً');

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.margin,
        vertical: AppSpacing.sm + AppSpacing.xs,
      ),
      color: AppColors.charcoalCardTier1,
      child: Row(
        children: [
          IconButton(
            onPressed: onBackPressed,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            tooltip: 'رجوع',
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  headerTitle,
                  style: AppTypography.headlineSmall,
                ),
                Text(
                  headerSubtitle,
                  style: AppTypography.labelSmall.copyWith(
                    color: isAllClaimed && !isNightModeratorActive
                        ? AppColors.mutedSlateSilver
                        : AppColors.syndicateCrimson,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: onReshufflePressed,
            icon: const Icon(Icons.shuffle_rounded, size: 16),
            label: const Text('إعادة خلط'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm + AppSpacing.xs,
                vertical: AppSpacing.sm,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardsGridContent extends StatelessWidget {
  const _CardsGridContent({
    required this.state,
    required this.onCardTapHidden,
    required this.onCardTapRevealed,
  });

  final GameState state;
  final ValueChanged<int> onCardTapHidden;
  final ValueChanged<int> onCardTapRevealed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Prominent Turn Badge: "دور اللاعب رقم {currentTurnPlayerNumber}"
        Container(
          margin: const EdgeInsets.fromLTRB(
            AppSpacing.margin,
            AppSpacing.md,
            AppSpacing.margin,
            AppSpacing.sm,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 4,
          ),
          decoration: BoxDecoration(
            color: AppColors.charcoalCardTier2,
            borderRadius: AppRadius.baseAll,
            border: Border.all(
              color: AppColors.syndicateCrimson,
              width: AppElevation.borderWidth,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.syndicateCrimson,
                      borderRadius: AppRadius.smAll,
                    ),
                    child: Text(
                      '#${state.currentTurnPlayerNumber}',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.pureWhite,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'دور اللاعب رقم ${state.currentTurnPlayerNumber}',
                    style: AppTypography.labelLarge,
                  ),
                ],
              ),
              Text(
                state.hasRevealedCard
                    ? 'بطاقة قيد المعاينة...'
                    : 'احفظ رقمك واسحب بطاقة',
                style: AppTypography.labelMedium,
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.margin,
              AppSpacing.sm,
              AppSpacing.margin,
              AppSpacing.lg,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: AppSpacing.gutter,
              crossAxisSpacing: AppSpacing.gutter,
              childAspectRatio: FlipCardWidget.cardAspectRatio, // Exact 2 / 3
            ),
            itemCount: state.cards.length,
            itemBuilder: (BuildContext context, int index) {
              final PlayableCard card = state.cards[index];
              final bool isLockedByAnother =
                  state.hasRevealedCard && state.revealedCardIndex != index;

              return FlipCardWidget(
                key: ValueKey<String>(card.id),
                card: card,
                isLockedByAnotherReveal: isLockedByAnother,
                onTapHidden: () => onCardTapHidden(index),
                onTapRevealed: () => onCardTapRevealed(index),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Centered, large 2:3 spotlight overlay above a blurred dark backdrop.
/// Guarantees 100% visibility of the role card's title and bottom description.
class _RevealedRoleOverlay extends StatelessWidget {
  const _RevealedRoleOverlay({
    required this.card,
    required this.playerNumber,
    required this.onClaimAndHide,
  });

  final PlayableCard card;
  final int playerNumber;
  final VoidCallback onClaimAndHide;

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.sizeOf(context);
    final double spotlightWidth = (screenSize.width * 0.78).clamp(240.0, 360.0);
    final double maxCardHeight = screenSize.height * 0.62;

    final GameRole role = card.role;
    final bool isMafia = role.team == RoleTeam.mafia;
    final Color factionColor =
        isMafia ? AppColors.syndicateCrimson : AppColors.citizensTeam;

    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: AppElevation.backdropBlurSigma,
        sigmaY: AppElevation.backdropBlurSigma,
      ),
      child: ColoredBox(
        color: AppColors.backdropScrim,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.margin,
              vertical: AppSpacing.md,
            ),
            child: SizedBox(
              width: spotlightWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top header pill: Faction & Sequential Player Number
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: AppElevation.tier2RaisedPanel(
                      radius: AppRadius.base,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: factionColor.withValues(alpha: 0.15),
                            borderRadius: AppRadius.smAll,
                            border: Border.all(color: factionColor),
                          ),
                          child: Text(
                            '${role.team.cornerIndex} ${role.team.suitSymbol}  ${role.team.arabicLabel}',
                            style: AppTypography.labelMedium.copyWith(
                              color: factionColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          'اللاعب رقم #$playerNumber',
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.pureWhite,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Large 2:3 3D-Flipped Role Card Artwork (zero cropping)
                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: spotlightWidth,
                        maxHeight: maxCardHeight,
                      ),
                      child: SpotlightRoleFlipCard(
                        role: role,
                        onTap: onClaimAndHide,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Primary Crimson CTA directly below the 2:3 spotlight card
                  SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: onClaimAndHide,
                      icon: const Icon(
                        Icons.visibility_off_outlined,
                        size: 20,
                      ),
                      label: const Text('فهمت — اضغط للإخفاء'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PassPhonePrivacyOverlay extends StatelessWidget {
  const _PassPhonePrivacyOverlay({
    required this.nextPlayerNumber,
    required this.onContinue,
  });

  final int nextPlayerNumber;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.obsidianCanvas.withValues(alpha: 0.96),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.margin),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: AppElevation.tier2RaisedPanel(radius: AppRadius.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.crimsonOverlay,
                        border: Border.all(
                          color: AppColors.syndicateCrimson,
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.screen_share_outlined,
                        color: AppColors.syndicateCrimson,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.crimsonOverlay,
                        borderRadius: AppRadius.baseAll,
                        border: Border.all(color: AppColors.syndicateCrimson),
                      ),
                      child: Text(
                        'دور اللاعب رقم $nextPlayerNumber',
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.pureWhite,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'مرر الهاتف للاعب التالي',
                    textAlign: TextAlign.center,
                    style: AppTypography.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'مرر الهاتف للاعب رقم $nextPlayerNumber لفتح بطاقة عشوائية',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.mutedSlateSilver,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: onContinue,
                      icon: const Icon(Icons.fingerprint_rounded, size: 22),
                      label: Text('أنا اللاعب رقم $nextPlayerNumber - متابعة'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
