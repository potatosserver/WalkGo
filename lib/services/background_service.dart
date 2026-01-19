import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import 'health_service.dart';
import 'log_service.dart';
import 'error_log_service.dart';

@pragma('vm:entry-point')
void onStart(ServiceInstance service) {
  DartPluginRegistrant.ensureInitialized();

  final healthService = HealthService();

  Timer? timer;
  Map<String, String> localizedStrings = {};
  int sessionTotalSteps = 0;
  int lastStepsWritten = 0;
  // Authoritative state for the service, IN-MEMORY ONLY.
  // This ensures that if the service is killed and restarted by the OS, it starts clean.
  bool isRunning = false;

  // Service-isolate specific cache for all settings
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
    // Load non-running state from prefs, but not isRunning state
    sessionTotalSteps = prefs.getInt(prefSessionTotalSteps) ?? 0;
    lastStepsWritten = prefs.getInt(prefLastStepsWritten) ?? 0;
  }

  void updateNotification(String title, String content) {
    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: title,
        content: content,
      );
    }
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

      updateNotification(title, body);
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
        final errorLog = localizedStrings['write_fail_check_log'] ?? 'Write failed.';
        ErrorLogService().addErrorLog('[BackgroundService] Health write failed',
            'Received failure from health service.');
        broadcastUIUpdate(statusLog: errorLog);
        return false;
      }

      await LogService.writeLogFromBackground(steps, source: source);
      service.invoke('log_updated');
      lastStepsWritten = steps;

      if (source == 'automatic') {
        sessionTotalSteps += steps;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(prefSessionTotalSteps, sessionTotalSteps);
        await prefs.setInt(prefLastStepsWritten, lastStepsWritten);

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
                DateFormat('HH:mm')
                    .format(DateTime.now().add(Duration(minutes: currentInterval))));
        updateNotification(
          localizedStrings['notification_service_running'] ?? 'Service Running',
          '$statusLog, $nextRunBody',
        );
      } else {
        service.invoke('manual_write_complete', {'steps': steps});
      }
      return false;
    } catch (e) {
      final errorLog = localizedStrings['write_fail_check_log'] ?? 'Write failed.';
      ErrorLogService().addErrorLog('[BackgroundService] Error writing steps', e.toString());
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

  // Initial setup when the service is first created.
  loadSettings().then((_) => broadcastUIUpdate());


  service.on('get_status').listen((event) => broadcastUIUpdate());

  service.on('start').listen((event) async {
    if (isRunning) {
      broadcastUIUpdate(); // Already running, just send current status
      return;
    }

    if (event != null) localizedStrings = Map<String, String>.from(event);
    await loadSettings();

    isRunning = true;

    // Reset counters on new start
    sessionTotalSteps = 0;
    lastStepsWritten = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(prefSessionTotalSteps, 0);
    await prefs.setInt(prefLastStepsWritten, 0);
    service.invoke('log_updated');

    final statusLog = localizedStrings['background_service_start'] ?? 'Service started.';
    broadcastUIUpdate(statusLog: statusLog);

    // Perform the first write immediately, then start the timer.
    if (!(await writeStepsLogic())) {
      restartTimer(currentInterval);
    }
  });

  service.on('stop').listen((event) async {
    timer?.cancel();
    if (!isRunning) {
      broadcastUIUpdate(); // Already stopped
      return;
    }

    isRunning = false;
    if (event != null) localizedStrings = Map<String, String>.from(event);

    lastStepsWritten = 0; // No steps are written on stop
    
    final title = localizedStrings['notification_service_stopped_title'] ?? 'Service Stopped';
    final body = localizedStrings['notification_service_stopped_content'] ?? 'Ready to start.';
    updateNotification(title, body);
    broadcastUIUpdate(statusLog: body);
  });

  service.on('write_now').listen((event) async {
    if (event != null) localizedStrings = Map<String, String>.from(event);
    await loadSettings();
    await writeStepsLogic(source: 'manual');
  });

  service.on('update').listen((event) async {
    final int oldInterval = currentInterval;
    await loadSettings();
    if (isRunning && oldInterval != currentInterval) {
      restartTimer(currentInterval);
    }
    service.invoke('settings_updated');
  });

  service.on('update_localization').listen((event) {
    if (event != null) localizedStrings = Map<String, String>.from(event);
  });
}
