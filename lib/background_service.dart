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

  Future<void> writeStepsLogic() async {
    final prefs = await SharedPreferences.getInstance();
    final baseSteps = prefs.getInt(prefBaseSteps) ?? 500;
    final random = Random();
    final offset = random.nextInt(101) - 50;
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

        final interval = prefs.getInt(prefInterval) ?? 1;
        restartTimer(interval);

        final nextRun = DateTime.now().add(Duration(minutes: interval));
        final formattedTime = DateFormat('HH:mm').format(nextRun);
        final title = localizedStrings['notification_service_running'] ?? 'Service Running';
        final body = (localizedStrings['notification_next_run'] ?? 'Next run at {time}').replaceAll('{time}', formattedTime);
        
        service.invoke('showStatusNotification', {
          'title': title,
          'body': body,
        });

        service.invoke('update_ui', {'is_running': true});
    });
  });

  service.on('write_now').listen((event) {
    if (event != null) {
      localizedStrings = Map<String, String>.from(event);
    }
    writeStepsLogic();
  });

  service.on('stop').listen((event) {
    Future.delayed(Duration.zero, () async {
      timer?.cancel();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(prefIsAuto, false);

      if (event != null) {
        localizedStrings = Map<String, String>.from(event);
      }

      final title = localizedStrings['notification_service_stopped_title'] ?? 'Service Stopped';
      final body = localizedStrings['notification_service_stopped_content'] ?? 'Ready to start.';
      service.invoke('showStatusNotification', {
        'title': title,
        'body': body,
      });

      service.invoke('update_ui', {'is_running': false});
    });
  });

  service.on('update').listen((event) {
    Future.delayed(Duration.zero, () async {
      final prefs = await SharedPreferences.getInstance();
      final interval = prefs.getInt(prefInterval) ?? 1;
      restartTimer(interval);
    });
  });

  service.on('update_localization').listen((event) {
    if (event != null) {
      localizedStrings = Map<String, String>.from(event);
    }
  });
}
