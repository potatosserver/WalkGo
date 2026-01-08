import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walkgo/app_widget.dart';
import 'package:walkgo/constants.dart';
import 'package:walkgo/health_service.dart';
import 'package:walkgo/log_service.dart';
import 'l10n/app_localizations.dart';
import 'utils/step_calculator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const platform = MethodChannel(channelName);
  platform.setMethodCallHandler((call) async {
    if (call.method == 'writeSteps') {
      final steps = call.arguments as int;
      return await HealthService().writeSteps(steps);
    }
  });

  await initializeService();
  runApp(const MyApp());
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  if (Platform.isAndroid) {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(foregroundChannel);
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(stepsUpdateChannel);
  }

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false,
      isForegroundMode: true,
      notificationChannelId: foregroundChannel.id,
      initialNotificationTitle: "WalkGo",
      initialNotificationContent: "Initializing...",
      foregroundServiceNotificationId: foregroundNotificationId,
    ),
    iosConfiguration: IosConfiguration(autoStart: false, onForeground: onStart),
  );
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  Timer? timer;
  AppLocalizations? l10n;

  if (Platform.isAndroid) {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(android: initializationSettingsAndroid),
    );
  }

  Future<void> loadL10n() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final langCode = prefs.getString(prefLanguageCode) ?? 'en';
    l10n = await AppLocalizations.delegate.load(Locale(langCode));
  }

  Future<void> updateNotificationAndUi() async {
    if (l10n == null) await loadL10n();
    final prefs = await SharedPreferences.getInstance();
    final isRunning = prefs.getBool(prefIsAuto) ?? false;

    String contentText;
    if (isRunning) {
      final nextRunTimestamp = prefs.getInt(prefNextRunTime);
      final nextRun = nextRunTimestamp != null
          ? DateTime.fromMillisecondsSinceEpoch(nextRunTimestamp)
          : null;

      if (nextRun != null) {
        final formattedTime = DateFormat('HH:mm').format(nextRun);
        contentText = l10n!.next_run_at(formattedTime);
      } else {
        contentText = l10n!.next_run_pending;
      }
    } else {
      contentText = l10n!.status_ready_to_start;
    }

    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        service.setForegroundNotificationInfo(
          title: isRunning ? l10n!.status_running : l10n!.status_stopped,
          content: contentText,
        );
      }
    }
    service.invoke(
        'update_ui', {"status_log": contentText, "is_running": isRunning});
  }

  await loadL10n();
  updateNotificationAndUi();

  service.on('start').listen((event) {
    timer?.cancel();

    Future<void> runAndSchedule() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      if (!(prefs.getBool(prefIsAuto) ?? false)) {
        timer?.cancel();
        updateNotificationAndUi();
        return;
      }

      if (l10n == null) await loadL10n();
      await executeStepWrite(
          service, flutterLocalNotificationsPlugin, l10n, prefs);

      final intervalMins = prefs.getInt(prefInterval) ?? 1;
      final nextRunTime = DateTime.now().add(Duration(minutes: intervalMins));
      await prefs.setInt(prefNextRunTime, nextRunTime.millisecondsSinceEpoch);
      updateNotificationAndUi();

      timer = Timer(Duration(minutes: intervalMins), runAndSchedule);
    }

    runAndSchedule();
  });

  service.on('stop').listen((event) async {
    timer?.cancel();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(prefNextRunTime);
    updateNotificationAndUi();
  });

  service.on('update').listen((event) async {
    await loadL10n();
    updateNotificationAndUi();
  });
}

Future<void> executeStepWrite(
    ServiceInstance service,
    FlutterLocalNotificationsPlugin plugin,
    AppLocalizations? l10n,
    SharedPreferences prefs) async {
  final logService = LogService();

  if (l10n == null) {
    debugPrint("[Background Error] Localization not loaded.");
    return;
  }

  final stepDetails = await calculateFinalSteps(prefs);
  final totalStepsToWrite = stepDetails['totalStepsToWrite']!;
  final originalSteps = stepDetails['originalSteps']!;
  final stepsAdded = stepDetails['stepsAdded']!;

  String notificationMessage;

  try {
    final bool success = await HealthService().writeSteps(totalStepsToWrite);

    if (success) {
      notificationMessage = l10n.automatic_write_success(totalStepsToWrite);
      await logService.addLog({
        'type': 'automatic',
        'originalSteps': originalSteps,
        'stepsAdded': stepsAdded,
        'totalStepsWritten': totalStepsToWrite,
      });

      final autoPauseEnabled = prefs.getBool(prefAutoPauseEnabled) ?? false;
      if (autoPauseEnabled) {
        final autoPauseSteps = prefs.getInt(prefAutoPauseSteps) ?? 50000;
        final currentSessionSteps =
            (prefs.getInt(prefSessionTotalSteps) ?? 0) + stepsAdded;
        await prefs.setInt(prefSessionTotalSteps, currentSessionSteps);

        if (currentSessionSteps >= autoPauseSteps) {
          await prefs.setBool(prefIsAuto, false);
          service.invoke('stop');
          plugin.show(
            stepsUpdateNotificationId + 1,
            l10n.auto_pause_notification_title,
            l10n.auto_pause_notification_content,
            NotificationDetails(
              android: AndroidNotificationDetails(
                stepsUpdateChannel.id,
                stepsUpdateChannel.name,
                channelDescription: stepsUpdateChannel.description,
                importance: Importance.defaultImportance,
                priority: Priority.defaultPriority,
              ),
            ),
          );
          return;
        }
      }
    } else {
      notificationMessage = l10n.write_fail_check_log;
    }
  } catch (e) {
    notificationMessage = l10n.write_error(e.toString());
    debugPrint("[Background Error] Error writing steps via channel: $e");
  }

  plugin.show(
    stepsUpdateNotificationId,
    l10n.notification_update_title,
    notificationMessage,
    NotificationDetails(
      android: AndroidNotificationDetails(
        stepsUpdateChannel.id,
        stepsUpdateChannel.name,
        channelDescription: stepsUpdateChannel.description,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        ongoing: false,
        autoCancel: true,
      ),
    ),
  );
}
