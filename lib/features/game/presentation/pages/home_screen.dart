import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/game_role.dart';
import '../widgets/role_guide_sheet.dart';
import 'setup_screen.dart';

/// Obsidian Syndicate Home Screen featuring high-stakes noir atmosphere
/// and automatic role image pre-caching.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Subtle crimson radial ambient ember in the background
          Positioned(
            top: -120,
            left: -80,
            right: -80,
            child: IgnorePointer(
              child: Container(
                height: 420,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.syndicateCrimson.withValues(alpha: 0.16),
                      AppColors.syndicateCrimson.withValues(alpha: 0.04),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.margin,
                vertical: AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top decorative noir dossier header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm + AppSpacing.xs,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.charcoalCardTier1,
                          borderRadius: AppRadius.baseAll,
                          border: Border.all(
                            color: AppColors.borderResting,
                            width: AppElevation.borderWidth,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.syndicateCrimson,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'طاولة اللعب السرية',
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.pureWhite,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '♠ ♦',
                        style: AppTypography.headlineSmall.copyWith(
                          color: AppColors.pipInactive,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Centerpiece Logo Dossier Frame
                  Center(
                    child: Container(
                      width: 210,
                      height: 210,
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.charcoalCardTier2,
                        borderRadius: AppRadius.xlAll,
                        border: Border.all(
                          color: AppColors.syndicateCrimson,
                          width: AppElevation.borderWidth,
                        ),
                        boxShadow: const [AppElevation.activeCardGlow],
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: AppRadius.lgAll,
                            child: Image.asset(
                              GameAssets.logo,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: AppColors.charcoalCardTier1,
                                child: const Icon(
                                  Icons.local_police_outlined,
                                  size: 64,
                                  color: AppColors.syndicateCrimson,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.obsidianCanvas
                                    .withValues(alpha: 0.82),
                                borderRadius: AppRadius.smAll,
                                border: Border.all(
                                  color: AppColors.syndicateCrimson,
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                'م ♠',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.syndicateCrimson,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Title & Subtitle
                  Text(
                    'مافيا',
                    textAlign: TextAlign.center,
                    style: AppTypography.displayLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'لعبة الذكاء والشك',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.mutedSlateSilver,
                    ),
                  ),
                  const Spacer(),
                  // Primary Assassin CTA: "لعبة جديدة"
                  SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const SetupScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.play_arrow_rounded, size: 22),
                      label: const Text('لعبة جديدة'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Secondary Alibi Action: "دليل الأدوار"
                  SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () => RoleGuideSheet.show(context),
                      icon: const Icon(Icons.menu_book_outlined, size: 20),
                      label: const Text('دليل الأدوار'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
