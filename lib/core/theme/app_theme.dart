import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_typography.dart';

/// Assembles the single unified Obsidian Syndicate Material 3 dark theme.
abstract final class AppTheme {
  /// System UI overlay style matching the `#0D0D0D` Obsidian Black canvas
  /// with crisp light status/navigation bar icons.
  static const SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
    statusBarColor: AppColors.obsidianCanvas,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: AppColors.obsidianCanvas,
    systemNavigationBarDividerColor: AppColors.borderResting,
    systemNavigationBarIconBrightness: Brightness.light,
  );

  /// Single fixed dark [ThemeData] for the application.
  static ThemeData get theme {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      tertiary: AppColors.tertiary,
      onTertiary: AppColors.onTertiary,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: AppColors.onTertiaryContainer,
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      shadow: Colors.transparent,
      scrim: AppColors.backdropScrim,
      inverseSurface: AppColors.inverseSurface,
      onInverseSurface: AppColors.inverseOnSurface,
      inversePrimary: AppColors.inversePrimary,
      surfaceDim: AppColors.surfaceDim,
      surfaceBright: AppColors.surfaceBright,
      surfaceContainerLowest: AppColors.surfaceContainerLowest,
      surfaceContainerLow: AppColors.surfaceContainerLow,
      surfaceContainer: AppColors.surfaceContainer,
      surfaceContainerHigh: AppColors.surfaceContainerHigh,
      surfaceContainerHighest: AppColors.surfaceContainerHighest,
      surfaceTint: AppColors.surfaceTint,
    );

    final textTheme = AppTypography.textTheme;
    final baseBorderRadius = BorderRadius.circular(AppRadius.base);
    final panelBorderRadius = BorderRadius.circular(AppRadius.lg);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.obsidianCanvas,
      canvasColor: AppColors.obsidianCanvas,
      textTheme: textTheme,
      extensions: const [
        SyndicateColorsExtension.instance,
      ],
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.obsidianCanvas,
        foregroundColor: AppColors.pureWhite,
        elevation: AppElevation.none,
        scrolledUnderElevation: AppElevation.none,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        systemOverlayStyle: systemUiOverlayStyle,
        titleTextStyle: AppTypography.headlineSmall,
        iconTheme: const IconThemeData(color: AppColors.pureWhite),
      ),
      iconTheme: const IconThemeData(
        color: AppColors.pureWhite,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.rosterDivider,
        thickness: AppElevation.borderWidth,
        space: AppElevation.borderWidth,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.syndicateCrimson,
        selectionColor: AppColors.crimsonGlow,
        selectionHandleColor: AppColors.syndicateCrimson,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors.syndicateCrimson.withValues(alpha: 0.35);
            }
            return AppColors.syndicateCrimson;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors.pureWhite.withValues(alpha: 0.5);
            }
            return AppColors.pureWhite;
          }),
          overlayColor: const WidgetStatePropertyAll(AppColors.crimsonOverlay),
          elevation: const WidgetStatePropertyAll(AppElevation.none),
          shadowColor: const WidgetStatePropertyAll(Colors.transparent),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          textStyle: WidgetStatePropertyAll(AppTypography.labelLarge),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm + AppSpacing.xs,
            ),
          ),
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.pressed) ||
                states.contains(WidgetState.focused)) {
              return const BorderSide(
                color: AppColors.crimsonHoverBorder,
                width: AppElevation.borderWidth,
              );
            }
            return BorderSide.none;
          }),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: baseBorderRadius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors.charcoalCardTier1.withValues(alpha: 0.5);
            }
            return AppColors.charcoalCardTier1;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors.pureWhite.withValues(alpha: 0.4);
            }
            return AppColors.pureWhite;
          }),
          overlayColor: WidgetStatePropertyAll(
            AppColors.pureWhite.withValues(alpha: 0.06),
          ),
          elevation: const WidgetStatePropertyAll(AppElevation.none),
          shadowColor: const WidgetStatePropertyAll(Colors.transparent),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          textStyle: WidgetStatePropertyAll(AppTypography.labelLarge),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm + AppSpacing.xs,
            ),
          ),
          side: const WidgetStatePropertyAll(
            BorderSide(
              color: AppColors.borderRaised,
              width: AppElevation.borderWidth,
            ),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: baseBorderRadius),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors.syndicateCrimson.withValues(alpha: 0.4);
            }
            return AppColors.syndicateCrimson;
          }),
          overlayColor: const WidgetStatePropertyAll(AppColors.crimsonOverlay),
          elevation: const WidgetStatePropertyAll(AppElevation.none),
          shadowColor: const WidgetStatePropertyAll(Colors.transparent),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          textStyle: WidgetStatePropertyAll(AppTypography.labelLarge),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm + AppSpacing.xs,
            ),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: baseBorderRadius),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.charcoalCardTier1,
        elevation: AppElevation.none,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: panelBorderRadius,
          side: const BorderSide(
            color: AppColors.borderResting,
            width: AppElevation.borderWidth,
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.charcoalCardTier2,
        elevation: AppElevation.none,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        barrierColor: AppColors.backdropScrim,
        titleTextStyle: AppTypography.headlineMedium,
        contentTextStyle: AppTypography.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: panelBorderRadius,
          side: const BorderSide(
            color: AppColors.borderRaised,
            width: AppElevation.borderWidth,
          ),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.charcoalCardTier2,
        modalBackgroundColor: AppColors.charcoalCardTier2,
        elevation: AppElevation.none,
        modalElevation: AppElevation.none,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        modalBarrierColor: AppColors.backdropScrim,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.lg),
          ),
          side: BorderSide(
            color: AppColors.borderRaised,
            width: AppElevation.borderWidth,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputCanvas,
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.mutedSlateSilver,
        ),
        labelStyle: AppTypography.labelMedium.copyWith(
          color: AppColors.mutedSlateSilver,
        ),
        floatingLabelStyle: AppTypography.labelMedium.copyWith(
          color: AppColors.syndicateCrimson,
        ),
        errorStyle: AppTypography.bodySmall.copyWith(
          color: AppColors.error,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + AppSpacing.xs,
        ),
        border: OutlineInputBorder(
          borderRadius: baseBorderRadius,
          borderSide: const BorderSide(
            color: AppColors.borderRaised,
            width: AppElevation.borderWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: baseBorderRadius,
          borderSide: const BorderSide(
            color: AppColors.borderRaised,
            width: AppElevation.borderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: baseBorderRadius,
          borderSide: const BorderSide(
            color: AppColors.syndicateCrimson,
            width: AppElevation.borderWidth,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: baseBorderRadius,
          borderSide: const BorderSide(
            color: AppColors.error,
            width: AppElevation.borderWidth,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: baseBorderRadius,
          borderSide: const BorderSide(
            color: AppColors.syndicateCrimson,
            width: AppElevation.borderWidth,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: baseBorderRadius,
          borderSide: BorderSide(
            color: AppColors.borderRaised.withValues(alpha: 0.4),
            width: AppElevation.borderWidth,
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.pureWhite;
          }
          return AppColors.mutedSlateSilver;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.syndicateCrimson;
          }
          return AppColors.charcoalCardTier1;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.syndicateCrimson;
          }
          return AppColors.borderRaised;
        }),
        trackOutlineWidth:
            const WidgetStatePropertyAll(AppElevation.borderWidth),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.syndicateCrimson;
          }
          return AppColors.charcoalCardTier1;
        }),
        checkColor: const WidgetStatePropertyAll(AppColors.pureWhite),
        overlayColor: const WidgetStatePropertyAll(AppColors.crimsonOverlay),
        side: WidgetStateBorderSide.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const BorderSide(
              color: AppColors.syndicateCrimson,
              width: AppElevation.borderWidth,
            );
          }
          return const BorderSide(
            color: AppColors.mutedSlateSilver,
            width: AppElevation.borderWidth,
          );
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
