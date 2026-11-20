import 'package:barber_sync/core/theme/app_colors.dart';
import 'package:barber_sync/core/theme/app_theme.dart';
import 'package:barber_sync/features/game/domain/entities/game_role.dart';
import 'package:barber_sync/features/game/domain/services/role_shuffler.dart';
import 'package:barber_sync/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('RoleShuffler guarantees 4 mandatory roles and fills remaining with regular citizens', () {
    final deck = RoleShuffler.buildShuffledDeck(
      playerCount: 8,
      enabledOptionalRoleIds: const {'sniper', 'avenger_villager'},
    );

    expect(deck.length, 8);
    expect(deck.where((c) => c.role.id == GameRole.mafiaLeader.id).length, 1);
    expect(deck.where((c) => c.role.id == GameRole.silencerMafia.id).length, 1);
    expect(deck.where((c) => c.role.id == GameRole.citizensLeader.id).length, 1);
    expect(deck.where((c) => c.role.id == GameRole.medic.id).length, 1);
    expect(deck.where((c) => c.role.id == GameRole.sniper.id).length, 1);
    expect(deck.where((c) => c.role.id == GameRole.avengerVillager.id).length, 1);
    expect(deck.where((c) => c.role.id == GameRole.regularCitizen.id).length, 2);
  });

  testWidgets('HomeScreen renders Obsidian Syndicate theme, RTL, and navigates to SetupScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const BarberSyncApp());

    final BuildContext context = tester.element(find.text('مافيا'));
    expect(Directionality.of(context), TextDirection.rtl);
    expect(Localizations.localeOf(context), const Locale('ar'));
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(Theme.of(context).scaffoldBackgroundColor, AppColors.obsidianCanvas);
    expect(AppTheme.theme.useMaterial3, isTrue);

    expect(find.text('لعبة الذكاء والشك'), findsOneWidget);
    expect(find.text('لعبة جديدة'), findsOneWidget);
    expect(find.text('دليل الأدوار'), findsOneWidget);
  });
}
