import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:walkgo/language_service.dart';
import 'package:walkgo/router/app_router.dart';
import 'package:walkgo/theme_provider.dart';
import 'l10n/app_localizations.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageService()),
      ],
      child: Consumer2<ThemeProvider, LanguageService>(
        builder: (context, themeProvider, languageService, child) {
          return MaterialApp.router(
            routerConfig: AppRouter.router,
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
      ),
    );
  }
}
