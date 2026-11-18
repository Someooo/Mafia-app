import 'package:flutter/material.dart';

/// Obsidian Syndicate color palette tokens defined in DESIGN.md.
abstract final class AppColors {
  // Core Architecture
  static const Color obsidianCanvas = Color(0xFF0D0D0D);
  static const Color charcoalCardTier1 = Color(0xFF161616);
  static const Color charcoalCardTier2 = Color(0xFF1A1A1A);
  static const Color syndicateCrimson = Color(0xFFD90429);
  static const Color crimsonHoverBorder = Color(0xFFFF2E4D);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color mutedSlateSilver = Color(0xFF8E9297);

  // Borders & Dividers
  static const Color borderResting = Color(0xFF262626);
  static const Color borderRaised = Color(0xFF333333);
  static const Color rosterDivider = Color(0xFF222222);
  static const Color inputCanvas = Color(0xFF121212);

  // Opacity & Atmospheric Tokens
  static const Color crimsonGlow = Color(0x40D90429);
  static const Color crimsonOverlay = Color(0x1AD90429);
  static const Color pipInactive = Color(0x338E9297);
  static const Color deceasedRing = Color(0x808E9297);
  static const Color backdropScrim = Color(0xCC000000);

  // Faction Tokens
  static const Color mafiaTeam = syndicateCrimson;
  static const Color citizensTeam = tertiary;

  // Material 3 Tonal Tokens
  static const Color surface = Color(0xFF131313);
  static const Color surfaceDim = Color(0xFF131313);
  static const Color surfaceBright = Color(0xFF3A3939);
  static const Color surfaceContainerLowest = Color(0xFF0E0E0E);
  static const Color surfaceContainerLow = Color(0xFF1C1B1B);
  static const Color surfaceContainer = Color(0xFF201F1F);
  static const Color surfaceContainerHigh = Color(0xFF2A2A2A);
  static const Color surfaceContainerHighest = Color(0xFF353534);
  static const Color onSurface = Color(0xFFE5E2E1);
  static const Color onSurfaceVariant = Color(0xFFE7BCBA);
  static const Color inverseSurface = Color(0xFFE5E2E1);
  static const Color inverseOnSurface = Color(0xFF313030);
  static const Color outline = Color(0xFFAE8885);
  static const Color outlineVariant = Color(0xFF5D3F3D);
  static const Color surfaceTint = Color(0xFFFFB3AF);

  static const Color primary = Color(0xFFFFB3AF);
  static const Color onPrimary = Color(0xFF68000E);
  static const Color primaryContainer = Color(0xFFD90429);
  static const Color onPrimaryContainer = Color(0xFFFFEAE8);
  static const Color inversePrimary = Color(0xFFBF0022);

  static const Color secondary = Color(0xFFC3C7CC);
  static const Color onSecondary = Color(0xFF2C3135);
  static const Color secondaryContainer = Color(0xFF43474C);
  static const Color onSecondaryContainer = Color(0xFFB2B5BB);

  static const Color tertiary = Color(0xFF80CFFF);
  static const Color onTertiary = Color(0xFF00344B);
  static const Color tertiaryContainer = Color(0xFF0074A0);
  static const Color onTertiaryContainer = Color(0xFFE0F1FF);

  static const Color error = Color(0xFFFFB4AB);
  static const Color onError = Color(0xFF690005);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color onErrorContainer = Color(0xFFFFDAD6);

  static const Color primaryFixed = Color(0xFFFFDAD7);
  static const Color primaryFixedDim = Color(0xFFFFB3AF);
  static const Color onPrimaryFixed = Color(0xFF410005);
  static const Color onPrimaryFixedVariant = Color(0xFF930018);

  static const Color secondaryFixed = Color(0xFFDFE3E8);
  static const Color secondaryFixedDim = Color(0xFFC3C7CC);
  static const Color onSecondaryFixed = Color(0xFF181C20);
  static const Color onSecondaryFixedVariant = Color(0xFF43474C);

  static const Color tertiaryFixed = Color(0xFFC5E7FF);
  static const Color tertiaryFixedDim = Color(0xFF80CFFF);
  static const Color onTertiaryFixed = Color(0xFF001E2D);
  static const Color onTertiaryFixedVariant = Color(0xFF004C6B);

  static const Color background = Color(0xFF131313);
  static const Color onBackground = Color(0xFFE5E2E1);
  static const Color surfaceVariant = Color(0xFF353534);
}

/// Custom game-specific color tokens exposed via [ThemeExtension].
@immutable
class SyndicateColorsExtension extends ThemeExtension<SyndicateColorsExtension> {
  const SyndicateColorsExtension({
    required this.crimsonGlow,
    required this.crimsonOverlay,
    required this.cardSurfaceTier1,
    required this.cardSurfaceTier2,
    required this.cardBorderResting,
    required this.cardBorderRaised,
    required this.cardBorderActive,
    required this.mafiaTeamColor,
    required this.citizensTeamColor,
    required this.obsidianCanvas,
    required this.inputCanvas,
    required this.rosterDivider,
    required this.mutedSlateSilver,
    required this.pipInactive,
    required this.deceasedRing,
    required this.backdropScrim,
  });

  final Color crimsonGlow;
  final Color crimsonOverlay;
  final Color cardSurfaceTier1;
  final Color cardSurfaceTier2;
  final Color cardBorderResting;
  final Color cardBorderRaised;
  final Color cardBorderActive;
  final Color mafiaTeamColor;
  final Color citizensTeamColor;
  final Color obsidianCanvas;
  final Color inputCanvas;
  final Color rosterDivider;
  final Color mutedSlateSilver;
  final Color pipInactive;
  final Color deceasedRing;
  final Color backdropScrim;

  static const SyndicateColorsExtension instance = SyndicateColorsExtension(
    crimsonGlow: AppColors.crimsonGlow,
    crimsonOverlay: AppColors.crimsonOverlay,
    cardSurfaceTier1: AppColors.charcoalCardTier1,
    cardSurfaceTier2: AppColors.charcoalCardTier2,
    cardBorderResting: AppColors.borderResting,
    cardBorderRaised: AppColors.borderRaised,
    cardBorderActive: AppColors.syndicateCrimson,
    mafiaTeamColor: AppColors.mafiaTeam,
    citizensTeamColor: AppColors.citizensTeam,
    obsidianCanvas: AppColors.obsidianCanvas,
    inputCanvas: AppColors.inputCanvas,
    rosterDivider: AppColors.rosterDivider,
    mutedSlateSilver: AppColors.mutedSlateSilver,
    pipInactive: AppColors.pipInactive,
    deceasedRing: AppColors.deceasedRing,
    backdropScrim: AppColors.backdropScrim,
  );

  @override
  SyndicateColorsExtension copyWith({
    Color? crimsonGlow,
    Color? crimsonOverlay,
    Color? cardSurfaceTier1,
    Color? cardSurfaceTier2,
    Color? cardBorderResting,
    Color? cardBorderRaised,
    Color? cardBorderActive,
    Color? mafiaTeamColor,
    Color? citizensTeamColor,
    Color? obsidianCanvas,
    Color? inputCanvas,
    Color? rosterDivider,
    Color? mutedSlateSilver,
    Color? pipInactive,
    Color? deceasedRing,
    Color? backdropScrim,
  }) {
    return SyndicateColorsExtension(
      crimsonGlow: crimsonGlow ?? this.crimsonGlow,
      crimsonOverlay: crimsonOverlay ?? this.crimsonOverlay,
      cardSurfaceTier1: cardSurfaceTier1 ?? this.cardSurfaceTier1,
      cardSurfaceTier2: cardSurfaceTier2 ?? this.cardSurfaceTier2,
      cardBorderResting: cardBorderResting ?? this.cardBorderResting,
      cardBorderRaised: cardBorderRaised ?? this.cardBorderRaised,
      cardBorderActive: cardBorderActive ?? this.cardBorderActive,
      mafiaTeamColor: mafiaTeamColor ?? this.mafiaTeamColor,
      citizensTeamColor: citizensTeamColor ?? this.citizensTeamColor,
      obsidianCanvas: obsidianCanvas ?? this.obsidianCanvas,
      inputCanvas: inputCanvas ?? this.inputCanvas,
      rosterDivider: rosterDivider ?? this.rosterDivider,
      mutedSlateSilver: mutedSlateSilver ?? this.mutedSlateSilver,
      pipInactive: pipInactive ?? this.pipInactive,
      deceasedRing: deceasedRing ?? this.deceasedRing,
      backdropScrim: backdropScrim ?? this.backdropScrim,
    );
  }

  @override
  SyndicateColorsExtension lerp(
    covariant ThemeExtension<SyndicateColorsExtension>? other,
    double t,
  ) {
    if (other is! SyndicateColorsExtension) {
      return this;
    }
    return SyndicateColorsExtension(
      crimsonGlow: Color.lerp(crimsonGlow, other.crimsonGlow, t)!,
      crimsonOverlay: Color.lerp(crimsonOverlay, other.crimsonOverlay, t)!,
      cardSurfaceTier1:
          Color.lerp(cardSurfaceTier1, other.cardSurfaceTier1, t)!,
      cardSurfaceTier2:
          Color.lerp(cardSurfaceTier2, other.cardSurfaceTier2, t)!,
      cardBorderResting:
          Color.lerp(cardBorderResting, other.cardBorderResting, t)!,
      cardBorderRaised:
          Color.lerp(cardBorderRaised, other.cardBorderRaised, t)!,
      cardBorderActive:
          Color.lerp(cardBorderActive, other.cardBorderActive, t)!,
      mafiaTeamColor: Color.lerp(mafiaTeamColor, other.mafiaTeamColor, t)!,
      citizensTeamColor:
          Color.lerp(citizensTeamColor, other.citizensTeamColor, t)!,
      obsidianCanvas: Color.lerp(obsidianCanvas, other.obsidianCanvas, t)!,
      inputCanvas: Color.lerp(inputCanvas, other.inputCanvas, t)!,
      rosterDivider: Color.lerp(rosterDivider, other.rosterDivider, t)!,
      mutedSlateSilver:
          Color.lerp(mutedSlateSilver, other.mutedSlateSilver, t)!,
      pipInactive: Color.lerp(pipInactive, other.pipInactive, t)!,
      deceasedRing: Color.lerp(deceasedRing, other.deceasedRing, t)!,
      backdropScrim: Color.lerp(backdropScrim, other.backdropScrim, t)!,
    );
  }
}

extension SyndicateColorsContext on BuildContext {
  SyndicateColorsExtension get syndicateColors =>
      Theme.of(this).extension<SyndicateColorsExtension>() ??
      SyndicateColorsExtension.instance;
}
