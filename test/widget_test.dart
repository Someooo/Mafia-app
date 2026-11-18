import 'package:barber_sync/core/theme/app_colors.dart';
import 'package:barber_sync/core/theme/app_theme.dart';
import 'package:barber_sync/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Obsidian Syndicate single dark theme and fixed Arabic RTL',
      (WidgetTester tester) async {
    await tester.pumpWidget(const BarberSyncApp());

    final BuildContext context = tester.element(find.text('المافيا'));
    expect(Directionality.of(context), TextDirection.rtl);
    expect(Localizations.localeOf(context), const Locale('ar'));
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(Theme.of(context).scaffoldBackgroundColor, AppColors.obsidianCanvas);
    expect(
      Theme.of(context).extension<SyndicateColorsExtension>(),
      SyndicateColorsExtension.instance,
    );
    expect(AppTheme.theme.useMaterial3, isTrue);
  });
}
