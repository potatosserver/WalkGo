import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'app_router.dart';
import 'constants.dart';
import 'l10n/app_localizations.dart';
import 'services/background_service.dart';
import 'services/device_id_service.dart';
import 'services/notification_service.dart';
import 'services/language_service.dart';
import 'services/log_service.dart';
import 'services/update_service.dart';
import 'theme_provider.dart';
import 'viewmodels/advanced_settings_viewmodel.dart';
import 'viewmodels/home_page_viewmodel.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
void onDidReceiveNotificationResponse(
  NotificationResponse notificationResponse,
) async {
  if (notificationResponse.actionId == 'notification_toggled') {
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
      'notification_next_run': l10n.notification_next_run('{time}'),
      'notification_service_running': l10n.notification_service_running,
      'background_service_start': l10n.background_service_start,
      'status_stopped':
          l10n.status_stopped,
      'status_ready_to_start':
          l10n.status_ready_to_start,
    };
    service.invoke('notification_toggled', localizedStrings);
  }
}

Future<void> initializeService(
  String initialTitle,
  String initialContent,
) async {
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
    iosConfiguration: IosConfiguration(autoStart: false, onForeground: onStart),
  );
}

Future<void> reportAppActive() async {
  try {
    final deviceData = await DeviceIdHelper.getDeviceInfo();
    final String deviceId = deviceData['id']!;
    final String deviceModel = deviceData['model']!;
    final String? fcmToken = await NotificationService.getFcmToken();

    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String appVersion = "${packageInfo.version}+${packageInfo.buildNumber}";

    const String rawChannel = String.fromEnvironment('UPDATE_CHANNEL', defaultValue: 'github');
    final String displayChannel = rawChannel == 'google_play' ? 'Google Play' : 'GitHub';

    await FirebaseFirestore.instance
        .collection('device_stats')
        .doc(deviceId)
        .set({
          'last_active': FieldValue.serverTimestamp(),
          'platform': 'Android ($displayChannel)',
          'device_model': deviceModel,
          'fcm_token': fcmToken ?? '',
          'app_version': appVersion,
        }, SetOptions(merge: true));
  } catch (e) {
    debugPrint('Error reporting app activity to Firestore: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

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
  final initialTitle = l10n.status_stopped;
  final initialContent = l10n.status_ready_to_start;

  await initializeService(initialTitle, initialContent);

  runApp(const WalkGoApp());
}

class WalkGoApp extends StatefulWidget {
  const WalkGoApp({super.key});

  @override
  State<WalkGoApp> createState() => _WalkGoAppState();
}

class _WalkGoAppState extends State<WalkGoApp> {
  @override
  void initState() {
    super.initState();
    _checkForUpdate();
  }

  Future<void> _checkForUpdate() async {
    if (updateChannel == 'google_play') {
      try {
        final updateInfo = await UpdateService().checkForUpdate();
        if (updateInfo is AppUpdateInfo &&
            updateInfo.updateAvailability ==
                UpdateAvailability.updateAvailable) {
          await UpdateService().startGooglePlayUpdate(updateInfo);
        }
      } catch (e) {
        // Silently fail on startup, user can manually check in settings
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appRouter = AppRouter();

    final dialogTheme = DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      titleTextStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    );

    final lightTheme = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.deepPurple,
      brightness: Brightness.light,
      dialogTheme: dialogTheme,
    );

    final darkTheme = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.deepPurple,
      brightness: Brightness.dark,
      dialogTheme: dialogTheme,
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
            Provider.of<HomePageViewModel>(context, listen: false),
          ),
          update: (context, homePageViewModel, previous) {
            if (previous != null) {
              previous.updateDependency(homePageViewModel);
              return previous;
            }
            return AdvancedSettingsViewModel(homePageViewModel);
          },
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
