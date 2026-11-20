import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/game_role.dart';

/// Displays a bottom sheet showcasing all 8 roles in the Obsidian Syndicate deck.
class RoleGuideSheet extends StatelessWidget {
  const RoleGuideSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.charcoalCardTier2,
      barrierColor: AppColors.backdropScrim,
      builder: (_) => const RoleGuideSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double maxHeight = MediaQuery.sizeOf(context).height * 0.84;

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
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.crimsonOverlay,
                    borderRadius: AppRadius.baseAll,
                    border: Border.all(
                      color: AppColors.syndicateCrimson,
                      width: AppElevation.borderWidth,
                    ),
                  ),
                  child: const Icon(
                    Icons.style_outlined,
                    color: AppColors.syndicateCrimson,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm + AppSpacing.xs),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'دليل الأدوار',
                        style: AppTypography.headlineMedium,
                      ),
                      Text(
                        'جميع شخصيات الطاولة وقدراتها السرية',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.close,
                    color: AppColors.mutedSlateSilver,
                  ),
                  tooltip: 'إغلاق',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(color: AppColors.rosterDivider),
            const SizedBox(height: AppSpacing.md),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: GameRole.allRoles.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.sm + AppSpacing.xs),
                itemBuilder: (BuildContext context, int index) {
                  final GameRole role = GameRole.allRoles[index];
                  return _RoleGuideCard(role: role);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleGuideCard extends StatelessWidget {
  const _RoleGuideCard({required this.role});

  final GameRole role;

  @override
  Widget build(BuildContext context) {
    final bool isMafia = role.team == RoleTeam.mafia;
    final Color factionColor =
        isMafia ? AppColors.syndicateCrimson : AppColors.citizensTeam;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm + AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.charcoalCardTier1,
        borderRadius: AppRadius.lgAll,
        border: Border.all(
          color: AppColors.borderResting,
          width: AppElevation.borderWidth,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Role portrait with corner suit badge
          Stack(
            children: [
              Container(
                width: 64,
                height: 82,
                decoration: BoxDecoration(
                  color: AppColors.obsidianCanvas,
                  borderRadius: AppRadius.baseAll,
                  border: Border.all(
                    color: factionColor.withValues(alpha: 0.6),
                    width: AppElevation.borderWidth,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  role.imagePath,
                  fit: BoxFit.cover,
                  cacheWidth: 180,
                  filterQuality: FilterQuality.medium,
                  errorBuilder: (_, __, ___) => Center(
                    child: Text(
                      role.team.cornerIndex,
                      style: AppTypography.headlineMedium.copyWith(
                        color: factionColor,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.obsidianCanvas.withValues(alpha: 0.85),
                    borderRadius: AppRadius.smAll,
                    border: Border.all(
                      color: factionColor,
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    role.team.cornerIndex,
                    style: AppTypography.labelSmall.copyWith(
                      color: factionColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        role.title,
                        style: AppTypography.headlineSmall,
                      ),
                    ),
                    _FactionBadge(
                      label: role.team.arabicLabel,
                      color: factionColor,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  role.description,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Icon(
                      role.isMandatory
                          ? Icons.lock_outline
                          : Icons.tune_outlined,
                      size: 13,
                      color: AppColors.mutedSlateSilver,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      role.isMandatory
                          ? 'دور أساسي إجباري'
                          : (role.isOptionalSelectable
                              ? 'دور تكتيكي اختياري'
                              : 'دور مواطن أساسي'),
                      style: AppTypography.labelSmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FactionBadge extends StatelessWidget {
  const _FactionBadge({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: AppRadius.baseAll,
        border: Border.all(
          color: color.withValues(alpha: 0.6),
          width: AppElevation.borderWidth,
        ),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
