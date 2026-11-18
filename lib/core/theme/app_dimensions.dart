import 'package:flutter/material.dart';

import 'app_colors.dart';

/// 8-point spatial rhythm and component dimension tokens from DESIGN.md.
abstract final class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 36.0;
  static const double gutter = 16.0;
  static const double margin = 20.0;

  // Component-specific dimensions
  static const double rosterItemHeight = 56.0;
  static const double avatarSize = 36.0;
  static const double checkboxSize = 20.0;
  static const double countdownGaugeHeight = 2.0;
}

/// Tactical corner radius tokens from DESIGN.md.
abstract final class AppRadius {
  static const double sm = 2.0;
  static const double base = 4.0;
  static const double md = 6.0;
  static const double lg = 8.0;
  static const double xl = 12.0;
  static const double full = 9999.0;

  static final BorderRadius smAll = BorderRadius.circular(sm);
  static final BorderRadius baseAll = BorderRadius.circular(base);
  static final BorderRadius mdAll = BorderRadius.circular(md);
  static final BorderRadius lgAll = BorderRadius.circular(lg);
  static final BorderRadius xlAll = BorderRadius.circular(xl);
  static final BorderRadius fullAll = BorderRadius.circular(full);
}

/// Flat planar elevation and border-based tonal tier definitions.
abstract final class AppElevation {
  static const double none = 0.0;
  static const double borderWidth = 1.0;
  static const double backdropBlurSigma = 8.0;

  static const BoxShadow activeCardGlow = BoxShadow(
    color: AppColors.crimsonGlow,
    blurRadius: 16.0,
    spreadRadius: 0.0,
  );

  static BoxDecoration tier0Canvas = const BoxDecoration(
    color: AppColors.obsidianCanvas,
  );

  static BoxDecoration tier1RestingCard({
    double radius = AppRadius.lg,
  }) {
    return BoxDecoration(
      color: AppColors.charcoalCardTier1,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: AppColors.borderResting,
        width: borderWidth,
      ),
    );
  }

  static BoxDecoration tier2RaisedPanel({
    double radius = AppRadius.lg,
  }) {
    return BoxDecoration(
      color: AppColors.charcoalCardTier2,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: AppColors.borderRaised,
        width: borderWidth,
      ),
    );
  }

  static BoxDecoration tier3ActiveTarget({
    double radius = AppRadius.lg,
  }) {
    return BoxDecoration(
      color: AppColors.charcoalCardTier2,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: AppColors.syndicateCrimson,
        width: borderWidth,
      ),
      boxShadow: const [activeCardGlow],
    );
  }
}
