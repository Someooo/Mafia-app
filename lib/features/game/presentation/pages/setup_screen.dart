import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/game_role.dart';
import '../../domain/services/role_shuffler.dart';
import '../cubit/game_cubit.dart';
import '../cubit/game_state.dart';
import '../widgets/role_guide_sheet.dart';
import 'play_grid_screen.dart';

/// Game Setup Screen configuring total players (6-18), mandatory roles, and optional roles.
class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  bool _hasPrecached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasPrecached) {
      _hasPrecached = true;
      unawaited(GameAssets.precacheAll(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidianCanvas,
      appBar: AppBar(
        title: const Text('إعداد الجولة'),
        actions: [
          IconButton(
            onPressed: () => RoleGuideSheet.show(context),
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: 'دليل الأدوار',
          ),
        ],
      ),
      body: BlocBuilder<GameCubit, GameState>(
        builder: (BuildContext context, GameState state) {
          final GameCubit cubit = context.read<GameCubit>();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.margin,
                    AppSpacing.md,
                    AppSpacing.margin,
                    AppSpacing.xl,
                  ),
                  children: [
                    _PlayerCounterPanel(
                      playerCount: state.playerCount,
                      canIncrement: state.canIncrementPlayers,
                      canDecrement: state.canDecrementPlayers,
                      mafiaCount: state.totalMafiaCount,
                      citizensCount: state.totalCitizensTeamCount,
                      onIncrement: cubit.incrementPlayerCount,
                      onDecrement: cubit.decrementPlayerCount,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _SectionHeader(
                      title: 'الأدوار الإجبارية',
                      subtitle: '٤ أدوار أساسية ثابتة في كل جولة',
                      trailingBadge: '${state.mandatoryCount}',
                    ),
                    const SizedBox(height: AppSpacing.sm + AppSpacing.xs),
                    ...GameRole.mandatoryRoles.map(
                      (GameRole role) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _MandatoryRoleTile(role: role),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _SectionHeader(
                      title: 'الأدوار الاختيارية',
                      subtitle: 'فعّل الأدوار الإضافية حسب تكتيك المجموعة',
                      trailingBadge: '${state.selectedOptionalCount}',
                    ),
                    const SizedBox(height: AppSpacing.sm + AppSpacing.xs),
                    ...GameRole.optionalRoles.map(
                      (GameRole role) {
                        final bool isSelected =
                            state.enabledOptionalRoleIds.contains(role.id);
                        final bool isEnabled =
                            state.canToggleOptionalRole(role.id);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: _OptionalRoleSwitchTile(
                            role: role,
                            isSelected: isSelected,
                            isEnabled: isEnabled,
                            onToggle: () => cubit.toggleOptionalRole(role.id),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              _StickyDealFooter(
                remainingCitizenCount: state.remainingCitizenCount,
                playerCount: state.playerCount,
                onDealCards: () {
                  cubit.dealCards();
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const PlayGridScreen(),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PlayerCounterPanel extends StatelessWidget {
  const _PlayerCounterPanel({
    required this.playerCount,
    required this.canIncrement,
    required this.canDecrement,
    required this.mafiaCount,
    required this.citizensCount,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int playerCount;
  final bool canIncrement;
  final bool canDecrement;
  final int mafiaCount;
  final int citizensCount;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
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
                'عدد اللاعبين',
                style: AppTypography.headlineSmall,
              ),
              Text(
                'الحد المسموح: ${RoleShuffler.minPlayers} - ${RoleShuffler.maxPlayers}',
                style: AppTypography.labelMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _CounterActionButton(
                icon: Icons.add_rounded,
                isEnabled: canIncrement,
                isPrimary: true,
                tooltip: 'زيادة لاعب',
                onPressed: onIncrement,
              ),
              Column(
                children: [
                  Text(
                    '$playerCount',
                    textAlign: TextAlign.center,
                    style: AppTypography.displayLarge.copyWith(
                      color: AppColors.pureWhite,
                    ),
                  ),
                  Text(
                    'لاعبين على الطاولة',
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
              _CounterActionButton(
                icon: Icons.remove_rounded,
                isEnabled: canDecrement,
                isPrimary: false,
                tooltip: 'إنقاص لاعب',
                onPressed: onDecrement,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(color: AppColors.rosterDivider),
          const SizedBox(height: AppSpacing.sm + AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: _TeamCountIndicator(
                  label: 'فريق المافيا',
                  count: mafiaCount,
                  color: AppColors.syndicateCrimson,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _TeamCountIndicator(
                  label: 'فريق المواطنين',
                  count: citizensCount,
                  color: AppColors.citizensTeam,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CounterActionButton extends StatelessWidget {
  const _CounterActionButton({
    required this.icon,
    required this.isEnabled,
    required this.isPrimary,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final bool isEnabled;
  final bool isPrimary;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = isPrimary
        ? (isEnabled
            ? AppColors.syndicateCrimson
            : AppColors.syndicateCrimson.withValues(alpha: 0.25))
        : AppColors.charcoalCardTier1;

    final Color borderColor = isPrimary
        ? (isEnabled ? AppColors.crimsonHoverBorder : Colors.transparent)
        : AppColors.borderRaised;

    return Material(
      color: backgroundColor,
      borderRadius: AppRadius.baseAll,
      child: InkWell(
        onTap: isEnabled ? onPressed : null,
        borderRadius: AppRadius.baseAll,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: AppRadius.baseAll,
            border: Border.all(
              color: borderColor,
              width: AppElevation.borderWidth,
            ),
          ),
          child: Icon(
            icon,
            size: 28,
            color: isEnabled
                ? AppColors.pureWhite
                : AppColors.mutedSlateSilver.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}

class _TeamCountIndicator extends StatelessWidget {
  const _TeamCountIndicator({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + AppSpacing.xs,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.charcoalCardTier1,
        borderRadius: AppRadius.baseAll,
        border: Border.all(
          color: color.withValues(alpha: 0.45),
          width: AppElevation.borderWidth,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.pureWhite,
            ),
          ),
          Text(
            '$count',
            style: AppTypography.labelLarge.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.trailingBadge,
  });

  final String title;
  final String subtitle;
  final String trailingBadge;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.headlineSmall,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.bodySmall,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm + 2,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.charcoalCardTier2,
            borderRadius: AppRadius.baseAll,
            border: Border.all(
              color: AppColors.borderRaised,
              width: AppElevation.borderWidth,
            ),
          ),
          child: Text(
            trailingBadge,
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.pureWhite,
            ),
          ),
        ),
      ],
    );
  }
}

class _MandatoryRoleTile extends StatelessWidget {
  const _MandatoryRoleTile({required this.role});

  final GameRole role;

  @override
  Widget build(BuildContext context) {
    final bool isMafia = role.team == RoleTeam.mafia;
    final Color factionColor =
        isMafia ? AppColors.syndicateCrimson : AppColors.citizensTeam;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm + AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.charcoalCardTier2,
        borderRadius: AppRadius.lgAll,
        border: Border.all(
          color: AppColors.borderResting,
          width: AppElevation.borderWidth,
        ),
      ),
      child: Row(
        children: [
          _RoleAvatarThumb(
            imagePath: role.imagePath,
            cornerIndex: role.team.cornerIndex,
            borderColor: factionColor,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      role.title,
                      style: AppTypography.headlineSmall,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: factionColor.withValues(alpha: 0.14),
                        borderRadius: AppRadius.smAll,
                      ),
                      child: Text(
                        role.team.arabicLabel,
                        style: AppTypography.labelSmall.copyWith(
                          color: factionColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  role.description,
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.charcoalCardTier1,
              borderRadius: AppRadius.baseAll,
              border: Border.all(
                color: AppColors.borderRaised,
                width: AppElevation.borderWidth,
              ),
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              size: 18,
              color: AppColors.mutedSlateSilver,
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionalRoleSwitchTile extends StatelessWidget {
  const _OptionalRoleSwitchTile({
    required this.role,
    required this.isSelected,
    required this.isEnabled,
    required this.onToggle,
  });

  final GameRole role;
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final bool isMafia = role.team == RoleTeam.mafia;
    final Color factionColor =
        isMafia ? AppColors.syndicateCrimson : AppColors.citizensTeam;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: isEnabled ? 1.0 : 0.45,
      child: InkWell(
        onTap: isEnabled ? onToggle : null,
        borderRadius: AppRadius.lgAll,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm + AppSpacing.xs),
          decoration: BoxDecoration(
            color: AppColors.charcoalCardTier1,
            borderRadius: AppRadius.lgAll,
            border: Border.all(
              color: isSelected
                  ? AppColors.syndicateCrimson
                  : AppColors.borderResting,
              width: AppElevation.borderWidth,
            ),
            boxShadow:
                isSelected ? const [AppElevation.activeCardGlow] : null,
          ),
          child: Row(
            children: [
              _RoleAvatarThumb(
                imagePath: role.imagePath,
                cornerIndex: role.team.cornerIndex,
                borderColor: factionColor,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          role.title,
                          style: AppTypography.headlineSmall,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: factionColor.withValues(alpha: 0.14),
                            borderRadius: AppRadius.smAll,
                          ),
                          child: Text(
                            role.team.arabicLabel,
                            style: AppTypography.labelSmall.copyWith(
                              color: factionColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      role.description,
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Switch(
                value: isSelected,
                onChanged: isEnabled ? (_) => onToggle() : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleAvatarThumb extends StatelessWidget {
  const _RoleAvatarThumb({
    required this.imagePath,
    required this.cornerIndex,
    required this.borderColor,
  });

  final String imagePath;
  final String cornerIndex;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.obsidianCanvas,
        borderRadius: AppRadius.baseAll,
        border: Border.all(
          color: borderColor.withValues(alpha: 0.7),
          width: AppElevation.borderWidth,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Center(
          child: Text(
            cornerIndex,
            style: AppTypography.headlineSmall.copyWith(
              color: borderColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _StickyDealFooter extends StatelessWidget {
  const _StickyDealFooter({
    required this.remainingCitizenCount,
    required this.playerCount,
    required this.onDealCards,
  });

  final int remainingCitizenCount;
  final int playerCount;
  final VoidCallback onDealCards;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.margin,
        AppSpacing.md,
        AppSpacing.margin,
        AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.charcoalCardTier2,
        border: Border(
          top: BorderSide(
            color: AppColors.borderRaised,
            width: AppElevation.borderWidth,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.people_alt_outlined,
                      size: 18,
                      color: AppColors.citizensTeam,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'المواطنون العاديون: $remainingCitizenCount',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.pureWhite,
                      ),
                    ),
                  ],
                ),
                Text(
                  'المجموع: $playerCount بطاقات',
                  style: AppTypography.labelMedium,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: onDealCards,
                icon: const Icon(Icons.style_rounded, size: 20),
                label: const Text('توزيع البطاقات'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
