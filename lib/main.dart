
import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walkgo/app_widget.dart';
import 'package:walkgo/constants.dart';
import 'package:walkgo/health_service.dart';
import 'package:walkgo/language_service.dart';
import 'package:walkgo/log_service.dart';
import 'package:walkgo/services/error_log_service.dart';
// DO NOT import notification_helper.dart in this file for onStart
import 'package:walkgo/services/notification_helper.dart'; 
import 'package:walkgo/theme_provider.dart';

// Background service entry point
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  // NO NotificationHelper instance here.
  final logService = LogService();
  final healthService = HealthService();
  Timer? timer;

  Map<String, String> localizedStrings = {};

  service.on('start').listen((event) async {
    if (event != null) {
      localizedStrings = Map<String, String>.from(event);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefIsAuto, true);

    // --- Immediate First Write ---
    try {
      final baseSteps = prefs.getInt(prefBaseSteps) ?? 500;
      final random = Random();
      final offset = random.nextInt(101) - 50;
      final steps = baseSteps + offset;

      await healthService.writeSteps(steps);
      final total = await logService.addLog(steps);

      final confirmationTitle = localizedStrings['notification_steps_written_title'] ?? 'Steps Written';
      final confirmationBody = (localizedStrings['notification_steps_written'] ?? '{steps} steps written').replaceAll('{steps}', steps.toString());
      
      service.invoke('showNotification', {
        'title': confirmationTitle,
        'body': confirmationBody,
        'isStatus': false,
      });

      service.invoke('update_ui', {
        'session_total_steps': total,
        'is_running': true,
        'status_log': (localizedStrings['automatic_write_success'] ?? 'Wrote {steps} steps').replaceAll('{steps}', steps.toString()),
      });
    } catch (e) {
      ErrorLogService().addErrorLog('[BackgroundService] Error on initial step write', e.toString());
      service.invoke('update_ui', {
        'is_running': true,
        'status_log': localizedStrings['write_fail_check_log'] ?? 'Write failed. Check logs.',
      });
    }
    // --- End of Immediate First Write ---

    final interval = prefs.getInt(prefInterval) ?? 1;

    timer?.cancel();
    timer = Timer.periodic(Duration(minutes: interval), (timer) async {
      final isAuto = prefs.getBool(prefIsAuto) ?? false;
      if (!isAuto) {
        timer.cancel();
        return;
      }

      final baseSteps = prefs.getInt(prefBaseSteps) ?? 500;
      final random = Random();
      final offset = random.nextInt(101) - 50;
      final steps = baseSteps + offset;

      try {
        await healthService.writeSteps(steps);
        final total = await logService.addLog(steps);

        final confirmationTitle = localizedStrings['notification_steps_written_title'] ?? 'Steps Written';
        final confirmationBody = (localizedStrings['notification_steps_written'] ?? '{steps} steps written').replaceAll('{steps}', steps.toString());
        service.invoke('showNotification', {
          'title': confirmationTitle,
          'body': confirmationBody,
          'isStatus': false,
        });

        final nextRun = DateTime.now().add(Duration(minutes: interval));
        final formattedTime = DateFormat('HH:mm').format(nextRun);
        final statusTitle = localizedStrings['notification_service_running'] ?? 'Service Running';
        final statusBody = (localizedStrings['notification_next_run'] ?? 'Next run at {time}').replaceAll('{time}', formattedTime);
        service.invoke('showNotification', {
          'title': statusTitle,
          'body': statusBody,
          'isStatus': true,
        });

        service.invoke('update_ui', {
          'session_total_steps': total,
          'is_running': true,
          'status_log': (localizedStrings['automatic_write_success'] ?? 'Wrote {steps} steps').replaceAll('{steps}', steps.toString()),
        });
      } catch (e) {
        ErrorLogService().addErrorLog('[BackgroundService] Error writing steps', e.toString());
        service.invoke('update_ui', {
          'is_running': true,
          'status_log': localizedStrings['write_fail_check_log'] ?? 'Write failed. Check logs.',
        });
      }
    });

    final nextRun = DateTime.now().add(Duration(minutes: interval));
    final formattedTime = DateFormat('HH:mm').format(nextRun);
    final title = localizedStrings['notification_service_running'] ?? 'Service Running';
    final body = (localizedStrings['notification_next_run'] ?? 'Next run at {time}').replaceAll('{time}', formattedTime);
    service.invoke('showNotification', {
      'title': title,
      'body': body,
      'isStatus': true,
    });

    service.invoke('update_ui', {'is_running': true});
  });

  service.on('stop').listen((event) async {
    timer?.cancel();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefIsAuto, false);

    if (event != null) {
      localizedStrings = Map<String, String>.from(event);
    }

    final title = localizedStrings['notification_service_stopped_title'] ?? 'Service Stopped';
    final body = localizedStrings['notification_service_stopped_content'] ?? 'Ready to start.';
    service.invoke('showNotification', {
      'title': title,
      'body': body,
      'isStatus': true,
    });

    service.invoke('update_ui', {'is_running': false});
  });
}

// Main application entry point
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications in the main isolate
  await NotificationHelper().init();

  final prefs = await SharedPreferences.getInstance();
  final isFirstLaunch = prefs.getBool(prefIsFirstLaunch) ?? true;

  final service = FlutterBackgroundService();
  await service.configure(
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
    ),
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: false,
    ),
  );

  // Set up listener for notifications from the background service
  service.on('showNotification').listen((event) {
    if (event == null) return;
    final title = event['title'] as String?;
    final body = event['body'] as String?;
    final isStatus = event['isStatus'] as bool? ?? false;

    if (title != null && body != null) {
      if (isStatus) {
        NotificationHelper().showOrUpdateStatusNotification(title: title, body: body);
      } else {
        NotificationHelper().showWriteConfirmationNotification(title: title, body: body);
      }
    }
  });

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageService()),
      ],
      child: MyApp(isFirstLaunch: isFirstLaunch),
    ),
  );
}
