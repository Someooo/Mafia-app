import 'package:flutter/widgets.dart';

import '../../domain/entities/game_role.dart';

/// Presentation-layer image cache pre-loader keeping `domain/` 100% pure Dart.
abstract final class GameAssetPrecacher {
  static bool _hasPrecachedGlobal = false;

  /// Pre-caches all 8 role card artworks, `card_back`, and branding logo into
  /// Flutter's [ImageCache] once per app lifecycle to eliminate frame drops
  /// or white flashes during 3D card flip animations.
  static Future<void> precacheAll(BuildContext context) async {
    if (_hasPrecachedGlobal) {
      return;
    }
    _hasPrecachedGlobal = true;
    for (final String assetPath in GameAssets.allCardAndBrandAssets) {
      if (!context.mounted) {
        return;
      }
      await precacheImage(
        AssetImage(assetPath),
        context,
        onError: (_, __) {},
      );
    }
  }
}
