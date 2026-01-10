import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walkgo/background_service.dart';
import 'package:walkgo/constants.dart';
import 'package:walkgo/l10n/app_localizations.dart';
import 'package:walkgo/language_service.dart';
import 'package:walkgo/log_service.dart';
import 'package:walkgo/router/app_router.dart';
import 'package:walkgo/theme_provider.dart';
import 'package:walkgo/viewmodels/advanced_settings_viewmodel.dart';
import 'package:walkgo/viewmodels/home_page_viewmodel.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false,
      isForegroundMode: true,
      notificationChannelId: foregroundChannelId,
      initialNotificationTitle: '服務已停止',
      initialNotificationContent: '準備就緒，等待您開啟自動模式。',
      foregroundServiceNotificationId: foregroundNotificationId,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
    ),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  await initializeService();

  final service = FlutterBackgroundService();
  await service.startService();

  final prefs = await SharedPreferences.getInstance();

  runApp(WalkGoApp(prefs: prefs));
}

class WalkGoApp extends StatelessWidget {
  final AppRouter appRouter = AppRouter();

  final SharedPreferences prefs;

  WalkGoApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    final lightTheme = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.deepPurple,
      brightness: Brightness.light,
    );

    final darkTheme = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.deepPurple,
      brightness: Brightness.dark,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageService()),
        ChangeNotifierProvider(create: (_) => AdvancedSettingsViewModel()),
        ChangeNotifierProvider(create: (_) => HomePageViewModel()),
        ChangeNotifierProvider(create: (_) => LogService()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return Consumer<LanguageService>(
            builder: (context, languageService, child) {
              return MaterialApp.router(
                routerConfig: appRouter.router,
                title: 'WalkGo',
                theme: lightTheme,
                darkTheme: darkTheme,
                themeMode: themeProvider.themeMode,
                locale: languageService.appLocale ?? Locale(prefs.getString(prefLanguageCode) ?? 'en'),
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: AppLocalizations.supportedLocales,
              );
            },
          );
        },
      ),
    );
  }
}
