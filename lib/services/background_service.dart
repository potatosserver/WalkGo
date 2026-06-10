import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math';
import 'dart:ui';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../main.dart'; // For flutterLocalNotificationsPlugin
import 'health_service.dart';
import 'log_utils.dart';
import 'error_log_service.dart';

@pragma('vm:entry-point')
void onStart(ServiceInstance service) {
  DartPluginRegistrant.ensureInitialized();

  final healthService = HealthService();

  Timer? timer;
  Map<String, String> localizedStrings = {};
  int sessionTotalSteps = 0;
  int lastStepsWritten = 0;
  bool isRunning = false;

  bool offsetEnabled = true;
  int offsetSteps = 50;
  int baseSteps = 500;
  int currentInterval = 1;
  bool autoPauseEnabled = false;
  int autoPauseThreshold = 5000;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    offsetEnabled = prefs.getBool(prefOffsetEnabled) ?? true;
    offsetSteps = prefs.getInt(prefOffsetSteps) ?? 50;
    baseSteps = prefs.getInt(prefBaseSteps) ?? 500;
    currentInterval = prefs.getInt(prefInterval) ?? 1;
    autoPauseEnabled = prefs.getBool(prefAutoPauseEnabled) ?? false;
    autoPauseThreshold = prefs.getInt(prefAutoPauseThreshold) ?? 5000;

    if (!isRunning) {
      sessionTotalSteps = prefs.getInt(prefSessionTotalSteps) ?? 0;
      lastStepsWritten = prefs.getInt(prefLastStepsWritten) ?? 0;
    }
  }

  Future<void> showCustomNotification(String title, String content,
      {required bool isRunning}) async {
    final buttonLabel = isRunning
        ? (localizedStrings['notification_stop_button'] ?? 'Stop')
        : (localizedStrings['notification_start_button'] ?? 'Start');

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      foregroundChannelId,
      'WalkGo Service',
      channelDescription: 'This channel is used for the WalkGo service.',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'toggle_service', // Positional argument 1: id
          buttonLabel,      // Positional argument 2: title
          showsUserInterface: true,
        ),
      ],
    );

    final NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      id: foregroundNotificationId,
      title: title,
      body: content,
      notificationDetails: platformDetails,
    );
  }

  void broadcastUIUpdate({String? statusLog}) {
    String? nextRunTime;
    if (isRunning) {
      final nextRun = DateTime.now().add(Duration(minutes: currentInterval));
      nextRunTime = DateFormat('HH:mm').format(nextRun);
    }

    service.invoke('update_ui', {
      'is_running': isRunning,
      'session_total_steps': sessionTotalSteps,
      'last_steps_written': lastStepsWritten,
      'next_run_time': nextRunTime,
      if (statusLog != null) 'status_log': statusLog,
    });
  }

  Future<bool> checkAndStopIfNeeded() async {
    if (autoPauseEnabled && sessionTotalSteps >= autoPauseThreshold) {
      timer?.cancel();
      isRunning = false;

      final title = localizedStrings['auto_pause_notification_title'] ??
          'Service Automatically Paused';
      final body =
          (localizedStrings['auto_pause_notification_content_with_steps'] ??
                  'Paused after reaching {steps} steps.')
              .replaceAll('{steps}', sessionTotalSteps.toString());

      showCustomNotification(title, body, isRunning: isRunning);
      broadcastUIUpdate(statusLog: title);

      return true;
    }
    return false;
  }

  Future<bool> writeStepsLogic({String source = 'automatic'}) async {
    final random = Random();
    final offset =
        offsetEnabled ? random.nextInt(offsetSteps * 2 + 1) - offsetSteps : 0;
    final steps = (source == 'manual') ? baseSteps : baseSteps + offset;

    try {
      final bool success = await healthService.writeSteps(steps);
      if (!success) {
        final errorLog =
            localizedStrings['write_fail_check_log'] ?? 'Write failed.';
        ErrorLogService().addErrorLog('[BackgroundService] Health write failed',
            'Received failure from health service.');
        broadcastUIUpdate(statusLog: errorLog);
        return false;
      }

      await LogUtils.writeLogFromBackground(steps, source: source);
      lastStepsWritten = steps;

      if (source == 'automatic') {
        sessionTotalSteps += steps;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(prefSessionTotalSteps, sessionTotalSteps);
      await prefs.setInt(prefLastStepsWritten, lastStepsWritten);

      service.invoke('log_updated');

      if (source == 'automatic') {
        final stopped = await checkAndStopIfNeeded();
        if (stopped) return true;

        final statusLog = (localizedStrings['automatic_write_success'] ??
                'Wrote {steps} steps')
            .replaceAll('{steps}', steps.toString());

        broadcastUIUpdate(statusLog: statusLog);

        final nextRunBody = (localizedStrings['notification_next_run'] ??
                'Next run at {time}')
            .replaceAll(
                '{time}',
                DateFormat('HH:mm').format(
                    DateTime.now().add(Duration(minutes: currentInterval))));
        showCustomNotification(
          localizedStrings['notification_service_running'] ?? 'Service Running',
          '$statusLog, $nextRunBody',
          isRunning: isRunning,
        );
      } else {
        final statusLog = (localizedStrings['automatic_write_success'] ??
                'Wrote {steps} steps')
            .replaceAll('{steps}', steps.toString());

        broadcastUIUpdate(statusLog: statusLog);
        service.invoke('manual_write_complete', {'steps': steps});
      }
      return false;
    } catch (e) {
      final errorLog =
          localizedStrings['write_fail_check_log'] ?? 'Write failed.';
      ErrorLogService()
          .addErrorLog('[BackgroundService] Error writing steps', e.toString());
      broadcastUIUpdate(statusLog: errorLog);
      return false;
    }
  }

  void restartTimer(int interval) {
    timer?.cancel();
    timer = Timer.periodic(Duration(minutes: interval), (timer) async {
      if (await writeStepsLogic()) {
        timer.cancel();
      }
    });
  }

  loadSettings().then((_) => broadcastUIUpdate());

  service.on('get_status').listen((event) async {
    developer.log('Received get_status event', name: 'WalkGo.Background');
    await loadSettings();
    broadcastUIUpdate();
  });

  service.on('start').listen((event) async {
    developer.log('Received start event', name: 'WalkGo.Background');
    if (isRunning) {
      developer.log('Service is already running, returning.', name: 'WalkGo.Background');
      broadcastUIUpdate();
      return;
    }
    if (event != null) localizedStrings = Map<String, String>.from(event);

    isRunning = true;
    sessionTotalSteps = 0;
    lastStepsWritten = 0;
    developer.log('Set isRunning to true', name: 'WalkGo.Background');

    await loadSettings();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(prefSessionTotalSteps, 0);
    await prefs.setInt(prefLastStepsWritten, 0);

    service.invoke('log_updated');
    final statusLog =
        localizedStrings['background_service_start'] ?? 'Service started.';
    broadcastUIUpdate(statusLog: statusLog);

    if (!(await writeStepsLogic())) {
      restartTimer(currentInterval);
    }
  });

  service.on('stop').listen((event) async {
    developer.log('Received stop event', name: 'WalkGo.Background');
    timer?.cancel();
    if (!isRunning) {
      developer.log('Service is not running, returning.', name: 'WalkGo.Background');
      broadcastUIUpdate();
      return;
    }
    isRunning = false;
    developer.log('Set isRunning to false', name: 'WalkGo.Background');
    if (event != null) localizedStrings = Map<String, String>.from(event);

    lastStepsWritten = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(prefLastStepsWritten, 0);

    final title = localizedStrings['notification_service_stopped_title'] ??
        'Service Stopped';
    final body = localizedStrings['notification_service_stopped_content'] ??
        'Ready to start.';
    showCustomNotification(title, body, isRunning: isRunning);
    broadcastUIUpdate(statusLog: body);
  });

  service.on('toggle_service').listen((event) {
    developer.log('Received toggle_service event, isRunning: $isRunning', name: 'WalkGo.Background');
    if (isRunning) {
      service.invoke('stop', event);
    } else {
      service.invoke('start', event);
    }
  });

  service.on('write_now').listen((event) async {
    developer.log('Received write_now event', name: 'WalkGo.Background');
    if (event != null) localizedStrings = Map<String, String>.from(event);
    await loadSettings();
    await writeStepsLogic(source: 'manual');
  });

  service.on('update').listen((event) async {
    developer.log('Received update event', name: 'WalkGo.Background');
    final int oldInterval = currentInterval;
    await loadSettings();
    if (isRunning && oldInterval != currentInterval) {
      restartTimer(currentInterval);
    }
    service.invoke('settings_updated');
    broadcastUIUpdate();
  });

  service.on('update_localization').listen((event) {
    developer.log('Received update_localization event', name: 'WalkGo.Background');
    if (event != null) {
      localizedStrings = Map<String, String>.from(event);
      if (isRunning) {
        final nextRun = DateTime.now().add(Duration(minutes: currentInterval));
        final nextRunTime = DateFormat('HH:mm').format(nextRun);
        final statusLog = (localizedStrings['automatic_write_success'] ??
                'Wrote {steps} steps')
            .replaceAll('{steps}', lastStepsWritten.toString());
        final nextRunBody = (localizedStrings['notification_next_run'] ??
                'Next run at {time}')
            .replaceAll('{time}', nextRunTime);
        showCustomNotification(
          localizedStrings['notification_service_running'] ?? 'Service Running',
          lastStepsWritten > 0 ? '$statusLog, $nextRunBody' : nextRunBody,
          isRunning: isRunning,
        );
      } else {
        final title = localizedStrings['notification_service_stopped_title'] ??
            'Service Stopped';
        final body = localizedStrings['notification_service_stopped_content'] ??
            'Ready to start.';
        showCustomNotification(title, body, isRunning: isRunning);
      }
    }
    broadcastUIUpdate();
  });

  service.on('app_detached').listen((event) {
    developer.log('Received app_detached event', name: 'WalkGo.Background');
    if (!isRunning) {
      service.stopSelf();
    }
  });
}
