import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'core/theme/app_theme.dart';
import 'features/game/presentation/cubit/game_cubit.dart';
import 'features/game/presentation/pages/home_screen.dart';

Future<void> main() async {
  final WidgetsBinding widgetsBinding =
      WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
  ]);
  SystemChrome.setSystemUIOverlayStyle(AppTheme.systemUiOverlayStyle);
  runApp(const BarberSyncApp());
  FlutterNativeSplash.remove();
}

class BarberSyncApp extends StatelessWidget {
  const BarberSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GameCubit>(
      create: (_) => GameCubit()..loadSavedSettings(),
      child: MaterialApp(
        title: 'مافيا',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        locale: const Locale('ar'),
        supportedLocales: const [
          Locale('ar'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (BuildContext context, Widget? child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: const HomeScreen(),
      ),
    );
  }
}
