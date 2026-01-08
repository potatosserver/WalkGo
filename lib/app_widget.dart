import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:walkgo/language_service.dart';
import 'package:walkgo/router/app_router.dart';
import 'package:walkgo/theme_provider.dart';
import 'l10n/app_localizations.dart';

class MyApp extends StatefulWidget {
  final bool isFirstLaunch;
  const MyApp({super.key, required this.isFirstLaunch});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;
  // A GlobalKey is the ultimate way to preserve the state of a widget across rebuilds.
  final _appKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // The GoRouter instance is created only once in initState.
    _router = AppRouter(isFirstLaunch: widget.isFirstLaunch).router;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageService>(
      builder: (context, themeProvider, languageService, child) {
        // By assigning the GlobalKey, we tell Flutter that this is the same
        // MaterialApp instance, and it should preserve its state (like the
        // navigation stack) even when its properties (theme, locale) change.
        return MaterialApp.router(
          key: _appKey,
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
          title: 'WalkGo',
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.deepPurple,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
          themeMode: themeProvider.themeMode,
          locale: languageService.appLocale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        );
      },
    );
  }
}
