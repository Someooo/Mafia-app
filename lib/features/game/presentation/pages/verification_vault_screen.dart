import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/game_role.dart';
import '../cubit/game_cubit.dart';
import '../cubit/game_state.dart';
import '../widgets/flip_card_widget.dart';
import 'night_moderator_screen.dart';

/// Standalone Scaffold wrapper for the Post-Deal Player Verification Vault.
class VerificationVaultScreen extends StatelessWidget {
  const VerificationVaultScreen({
    super.key,
    this.onInstantRematch,
    this.onReplayNightModerator,
    this.onReturnToSetup,
    this.onReturnHome,
  });

  final VoidCallback? onInstantRematch;
  final VoidCallback? onReplayNightModerator;
  final VoidCallback? onReturnToSetup;
  final VoidCallback? onReturnHome;

  @override
  Widget build(BuildContext context) {
    final GameCubit cubit = context.read<GameCubit>();
    return Scaffold(
      backgroundColor: AppColors.obsidianCanvas,
      appBar: AppBar(
        title: const Text('خزنة التحقق من الهوية'),
      ),
      body: SafeArea(
        child: VerificationVaultView(
          onInstantRematch: onInstantRematch ?? cubit.startInstantRematch,
          onReplayNightModerator: onReplayNightModerator,
          onReturnToSetup:
              onReturnToSetup ?? () => Navigator.of(context).maybePop(),
          onReturnHome: onReturnHome ??
              () => Navigator.of(context)
                  .popUntil((Route<dynamic> r) => r.isFirst),
        ),
      ),
    );
  }
}

/// Post-Deal Player Verification Vault ("خزنة التحقق من الهوية").
///
/// Includes:
/// 1. Live Faction Balance Bar ("المافيا الأحياء" vs "الصالحون الأحياء") via [BlocSelector]
/// 2. Automatic Win-Condition Banner (Mafia Victory / Citizens Victory) via [BlocSelector]
/// 3. Suspense Search by Player Number (1..N) with managed [TextEditingController] & [FocusNode]
/// 4. Eliminated Players Log, "إعادة الليدر الآلي" button, & End-of-Game Full Reveal sheet
class VerificationVaultView extends StatefulWidget {
  const VerificationVaultView({
    super.key,
    required this.onInstantRematch,
    required this.onReturnToSetup,
    required this.onReturnHome,
    this.onReplayNightModerator,
  });

  final VoidCallback onInstantRematch;
  final VoidCallback onReturnToSetup;
  final VoidCallback onReturnHome;
  final VoidCallback? onReplayNightModerator;

  @override
  State<VerificationVaultView> createState() => _VerificationVaultViewState();
}

class _VerificationVaultViewState extends State<VerificationVaultView> {
  final TextEditingController _playerNumberController = TextEditingController();
  final FocusNode _playerNumberFocusNode = FocusNode();
  String? _errorText;

  @override
  void dispose() {
    _playerNumberController.dispose();
    _playerNumberFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleVerifySubmission(BuildContext context) async {
    _playerNumberFocusNode.unfocus();

    final GameCubit cubit = context.read<GameCubit>();
    final int maxPlayers = cubit.state.playerCount;
    final String rawInput = _playerNumberController.text.trim();
    final int? playerNumber = int.tryParse(rawInput);

    if (playerNumber == null || playerNumber < 1 || playerNumber > maxPlayers) {
      setState(() {
        _errorText = 'يرجى إدخال رقم لاعب صحيح بين 1 و $maxPlayers';
      });
      return;
    }

    if (_errorText != null) {
      setState(() {
        _errorText = null;
      });
    }

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

    final GameRole? role = cubit.verifyPlayerRole(playerNumber);
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

  static Future<void> _showPlayerRoleModal({
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
        final Size screenSize = MediaQuery.sizeOf(dialogContext);
        final double maxCardHeight = screenSize.height * 0.62;
        final double dialogWidth =
            (screenSize.width * 0.82).clamp(260.0, 380.0);

        return Dialog(
          backgroundColor: AppColors.charcoalCardTier2,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.margin,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.xlAll,
            side: const BorderSide(
              color: AppColors.syndicateCrimson,
              width: 1.5,
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: SizedBox(
              width: dialogWidth,
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
                  // Exact 2:3 Portrait Card Container constrained to 62% screen height
                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: maxCardHeight,
                      ),
                      child: RoleCardFace(
                        role: role,
                        cacheWidth: 720,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
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

  Future<void> _confirmAndShowAllRoles(BuildContext context) async {
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

    final GameState state = context.read<GameCubit>().state;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.charcoalCardTier2,
      barrierColor: AppColors.backdropScrim,
      builder: (BuildContext sheetContext) {
        final double maxHeight = MediaQuery.sizeOf(sheetContext).height * 0.86;
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
                                  'مطرود',
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
                const SizedBox(height: AppSpacing.md),
                // Instant Rematch CTA inside the End-of-Game Full Reveal sheet
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      widget.onInstantRematch();
                    },
                    icon: const Icon(Icons.replay_rounded, size: 20),
                    label: const Text('جولة جديدة (إعادة خلط فورية)'),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.margin),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Isolated Live Faction Balance Bar
              const _LiveFactionBalanceSection(),

              const SizedBox(height: AppSpacing.md),

              // 2. Isolated Automatic Win-Condition Banner
              _WinConditionBannerSection(
                onInstantRematch: widget.onInstantRematch,
              ),

              // 3. Suspense Search Box by Player Number
              BlocSelector<GameCubit, GameState, int>(
                selector: (GameState state) => state.playerCount,
                builder: (BuildContext context, int playerCount) {
                  return Container(
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
                                    'خزنة التحقق من الهوية',
                                    style: AppTypography.headlineSmall,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'ابحث برقم اللاعب المطرود (1 - $playerCount) لكشف بطاقته الحقيقية وتحديث ميزان القوى تلقائياً.',
                                    style: AppTypography.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextField(
                          controller: _playerNumberController,
                          focusNode: _playerNumberFocusNode,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.right,
                          style: AppTypography.headlineSmall,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(2),
                          ],
                          decoration: InputDecoration(
                            hintText:
                                'أدخل رقم اللاعب المطرود (1 - $playerCount)',
                            errorText: _errorText,
                            prefixIcon: const Icon(
                              Icons.tag_rounded,
                              color: AppColors.syndicateCrimson,
                            ),
                          ),
                          onSubmitted: (_) => _handleVerifySubmission(context),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        SizedBox(
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: () => _handleVerifySubmission(context),
                            icon: const Icon(
                              Icons.visibility_outlined,
                              size: 20,
                            ),
                            label: const Text('كشف هوية اللاعب'),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              // 4. Isolated Verified Eliminated Players Log
              const _EliminatedPlayersLogSection(),

              const SizedBox(height: AppSpacing.lg),

              // 5. Night Moderator Replay, End-of-Game Full Reveal & Instant Rematch Controls
              SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {
                    if (widget.onReplayNightModerator != null) {
                      widget.onReplayNightModerator!();
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const Scaffold(
                            backgroundColor: AppColors.obsidianCanvas,
                            body: SafeArea(
                              child: NightModeratorScreen(),
                            ),
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.record_voice_over_outlined,
                    size: 20,
                  ),
                  label: const Text('إعادة الليدر الآلي'),
                ),
              ),
              const SizedBox(height: AppSpacing.sm + AppSpacing.xs),
              SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmAndShowAllRoles(context),
                  icon: const Icon(Icons.fact_check_outlined, size: 20),
                  label: const Text('كشف جميع الأدوار (نهاية الجولة)'),
                ),
              ),
              const SizedBox(height: AppSpacing.sm + AppSpacing.xs),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: widget.onInstantRematch,
                  icon: const Icon(Icons.replay_rounded, size: 20),
                  label: const Text('جولة جديدة (إعادة خلط فورية)'),
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
  }
}

class _LiveFactionBalanceSection extends StatelessWidget {
  const _LiveFactionBalanceSection();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<GameCubit, GameState,
        ({int aliveMafiaCount, int aliveCitizensCount})>(
      selector: (GameState state) => (
        aliveMafiaCount: state.aliveMafiaCount,
        aliveCitizensCount: state.aliveCitizensCount,
      ),
      builder: (BuildContext context, data) {
        return _LiveFactionBalanceBar(
          aliveMafiaCount: data.aliveMafiaCount,
          aliveCitizensCount: data.aliveCitizensCount,
        );
      },
    );
  }
}

class _WinConditionBannerSection extends StatelessWidget {
  const _WinConditionBannerSection({required this.onInstantRematch});

  final VoidCallback onInstantRematch;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<GameCubit, GameState,
        ({bool isMafiaVictory, bool isCitizensVictory})>(
      selector: (GameState state) => (
        isMafiaVictory: state.isMafiaVictory,
        isCitizensVictory: state.isCitizensVictory,
      ),
      builder: (BuildContext context, data) {
        if (data.isMafiaVictory) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _WinConditionBanner(
              isMafiaVictory: true,
              title: 'سيطرت المافيا على المدينة! انتهت الجولة',
              subtitle: 'تساوى عدد المافيا الأحياء مع الصالحين',
              onInstantRematch: onInstantRematch,
            ),
          );
        }
        if (data.isCitizensVictory) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _WinConditionBanner(
              isMafiaVictory: false,
              title: 'انتصر الصالحون! تم القضاء على جميع أفراد المافيا',
              subtitle:
                  'نجح المواطنون في كشف وطرد جميع عناصر المافيا من المدينة',
              onInstantRematch: onInstantRematch,
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _EliminatedPlayersLogSection extends StatelessWidget {
  const _EliminatedPlayersLogSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameCubit, GameState>(
      buildWhen: (GameState previous, GameState current) =>
          previous.revealedEliminatedPlayers !=
              current.revealedEliminatedPlayers ||
          previous.playerCount != current.playerCount ||
          previous.playerRoles != current.playerRoles,
      builder: (BuildContext context, GameState state) {
        final List<int> verifiedList =
            state.revealedEliminatedPlayers.toList()..sort();

        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: AppElevation.tier2RaisedPanel(radius: AppRadius.lg),
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
                    final GameRole? role = state.playerRoles[playerNum];
                    if (role == null) {
                      return const SizedBox.shrink();
                    }
                    final bool isMafia = role.team == RoleTeam.mafia;
                    final Color factionColor = isMafia
                        ? AppColors.syndicateCrimson
                        : AppColors.citizensTeam;

                    return InkWell(
                      key: ValueKey<int>(playerNum),
                      onTap: () =>
                          _VerificationVaultViewState._showPlayerRoleModal(
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
                            color: factionColor.withValues(alpha: 0.65),
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
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.mutedSlateSilver,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              role.title,
                              style: AppTypography.labelLarge.copyWith(
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
        );
      },
    );
  }
}

/// Tier 1 (`#161616` with `1px` `#262626` border) split status card
/// displaying real-time surviving counts for Mafia and Citizens.
class _LiveFactionBalanceBar extends StatelessWidget {
  const _LiveFactionBalanceBar({
    required this.aliveMafiaCount,
    required this.aliveCitizensCount,
  });

  final int aliveMafiaCount;
  final int aliveCitizensCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + AppSpacing.xs,
      ),
      decoration: AppElevation.tier1RestingCard(radius: AppRadius.lg),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Right side in RTL (Crimson accent #D90429): "المافيا الأحياء: {aliveMafiaCount}"
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.syndicateCrimson,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Flexible(
                    child: Text(
                      'المافيا الأحياء: $aliveMafiaCount',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.syndicateCrimson,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const VerticalDivider(
              color: AppColors.borderResting,
              thickness: AppElevation.borderWidth,
              width: AppSpacing.lg,
            ),
            // Left side in RTL (Crisp White #FFFFFF): "الصالحون الأحياء: {aliveCitizensCount}"
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.pureWhite,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Flexible(
                    child: Text(
                      'الصالحون الأحياء: $aliveCitizensCount',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.pureWhite,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dramatic Win-Condition Alert Banner with Instant Rematch CTA.
class _WinConditionBanner extends StatelessWidget {
  const _WinConditionBanner({
    required this.isMafiaVictory,
    required this.title,
    required this.subtitle,
    required this.onInstantRematch,
  });

  final bool isMafiaVictory;
  final String title;
  final String subtitle;
  final VoidCallback onInstantRematch;

  static const Color _emeraldAccent = Color(0xFF2EC4B6);

  @override
  Widget build(BuildContext context) {
    final Color borderColor =
        isMafiaVictory ? AppColors.syndicateCrimson : _emeraldAccent;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.charcoalCardTier2,
        borderRadius: AppRadius.xlAll,
        border: Border.all(
          color: borderColor,
          width: AppElevation.borderWidth,
        ),
        boxShadow: isMafiaVictory
            ? const [AppElevation.activeCardGlow]
            : [
                BoxShadow(
                  color: _emeraldAccent.withValues(alpha: 0.22),
                  blurRadius: 16.0,
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: borderColor.withValues(alpha: 0.16),
                  border: Border.all(
                    color: borderColor,
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  isMafiaVictory
                      ? Icons.local_fire_department_rounded
                      : Icons.emoji_events_outlined,
                  color: borderColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.headlineSmall.copyWith(
                        color: AppColors.pureWhite,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: isMafiaVictory
                            ? AppColors.primary
                            : AppColors.pureWhite.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: onInstantRematch,
              icon: const Icon(Icons.replay_rounded, size: 20),
              label: const Text('جولة جديدة (إعادة خلط فورية)'),
            ),
          ),
        ],
      ),
    );
  }
}
