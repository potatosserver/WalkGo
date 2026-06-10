import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/background_service.dart';
import 'constants.dart';
import 'l10n/app_localizations.dart';
import 'services/language_service.dart';
import 'services/log_service.dart';
import 'app_router.dart';
import 'theme_provider.dart';
import 'viewmodels/advanced_settings_viewmodel.dart';
import 'viewmodels/home_page_viewmodel.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
void onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse) async {
  if (notificationResponse.actionId == 'toggle_service') {
    final service = FlutterBackgroundService();
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString('languageCode');
    Locale locale;
    if (languageCode != null && languageCode.isNotEmpty) {
      locale = Locale(languageCode);
    } else {
      locale = PlatformDispatcher.instance.locale;
    }

    // Ensure it's a supported locale or fallback to English
    bool supported = false;
    for (var supportedLocale in AppLocalizations.supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        locale = supportedLocale;
        supported = true;
        break;
      }
    }
    if (!supported) {
      locale = const Locale('en');
    }

    final l10n = await AppLocalizations.delegate.load(locale);
    final localizedStrings = {
      'notification_stop_button': l10n.notification_stop_button,
      'notification_start_button': l10n.notification_start_button,
      'auto_pause_notification_title': l10n.auto_pause_notification_title,
      'auto_pause_notification_content_with_steps':
          l10n.auto_pause_notification_content_with_steps('{steps}'),
      'write_fail_check_log': l10n.write_fail_check_log,
      'automatic_write_success': l10n.automatic_write_success('{steps}'),
      'notification_next_run': l10n.notification_next_run('{time}'),
      'notification_service_running': l10n.notification_service_running,
      'background_service_start': l10n.background_service_start,
      'notification_service_stopped_title':
          l10n.notification_service_stopped_title,
      'notification_service_stopped_content':
          l10n.notification_service_stopped_content,
    };
    service.invoke('toggle_service', localizedStrings);
  }
}

Future<void> initializeService(
    String initialTitle, String initialContent) async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    foregroundChannelId,
    'WalkGo Service',
    description: 'This channel is used for the WalkGo service.',
    importance: Importance.low, // Set to low to avoid sound
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false,
      isForegroundMode: true,
      notificationChannelId: foregroundChannelId,
      initialNotificationTitle: initialTitle,
      initialNotificationContent: initialContent,
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

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    settings: initializationSettings,
    onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
  );

  // Load localization for background service initial notification
  final prefs = await SharedPreferences.getInstance();
  final String? languageCode = prefs.getString('languageCode');
  Locale locale;
  if (languageCode != null && languageCode.isNotEmpty) {
    locale = Locale(languageCode);
  } else {
    locale = PlatformDispatcher.instance.locale;
  }

  // Ensure it's a supported locale or fallback to English
  bool supported = false;
  for (var supportedLocale in AppLocalizations.supportedLocales) {
    if (supportedLocale.languageCode == locale.languageCode) {
      locale = supportedLocale;
      supported = true;
      break;
    }
  }
  if (!supported) {
    locale = const Locale('en');
  }

  final l10n = await AppLocalizations.delegate.load(locale);
  final initialTitle = l10n.notification_service_stopped_title;
  final initialContent = l10n.notification_service_stopped_content;

  await initializeService(initialTitle, initialContent);

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
        ChangeNotifierProvider(create: (_) => LogService()),
        ChangeNotifierProvider(create: (_) => HomePageViewModel()),
        ChangeNotifierProxyProvider<HomePageViewModel,
            AdvancedSettingsViewModel>(
          create: (context) => AdvancedSettingsViewModel(
              Provider.of<HomePageViewModel>(context, listen: false)),
          update: (context, homePageViewModel, previous) =>
              AdvancedSettingsViewModel(homePageViewModel),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return Consumer<LanguageService>(
            builder: (context, languageService, child) {
              return MaterialApp.router(
                routerConfig: appRouter.router,
                debugShowCheckedModeBanner: false,
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
