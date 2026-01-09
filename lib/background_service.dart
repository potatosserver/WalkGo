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

  Timer? timer;
  Map<String, String> localizedStrings = {};
  int sessionTotalSteps = 0;

  bool offsetEnabled = true;
  int offsetSteps = 50;
  bool autoPauseEnabled = false;
  int autoPauseThreshold = 50000;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    offsetEnabled = prefs.getBool(prefOffsetEnabled) ?? true;
    offsetSteps = prefs.getInt(prefOffsetSteps) ?? 50;
    autoPauseEnabled = prefs.getBool(prefAutoPauseEnabled) ?? false;
    autoPauseThreshold = prefs.getInt(prefAutoPauseThreshold) ?? 50000;
  }

  Future<bool> checkAndStopIfNeeded() async {
    await loadSettings();
    final prefs = await SharedPreferences.getInstance();
    final baseSteps = prefs.getInt(prefBaseSteps) ?? 500;

    if (autoPauseEnabled && (sessionTotalSteps + baseSteps) > autoPauseThreshold) {
      timer?.cancel();
      await prefs.setBool(prefIsAuto, false);
      await prefs.remove(prefNextRunTime);

      final title = localizedStrings['auto_pause_notification_title'] ?? 'Service Automatically Paused';
      final body = (localizedStrings['auto_pause_notification_content_with_steps'] ?? 'Paused after reaching {steps} steps.').replaceAll('{steps}', sessionTotalSteps.toString());
      
      service.invoke('showStatusNotification', {
        'title': title,
        'body': body,
      });

      service.invoke('update_ui', {
        'is_running': false,
        'session_total_steps': sessionTotalSteps,
        'status_log': title,
        'next_run_time': null,
      });

      return true; // Indicates that the service WAS stopped
    }
    return false; // Indicates that the service should continue
  }

  Future<bool> writeStepsLogic({String source = 'automatic'}) async {
    await loadSettings();
    
    final prefs = await SharedPreferences.getInstance();
    final baseSteps = prefs.getInt(prefBaseSteps) ?? 500;
    
    int steps;
    if (source == 'manual') {
      steps = baseSteps; // Manual write uses base steps only
    } else { // For 'automatic' source
      final random = Random();
      final offset = offsetEnabled ? random.nextInt(offsetSteps * 2 + 1) - offsetSteps : 0;
      steps = baseSteps + offset; // Automatic write includes random offset
    }

    final completer = Completer<bool>();

    final subscription = service.on('write_steps_result').listen((event) {
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
        await LogService.writeLogToStorage(steps, source: source);
        service.invoke('log_updated');
        
        final confirmationTitle = localizedStrings['notification_steps_written_title'] ?? 'Steps Written';
        final confirmationBody = (localizedStrings['notification_steps_written'] ?? '{steps} steps written').replaceAll('{steps}', steps.toString());

        service.invoke('showConfirmationNotification', {
          'title': confirmationTitle,
          'body': confirmationBody,
        });

        if (source == 'automatic') {
          sessionTotalSteps += steps;
          await prefs.setInt(prefSessionTotalSteps, sessionTotalSteps);

          final stopped = await checkAndStopIfNeeded();
          if (stopped) {
            return true; 
          }

          final currentInterval = prefs.getInt(prefInterval) ?? 1;
          final nextRun = DateTime.now().add(Duration(minutes: currentInterval));
          final formattedTime = DateFormat('HH:mm').format(nextRun);
          await prefs.setString(prefNextRunTime, formattedTime);

          service.invoke('update_ui', {
            'session_total_steps': sessionTotalSteps,
            'is_running': true,
            'last_steps_written': steps,
            'status_log': (localizedStrings['automatic_write_success'] ?? 'Wrote {steps} steps').replaceAll('{steps}', steps.toString()),
            'next_run_time': formattedTime,
          });
        } else if (source == 'manual') {
            service.invoke('manual_write_complete', {'steps': steps});
        }
        
        return false;

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

  service.on('start').listen((event) {
    if (event != null) {
      localizedStrings = Map<String, String>.from(event);
    }

    Future.delayed(Duration.zero, () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(prefIsAuto, true);
      sessionTotalSteps = 0; // Always reset on start
      await prefs.setInt(prefSessionTotalSteps, 0);
      
      final bool wasStopped = await writeStepsLogic();

      if (!wasStopped) {
        final interval = prefs.getInt(prefInterval) ?? 1;
        restartTimer(interval);
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
      await prefs.setInt(prefSessionTotalSteps, 0);
      service.invoke('log_updated');

      if (event != null) {
        localizedStrings = Map<String, String>.from(event);
      }

      final title = localizedStrings['notification_service_stopped_title'] ?? 'Service Stopped';
      final body = localizedStrings['notification_service_stopped_content'] ?? 'Ready to start.';
      service.invoke('showStatusNotification', {
        'title': title,
        'body': body,
      });

      service.invoke('update_ui', {
        'is_running': false,
        'session_total_steps': 0,
        'last_steps_written': 0,
        'status_log': localizedStrings['notification_service_stopped_content'],
        'next_run_time': null,
      });
    });
  });

  service.on('write_now').listen((event) async {
    if (event != null) {
      localizedStrings = Map<String, String>.from(event);
    }
    await writeStepsLogic(source: 'manual');
  });

  service.on('update').listen((event) async {
    await loadSettings();
    service.invoke('settings_updated');
  });

  service.on('update_localization').listen((event) {
    if (event != null) {
      localizedStrings = Map<String, String>.from(event);
    }
  });
}
