import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Obsidian Syndicate typography tokens built exclusively on IBM Plex Sans Arabic.
///
/// Enforces Arabic typesetting rules from DESIGN.md:
/// - Default RTL directionality and right-aligned text hierarchy
/// - Strictly `fontStyle: FontStyle.normal` (zero faux italics)
/// - Generous line heights to prevent clipping Arabic ascenders/descenders
/// - Crisp Western Arabic numerals (`0-9`) via lining figures
abstract final class AppTypography {
  static const TextDirection textDirection = TextDirection.rtl;
  static const TextAlign defaultTextAlign = TextAlign.right;

  static const List<FontFeature> _numeralFeatures = [
    FontFeature.liningFigures(),
  ];

  static TextStyle _plexArabic({
    required double fontSize,
    required double lineHeight,
    required FontWeight fontWeight,
    Color? color,
  }) {
    return GoogleFonts.ibmPlexSansArabic(
      fontSize: fontSize,
      height: lineHeight / fontSize,
      fontWeight: fontWeight,
      fontStyle: FontStyle.normal,
      color: color,
      fontFeatures: _numeralFeatures,
    );
  }

  /// 40px / 48px, w700 (`display-lg`)
  static TextStyle get displayLarge => _plexArabic(
        fontSize: 40,
        lineHeight: 48,
        fontWeight: FontWeight.w700,
        color: AppColors.pureWhite,
      );

  /// 32px / 40px, w700 (`display-lg-mobile`)
  static TextStyle get displayMedium => _plexArabic(
        fontSize: 32,
        lineHeight: 40,
        fontWeight: FontWeight.w700,
        color: AppColors.pureWhite,
      );

  /// 28px / 36px, w700 (`headline-lg`)
  static TextStyle get headlineLarge => _plexArabic(
        fontSize: 28,
        lineHeight: 36,
        fontWeight: FontWeight.w700,
        color: AppColors.pureWhite,
      );

  /// 22px / 30px, w600 (`headline-md`)
  static TextStyle get headlineMedium => _plexArabic(
        fontSize: 22,
        lineHeight: 30,
        fontWeight: FontWeight.w600,
        color: AppColors.pureWhite,
      );

  /// 18px / 26px, w600 (`headline-sm`)
  static TextStyle get headlineSmall => _plexArabic(
        fontSize: 18,
        lineHeight: 26,
        fontWeight: FontWeight.w600,
        color: AppColors.pureWhite,
      );

  /// 16px / 24px, w400 (`body-lg`)
  static TextStyle get bodyLarge => _plexArabic(
        fontSize: 16,
        lineHeight: 24,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurface,
      );

  /// 14px / 20px, w400 (`body-md`)
  static TextStyle get bodyMedium => _plexArabic(
        fontSize: 14,
        lineHeight: 20,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurface,
      );

  /// 12px / 18px, w400 (`body-sm`)
  static TextStyle get bodySmall => _plexArabic(
        fontSize: 12,
        lineHeight: 18,
        fontWeight: FontWeight.w400,
        color: AppColors.mutedSlateSilver,
      );

  /// 14px / 20px, w600 (`label-lg`)
  static TextStyle get labelLarge => _plexArabic(
        fontSize: 14,
        lineHeight: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.pureWhite,
      );

  /// 12px / 16px, w500 (`label-md`)
  static TextStyle get labelMedium => _plexArabic(
        fontSize: 12,
        lineHeight: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.mutedSlateSilver,
      );

  /// 10px / 14px, w500 (`label-sm`)
  static TextStyle get labelSmall => _plexArabic(
        fontSize: 10,
        lineHeight: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.mutedSlateSilver,
      );

  static TextTheme get textTheme {
    final baseTheme = TextTheme(
      displayLarge: displayLarge,
      displayMedium: displayMedium,
      headlineLarge: headlineLarge,
      headlineMedium: headlineMedium,
      headlineSmall: headlineSmall,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelLarge: labelLarge,
      labelMedium: labelMedium,
      labelSmall: labelSmall,
    );

    return GoogleFonts.ibmPlexSansArabicTextTheme(baseTheme).apply(
      bodyColor: AppColors.onSurface,
      displayColor: AppColors.pureWhite,
    );
  }
}
