import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walkgo/advanced_settings_page.dart';
import 'package:walkgo/health_service.dart';
import 'package:walkgo/language_service.dart';
import 'package:walkgo/log_service.dart';
import 'package:walkgo/permission_handler_page.dart';
import 'package:walkgo/settings_page.dart';
import 'package:walkgo/theme_provider.dart';
import 'package:walkgo/welcome_page.dart';
import 'l10n/app_localizations.dart';

// --- Method Channel ---
const platform = MethodChannel('com.walkgo/health');

// --- Global Variable Keys ---
const String prefIsAuto = "is_auto_running";
const String prefBaseSteps = "base_steps";
const String prefInterval = "interval_minutes";
const String prefPermissionsGranted = "permissions_granted";
const String prefIsFirstLaunch = "is_first_launch";
const String prefLanguageCode = "languageCode";
const String prefSessionTotalSteps = "session_total_steps"; // For auto-pause
const String prefOffsetEnabled = "offset_enabled";
const String prefOffset = "offset_steps"; // Corrected key
const String prefAutoPauseEnabled = "auto_pause_enabled";
const String prefAutoPauseSteps = "auto_pause_steps";
const String prefNextRunTime = "next_run_time";

// --- Notification Channels & IDs ---
const AndroidNotificationChannel foregroundChannel = AndroidNotificationChannel(
  'my_foreground',
  'WalkGo Background Service',
  description: 'This channel is used for the persistent service notification.',
  importance: Importance.low, // To be non-intrusive
);

const AndroidNotificationChannel stepsUpdateChannel = AndroidNotificationChannel(
  'steps_update',
  'Steps Write Updates',
  description: 'Shows the result of each automatic step write.',
  importance: Importance.defaultImportance, // Make it visible
);

const int foregroundNotificationId = 888;
const int stepsUpdateNotificationId = 999; // Fixed ID for overwriting

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Setup method channel handler in the main isolate
  platform.setMethodCallHandler((call) async {
    if (call.method == 'writeSteps') {
      final steps = call.arguments as int;
      return await HealthService().writeSteps(steps);
    }
  });

  await initializeService();
  runApp(const MyApp());
  
  final service = FlutterBackgroundService();
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getBool(prefPermissionsGranted) ?? false) {
    service.startService();
  }
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
    service.invoke('update_ui', {"status_log": contentText, "is_running": isRunning});
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
      await executeStepWrite(service, flutterLocalNotificationsPlugin, l10n, prefs);

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


Future<int> _calculateFinalSteps(SharedPreferences prefs) async {
  await prefs.reload();
  final baseSteps = prefs.getInt(prefBaseSteps) ?? 500;
  final offsetEnabled = prefs.getBool(prefOffsetEnabled) ?? false;
  if (!offsetEnabled) return baseSteps;
  final offset = prefs.getInt(prefOffset) ?? 50;
  final randomJitter = offset > 0 ? Random().nextInt(offset * 2 + 1) - offset : 0;
  final finalSteps = baseSteps + randomJitter;
  return finalSteps < 1 ? 1 : finalSteps;
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

  final finalSteps = await _calculateFinalSteps(prefs);
  String notificationMessage;

  try {
    final bool success = await platform.invokeMethod('writeSteps', finalSteps);

    if (success) {
      notificationMessage = l10n.automatic_write_success(finalSteps);
      await logService.addLog({'steps': finalSteps, 'type': 'automatic'});

      final autoPauseEnabled = prefs.getBool(prefAutoPauseEnabled) ?? false;
      if (autoPauseEnabled) {
        final autoPauseSteps = prefs.getInt(prefAutoPauseSteps) ?? 50000;
        final currentSessionSteps =
            (prefs.getInt(prefSessionTotalSteps) ?? 0) + finalSteps;
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageService()),
      ],
      child: Consumer2<ThemeProvider, LanguageService>(
        builder: (context, themeProvider, languageService, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'WalkGo',
            theme: ThemeData(
                useMaterial3: true,
                colorSchemeSeed: Colors.deepPurple,
                brightness: Brightness.light),
            darkTheme: ThemeData(
                useMaterial3: true,
                colorSchemeSeed: Colors.deepPurple,
                brightness: Brightness.dark),
            themeMode: themeProvider.themeMode,
            locale: languageService.appLocale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            initialRoute: '/',
            routes: {
              '/': (context) => const InitialPage(),
              '/home': (context) => const HomePage(),
              '/welcome': (context) => const WelcomePage(),
              '/permission': (context) => const PermissionHandlerPage(),
            },
          );
        },
      ),
    );
  }
}

class InitialPage extends StatefulWidget {
  const InitialPage({super.key});
  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  Future<String> _getInitialRoute() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bool isFirstLaunch = prefs.getBool(prefIsFirstLaunch) ?? true;
      if (isFirstLaunch) return '/welcome';
      final bool permissionsGranted =
          prefs.getBool(prefPermissionsGranted) ?? false;
      if (!permissionsGranted) return '/permission';
      return '/home';
    } catch (e) {
      return '/welcome';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getInitialRoute(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed(snapshot.data!);
          });
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/welcome');
          });
        }
        return const Scaffold(
            body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final LogService _logService = LogService();
  final HealthService _healthService = HealthService();
  bool _isAutoRunning = false;
  String _statusLog = "";
  final TextEditingController _stepsController = TextEditingController();
  final TextEditingController _intervalController = TextEditingController();
  Timer? _optimisticUiTimer;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _setupServiceListeners();
  }
  
  void _setupServiceListeners(){
    final service = FlutterBackgroundService();
    service.on('update_ui').listen((event) {
      if (mounted && event != null) {
        setState(() {
          _statusLog = event['status_log'] ?? '';
          _isAutoRunning = event['is_running'] ?? false;
        });
      }
    });
  }


  @override
  void dispose() {
    _optimisticUiTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateStatusLogText();
  }

  Future<void> _updateStatusLogText() async {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;
    final prefs = await SharedPreferences.getInstance();
    final isRunning = prefs.getBool(prefIsAuto) ?? false;
    String statusText;
    if (isRunning) {
      final nextRunTimestamp = prefs.getInt(prefNextRunTime);
      if (nextRunTimestamp != null) {
        final nextRun = DateTime.fromMillisecondsSinceEpoch(nextRunTimestamp);
        final formattedTime = DateFormat('HH:mm').format(nextRun);
        statusText = l10n.next_run_at(formattedTime);
      } else {
        statusText = l10n.status_running;
      }
    } else {
      statusText = l10n.status_ready_to_start;
    }
    if (mounted) {
      setState(() {
        _statusLog = statusText;
      });
    }
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _stepsController.text = (prefs.getInt(prefBaseSteps) ?? 500).toString();
      _intervalController.text =
          (prefs.getInt(prefInterval) ?? 1).toString();
    });
    _updateStatusLogText();
  }

  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
        prefBaseSteps, int.tryParse(_stepsController.text) ?? 500);
    await prefs.setInt(
        prefInterval, int.tryParse(_intervalController.text) ?? 1);
    FlutterBackgroundService().invoke('update'); // Notify service of changes
  }


  void _updateStatus(String message, {bool isError = false}) {
    if (!mounted) return;
    Fluttertoast.showToast(
        msg: message,
        toastLength: isError ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM);
  }

  Future<void> _manualAdd() async {
    final l10n = AppLocalizations.of(context)!;
    await _saveSettings();
    final prefs = await SharedPreferences.getInstance();

    final baseSteps = int.tryParse(_stepsController.text) ?? 0;
    if (baseSteps <= 0) {
      _updateStatus(l10n.steps_gt_zero, isError: true);
      return;
    }

    final finalSteps = await _calculateFinalSteps(prefs);

    try {
      final success = await _healthService.writeSteps(finalSteps);
      if (success) {
        await _logService.addLog({'steps': finalSteps, 'type': 'manual'});
        _updateStatus(l10n.manual_write_success(finalSteps));
      } else {
        _updateStatus(l10n.write_fail_check_log, isError: true);
      }
    } catch (e) {
      _updateStatus(l10n.write_error(e.toString()), isError: true);
    }
  }

  Future<void> _toggleAutoMode(bool enable) async {
    final l10n = AppLocalizations.of(context)!;
    await _saveSettings();
    final prefs = await SharedPreferences.getInstance();
    final service = FlutterBackgroundService();

    // Optimistically update UI
    setState(() {
       _isAutoRunning = enable;
      _updateStatusLogText();
    });

    _optimisticUiTimer?.cancel();
    _optimisticUiTimer = Timer(const Duration(seconds: 8), () {
       if (mounted) {
        // After a delay, query the actual state from prefs
        SharedPreferences.getInstance().then((prefs) {
          final actualRunningState = prefs.getBool(prefIsAuto) ?? false;
          if (_isAutoRunning != actualRunningState) {
            setState(() => _isAutoRunning = actualRunningState);
            _updateStatusLogText();
            _updateStatus(
              enable ? l10n.start_service_fail : l10n.stop_service_fail,
              isError: true);
          }
        });
      }
    });

    await prefs.setBool(prefIsAuto, enable);
    if (enable) {
      await prefs.setInt(prefSessionTotalSteps, 0);
      service.invoke('start');
    } else {
      service.invoke("stop");
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isLightMode = theme.brightness == Brightness.light;

    final systemUiOverlayStyle = SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            isLightMode ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: theme.colorScheme.surface,
        systemNavigationBarIconBrightness:
            isLightMode ? Brightness.dark : Brightness.light);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemUiOverlayStyle,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(l10n.walkgo),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingsPage()))
                  .then((_) => _loadSettings()),
              tooltip: l10n.settings_tooltip,
            ),
          ],
          elevation: 0,
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
        ),
        body: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _buildStatusCard(l10n, theme),
                const SizedBox(height: 16),
                _buildSettingsCard(l10n, theme),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.touch_app_outlined),
                  label: Text(l10n.manual_write_once),
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      foregroundColor:
                          theme.colorScheme.onSecondaryContainer,
                      backgroundColor: theme.colorScheme.secondaryContainer,
                      elevation: 1),
                  onPressed: _manualAdd,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: Icon(_isAutoRunning
                      ? Icons.stop_circle_outlined
                      : Icons.play_circle_outline),
                  label: Text(_isAutoRunning
                      ? l10n.stop_auto_steps
                      : l10n.start_auto_steps),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    foregroundColor: Colors.white,
                    backgroundColor: _isAutoRunning
                        ? Colors.red.shade600
                        : Colors.green.shade600,
                    textStyle: theme.textTheme.titleMedium
                        ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => _toggleAutoMode(!_isAutoRunning),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(AppLocalizations l10n, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final bool isRunning = _isAutoRunning;
    final cardColor = isRunning
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHighest;
    final contentColor =
        isRunning ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant;
    final icon = isRunning ? Icons.directions_walk : Icons.check_circle_outline;

    return Card(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(icon, size: 48, color: contentColor),
            const SizedBox(height: 12),
            Text(
              _statusLog,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold, color: contentColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(AppLocalizations l10n, ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.dividerColor)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.param_settings,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildTextField(
                controller: _stepsController,
                label: l10n.base_steps,
                icon: Icons.filter_1),
            const SizedBox(height: 16),
            _buildTextField(
                controller: _intervalController,
                label: l10n.interval,
                icon: Icons.timer_outlined),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                icon: const Icon(Icons.settings_applications_outlined, size: 16),
                label: Text(l10n.advanced_settings,
                    style: theme.textTheme.labelMedium),
                style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.onSurfaceVariant),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const AdvancedSettingsPage())),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller,
      required String label,
      required IconData icon}) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border:
            const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        filled: true,
      ),
      onChanged: (_) => _saveSettings(),
    );
  }
}
