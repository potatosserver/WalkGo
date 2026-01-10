import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walkgo/constants.dart';
import 'package:walkgo/health_service.dart';
import 'package:walkgo/log_service.dart';
import 'package:walkgo/services/error_log_service.dart';

@pragma('vm:entry-point')
void onStart(ServiceInstance service) {
  DartPluginRegistrant.ensureInitialized();

  final healthService = HealthService();

  Timer? timer;
  Map<String, String> localizedStrings = {};
  int sessionTotalSteps = 0;
  int lastStepsWritten = 0;

  // Service-isolate specific cache for all settings
  bool offsetEnabled = true;
  int offsetSteps = 50;
  int baseSteps = 500;
  int currentInterval = 1;
  bool autoPauseEnabled = false;
  int autoPauseThreshold = 5000;

  // --- FUNCTION DEFINITIONS (Must be defined before use) ---

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload(); // Force reload from disk, crucial for isolates
    offsetEnabled = prefs.getBool(prefOffsetEnabled) ?? true;
    offsetSteps = prefs.getInt(prefOffsetSteps) ?? 50;
    baseSteps = prefs.getInt(prefBaseSteps) ?? 500;
    currentInterval = prefs.getInt(prefInterval) ?? 1;
    autoPauseEnabled = prefs.getBool(prefAutoPauseEnabled) ?? false;
    autoPauseThreshold = prefs.getInt(prefAutoPauseThreshold) ?? 5000;
  }

  void updateNotification(String title, String content) {
    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: title,
        content: content,
      );
    }
  }

  Future<bool> checkAndStopIfNeeded() async {
    if (autoPauseEnabled && sessionTotalSteps >= autoPauseThreshold) {
      timer?.cancel();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(prefIsAuto, false);
      await prefs.remove(prefNextRunTime);
      await prefs.remove(prefLastStepsWritten);

      final title = localizedStrings['auto_pause_notification_title'] ??
          'Service Automatically Paused';
      final body =
          (localizedStrings['auto_pause_notification_content_with_steps'] ??
                  'Paused after reaching {steps} steps.')
              .replaceAll('{steps}', sessionTotalSteps.toString());

      updateNotification(title, body);

      service.invoke('update_ui', {
        'is_running': false,
        'session_total_steps': sessionTotalSteps,
        'last_steps_written': 0,
        'status_log': title,
        'next_run_time': null,
      });

      return true;
    }
    return false;
  }

  Future<bool> writeStepsLogic({String source = 'automatic'}) async {
    int steps;
    if (source == 'manual') {
      steps = baseSteps;
    } else {
      final random = Random();
      final offset =
          offsetEnabled ? random.nextInt(offsetSteps * 2 + 1) - offsetSteps : 0;
      steps = baseSteps + offset;
    }

    try {
      final bool success = await healthService.writeSteps(steps);

      if (success) {
        await LogService.writeLogToStorage(steps, source: source);
        service.invoke('log_updated');

        lastStepsWritten = steps;

        if (source == 'automatic') {
          sessionTotalSteps += steps;

          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt(prefSessionTotalSteps, sessionTotalSteps);
          await prefs.setInt(prefLastStepsWritten, lastStepsWritten);

          final stopped = await checkAndStopIfNeeded();
          if (stopped) {
            return true;
          }

          final statusLog = (localizedStrings['automatic_write_success'] ??
                  'Wrote {steps} steps')
              .replaceAll('{steps}', steps.toString());

          final nextRun =
              DateTime.now().add(Duration(minutes: currentInterval));
          final formattedTime = DateFormat('HH:mm').format(nextRun);
          await prefs.setString(prefNextRunTime, formattedTime);

          final nextRunBody = (localizedStrings['notification_next_run'] ??
                  'Next run at {time}')
              .replaceAll('{time}', formattedTime);
          final combinedNotificationBody = '$statusLog, $nextRunBody';

          updateNotification(
            localizedStrings['notification_service_running'] ??
                'Service Running',
            combinedNotificationBody,
          );

          service.invoke('update_ui', {
            'session_total_steps': sessionTotalSteps,
            'is_running': true,
            'last_steps_written': lastStepsWritten,
            'status_log': statusLog,
            'next_run_time': formattedTime,
          });
        } else if (source == 'manual') {
          service.invoke('manual_write_complete', {'steps': steps});
        }

        return false;
      } else {
        ErrorLogService().addErrorLog('[BackgroundService] Health write failed',
            'Received failure from health service.');
        final errorLog = localizedStrings['write_fail_check_log'] ??
            'Write failed. Check logs.';
        updateNotification(
          localizedStrings['notification_service_running'] ?? 'Service Running',
          errorLog,
        );
        service.invoke('update_ui', {
          'is_running': true,
          'status_log': errorLog,
        });
      }
    } catch (e) {
      ErrorLogService()
          .addErrorLog('[BackgroundService] Error writing steps', e.toString());
      final errorLog = localizedStrings['write_fail_check_log'] ??
          'Write failed. Check logs.';
      updateNotification(
        localizedStrings['notification_service_running'] ?? 'Service Running',
        errorLog,
      );
      service.invoke('update_ui', {
        'is_running': true,
        'status_log': errorLog,
      });
    }
    return false;
  }

  void restartTimer(int interval) {
    timer?.cancel();
    timer = Timer.periodic(Duration(minutes: interval), (timer) async {
      final bool wasStopped = await writeStepsLogic();
      if (wasStopped) {
        timer.cancel();
      }
    });
  }

  Future<void> initializeOrRestoreState() async {
    await loadSettings();
    final prefs = await SharedPreferences.getInstance();
    final isAutoRunning = prefs.getBool(prefIsAuto) ?? false;

    if (isAutoRunning) {
      sessionTotalSteps = prefs.getInt(prefSessionTotalSteps) ?? 0;
      lastStepsWritten = prefs.getInt(prefLastStepsWritten) ?? 0;

      if (timer == null || !timer!.isActive) {
        restartTimer(currentInterval);
      }
    } else {
      sessionTotalSteps = 0;
      lastStepsWritten = 0;
      await prefs.remove(prefNextRunTime);
    }
  }

  // --- SERVICE INITIALIZATION AND EVENT LISTENERS ---

  initializeOrRestoreState();

  service.on('start').listen((event) {
    if (event != null) {
      localizedStrings = Map<String, String>.from(event);
    }

    Future.delayed(Duration.zero, () async {
      await loadSettings();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(prefIsAuto, true);

      sessionTotalSteps = 0;
      lastStepsWritten = 0;
      await prefs.setInt(prefSessionTotalSteps, 0);
      await prefs.setInt(prefLastStepsWritten, 0);

      if (timer == null || !timer!.isActive) {
        final bool wasStoppedInitially = await writeStepsLogic();

        if (!wasStoppedInitially) {
          restartTimer(currentInterval);
        }
      }
    });
  });

  service.on('stop').listen((event) {
    Future.delayed(Duration.zero, () async {
      timer?.cancel();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(prefIsAuto, false);
      await prefs.remove(prefNextRunTime);

      sessionTotalSteps = 0;
      lastStepsWritten = 0;
      await prefs.setInt(prefSessionTotalSteps, 0);
      await prefs.setInt(prefLastStepsWritten, 0);
      service.invoke('log_updated');

      if (event != null) {
        localizedStrings = Map<String, String>.from(event);
      }

      final title = localizedStrings['notification_service_stopped_title'] ??
          'Service Stopped';
      final body = localizedStrings['notification_service_stopped_content'] ??
          'Ready to start.';

      updateNotification(title, body);

      service.invoke('update_ui', {
        'is_running': false,
        'session_total_steps': 0,
        'last_steps_written': 0,
        'status_log': body,
        'next_run_time': null,
      });
    });
  });

  service.on('write_now').listen((event) async {
    if (event != null) {
      localizedStrings = Map<String, String>.from(event);
    }
    await loadSettings();
    await writeStepsLogic(source: 'manual');
  });

  service.on('update').listen((event) async {
    final int oldInterval = currentInterval;
    await loadSettings();

    final prefs = await SharedPreferences.getInstance();
    final isAutoRunning = prefs.getBool(prefIsAuto) ?? false;

    if (isAutoRunning && oldInterval != currentInterval) {
      restartTimer(currentInterval);
    }

    service.invoke('settings_updated');
  });

  service.on('update_localization').listen((event) {
    if (event != null) {
      localizedStrings = Map<String, String>.from(event);
    }
  });
}
