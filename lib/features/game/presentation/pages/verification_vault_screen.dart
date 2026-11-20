import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/game_role.dart';
import '../cubit/game_cubit.dart';
import '../cubit/game_state.dart';

/// Post-Deal Player Verification Vault ("خزنة التحقق من الهوية").
///
/// Allows the narrator or table to verify an eliminated player's secret role
/// by their sequential player number (`1..N`) without exposing the rest of the table,
/// logs verified eliminations, and provides an end-of-round full roster reveal.
class VerificationVaultView extends StatefulWidget {
  const VerificationVaultView({
    super.key,
    required this.onReshuffle,
    required this.onReturnToSetup,
    required this.onReturnHome,
  });

  final VoidCallback onReshuffle;
  final VoidCallback onReturnToSetup;
  final VoidCallback onReturnHome;

  @override
  State<VerificationVaultView> createState() => _VerificationVaultViewState();
}

class _VerificationVaultViewState extends State<VerificationVaultView> {
  final TextEditingController _playerNumberController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _playerNumberController.dispose();
    super.dispose();
  }

  Future<void> _handleVerifySubmission(
    BuildContext context,
    GameState state,
  ) async {
    FocusScope.of(context).unfocus();

    final String rawInput = _playerNumberController.text.trim();
    final int? playerNumber = int.tryParse(rawInput);

    if (playerNumber == null ||
        playerNumber < 1 ||
        playerNumber > state.playerCount) {
      setState(() {
        _errorText =
            'يرجى إدخال رقم لاعب صحيح بين 1 و ${state.playerCount}';
      });
      return;
    }

    setState(() {
      _errorText = null;
    });

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('كشف هوية اللاعب رقم $playerNumber؟'),
          content: Text(
            'سيتم كشف البطاقة السرية الخاصة باللاعب رقم $playerNumber أمام الطاولة وتسجيله في سجل المطرودين.',
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('تراجع'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('كشف الهوية'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final GameRole? role =
        context.read<GameCubit>().verifyPlayerRole(playerNumber);
    if (role == null || !context.mounted) {
      return;
    }

    _playerNumberController.clear();
    await _showPlayerRoleModal(
      context: context,
      playerNumber: playerNumber,
      role: role,
    );
  }

  Future<void> _showPlayerRoleModal({
    required BuildContext context,
    required int playerNumber,
    required GameRole role,
  }) {
    final bool isMafia = role.team == RoleTeam.mafia;
    final Color factionColor =
        isMafia ? AppColors.syndicateCrimson : AppColors.citizensTeam;

    return showDialog<void>(
      context: context,
      barrierColor: AppColors.backdropScrim,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: AppColors.charcoalCardTier2,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.xlAll,
            side: const BorderSide(
              color: AppColors.syndicateCrimson,
              width: 1.5,
            ),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm + 2,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.crimsonOverlay,
                          borderRadius: AppRadius.baseAll,
                          border: Border.all(
                            color: AppColors.syndicateCrimson,
                          ),
                        ),
                        child: Text(
                          'بطاقة اللاعب رقم $playerNumber',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.pureWhite,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: factionColor.withValues(alpha: 0.15),
                          borderRadius: AppRadius.baseAll,
                          border: Border.all(color: factionColor),
                        ),
                        child: Text(
                          '${role.team.cornerIndex} ${role.team.suitSymbol} ${role.team.arabicLabel}',
                          style: AppTypography.labelSmall.copyWith(
                            color: factionColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AspectRatio(
                    aspectRatio: 0.88,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.obsidianCanvas,
                        borderRadius: AppRadius.lgAll,
                        border: Border.all(
                          color: factionColor.withValues(alpha: 0.75),
                          width: AppElevation.borderWidth,
                        ),
                        boxShadow: const [AppElevation.activeCardGlow],
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
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: const Icon(Icons.check_circle_outline, size: 20),
                      label: const Text('إغلاق البطاقة'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmAndShowAllRoles(
    BuildContext context,
    GameState state,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('كشف جميع الأدوار؟'),
          content: const Text(
            'هل انتهت الجولة بالفعل وتريد كشف أدوار جميع اللاعبين؟',
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('تراجع'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('كشف الجميع'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.charcoalCardTier2,
      barrierColor: AppColors.backdropScrim,
      builder: (BuildContext sheetContext) {
        final double maxHeight = MediaQuery.sizeOf(sheetContext).height * 0.85;
        final List<int> sortedPlayers = state.playerRoles.keys.toList()..sort();

        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.margin,
              AppSpacing.md,
              AppSpacing.margin,
              AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderRaised,
                      borderRadius: AppRadius.fullAll,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'سجل أدوار الجولة الكامل',
                          style: AppTypography.headlineMedium,
                        ),
                        Text(
                          'جميع اللاعبين وأدوارهم السرية من 1 إلى ${state.playerCount}',
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.mutedSlateSilver,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                const Divider(color: AppColors.rosterDivider),
                const SizedBox(height: AppSpacing.sm),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: sortedPlayers.length,
                    separatorBuilder: (_, __) =>
                        const Divider(color: AppColors.rosterDivider),
                    itemBuilder: (BuildContext context, int index) {
                      final int playerNum = sortedPlayers[index];
                      final GameRole role = state.playerRoles[playerNum]!;
                      final bool isMafia = role.team == RoleTeam.mafia;
                      final Color factionColor = isMafia
                          ? AppColors.syndicateCrimson
                          : AppColors.citizensTeam;
                      final bool wasEliminated = state
                          .revealedEliminatedPlayers
                          .contains(playerNum);

                      return Container(
                        height: AppSpacing.rosterItemHeight,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                        ),
                        color: AppColors.charcoalCardTier1,
                        child: Row(
                          children: [
                            // 36px circular avatar framed with faction/state ring
                            Container(
                              width: AppSpacing.avatarSize,
                              height: AppSpacing.avatarSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.obsidianCanvas,
                                border: Border.all(
                                  color: wasEliminated
                                      ? AppColors.deceasedRing
                                      : factionColor,
                                  width: 1.5,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '$playerNum',
                                style: AppTypography.labelLarge.copyWith(
                                  color: AppColors.pureWhite,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'اللاعب رقم $playerNum',
                                    style: AppTypography.headlineSmall,
                                  ),
                                  Text(
                                    role.description,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.labelSmall,
                                  ),
                                ],
                              ),
                            ),
                            if (wasEliminated)
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: AppSpacing.sm,
                                ),
                                child: Text(
                                  'مكشوف',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.mutedSlateSilver,
                                  ),
                                ),
                              ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm + 2,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: factionColor.withValues(alpha: 0.14),
                                borderRadius: AppRadius.baseAll,
                                border: Border.all(
                                  color: factionColor.withValues(alpha: 0.7),
                                ),
                              ),
                              child: Text(
                                role.title,
                                style: AppTypography.labelMedium.copyWith(
                                  color: factionColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameCubit, GameState>(
      builder: (BuildContext context, GameState state) {
        final List<int> verifiedList =
            state.revealedEliminatedPlayers.toList()..sort();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.margin),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Status Banner: Ready to Play + Active Vault
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration:
                        AppElevation.tier3ActiveTarget(radius: AppRadius.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.crimsonOverlay,
                                border: Border.all(
                                  color: AppColors.syndicateCrimson,
                                  width: 1.5,
                                ),
                              ),
                              child: const Icon(
                                Icons.verified_user_outlined,
                                color: AppColors.syndicateCrimson,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'جاهزون للعب! • خزنة التحقق من الهوية',
                                    style: AppTypography.headlineSmall,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'تم ربط كل لاعب برقمه التسلسلي (1 - ${state.playerCount}). ابحث برقم اللاعب المطرود لكشف بطاقته الحقيقية ومنع الكذب.',
                                    style: AppTypography.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        // Suspense Numeric Search Field
                        TextField(
                          controller: _playerNumberController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.right,
                          style: AppTypography.headlineSmall,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(2),
                          ],
                          decoration: InputDecoration(
                            hintText:
                                'أدخل رقم اللاعب المطرود (1 - ${state.playerCount})',
                            errorText: _errorText,
                            prefixIcon: const Icon(
                              Icons.tag_rounded,
                              color: AppColors.syndicateCrimson,
                            ),
                          ),
                          onSubmitted: (_) =>
                              _handleVerifySubmission(context, state),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        SizedBox(
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _handleVerifySubmission(context, state),
                            icon: const Icon(
                              Icons.visibility_outlined,
                              size: 20,
                            ),
                            label: const Text('كشف هوية اللاعب'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Verified Eliminated Players Log
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration:
                        AppElevation.tier2RaisedPanel(radius: AppRadius.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'سجل اللاعبين المطرودين',
                              style: AppTypography.headlineSmall,
                            ),
                            Text(
                              '${verifiedList.length} من ${state.playerCount}',
                              style: AppTypography.labelMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        if (verifiedList.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            child: Text(
                              'لم يتم كشف هوية أي لاعب حتى الآن. عند طرد لاعب بالتصويت، أدخل رقمه أعلاه للتحقق من بطاقته.',
                              textAlign: TextAlign.center,
                              style: AppTypography.bodySmall,
                            ),
                          )
                        else
                          Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: verifiedList.map((int playerNum) {
                              final GameRole? role =
                                  state.playerRoles[playerNum];
                              if (role == null) {
                                return const SizedBox.shrink();
                              }
                              final bool isMafia = role.team == RoleTeam.mafia;
                              final Color factionColor = isMafia
                                  ? AppColors.syndicateCrimson
                                  : AppColors.citizensTeam;

                              return InkWell(
                                onTap: () => _showPlayerRoleModal(
                                  context: context,
                                  playerNumber: playerNum,
                                  role: role,
                                ),
                                borderRadius: AppRadius.baseAll,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm + 4,
                                    vertical: AppSpacing.sm,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.charcoalCardTier1,
                                    borderRadius: AppRadius.baseAll,
                                    border: Border.all(
                                      color:
                                          factionColor.withValues(alpha: 0.65),
                                      width: AppElevation.borderWidth,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'لاعب #$playerNum',
                                        style: AppTypography.labelLarge,
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      Text(
                                        '•',
                                        style:
                                            AppTypography.labelMedium.copyWith(
                                          color: AppColors.mutedSlateSilver,
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      Text(
                                        role.title,
                                        style:
                                            AppTypography.labelLarge.copyWith(
                                          color: factionColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // End-of-Game Full Reveal & Round Management Controls
                  SizedBox(
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _confirmAndShowAllRoles(context, state),
                      icon: const Icon(Icons.fact_check_outlined, size: 20),
                      label: const Text('كشف جميع الأدوار (نهاية الجولة)'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm + AppSpacing.xs),
                  SizedBox(
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: widget.onReshuffle,
                      icon: const Icon(Icons.refresh_rounded, size: 20),
                      label: const Text('جولة جديدة بنفس الإعدادات'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton.icon(
                        onPressed: widget.onReturnToSetup,
                        icon: const Icon(Icons.tune_rounded, size: 18),
                        label: const Text('تعديل الإعدادات'),
                      ),
                      TextButton.icon(
                        onPressed: widget.onReturnHome,
                        icon: const Icon(Icons.home_outlined, size: 18),
                        label: const Text('القائمة الرئيسية'),
                      ),
                    ],
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
