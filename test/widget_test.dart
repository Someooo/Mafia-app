import 'package:barber_sync/core/theme/app_colors.dart';
import 'package:barber_sync/core/theme/app_theme.dart';
import 'package:barber_sync/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets(
    'App boots in Arabic RTL with Obsidian Syndicate dark theme, renders HomeScreen, and navigates to SetupScreen',
    (WidgetTester tester) async {
      await tester.pumpWidget(const BarberSyncApp());
      await tester.pumpAndSettle();

      // Verify fixed Arabic locale & RTL directionality
      final BuildContext context = tester.element(find.text('مافيا'));
      expect(Directionality.of(context), TextDirection.rtl);
      expect(Localizations.localeOf(context), const Locale('ar'));

      // Verify single unified Obsidian Syndicate dark theme
      final ThemeData activeTheme = Theme.of(context);
      expect(activeTheme.brightness, Brightness.dark);
      expect(activeTheme.scaffoldBackgroundColor, AppColors.obsidianCanvas);
      expect(
        activeTheme.extension<SyndicateColorsExtension>(),
        SyndicateColorsExtension.instance,
      );
      expect(AppTheme.theme.useMaterial3, isTrue);

      // Verify HomeScreen content & CTAs
      expect(find.text('مافيا'), findsOneWidget);
      expect(find.text('لعبة الذكاء والشك'), findsOneWidget);
      expect(find.text('لعبة جديدة'), findsOneWidget);
      expect(find.text('دليل الأدوار'), findsOneWidget);

      // Navigate to SetupScreen via "لعبة جديدة"
      await tester.tap(find.text('لعبة جديدة'));
      await tester.pumpAndSettle();

      expect(find.text('إعداد الجولة'), findsOneWidget);
      expect(find.text('عدد اللاعبين'), findsOneWidget);
      expect(find.text('الأدوار الإجبارية'), findsOneWidget);
      expect(find.text('توزيع البطاقات'), findsOneWidget);
    },
  );
}
