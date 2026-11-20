import 'dart:async';

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

/// Play Grid Screen managing secret role card distribution, 3D flips,
/// single-card lock enforcement, pass-the-phone privacy shield,
/// image pre-caching, and accidental back-navigation guard (`PopScope`).
class PlayGridScreen extends StatefulWidget {
  const PlayGridScreen({super.key});

  @override
  State<PlayGridScreen> createState() => _PlayGridScreenState();
}

class _PlayGridScreenState extends State<PlayGridScreen> {
  bool _hasPrecached = false;

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
            'سيتم إلغاء التوزيع الحالي وإعادة خلط جميع البطاقات عشوائياً بنفس إعدادات اللاعبين.',
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
    return BlocBuilder<GameCubit, GameState>(
      builder: (BuildContext context, GameState state) {
        final GameCubit cubit = context.read<GameCubit>();

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
                        onReshufflePressed: () => _confirmReshuffle(context),
                        onBackPressed: () => _confirmExitRound(context),
                      ),
                      // Top 2px countdown/progress razor gauge
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
                            ? _ReadyToPlayView(
                                playerCount: state.playerCount,
                                mafiaCount: state.totalMafiaCount,
                                citizensCount: state.totalCitizensTeamCount,
                                onReshuffle: cubit.reshuffle,
                                onReturnToSetup: () =>
                                    Navigator.of(context).pop(),
                                onReturnHome: () => Navigator.of(context)
                                    .popUntil((Route<dynamic> r) => r.isFirst),
                              )
                            : _CardsGridContent(
                                state: state,
                                onCardTapHidden: cubit.revealCard,
                                onCardTapRevealed: cubit.claimAndHideCard,
                              ),
                      ),
                    ],
                  ),

                  // Active Revealed Role Dossier Modal Overlay
                  if (state.revealedCard != null)
                    _RevealedRoleOverlay(
                      card: state.revealedCard!,
                      playerNumber: state.nextPlayerNumber,
                      onClaimAndHide: () =>
                          cubit.claimAndHideCard(state.revealedCardIndex!),
                    ),

                  // Transitional Pass-the-Phone Privacy Shield
                  if (state.showPassPhoneOverlay)
                    _PassPhonePrivacyOverlay(
                      nextPlayerNumber: state.nextPlayerNumber,
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
    required this.onReshufflePressed,
    required this.onBackPressed,
  });

  final int remainingCount;
  final int totalCount;
  final VoidCallback onReshufflePressed;
  final VoidCallback onBackPressed;

  @override
  Widget build(BuildContext context) {
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
          // Right side (Leading in RTL): "البطاقات المتبقية: X من Y"
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'البطاقات المتبقية: $remainingCount من $totalCount',
                  style: AppTypography.headlineSmall,
                ),
                Text(
                  'اسحب بطاقة واحدة واكتم هويتك عن الآخرين',
                  style: AppTypography.labelSmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Left side (Trailing in RTL): "إعادة خلط"
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
        Container(
          margin: const EdgeInsets.fromLTRB(
            AppSpacing.margin,
            AppSpacing.md,
            AppSpacing.margin,
            AppSpacing.sm,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          decoration: AppElevation.tier1RestingCard(radius: AppRadius.base),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.person_pin_circle_outlined,
                    color: AppColors.syndicateCrimson,
                    size: 18,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'دور اللاعب رقم ${state.nextPlayerNumber}',
                    style: AppTypography.labelLarge,
                  ),
                ],
              ),
              Text(
                state.hasRevealedCard
                    ? 'بطاقة قيد المعاينة...'
                    : 'اختر أي بطاقة متاحة',
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
              childAspectRatio: 0.72,
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
    final GameRole role = card.role;
    final bool isMafia = role.team == RoleTeam.mafia;
    final Color factionColor =
        isMafia ? AppColors.syndicateCrimson : AppColors.citizensTeam;

    return ColoredBox(
      color: AppColors.backdropScrim,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.margin),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.charcoalCardTier2,
                borderRadius: AppRadius.xlAll,
                border: Border.all(
                  color: AppColors.syndicateCrimson,
                  width: 1.5,
                ),
                boxShadow: const [AppElevation.activeCardGlow],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: factionColor.withValues(alpha: 0.15),
                          borderRadius: AppRadius.baseAll,
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
                        'اللاعب رقم $playerNumber',
                        style: AppTypography.labelMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AspectRatio(
                    aspectRatio: 0.85,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.obsidianCanvas,
                        borderRadius: AppRadius.lgAll,
                        border: Border.all(
                          color: factionColor.withValues(alpha: 0.7),
                          width: AppElevation.borderWidth,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        role.imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: Text(
                            role.team.cornerIndex,
                            style: AppTypography.displayLarge.copyWith(
                              color: factionColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    role.title,
                    textAlign: TextAlign.center,
                    style: AppTypography.headlineLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    role.description,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: onClaimAndHide,
                      icon: const Icon(Icons.visibility_off_outlined, size: 20),
                      label: const Text('فهمت - اضغط للإخفاء'),
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
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'مرر الهاتف للاعب التالي',
                    textAlign: TextAlign.center,
                    style: AppTypography.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'مرر الهاتف للاعب رقم $nextPlayerNumber لفتح بطاقة',
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

class _ReadyToPlayView extends StatelessWidget {
  const _ReadyToPlayView({
    required this.playerCount,
    required this.mafiaCount,
    required this.citizensCount,
    required this.onReshuffle,
    required this.onReturnToSetup,
    required this.onReturnHome,
  });

  final int playerCount;
  final int mafiaCount;
  final int citizensCount;
  final VoidCallback onReshuffle;
  final VoidCallback onReturnToSetup;
  final VoidCallback onReturnHome;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: AppElevation.tier3ActiveTarget(radius: AppRadius.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.crimsonOverlay,
                      border: Border.all(
                        color: AppColors.syndicateCrimson,
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.nights_stay_outlined,
                      size: 38,
                      color: AppColors.syndicateCrimson,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'جاهزون للعب!',
                  textAlign: TextAlign.center,
                  style: AppTypography.displayMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'تم توزيع جميع البطاقات السرية بنجاح. أغمضوا أعينكم لتبدأ الليلة الأولى تحت إدارة الراوي.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.mutedSlateSilver,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration:
                      AppElevation.tier1RestingCard(radius: AppRadius.base),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _SummaryStat(
                        label: 'اللاعبون',
                        value: '$playerCount',
                        color: AppColors.pureWhite,
                      ),
                      _SummaryStat(
                        label: 'المافيا',
                        value: '$mafiaCount',
                        color: AppColors.syndicateCrimson,
                      ),
                      _SummaryStat(
                        label: 'المواطنون',
                        value: '$citizensCount',
                        color: AppColors.citizensTeam,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: onReshuffle,
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                    label: const Text('جولة جديدة بنفس الإعدادات'),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm + AppSpacing.xs),
                SizedBox(
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: onReturnToSetup,
                    icon: const Icon(Icons.tune_rounded, size: 18),
                    label: const Text('تعديل إعدادات الأدوار'),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: onReturnHome,
                  child: const Text('العودة إلى القائمة الرئيسية'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.headlineLarge.copyWith(color: color),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.labelMedium,
        ),
      ],
    );
  }
}
