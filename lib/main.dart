import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'services/background_service.dart';
import 'constants.dart';
import 'l10n/app_localizations.dart';
import 'services/language_service.dart';
import 'services/log_service.dart';
import 'app_router.dart';
import 'theme_provider.dart';
import 'viewmodels/advanced_settings_viewmodel.dart';
import 'viewmodels/home_page_viewmodel.dart';

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

  runApp(const WalkGoApp());
}

class WalkGoApp extends StatelessWidget {
  const WalkGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = AppRouter();
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
                locale: languageService.appLocale,
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
