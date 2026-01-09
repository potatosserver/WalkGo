import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walkgo/constants.dart';
import 'package:walkgo/log_service.dart';
import 'package:walkgo/services/error_log_service.dart';

@pragma('vm:entry-point')
void onStart(ServiceInstance service) {
  DartPluginRegistrant.ensureInitialized();

  final logService = LogService();
  Timer? timer;
  Map<String, String> localizedStrings = {};

  // --- Helper Functions ---

  void stopService({String? statusLog}) async {
    timer?.cancel();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefIsAuto, false);
    await logService.resetLogs(); // Reset session steps

    final title = localizedStrings['notification_service_stopped_title'] ?? 'Service Stopped';
    final body = localizedStrings['notification_service_stopped_content'] ?? 'Ready to start.';
    service.invoke('showStatusNotification', {
      'title': title,
      'body': body,
    });

    service.invoke('update_ui', {
      'is_running': false,
      'session_total_steps': 0,
      'status_log': statusLog, // Can be null, UI will handle it
    });
  }

  Future<void> writeStepsLogic() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if service should be running
    final isAuto = prefs.getBool(prefIsAuto) ?? false;
    if (!isAuto) {
      timer?.cancel();
      return;
    }

    // Read settings for this run
    final baseSteps = prefs.getInt(prefBaseSteps) ?? 500;
    final offsetEnabled = prefs.getBool(prefOffsetEnabled) ?? true;
    final offsetSteps = prefs.getInt(prefOffsetSteps) ?? 50;
    final random = Random();
    final offset = offsetEnabled ? random.nextInt(offsetSteps * 2 + 1) - offsetSteps : 0;
    final steps = max(0, baseSteps + offset); // Ensure steps are not negative

    final completer = Completer<bool>();
    StreamSubscription? subscription;

    subscription = service.on('write_steps_result').listen((event) {
      final success = event?['success'] as bool? ?? false;
      if (!completer.isCompleted) {
        completer.complete(success);
      }
    });

    service.invoke('write_steps', {'steps': steps});

    try {
      final bool success = await completer.future.timeout(const Duration(seconds: 15));
      subscription.cancel();

      if (success) {
        final total = await logService.addLog(steps);
        final confirmationTitle = localizedStrings['notification_steps_written_title'] ?? 'Steps Written';
        final confirmationBody = (localizedStrings['notification_steps_written'] ?? '{steps} steps written').replaceAll('{steps}', steps.toString());

        service.invoke('showConfirmationNotification', {
          'title': confirmationTitle,
          'body': confirmationBody,
        });

        service.invoke('update_ui', {
          'session_total_steps': total,
          'is_running': true,
          'status_log': (localizedStrings['automatic_write_success'] ?? 'Wrote {steps} steps').replaceAll('{steps}', steps.toString()),
        });

        // Check for auto-pause
        final autoPauseEnabled = prefs.getBool(prefAutoPauseEnabled) ?? false;
        if (autoPauseEnabled) {
          final autoPauseThreshold = prefs.getInt(prefAutoPauseThreshold) ?? 50000;
          if (total >= autoPauseThreshold) {
            final statusLog = (localizedStrings['auto_pause_notification_content_with_steps'] ?? 'Reached {steps} steps, service stopped.').replaceAll('{steps}', total.toString());
            final notificationTitle = localizedStrings['auto_pause_notification_title'] ?? 'Auto Paused';
            
            service.invoke('showStatusNotification', {
              'title': notificationTitle,
              'body': statusLog,
            });
            stopService(statusLog: statusLog);
          }
        }

      } else {
        ErrorLogService().addErrorLog('[BackgroundService] Health write failed', 'Received failure from main isolate.');
        service.invoke('update_ui', {
          'is_running': true,
          'status_log': localizedStrings['write_fail_check_log'] ?? 'Write failed. Check logs.',
        });
      }
    } catch (e) {
      subscription.cancel();
      ErrorLogService().addErrorLog('[BackgroundService] Error writing steps', e.toString());
      service.invoke('update_ui', {
        'is_running': true,
        'status_log': localizedStrings['write_fail_check_log'] ?? 'Write failed. Check logs.',
      });
    }
  }
  
  void restartTimer() async {
      timer?.cancel();
      final prefs = await SharedPreferences.getInstance();
      final interval = prefs.getInt(prefInterval) ?? 1;

      timer = Timer.periodic(Duration(minutes: interval), (timer) async {
        await writeStepsLogic();

        // Update next run notification
        final prefs = await SharedPreferences.getInstance();
        final isAuto = prefs.getBool(prefIsAuto) ?? false;
        if (isAuto) {
            final currentInterval = prefs.getInt(prefInterval) ?? 1;
            final nextRun = DateTime.now().add(Duration(minutes: currentInterval));
            final formattedTime = DateFormat('HH:mm').format(nextRun);
            final statusTitle = localizedStrings['notification_service_running'] ?? 'Service Running';
            final statusBody = (localizedStrings['notification_next_run'] ?? 'Next run at {time}').replaceAll('{time}', formattedTime);
            service.invoke('showStatusNotification', {
              'title': statusTitle,
              'body': statusBody,
            });
        } else {
            timer.cancel();
        }
      });
  }

  // --- Service Event Handlers ---

  service.on('start').listen((event) async {
    if (event != null) {
      localizedStrings = Map<String, String>.from(event);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefIsAuto, true);
    await logService.resetLogs(); // IMPORTANT: Reset logs on start

    restartTimer();

    final title = localizedStrings['notification_service_running'] ?? 'Service Running';
    final body = localizedStrings['background_service_start'] ?? 'Background service has started.';
    
    service.invoke('showStatusNotification', {
      'title': title,
      'body': body,
    });

    service.invoke('update_ui', {
      'is_running': true,
      'session_total_steps': 0,
      'status_log': body,
    });
  });

  service.on('write_now').listen((event) {
    if (event != null) {
      localizedStrings = Map<String, String>.from(event);
    }
    writeStepsLogic();
  });

  service.on('stop').listen((event) {
     if (event != null) {
      localizedStrings = Map<String, String>.from(event);
    }
    stopService();
  });

  service.on('update').listen((event) async {
    final prefs = await SharedPreferences.getInstance();
    final isRunning = prefs.getBool(prefIsAuto) ?? false;

    // Only perform checks if the service is currently supposed to be running.
    if (isRunning) {
      final total = prefs.getInt(prefSessionTotalSteps) ?? 0;
      final autoPauseEnabled = prefs.getBool(prefAutoPauseEnabled) ?? false;

      if (autoPauseEnabled) {
        final autoPauseThreshold = prefs.getInt(prefAutoPauseThreshold) ?? 50000;
        if (total >= autoPauseThreshold) {
          final statusLog = (localizedStrings['auto_pause_notification_content_with_steps'] ?? 'Reached {steps} steps, service stopped.').replaceAll('{steps}', total.toString());
          final notificationTitle = localizedStrings['auto_pause_notification_title'] ?? 'Auto Paused';
          
          service.invoke('showStatusNotification', {
            'title': notificationTitle,
            'body': statusLog,
          });
          stopService(statusLog: statusLog);
          return; // Stop further processing as the service is now stopped
        }
      }
      
      // If not auto-paused, just restart the timer to apply new interval.
      restartTimer();
    }
  });

  service.on('update_localization').listen((event) {
    if (event != null) {
      localizedStrings = Map<String, String>.from(event);
    }
  });
}
