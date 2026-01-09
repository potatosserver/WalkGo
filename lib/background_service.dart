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

  // Add these variables to hold the settings
  bool offsetEnabled = true;
  int offsetSteps = 50;
  bool autoPauseEnabled = false;
  int autoPauseThreshold = 50000;

  // Function to load all settings from SharedPreferences
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    offsetEnabled = prefs.getBool(prefOffsetEnabled) ?? true;
    offsetSteps = prefs.getInt(prefOffsetSteps) ?? 50;
    autoPauseEnabled = prefs.getBool(prefAutoPauseEnabled) ?? false;
    autoPauseThreshold = prefs.getInt(prefAutoPauseThreshold) ?? 50000;
  }

  Future<void> writeStepsLogic({String source = 'automatic'}) async {
    // Ensure settings are loaded before writing steps
    await loadSettings();
    
    final prefs = await SharedPreferences.getInstance();
    final baseSteps = prefs.getInt(prefBaseSteps) ?? 500;
    final random = Random();
    
    // Use the loaded settings
    final offset = offsetEnabled ? random.nextInt(offsetSteps * 2 + 1) - offsetSteps : 0;
    final steps = baseSteps + offset;

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
        // Use the new static method to write the log
        final total = await LogService.writeLogToStorage(steps, source: source);

        // Emit an event to notify the UI that the log has been updated
        service.invoke('log_updated');

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
        if (autoPauseEnabled && total >= autoPauseThreshold) {
          service.invoke('stop', {
            // You might want to pass specific localization for auto-pause
          });
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
  
  void restartTimer(int interval) {
      timer?.cancel();
      timer = Timer.periodic(Duration(minutes: interval), (timer) async {
        final prefs = await SharedPreferences.getInstance();
        final isAuto = prefs.getBool(prefIsAuto) ?? false;
        if (!isAuto) {
          timer.cancel();
          return;
        }
        
        await writeStepsLogic();

        final currentInterval = prefs.getInt(prefInterval) ?? 1;
        final nextRun = DateTime.now().add(Duration(minutes: currentInterval));
        final formattedTime = DateFormat('HH:mm').format(nextRun);
        final statusTitle = localizedStrings['notification_service_running'] ?? 'Service Running';
        final statusBody = (localizedStrings['notification_next_run'] ?? 'Next run at {time}').replaceAll('{time}', formattedTime);
        service.invoke('showStatusNotification', {
          'title': statusTitle,
          'body': statusBody,
        });
      });
  }

  service.on('start').listen((event) {
    if (event != null) {
      localizedStrings = Map<String, String>.from(event);
    }

    Future.delayed(Duration.zero, () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(prefIsAuto, true);

        // Load settings on start
        await loadSettings(); 

        await writeStepsLogic();

        final interval = prefs.getInt(prefInterval) ?? 1;
        restartTimer(interval);
    });
  });

  service.on('stop').listen((event) {
    Future.delayed(Duration.zero, () async {
      timer?.cancel();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(prefIsAuto, false);

      // When stopping, we don't need to use LogService anymore
      // as it's handled by the UI or other parts.
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

      // Update the UI with reset values
      service.invoke('update_ui', {
        'is_running': false,
        'session_total_steps': 0, // Explicitly send 0
        'status_log': localizedStrings['notification_service_stopped_content'],
      });
      service.stopSelf();
    });
  });

  // Listener for manual write
  service.on('write_now').listen((event) async {
    if (event != null) {
      localizedStrings = Map<String, String>.from(event);
    }
    await writeStepsLogic(source: 'manual');
  });

  // When settings are updated from the UI, reload them and notify the UI.
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
